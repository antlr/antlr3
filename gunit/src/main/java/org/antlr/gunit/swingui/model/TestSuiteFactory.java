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
package org.antlr.gunit.swingui.model;

import org.antlr.gunit.swingui.parsers.ANTLRv3Lexer;
import org.antlr.gunit.swingui.parsers.ANTLRv3Parser;
import org.antlr.gunit.swingui.parsers.StGUnitLexer;
import org.antlr.gunit.swingui.parsers.StGUnitParser;
import org.antlr.gunit.swingui.runner.TestSuiteAdapter;
import org.antlr.runtime.ANTLRReaderStream;
import org.antlr.runtime.CommonTokenStream;
import org.antlr.stringtemplate.StringTemplate;
import org.antlr.stringtemplate.StringTemplateGroup;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class TestSuiteFactory {

    private static String TEMPLATE_FILE = "org/antlr/gunit/swingui/gunit.stg";
    private static StringTemplateGroup templates;
    public static final String TEST_SUITE_EXT = ".gunit";
    public static final String GRAMMAR_EXT = ".g";

    static  {
        ClassLoader loader = TestSuiteFactory.class.getClassLoader();
        InputStream in = loader.getResourceAsStream(TEMPLATE_FILE);
        if ( in == null ) {
            throw new RuntimeException("internal error: Can't find templates "+TEMPLATE_FILE);
        }
        Reader rd = new InputStreamReader(in);
        templates = new StringTemplateGroup(rd);
    }

    /**
     * Factory method: create a testsuite from ANTLR grammar.  Save the test
     * suite file in the same directory of the grammar file.
     * @param grammarFile ANTLRv3 grammar file.
     * @return test suite object
     */
    public static TestSuite createTestSuite(File grammarFile) {
        if(grammarFile != null && grammarFile.exists() && grammarFile.isFile()) {

            final String fileName = grammarFile.getName();
            final String grammarName = fileName.substring(0, fileName.lastIndexOf('.'));
            final String grammarDir = grammarFile.getParent();
            final File testFile = new File(grammarDir + File.separator + grammarName + TEST_SUITE_EXT);

            final TestSuite result = new TestSuite(grammarName, testFile);
            result.rules = loadRulesFromGrammar(grammarFile);

            if(saveTestSuite(result)) {
                return result;
            } else {
                throw new RuntimeException("Can't save test suite file.");
            }
        } else {
            throw new RuntimeException("Invalid grammar file.");
        }
    }


    /* Load rules from an ANTLR grammar file. */
    private static List<Rule> loadRulesFromGrammar(File grammarFile) {

        // get all the rule names
        final List<String> ruleNames = new ArrayList<String>();
        try {
            final Reader reader = new BufferedReader(new FileReader(grammarFile));
            final ANTLRv3Lexer lexer = new ANTLRv3Lexer(new ANTLRReaderStream(reader));
            final CommonTokenStream tokens = new CommonTokenStream(lexer);
            final ANTLRv3Parser parser = new ANTLRv3Parser(tokens);
            parser.rules = ruleNames;
            parser.grammarDef();
            reader.close();
        } catch (Exception e) {
            e.printStackTrace();
        }

        // convert to rule object
        final List<Rule> ruleList = new ArrayList<Rule>();
        for(String str: ruleNames) {
            ruleList.add(new Rule(str));
        }

        return ruleList;
    }

    /* Save testsuite to *.gunit file. */
    public static boolean saveTestSuite(TestSuite testSuite) {
        final String data = getScript(testSuite);
        try {
            FileWriter fw = new FileWriter(testSuite.getTestSuiteFile());
            fw.write(data);
            fw.flush();
            fw.close();
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
        return true;
    }

    /**
     * Get the text script from the testSuite.
     * @param testSuite
     * @return test script
     */
    public static String getScript(TestSuite testSuite) {
        if(testSuite == null) return null;
        StringTemplate gUnitScript = templates.getInstanceOf("gUnitFile");
        gUnitScript.setAttribute("testSuite", testSuite);

        return gUnitScript.toString();
    }

    /**
     * From textual script to program model.
     * @param file testsuite file (.gunit)
     * @return test suite object
     */
    public static TestSuite loadTestSuite(File file) {
        if ( file.getName().endsWith(GRAMMAR_EXT) ) {
            throw new RuntimeException(file.getName()+" is a grammar file not a gunit file");
        }
        // check grammar file
        final File grammarFile = getGrammarFile(file);
        if(grammarFile == null)
            throw new RuntimeException("Can't find grammar file associated with gunit file: "+file.getAbsoluteFile());

        TestSuite result = new TestSuite("", file);

        // read in test suite
        try {
            final Reader reader = new BufferedReader(new FileReader(file));
            final StGUnitLexer lexer = new StGUnitLexer(new ANTLRReaderStream(reader));
            final CommonTokenStream tokens = new CommonTokenStream(lexer);
            final StGUnitParser parser = new StGUnitParser(tokens);
            final TestSuiteAdapter adapter = new TestSuiteAdapter(result);
            parser.adapter = adapter;
            parser.gUnitDef();
            result.setTokens(tokens);
            reader.close();
        } catch (Exception ex) {
            throw new RuntimeException("Error reading test suite file.\n" + ex.getMessage());
        }

        // load un-tested rules from grammar
        final List<Rule> completeRuleList = loadRulesFromGrammar(grammarFile);
        for(Rule rule: completeRuleList) {
            if(!result.hasRule(rule)) {
                result.addRule(rule);
                //System.out.println("Add rule:" + rule);
            }
        }

        return result;
    }

    /**
     * Get the grammar file of the testsuite file in the same directory.
     * @param testsuiteFile
     * @return grammar file or null
     */
    private static File getGrammarFile(File testsuiteFile) {
        String sTestFile;
        try {
            sTestFile = testsuiteFile.getCanonicalPath();
        }
        catch (IOException e) {
            return null;
        }
        // Try Foo.g from Foo.gunit
        String fname =
            sTestFile.substring(0, sTestFile.lastIndexOf('.')) + GRAMMAR_EXT;
        File fileGrammar = new File(fname);
        if(fileGrammar.exists() && fileGrammar.isFile()) return fileGrammar;
        // Try FooParser.g from Foo.gunit
        fname = sTestFile.substring(0, sTestFile.lastIndexOf('.'))+"Parser"+GRAMMAR_EXT;
        if(fileGrammar.exists() && fileGrammar.isFile()) return fileGrammar;
        return fileGrammar;
    }
}
