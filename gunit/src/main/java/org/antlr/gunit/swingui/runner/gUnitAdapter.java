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

import java.io.File;
import java.io.IOException;
import org.antlr.runtime.*;
import org.antlr.runtime.CharStream;
import org.antlr.gunit.*;
import org.antlr.gunit.swingui.model.TestSuite;

/**
 * Adapter between gUnitEditor Swing GUI and gUnit command-line tool.
 * @author scai
 */
public class gUnitAdapter {

    private ParserLoader loader ;
    private TestSuite testSuite;

    public gUnitAdapter(TestSuite suite) throws IOException, ClassNotFoundException {
        int i = 3;
        loader = new ParserLoader(suite.getGrammarName(), 
                                  suite.getTestSuiteFile().getParent());
        testSuite = suite;
    }

    public void run() {
        if (testSuite == null)
            throw new IllegalArgumentException("Null testsuite.");
        
        
        try {

            // Parse gUnit test suite file
            final CharStream input = new ANTLRFileStream(testSuite.getTestSuiteFile().getCanonicalPath());
            final gUnitLexer lexer = new gUnitLexer(input);
            final CommonTokenStream tokens = new CommonTokenStream(lexer);
            final GrammarInfo grammarInfo = new GrammarInfo();
            final gUnitParser parser = new gUnitParser(tokens, grammarInfo);
            parser.gUnitDef();	// parse gunit script and save elements to grammarInfo

            // Execute test suite
            final gUnitExecutor executer = new NotifiedTestExecuter(
                    grammarInfo, loader, 
                    testSuite.getTestSuiteFile().getParent(), testSuite);
            executer.execTest();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
