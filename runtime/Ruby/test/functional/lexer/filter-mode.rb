#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestFilterMode < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    lexer grammar Filter;
    options {
        language = Ruby;
        filter=true;
    }
    
    IMPORT
      :  'import' WS QIDStar WS? ';'
      ;
      
    RETURN
      :  'return' .* ';'
      ;
    
    CLASS
      :  'class' WS ID WS? ('extends' WS QID WS?)?
        ('implements' WS QID WS? (',' WS? QID WS?)*)? '{'
      ;
      
    COMMENT
        :   '/*' .* '*/'
        ;
    
    STRING
        :  '"' (options {greedy=false;}: ESC | .)* '"'
      ;
    
    CHAR
      :  '\'' (options {greedy=false;}: ESC | .)* '\''
      ;
    
    WS  :   (' '|'\t'|'\n')+
        ;
    
    fragment
    QID :  ID ('.' ID)*
      ;
      
    /** QID cannot see beyond end of token so using QID '.*'? somewhere won't
     *  ever match since k=1 look in the QID loop of '.' will make it loop.
     *  I made this rule to compensate.
     */
    fragment
    QIDStar
      :  ID ('.' ID)* '.*'?
      ;
    
    fragment
    TYPE:   QID '[]'?
        ;
        
    fragment
    ARG :   TYPE WS ID
        ;
    
    fragment
    ID  :   ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'_'|'0'..'9')*
        ;
    
    fragment
    ESC  :  '\\' ('"'|'\''|'\\')
      ;
  END

  example "skipping tokens that aren't important with filter mode" do
    input = <<-END.fixed_indent( 0 )
      import org.antlr.runtime.*;
      
      public class Main {
        public static void main(String[] args) throws Exception {
            for (int i=0; i<args.length; i++) {
          CharStream input = new ANTLRFileStream(args[i]);
          FuzzyJava lex = new FuzzyJava(input);
          TokenStream tokens = new CommonTokenStream(lex);
          tokens.toString();
          //System.out.println(tokens);
            }
        }
      }
    END
    
    lexer = Filter::Lexer.new( input )
    tokens = lexer.map { |tk| tk }
  end
  

end


class TestFuzzy < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    lexer grammar Fuzzy;
    options {
        language = Ruby;
        filter=true;
    }
    
    @members {
      include ANTLR3::Test::CaptureOutput
    }
    
    IMPORT
      :  'import' WS name=QIDStar WS? ';'
      ;
      
    /** Avoids having "return foo;" match as a field */
    RETURN
      :  'return' (options {greedy=false;}:.)* ';'
      ;
    
    CLASS
      :  'class' WS name=ID WS? ('extends' WS QID WS?)?
        ('implements' WS QID WS? (',' WS? QID WS?)*)? '{'
        {  
          say("found class " << $name.text)  
        }
      ;
      
    METHOD
        :   TYPE WS name=ID WS? '(' ( ARG WS? (',' WS? ARG WS?)* )? ')' WS? 
           ('throws' WS QID WS? (',' WS? QID WS?)*)? '{'
            {
              say("found method " << $name.text)
            }
        ;
    
    FIELD
        :   TYPE WS name=ID '[]'? WS? (';'|'=')
            {
              say("found var " << $name.text)
            }
        ;
    
    STAT:  ('if'|'while'|'switch'|'for') WS? '(' ;
      
    CALL
        :   name=QID WS? '('
            {
              say("found call " << $name.text)
            }
        ;
    
    COMMENT
        :   '/*' (options {greedy=false;} : . )* '*/'
            {
              say("found comment " << self.text)
            }
        ;
    
    SL_COMMENT
        :   '//' (options {greedy=false;} : . )* '\n'
            {
              say("found // comment " << self.text)
            }
        ;
      
    STRING
      :  '"' (options {greedy=false;}: ESC | .)* '"'
      ;
    
    CHAR
      :  '\'' (options {greedy=false;}: ESC | .)* '\''
      ;
    
    WS  :   (' '|'\t'|'\n')+
        ;
    
    fragment
    QID :  ID ('.' ID)*
      ;
      
    /** QID cannot see beyond end of token so using QID '.*'? somewhere won't
     *  ever match since k=1 look in the QID loop of '.' will make it loop.
     *  I made this rule to compensate.
     */
    fragment
    QIDStar
      :  ID ('.' ID)* '.*'?
      ;
    
    fragment
    TYPE:   QID '[]'?
        ;
        
    fragment
    ARG :   TYPE WS ID
        ;
    
    fragment
    ID  :   ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'_'|'0'..'9')*
        ;
    
    fragment
    ESC  :  '\\' ('"'|'\''|'\\')
      ;
  END
  
  example "fuzzy lexing with the filter mode option" do
    input = <<-END.fixed_indent( 0 )
      import org.antlr.runtime.*;
      
      public class Main {
        public static void main(String[] args) throws Exception {
            for (int i=0; i<args.length; i++) {
          CharStream input = new ANTLRFileStream(args[i]);
          FuzzyJava lex = new FuzzyJava(input);
          TokenStream tokens = new CommonTokenStream(lex);
          tokens.toString();
          //System.out.println(tokens);
            }
        }
      }
    END
    
    expected_output = <<-END.fixed_indent( 0 )
      found class Main
      found method main
      found var i
      found var input
      found call ANTLRFileStream
      found var lex
      found call FuzzyJava
      found var tokens
      found call CommonTokenStream
      found call tokens.toString
      found // comment //System.out.println(tokens);
    END
    
    lexer = Fuzzy::Lexer.new( input )
    lexer.each { |tk| tk }
    lexer.output.should == expected_output
  end


end
