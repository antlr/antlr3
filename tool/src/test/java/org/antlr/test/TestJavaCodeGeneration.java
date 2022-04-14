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

import org.junit.Test;

import static org.junit.Assert.*;

/** General code generation testing; compilation and/or execution.
 *  These tests are more about avoiding duplicate var definitions
 *  etc... than testing a particular ANTLR feature.
 */
public class TestJavaCodeGeneration extends BaseTest {
	@Test public void testDupVarDefForPinchedState() {
		// so->s2 and s0->s3->s1 pinches back to s1
		// LA3_1, s1 state for DFA 3, was defined twice in similar scope
		// just wrapped in curlies and it's cool.
		String grammar =
			"grammar T;\n" +
			"a : (| A | B) X Y\n" +
			"  | (| A | B) X Z\n" +
			"  ;\n" ;
		boolean found =
			rawGenerateAndBuildRecognizer(
				"T.g", grammar, "TParser", null, false);
		boolean expecting = true; // should be ok
		assertEquals(expecting, found);
	}

	@Test public void testLabeledNotSetsInLexer() {
		// d must be an int
		String grammar =
			"lexer grammar T;\n" +
			"A : d=~('x'|'y') e='0'..'9'\n" +
			"  ; \n" ;
		boolean found =
			rawGenerateAndBuildRecognizer(
				"T.g", grammar, null, "T", false);
		boolean expecting = true; // should be ok
		assertEquals(expecting, found);
	}

	@Test public void testLabeledSetsInLexer() {
		// d must be an int
		String grammar =
			"grammar T;\n" +
			"a : A ;\n" +
			"A : d=('x'|'y') {System.out.println((char)$d);}\n" +
			"  ; \n" ;
		String found = execParser("T.g", grammar, "TParser", "TLexer",
								  "a", "x", false);
		assertEquals("x\n", found);
	}

	@Test public void testLabeledRangeInLexer() {
		// d must be an int
		String grammar =
			"grammar T;\n" +
			"a : A;\n" +
			"A : d='a'..'z' {System.out.println((char)$d);} \n" +
			"  ; \n" ;
		String found = execParser("T.g", grammar, "TParser", "TLexer",
								  "a", "x", false);
		assertEquals("x\n", found);
	}

	@Test public void testLabeledWildcardInLexer() {
		// d must be an int
		String grammar =
			"grammar T;\n" +
			"a : A;\n" +
			"A : d=. {System.out.println((char)$d);}\n" +
			"  ; \n" ;
		String found = execParser("T.g", grammar, "TParser", "TLexer",
								  "a", "x", false);
		assertEquals("x\n", found);
	}

	@Test public void testSynpredWithPlusLoop() {
		String grammar =
			"grammar T; \n" +
			"a : (('x'+)=> 'x'+)?;\n";
		boolean found =
			rawGenerateAndBuildRecognizer(
				"T.g", grammar, "TParser", "TLexer", false);
		boolean expecting = true; // should be ok
		assertEquals(expecting, found);
	}

	@Test public void testDoubleQuoteEscape() {
		String grammar =
			"lexer grammar T; \n" +
			"A : '\\\\\"';\n" +          // this is A : '\\"', which should give "\\\"" at Java level;
            "B : '\\\"';\n" +            // this is B: '\"', which shodl give "\"" at Java level;
            "C : '\\'\\'';\n" +          // this is C: '\'\'', which shoudl give "''" at Java level
            "D : '\\k';\n";              // this is D: '\k', which shoudl give just "k" at Java level;

		boolean found =
			rawGenerateAndBuildRecognizer(
				"T.g", grammar, null, "T", false);
		boolean expecting = true; // should be ok
		assertEquals(expecting, found);
	}

	@Test public void testBlankRuleGetsNoException() {
		String grammar =
			"grammar T;\n" +
			"a : sync (ID sync)* ;\n" +
			"sync : ;\n" +
			"ID : 'a'..'z'+;\n";
		boolean found =
			rawGenerateAndBuildRecognizer(
				"T.g", grammar, "TParser", "TLexer", false);
		boolean expecting = true; // should be ok
		assertEquals(expecting, found);
	}

	/**
	 * This is a regression test for antlr/antlr3#20: StackOverflow error when
	 * compiling grammar with backtracking.
	 * https://github.com/antlr/antlr3/issues/20
	 */
	@Test
	public void testSemanticPredicateAnalysisStackOverflow() throws Exception {
		String grammar =
			"grammar T;\n"
			+ "\n"
			+ "options {\n"
			+ "  backtrack=true;\n"
			+ "}\n"
			+ "\n"
			+ "main : ('x'*)*;\n";
		boolean success = rawGenerateAndBuildRecognizer("T.g", grammar, "TParser", "TLexer", false);
		assertTrue(success);
	}

	/**
	 * This is a regression test for antlr/antlr3#157 "missing lexer rules if
	 * tokenVocab defined"
	 * https://github.com/antlr/antlr3/pull/157
	 */
	@Test public void testImportedTokensInCombinedGrammar() {
		String tokensFile =
			"TypeArray=394\n" +
			"Null=395\n";
		System.out.println("dir " + tmpdir);
		mkdir(tmpdir);
		writeFile(tmpdir, "CustomVocab.tokens", tokensFile);

		String grammar =
			"grammar T;\n" +
			"options { output = AST; tokenVocab = CustomVocab; }\n" +
			"tokens { TypeArray = 'array'; }\n" +
			"a : ('array' TypeArray 'null' Null ID)* EOF\n" +
			"    {System.out.println(tokenNames[TypeArray] + \"=\" + TypeArray);\n" +
			"     System.out.println(tokenNames[Null] + \"=\" + Null);};\n" +
			"Null : 'null';\n" +
			"ID : 'a'..'z'+;\n" +
			"WS : ' '+ {skip();};\n";
		String input = "array array null null foo";
		String found = execParser("T.g", grammar, "TParser", "TLexer", "a", input, false);
		String expected =
			"TypeArray=394\n" +
			"Null=395\n" +
			"array array null null foo <EOF>\n";
		assertEquals(expected, found);
		assertNull(stderrDuringParse);
	}

	/**
	 * This is a regression test for antlr/antlr3#157 "missing lexer rules if
	 * tokenVocab defined"
	 * https://github.com/antlr/antlr3/pull/157
	 */
	@Test public void testImportedTokensInCombinedGrammarNoReferences() {
		String tokensFile =
			"TypeArray=394\n" +
			"Null=395\n";
		System.out.println("dir " + tmpdir);
		mkdir(tmpdir);
		writeFile(tmpdir, "CustomVocab.tokens", tokensFile);

		String grammar =
			"grammar T;\n" +
			"options { output = AST; tokenVocab = CustomVocab; }\n" +
			"tokens { TypeArray = 'array'; }\n" +
			"a : (ID)* EOF\n" +
			"    {System.out.println(tokenNames[TypeArray] + \"=\" + TypeArray);\n" +
			"     System.out.println(tokenNames[Null] + \"=\" + Null);};\n" +
			"Null : 'null';\n" +
			"ID : 'a'..'z'+;\n" +
			"WS : ' '+ {skip();};\n";
		String input = "foo";
		String found = execParser("T.g", grammar, "TParser", "TLexer", "a", input, false);
		String expected =
			"TypeArray=394\n" +
			"Null=395\n" +
			"foo <EOF>\n";
		assertEquals(expected, found);
		assertNull(stderrDuringParse);
	}

	/**
	 * This is a regression test for antlr/antlr3#157 "missing lexer rules if
	 * tokenVocab defined"
	 * https://github.com/antlr/antlr3/pull/157
	 */
	@Test public void testImportedTokensInCombinedGrammarLiteralReferencesOnly() {
		String tokensFile =
			"TypeArray=394\n" +
			"Null=395\n";
		System.out.println("dir " + tmpdir);
		mkdir(tmpdir);
		writeFile(tmpdir, "CustomVocab.tokens", tokensFile);

		String grammar =
			"grammar T;\n" +
			"options { output = AST; tokenVocab = CustomVocab; }\n" +
			"tokens { TypeArray = 'array'; }\n" +
			"a : ('array' 'null' ID)* EOF\n" +
			"    {System.out.println(tokenNames[TypeArray] + \"=\" + TypeArray);\n" +
			"     System.out.println(tokenNames[Null] + \"=\" + Null);};\n" +
			"Null : 'null';\n" +
			"ID : 'a'..'z'+;\n" +
			"WS : ' '+ {skip();};\n";
		String input = "array null foo";
		String found = execParser("T.g", grammar, "TParser", "TLexer", "a", input, false);
		String expected =
			"TypeArray=394\n" +
			"Null=395\n" +
			"array null foo <EOF>\n";
		assertEquals(expected, found);
		assertNull(stderrDuringParse);
	}

	/**
	 * This is a regression test for antlr/antlr3#157 "missing lexer rules if
	 * tokenVocab defined"
	 * https://github.com/antlr/antlr3/pull/157
	 */
	@Test public void testImportedTokensInCombinedGrammarSymbolicReferencesOnly() {
		String tokensFile =
			"TypeArray=394\n" +
			"Null=395\n";
		System.out.println("dir " + tmpdir);
		mkdir(tmpdir);
		writeFile(tmpdir, "CustomVocab.tokens", tokensFile);

		String grammar =
			"grammar T;\n" +
			"options { output = AST; tokenVocab = CustomVocab; }\n" +
			"tokens { TypeArray = 'array'; }\n" +
			"a : (TypeArray Null ID)* EOF\n" +
			"    {System.out.println(tokenNames[TypeArray] + \"=\" + TypeArray);\n" +
			"     System.out.println(tokenNames[Null] + \"=\" + Null);};\n" +
			"Null : 'null';\n" +
			"ID : 'a'..'z'+;\n" +
			"WS : ' '+ {skip();};\n";
		String input = "array null foo";
		String found = execParser("T.g", grammar, "TParser", "TLexer", "a", input, false);
		String expected =
			"TypeArray=394\n" +
			"Null=395\n" +
			"array null foo <EOF>\n";
		assertEquals(expected, found);
		assertNull(stderrDuringParse);
	}
}
