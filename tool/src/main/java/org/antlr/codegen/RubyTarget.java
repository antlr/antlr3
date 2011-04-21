/*
 [The "BSD license"]
 Copyright (c) 2010 Kyle Yetter
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 3. The name of the author may not be used to endorse or promote products
    derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package org.antlr.codegen;

import org.antlr.Tool;
import org.antlr.tool.Grammar;
import org.stringtemplate.v4.AttributeRenderer;
import org.stringtemplate.v4.ST;
import org.stringtemplate.v4.STGroup;

import java.io.IOException;
import java.util.*;

public class RubyTarget extends Target
{
    /** A set of ruby keywords which are used to escape labels and method names
     *  which will cause parse errors in the ruby source
     */
    public static final Set rubyKeywords =
    new HashSet() {
        {
        	add( "alias" );     add( "END" );     add( "retry" );
        	add( "and" );       add( "ensure" );  add( "return" );
        	add( "BEGIN" );     add( "false" );   add( "self" );
        	add( "begin" );     add( "for" );     add( "super" );
        	add( "break" );     add( "if" );      add( "then" );
        	add( "case" );      add( "in" );      add( "true" );
        	add( "class" );     add( "module" );  add( "undef" );
        	add( "def" );       add( "next" );    add( "unless" );
        	add( "defined?" );  add( "nil" );     add( "until" );
        	add( "do" );        add( "not" );     add( "when" );
        	add( "else" );      add( "or" );      add( "while" );
        	add( "elsif" );     add( "redo" );    add( "yield" );
        	add( "end" );       add( "rescue" );
        }
    };

    public static Map<String, Map<String, Object>> sharedActionBlocks = new HashMap<String, Map<String, Object>>();

    public class RubyRenderer implements AttributeRenderer
    {
    	protected String[] rubyCharValueEscape = new String[256];

    	public RubyRenderer() {
    		for ( int i = 0; i < 16; i++ ) {
    			rubyCharValueEscape[ i ] = "\\x0" + Integer.toHexString( i );
    		}
    		for ( int i = 16; i < 32; i++ ) {
    			rubyCharValueEscape[ i ] = "\\x" + Integer.toHexString( i );
    		}
    		for ( char i = 32; i < 127; i++ ) {
    			rubyCharValueEscape[ i ] = Character.toString( i );
    		}
    		for ( int i = 127; i < 256; i++ ) {
    			rubyCharValueEscape[ i ] = "\\x" + Integer.toHexString( i );
    		}

    		rubyCharValueEscape['\n'] = "\\n";
    		rubyCharValueEscape['\r'] = "\\r";
    		rubyCharValueEscape['\t'] = "\\t";
    		rubyCharValueEscape['\b'] = "\\b";
    		rubyCharValueEscape['\f'] = "\\f";
    		rubyCharValueEscape['\\'] = "\\\\";
    		rubyCharValueEscape['"'] = "\\\"";
    	}

        public String toString( Object o, String formatName, Locale locale ) {
			if ( formatName==null ) {
				return o.toString();
			}
			
            String idString = o.toString();

            if ( idString.isEmpty() ) return idString;

            if ( formatName.equals( "snakecase" ) ) {
                return snakecase( idString );
            } else if ( formatName.equals( "camelcase" ) ) {
                return camelcase( idString );
            } else if ( formatName.equals( "subcamelcase" ) ) {
                return subcamelcase( idString );
            } else if ( formatName.equals( "constant" ) ) {
                return constantcase( idString );
            } else if ( formatName.equals( "platform" ) ) {
                return platform( idString );
            } else if ( formatName.equals( "lexerRule" ) ) {
                return lexerRule( idString );
            } else if ( formatName.equals( "constantPath" ) ) {
            	return constantPath( idString );
            } else if ( formatName.equals( "rubyString" ) ) {
                return rubyString( idString );
            } else if ( formatName.equals( "label" ) ) {
                return label( idString );
            } else if ( formatName.equals( "symbol" ) ) {
                return symbol( idString );
            } else {
                throw new IllegalArgumentException( "Unsupported format name" );
            }
        }

        /** given an input string, which is presumed
         * to contain a word, which may potentially be camelcased,
         * and convert it to snake_case underscore style.
         *
         * algorithm --
         *   iterate through the string with a sliding window 3 chars wide
         *
         * example -- aGUIWhatNot
         *   c   c+1 c+2  action
         *   a   G        << 'a' << '_'  // a lower-upper word edge
         *   G   U   I    << 'g'
         *   U   I   W    << 'w'
         *   I   W   h    << 'i' << '_'  // the last character in an acronym run of uppers
         *   W   h        << 'w'
         *   ... and so on
         */
        private String snakecase( String value ) {
            StringBuilder output_buffer = new StringBuilder();
            int l = value.length();
            int cliff = l - 1;
            char cur;
            char next;
            char peek;

            if ( value.isEmpty() ) return value;
            if ( l == 1 ) return value.toLowerCase();

            for ( int i = 0; i < cliff; i++ ) {
                cur  = value.charAt( i );
                next = value.charAt( i + 1 );

                if ( Character.isLetter( cur ) ) {
                    output_buffer.append( Character.toLowerCase( cur ) );

                    if ( Character.isDigit( next ) || Character.isWhitespace( next ) ) {
                        output_buffer.append( '_' );
                    } else if ( Character.isLowerCase( cur ) && Character.isUpperCase( next ) ) {
                        // at camelcase word edge
                        output_buffer.append( '_' );
                    } else if ( ( i < cliff - 1 ) && Character.isUpperCase( cur ) && Character.isUpperCase( next ) ) {
                        // cur is part of an acronym

                        peek = value.charAt( i + 2 );
                        if ( Character.isLowerCase( peek ) ) {
                            /* if next is the start of word (indicated when peek is lowercase)
                                         then the acronym must be completed by appending an underscore */
                            output_buffer.append( '_' );
                        }
                    }
                } else if ( Character.isDigit( cur ) ) {
                    output_buffer.append( cur );
                    if ( Character.isLetter( next ) ) {
                        output_buffer.append( '_' );
                    }
                } else if ( Character.isWhitespace( cur ) ) {
                    // do nothing
                } else {
                    output_buffer.append( cur );
                }

            }

            cur  = value.charAt( cliff );
            if ( ! Character.isWhitespace( cur ) ) {
                output_buffer.append( Character.toLowerCase( cur ) );
            }

            return output_buffer.toString();
        }

        private String constantcase( String value ) {
            return snakecase( value ).toUpperCase();
        }

        private String platform( String value ) {
            return ( "__" + value + "__" );
        }

        private String symbol( String value ) {
            if ( value.matches( "[a-zA-Z_]\\w*[\\?\\!\\=]?" ) ) {
                return ( ":" + value );
            } else {
                return ( "%s(" + value + ")" );
            }
        }

        private String lexerRule( String value ) {
					  // System.out.print( "lexerRule( \"" + value + "\") => " );
            if ( value.equals( "Tokens" ) ) {
							  // System.out.println( "\"token!\"" );
                return "token!";
            } else {
							  // String result = snakecase( value ) + "!";
								// System.out.println( "\"" + result + "\"" );
                return ( snakecase( value ) + "!" );
            }
        }

        private String constantPath( String value ) {
            return value.replaceAll( "\\.", "::" );
        }

        private String rubyString( String value ) {
        	StringBuilder output_buffer = new StringBuilder();
        	int len = value.length();

        	output_buffer.append( '"' );
        	for ( int i = 0; i < len; i++ ) {
        		output_buffer.append( rubyCharValueEscape[ value.charAt( i ) ] );
        	}
        	output_buffer.append( '"' );
        	return output_buffer.toString();
        }

        private String camelcase( String value ) {
            StringBuilder output_buffer = new StringBuilder();
            int cliff = value.length();
            char cur;
            char next;
            boolean at_edge = true;

            if ( value.isEmpty() ) return value;
            if ( cliff == 1 ) return value.toUpperCase();

            for ( int i = 0; i < cliff; i++ ) {
                cur  = value.charAt( i );

                if ( Character.isWhitespace( cur ) ) {
                    at_edge = true;
                    continue;
                } else if ( cur == '_' ) {
                    at_edge = true;
                    continue;
                } else if ( Character.isDigit( cur ) ) {
                    output_buffer.append( cur );
                    at_edge = true;
                    continue;
                }

                if ( at_edge ) {
                    output_buffer.append( Character.toUpperCase( cur ) );
                    if ( Character.isLetter( cur ) ) at_edge = false;
                } else {
                    output_buffer.append( cur );
                }
            }

            return output_buffer.toString();
        }

        private String label( String value ) {
            if ( rubyKeywords.contains( value ) ) {
                return platform( value );
            } else if ( Character.isUpperCase( value.charAt( 0 ) ) &&
                        ( !value.equals( "FILE" ) ) &&
                        ( !value.equals( "LINE" ) ) ) {
                return platform( value );
            } else if ( value.equals( "FILE" ) ) {
                return "_FILE_";
            } else if ( value.equals( "LINE" ) ) {
                return "_LINE_";
            } else {
                return value;
            }
        }

        private String subcamelcase( String value ) {
            value = camelcase( value );
            if ( value.isEmpty() )
                return value;
            Character head = Character.toLowerCase( value.charAt( 0 ) );
            String tail = value.substring( 1 );
            return head.toString().concat( tail );
        }
    }

    protected void genRecognizerFile(
    		Tool tool,
    		CodeGenerator generator,
    		Grammar grammar,
    		ST outputFileST
    ) throws IOException
    {
        /*
            Below is an experimental attempt at providing a few named action blocks
            that are printed in both lexer and parser files from combined grammars.
            ANTLR appears to first generate a parser, then generate an independent lexer,
            and then generate code from that. It keeps the combo/parser grammar object
            and the lexer grammar object, as well as their respective code generator and
            target instances, completely independent. So, while a bit hack-ish, this is
            a solution that should work without having to modify Terrence Parr's
            core tool code.

            - sharedActionBlocks is a class variable containing a hash map
            - if this method is called with a combo grammar, and the action map
              in the grammar contains an entry for the named scope "all",
              add an entry to sharedActionBlocks mapping the grammar name to
              the "all" action map.
            - if this method is called with an `implicit lexer'
              (one that's extracted from a combo grammar), check to see if
              there's an entry in sharedActionBlocks for the lexer's grammar name.
            - if there is an action map entry, place it in the lexer's action map
            - the recognizerFile template has code to place the
              "all" actions appropriately

            problems:
              - This solution assumes that the parser will be generated
                before the lexer. If that changes at some point, this will
                not work.
              - I have not investigated how this works with delegation yet

            Kyle Yetter - March 25, 2010
        */

        if ( grammar.type == Grammar.COMBINED ) {
            Map<String, Map<String, Object>> actions = grammar.getActions();
            if ( actions.containsKey( "all" ) ) {
                sharedActionBlocks.put( grammar.name, actions.get( "all" ) );
            }
        } else if ( grammar.implicitLexer ) {
            if ( sharedActionBlocks.containsKey( grammar.name ) ) {
                Map<String, Map<String, Object>> actions = grammar.getActions();
                actions.put( "all", sharedActionBlocks.get( grammar.name ) );
            }
        }

        STGroup group = generator.getTemplates();
        RubyRenderer renderer = new RubyRenderer();
        try {
            group.registerRenderer( Class.forName( "java.lang.String" ), renderer );
        } catch ( ClassNotFoundException e ) {
            // this shouldn't happen
            System.err.println( "ClassNotFoundException: " + e.getMessage() );
            e.printStackTrace( System.err );
        }
        String fileName =
            generator.getRecognizerFileName( grammar.name, grammar.type );
        generator.write( outputFileST, fileName );
    }

    public String getTargetCharLiteralFromANTLRCharLiteral(
        CodeGenerator generator,
        String literal
    )
    {
        int code_point = 0;
        literal = literal.substring( 1, literal.length() - 1 );

        if ( literal.charAt( 0 ) == '\\' ) {
            switch ( literal.charAt( 1 ) ) {
                case    '\\':
                case    '"':
                case    '\'':
                    code_point = literal.codePointAt( 1 );
                    break;
                case    'n':
                    code_point = 10;
                    break;
                case    'r':
                    code_point = 13;
                    break;
                case    't':
                    code_point = 9;
                    break;
                case    'b':
                    code_point = 8;
                    break;
                case    'f':
                    code_point = 12;
                    break;
                case    'u':    // Assume unnnn
                    code_point = Integer.parseInt( literal.substring( 2 ), 16 );
                    break;
                default:
                    System.out.println( "1: hey you didn't account for this: \"" + literal + "\"" );
                    break;
            }
        } else if ( literal.length() == 1 ) {
            code_point = literal.codePointAt( 0 );
        } else {
            System.out.println( "2: hey you didn't account for this: \"" + literal + "\"" );
        }

        return ( "0x" + Integer.toHexString( code_point ) );
    }

    public int getMaxCharValue( CodeGenerator generator )
    {
        // Versions before 1.9 do not support unicode
        return 0xFF;
    }

    public String getTokenTypeAsTargetLabel( CodeGenerator generator, int ttype )
    {
        String name = generator.grammar.getTokenDisplayName( ttype );
        // If name is a literal, return the token type instead
        if ( name.charAt( 0 )=='\'' ) {
            return generator.grammar.computeTokenNameFromLiteral( ttype, name );
        }
        return name;
    }

    public boolean isValidActionScope( int grammarType, String scope ) {
        if ( scope.equals( "all" ) )       {
            return true;
        }
        if ( scope.equals( "token" ) )     {
            return true;
        }
        if ( scope.equals( "module" ) )    {
            return true;
        }
        if ( scope.equals( "overrides" ) ) {
            return true;
        }

        switch ( grammarType ) {
        case Grammar.LEXER:
            if ( scope.equals( "lexer" ) ) {
                return true;
            }
            break;
        case Grammar.PARSER:
            if ( scope.equals( "parser" ) ) {
                return true;
            }
            break;
        case Grammar.COMBINED:
            if ( scope.equals( "parser" ) ) {
                return true;
            }
            if ( scope.equals( "lexer" ) ) {
                return true;
            }
            break;
        case Grammar.TREE_PARSER:
            if ( scope.equals( "treeparser" ) ) {
                return true;
            }
            break;
        }
        return false;
    }

    public String encodeIntAsCharEscape( final int v ) {
        final int intValue;

        if ( v == 65535 ) {
            intValue = -1;
        } else {
            intValue = v;
        }

        return String.valueOf( intValue );
    }
}
