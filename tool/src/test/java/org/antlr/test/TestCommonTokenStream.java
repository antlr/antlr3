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

package org.antlr.test;

import org.antlr.runtime.*;
import org.antlr.tool.Grammar;
import org.antlr.tool.Interpreter;
import org.junit.Test;

import static org.junit.Assert.*;

/** This actually tests new (12/4/09) buffered but on-demand fetching stream */
public class TestCommonTokenStream extends BaseTest {
    @Test public void testFirstToken() throws Exception {
        Grammar g = new Grammar(
            "lexer grammar t;\n"+
            "ID : 'a'..'z'+;\n" +
            "INT : '0'..'9'+;\n" +
            "SEMI : ';';\n" +
            "ASSIGN : '=';\n" +
            "PLUS : '+';\n" +
            "MULT : '*';\n" +
            "WS : ' '+;\n");
        // Tokens: 012345678901234567
        // Input:  x = 3 * 0 + 2 * 0;
        CharStream input = new ANTLRStringStream("x = 3 * 0 + 2 * 0;");
        Interpreter lexEngine = new Interpreter(g, input);
        BufferedTokenStream tokens = new BufferedTokenStream(lexEngine);

        String result = tokens.LT(1).getText();
        String expecting = "x";
        assertEquals(expecting, result);
    }

    @Test public void test2ndToken() throws Exception {
        Grammar g = new Grammar(
            "lexer grammar t;\n"+
            "ID : 'a'..'z'+;\n" +
            "INT : '0'..'9'+;\n" +
            "SEMI : ';';\n" +
            "ASSIGN : '=';\n" +
            "PLUS : '+';\n" +
            "MULT : '*';\n" +
            "WS : ' '+;\n");
        // Tokens: 012345678901234567
        // Input:  x = 3 * 0 + 2 * 0;
        CharStream input = new ANTLRStringStream("x = 3 * 0 + 2 * 0;");
        Interpreter lexEngine = new Interpreter(g, input);
        BufferedTokenStream tokens = new BufferedTokenStream(lexEngine);

        String result = tokens.LT(2).getText();
        String expecting = " ";
        assertEquals(expecting, result);
    }

    @Test public void testCompleteBuffer() throws Exception {
        Grammar g = new Grammar(
            "lexer grammar t;\n"+
            "ID : 'a'..'z'+;\n" +
            "INT : '0'..'9'+;\n" +
            "SEMI : ';';\n" +
            "ASSIGN : '=';\n" +
            "PLUS : '+';\n" +
            "MULT : '*';\n" +
            "WS : ' '+;\n");
        // Tokens: 012345678901234567
        // Input:  x = 3 * 0 + 2 * 0;
        CharStream input = new ANTLRStringStream("x = 3 * 0 + 2 * 0;");
        Interpreter lexEngine = new Interpreter(g, input);
        BufferedTokenStream tokens = new BufferedTokenStream(lexEngine);

        int i = 1;
        Token t = tokens.LT(i);
        while ( t.getType()!=Token.EOF ) {
            i++;
            t = tokens.LT(i);
        }
        tokens.LT(i++); // push it past end
        tokens.LT(i++);

        String result = tokens.toString();
        String expecting = "x = 3 * 0 + 2 * 0;";
        assertEquals(expecting, result);
    }

    @Test public void testCompleteBufferAfterConsuming() throws Exception {
        Grammar g = new Grammar(
            "lexer grammar t;\n"+
            "ID : 'a'..'z'+;\n" +
            "INT : '0'..'9'+;\n" +
            "SEMI : ';';\n" +
            "ASSIGN : '=';\n" +
            "PLUS : '+';\n" +
            "MULT : '*';\n" +
            "WS : ' '+;\n");
        // Tokens: 012345678901234567
        // Input:  x = 3 * 0 + 2 * 0;
        CharStream input = new ANTLRStringStream("x = 3 * 0 + 2 * 0;");
        Interpreter lexEngine = new Interpreter(g, input);
        BufferedTokenStream tokens = new BufferedTokenStream(lexEngine);

        Token t = tokens.LT(1);
        while ( t.getType()!=Token.EOF ) {
            tokens.consume();
            t = tokens.LT(1);
        }
        tokens.consume();
        tokens.LT(1); // push it past end
        tokens.consume();
        tokens.LT(1);

        String result = tokens.toString();
        String expecting = "x = 3 * 0 + 2 * 0;";
        assertEquals(expecting, result);
    }

    @Test public void testLookback() throws Exception {
        Grammar g = new Grammar(
            "lexer grammar t;\n"+
            "ID : 'a'..'z'+;\n" +
            "INT : '0'..'9'+;\n" +
            "SEMI : ';';\n" +
            "ASSIGN : '=';\n" +
            "PLUS : '+';\n" +
            "MULT : '*';\n" +
            "WS : ' '+;\n");
        // Tokens: 012345678901234567
        // Input:  x = 3 * 0 + 2 * 0;
        CharStream input = new ANTLRStringStream("x = 3 * 0 + 2 * 0;");
        Interpreter lexEngine = new Interpreter(g, input);
        BufferedTokenStream tokens = new BufferedTokenStream(lexEngine);

        tokens.consume(); // get x into buffer
        Token t = tokens.LT(-1);
        assertEquals("x", t.getText());

        tokens.consume();
        tokens.consume(); // consume '='
        t = tokens.LT(-3);
        assertEquals("x", t.getText());
        t = tokens.LT(-2);
        assertEquals(" ", t.getText());
        t = tokens.LT(-1);
        assertEquals("=", t.getText());
    }

    @Test public void testOffChannel() throws Exception {
        TokenSource lexer = // simulate input " x =34  ;\n"
            new TokenSource() {
                int i = 0;
                Token[] tokens = {
                    new CommonToken(1," "),
                    new CommonToken(1,"x"),
                    new CommonToken(1," "),
                    new CommonToken(1,"="),
                    new CommonToken(1,"34"),
                    new CommonToken(1," "),
                    new CommonToken(1," "),
                    new CommonToken(1,";"),
                    new CommonToken(1,"\n"),
                    new CommonToken(Token.EOF,"")
                };
                {
                    tokens[0].setChannel(Lexer.HIDDEN);
                    tokens[2].setChannel(Lexer.HIDDEN);
                    tokens[5].setChannel(Lexer.HIDDEN);
                    tokens[6].setChannel(Lexer.HIDDEN);
                    tokens[8].setChannel(Lexer.HIDDEN);
                }
			@Override
                public Token nextToken() {
                    return tokens[i++];
                }
			@Override
                public String getSourceName() { return "test"; }
            };

        CommonTokenStream tokens = new CommonTokenStream(lexer);

        assertEquals("x", tokens.LT(1).getText()); // must skip first off channel token
        tokens.consume();
        assertEquals("=", tokens.LT(1).getText());
        assertEquals("x", tokens.LT(-1).getText());

        tokens.consume();
        assertEquals("34", tokens.LT(1).getText());
        assertEquals("=", tokens.LT(-1).getText());

        tokens.consume();
        assertEquals(";", tokens.LT(1).getText());
        assertEquals("34", tokens.LT(-1).getText());

        tokens.consume();
        assertEquals(Token.EOF, tokens.LA(1));
        assertEquals(";", tokens.LT(-1).getText());

        assertEquals("34", tokens.LT(-2).getText());
        assertEquals("=", tokens.LT(-3).getText());
        assertEquals("x", tokens.LT(-4).getText());
    }
}