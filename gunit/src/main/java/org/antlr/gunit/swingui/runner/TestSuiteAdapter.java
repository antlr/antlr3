/*
 [The "BSD licence"]
 Copyright (c) 2009 Shaoting Cai
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
package org.antlr.gunit.swingui.runner;

import org.antlr.gunit.swingui.model.*;

/**
 * Adapter class for gunit parser to save information into testsuite object.
 * @author Shaoting
 */
public class TestSuiteAdapter {

    private TestSuite model ;
    private Rule currentRule;

    public TestSuiteAdapter(TestSuite testSuite) {
        model = testSuite;
    }

    public void setGrammarName(String name) {
        model.setGrammarName(name);
    }

    public void startRule(String name) {
        currentRule = new Rule(name);
    }

    public void endRule() {
        model.addRule(currentRule);
        currentRule = null;
    }

    public void addTestCase(ITestCaseInput in, ITestCaseOutput out) {
        TestCase testCase = new TestCase(in, out);
        currentRule.addTestCase(testCase);
    }

    private static String trimChars(String text, int numOfChars) {
        return text.substring(numOfChars, text.length() - numOfChars);
    }

    public static ITestCaseInput createFileInput(String fileName) {
        if(fileName == null) throw new IllegalArgumentException("null");
        return new TestCaseInputFile(fileName);
    }

    public static ITestCaseInput createStringInput(String line) {
        if(line == null) throw new IllegalArgumentException("null");
        // trim double quotes
        return new TestCaseInputString(trimChars(line, 1));
    }

    public static ITestCaseInput createMultiInput(String text) {
        if(text == null) throw new IllegalArgumentException("null");
        // trim << and >>
        return new TestCaseInputMultiString(trimChars(text, 2));
    }

    public static ITestCaseOutput createBoolOutput(boolean bool) {
        return new TestCaseOutputResult(bool);
    }

    public static ITestCaseOutput createAstOutput(String ast) {
        if(ast == null) throw new IllegalArgumentException("null");
        return new TestCaseOutputAST(ast);
    }

    public static ITestCaseOutput createStdOutput(String text) {
        if(text == null) throw new IllegalArgumentException("null");
        // trim double quotes
        return new TestCaseOutputStdOut(trimChars(text, 1));
    }

    public static ITestCaseOutput createReturnOutput(String text) {
        if(text == null) throw new IllegalArgumentException("null");
        // trim square brackets
        return new TestCaseOutputReturn(trimChars(text, 1));
    }    
}
