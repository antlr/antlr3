/*
 * [The "BSD license"]
 *  Copyright (c) 2010 Terence Parr
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *  1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *  3. The name of the author may not be used to endorse or promote products
 *      derived from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 *  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 *  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 *  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 *  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 *  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package org.antlr.codegen;

import org.antlr.Tool;
import org.stringtemplate.v4.ST;
import org.antlr.tool.Grammar;

import java.io.IOException;
import java.util.ArrayList;

public class CTarget extends Target {

    ArrayList strings = new ArrayList();

    @Override
    protected void genRecognizerFile(Tool tool,
            CodeGenerator generator,
            Grammar grammar,
            ST outputFileST)
            throws IOException {

        // Before we write this, and cause it to generate its string,
        // we need to add all the string literals that we are going to match
        //
        outputFileST.add("literals", strings);
        String fileName = generator.getRecognizerFileName(grammar.name, grammar.type);
        generator.write(outputFileST, fileName);
    }

    @Override
    protected void genRecognizerHeaderFile(Tool tool,
            CodeGenerator generator,
            Grammar grammar,
            ST headerFileST,
            String extName)
            throws IOException {
        // Pick up the file name we are generating. This method will return a
        // a file suffixed with .c, so we must substring and add the extName
        // to it as we cannot assign into strings in Java.
        ///
        String fileName = generator.getRecognizerFileName(grammar.name, grammar.type);
        fileName = fileName.substring(0, fileName.length() - 2) + extName;

        generator.write(headerFileST, fileName);
    }

    protected ST chooseWhereCyclicDFAsGo(Tool tool,
            CodeGenerator generator,
            Grammar grammar,
            ST recognizerST,
            ST cyclicDFAST) {
        return recognizerST;
    }

    /** Is scope in @scope::name {action} valid for this kind of grammar?
     *  Targets like C++ may want to allow new scopes like headerfile or
     *  some such.  The action names themselves are not policed at the
     *  moment so targets can add template actions w/o having to recompile
     *  ANTLR.
     */
    @Override
    public boolean isValidActionScope(int grammarType, String scope) {
        switch (grammarType) {
            case Grammar.LEXER:
                if (scope.equals("lexer")) {
                    return true;
                }
                if (scope.equals("header")) {
                    return true;
                }
                if (scope.equals("includes")) {
                    return true;
                }
                if (scope.equals("preincludes")) {
                    return true;
                }
                if (scope.equals("overrides")) {
                    return true;
                }
                break;
            case Grammar.PARSER:
                if (scope.equals("parser")) {
                    return true;
                }
                if (scope.equals("header")) {
                    return true;
                }
                if (scope.equals("includes")) {
                    return true;
                }
                if (scope.equals("preincludes")) {
                    return true;
                }
                if (scope.equals("overrides")) {
                    return true;
                }
                break;
            case Grammar.COMBINED:
                if (scope.equals("parser")) {
                    return true;
                }
                if (scope.equals("lexer")) {
                    return true;
                }
                if (scope.equals("header")) {
                    return true;
                }
                if (scope.equals("includes")) {
                    return true;
                }
                if (scope.equals("preincludes")) {
                    return true;
                }
                if (scope.equals("overrides")) {
                    return true;
                }
                break;
            case Grammar.TREE_PARSER:
                if (scope.equals("treeparser")) {
                    return true;
                }
                if (scope.equals("header")) {
                    return true;
                }
                if (scope.equals("includes")) {
                    return true;
                }
                if (scope.equals("preincludes")) {
                    return true;
                }
                if (scope.equals("overrides")) {
                    return true;
                }
                break;
        }
        return false;
    }

    @Override
    public String getTargetCharLiteralFromANTLRCharLiteral(
            CodeGenerator generator,
            String literal) {

        if (literal.startsWith("'\\u")) {
            literal = "0x" + literal.substring(3, 7);
        } else {
            int c = literal.charAt(1);

            if (c < 32 || c > 127) {
                literal = "0x" + Integer.toHexString(c);
            }
        }

        return literal;
    }

    /** Convert from an ANTLR string literal found in a grammar file to
     *  an equivalent string literal in the C target.
     *  Because we must support Unicode character sets and have chosen
     *  to have the lexer match UTF32 characters, then we must encode
     *  string matches to use 32 bit character arrays. Here then we
     *  must produce the C array and cater for the case where the
     *  lexer has been encoded with a string such as 'xyz\n',
     */
    @Override
    public String getTargetStringLiteralFromANTLRStringLiteral(
            CodeGenerator generator,
            String literal) {
        int index;
        String bytes;
        StringBuffer buf = new StringBuffer();

        buf.append("{ ");

        // We need ot lose any escaped characters of the form \x and just
        // replace them with their actual values as well as lose the surrounding
        // quote marks.
        //
        for (int i = 1; i < literal.length() - 1; i++) {
            buf.append("0x");

            if (literal.charAt(i) == '\\') {
                i++; // Assume that there is a next character, this will just yield
                // invalid strings if not, which is what the input would be of course - invalid
                switch (literal.charAt(i)) {
                    case 'u':
                    case 'U':
                        buf.append(literal.substring(i + 1, i + 5));  // Already a hex string
                        i = i + 5;                                // Move to next string/char/escape
                        break;

                    case 'n':
                    case 'N':

                        buf.append("0A");
                        break;

                    case 'r':
                    case 'R':

                        buf.append("0D");
                        break;

                    case 't':
                    case 'T':

                        buf.append("09");
                        break;

                    case 'b':
                    case 'B':

                        buf.append("08");
                        break;

                    case 'f':
                    case 'F':

                        buf.append("0C");
                        break;

                    default:

                        // Anything else is what it is!
                        //
                        buf.append(Integer.toHexString((int) literal.charAt(i)).toUpperCase());
                        break;
                }
            } else {
                buf.append(Integer.toHexString((int) literal.charAt(i)).toUpperCase());
            }
            buf.append(", ");
        }
        buf.append(" ANTLR3_STRING_TERMINATOR}");

        bytes = buf.toString();
        index = strings.indexOf(bytes);

        if (index == -1) {
            strings.add(bytes);
            index = strings.indexOf(bytes);
        }

        String strref = "lit_" + String.valueOf(index + 1);

        return strref;
    }

    /**
     * Overrides the standard grammar analysis so we can prepare the analyser
     * a little differently from the other targets.
     *
     * In particular we want to influence the way the code generator makes assumptions about
     * switchs vs ifs, vs table driven DFAs. In general, C code should be generated that
     * has the minimum use of tables, and tha meximum use of large switch statements. This
     * allows the optimizers to generate very efficient code, it can reduce object code size
     * by about 30% and give about a 20% performance improvement over not doing this. Hence,
     * for the C target only, we change the defaults here, but only if they are still set to the
     * defaults.
     *
     * @param generator An instance of the generic code generator class.
     * @param grammar The grammar that we are currently analyzing
     */
    @Override
    protected void performGrammarAnalysis(CodeGenerator generator, Grammar grammar) {

        // Check to see if the maximum inline DFA states is still set to
        // the default size. If it is then whack it all the way up to the maximum that
        // we can sensibly get away with.
        //
        if (CodeGenerator.MAX_ACYCLIC_DFA_STATES_INLINE == CodeGenerator.MAX_ACYCLIC_DFA_STATES_INLINE ) {

            CodeGenerator.MAX_ACYCLIC_DFA_STATES_INLINE = 65535;
        }

        // Check to see if the maximum switch size is still set to the default
        // and bring it up much higher if it is. Modern C compilers can handle
        // much bigger switch statements than say Java can and if anyone finds a compiler
        // that cannot deal with such big switches, all the need do is generate the
        // code with a reduced -Xmaxswitchcaselabels nnn
        //
        if  (CodeGenerator.MAX_SWITCH_CASE_LABELS == CodeGenerator.MSCL_DEFAULT) {

            CodeGenerator.MAX_SWITCH_CASE_LABELS = 3000;
        }

        // Check to see if the number of transitions considered a miminum for using
        // a switch is still at the default. Because a switch is still generally faster than
        // an if even with small sets, and given that the optimizer will do the best thing with it
        // anyway, then we simply want to generate a switch for any number of states.
        //
        if (CodeGenerator.MIN_SWITCH_ALTS == CodeGenerator.MSA_DEFAULT) {

            CodeGenerator.MIN_SWITCH_ALTS = 1;
        }

        // Now we allow the superclass implementation to do whatever it feels it
        // must do.
        //
        super.performGrammarAnalysis(generator, grammar);
    }
}

