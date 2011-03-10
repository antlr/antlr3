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

import org.antlr.gunit.*;
import org.antlr.gunit.swingui.model.*;

/**
 * The gUnit test executer that will respond to the fail/pass event during the
 * execution.  The executer is passed into gUnit Interp for execution.
 * @author scai
 */
public class NotifiedTestExecuter extends gUnitExecutor {

    private TestSuite testSuite ;

    public NotifiedTestExecuter(GrammarInfo grammarInfo, ClassLoader loader, String testsuiteDir, TestSuite suite) {
    	super(grammarInfo, loader, testsuiteDir);
        
        testSuite = suite;
    }

    @Override
    public void onFail(ITestCase failTest) {
        if(failTest == null) throw new IllegalArgumentException("Null fail test");

        final String ruleName = failTest.getTestedRuleName();
        if(ruleName == null) throw new NullPointerException("Null rule name");

        final Rule rule = testSuite.getRule(ruleName);
        final TestCase failCase = (TestCase) rule.getElementAt(failTest.getTestCaseIndex());
        failCase.setPass(false);
        //System.out.println(String.format("[FAIL] %s (%d) ", failTest.getTestedRuleName(), failTest.getTestCaseIndex()));
    }

    @Override
    public void onPass(ITestCase passTest) {
        if(passTest == null) throw new IllegalArgumentException("Null pass test");

        final String ruleName = passTest.getTestedRuleName();
        if(ruleName == null) throw new NullPointerException("Null rule name");
        
        final Rule rule = testSuite.getRule(ruleName);
        final TestCase passCase = (TestCase) rule.getElementAt(passTest.getTestCaseIndex());
        passCase.setPass(true);
        //System.out.println(String.format("[PASS] %s (%d) ", passTest.getTestedRuleName(), passTest.getTestCaseIndex()));
    }
}
