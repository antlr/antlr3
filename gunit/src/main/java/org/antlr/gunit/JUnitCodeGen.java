/*
 [The "BSD licence"]
 Copyright (c) 2007-2008 Leon Jen-Yuan Su
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
package org.antlr.gunit;

import org.antlr.stringtemplate.StringTemplate;
import org.antlr.stringtemplate.StringTemplateGroup;
import org.antlr.stringtemplate.StringTemplateGroupLoader;
import org.antlr.stringtemplate.CommonGroupLoader;
import org.antlr.stringtemplate.language.AngleBracketTemplateLexer;

import java.io.*;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.ConsoleHandler;
import java.util.logging.Handler;
import java.util.logging.Level;
import java.util.logging.Logger;

public class JUnitCodeGen {
    public GrammarInfo grammarInfo;
    public Map<String, String> ruleWithReturn;
    private final String testsuiteDir;
    private String outputDirectoryPath = ".";

    private final static Handler console = new ConsoleHandler();
    private static final Logger logger = Logger.getLogger(JUnitCodeGen.class.getName());
    static {
        logger.addHandler(console);
    }

    public JUnitCodeGen(GrammarInfo grammarInfo, String testsuiteDir) throws ClassNotFoundException {
        this( grammarInfo, determineClassLoader(), testsuiteDir);
    }

    private static ClassLoader determineClassLoader() {
        ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
        if ( classLoader == null ) {
            classLoader = JUnitCodeGen.class.getClassLoader();
        }
        return classLoader;
    }

    public JUnitCodeGen(GrammarInfo grammarInfo, ClassLoader classLoader, String testsuiteDir) throws ClassNotFoundException {
        this.grammarInfo = grammarInfo;
        this.testsuiteDir = testsuiteDir;
        /** Map the name of rules having return value to its return type */
        ruleWithReturn = new HashMap<String, String>();
        Class parserClass = locateParserClass( grammarInfo, classLoader );
        Method[] methods = parserClass.getDeclaredMethods();
        for(Method method : methods) {
            if ( !method.getReturnType().getName().equals("void") ) {
                ruleWithReturn.put(method.getName(), method.getReturnType().getName().replace('$', '.'));
            }
        }
    }

    private Class locateParserClass(GrammarInfo grammarInfo, ClassLoader classLoader) throws ClassNotFoundException {
        String parserClassName = grammarInfo.getGrammarName() + "Parser";
        if ( grammarInfo.getGrammarPackage() != null ) {
            parserClassName = grammarInfo.getGrammarPackage()+ "." + parserClassName;
        }
        return classLoader.loadClass( parserClassName );
    }

    public String getOutputDirectoryPath() {
        return outputDirectoryPath;
    }

    public void setOutputDirectoryPath(String outputDirectoryPath) {
        this.outputDirectoryPath = outputDirectoryPath;
    }

    public void compile() throws IOException{
        String junitFileName;
        if ( grammarInfo.getTreeGrammarName()!=null ) {
            junitFileName = "Test"+grammarInfo.getTreeGrammarName();
        }
        else {
            junitFileName = "Test"+grammarInfo.getGrammarName();
        }
        String lexerName = grammarInfo.getGrammarName()+"Lexer";
        String parserName = grammarInfo.getGrammarName()+"Parser";

        StringTemplateGroupLoader loader = new CommonGroupLoader("org/antlr/gunit", null);
        StringTemplateGroup.registerGroupLoader(loader);
        StringTemplateGroup.registerDefaultLexer(AngleBracketTemplateLexer.class);
        StringBuffer buf = compileToBuffer(junitFileName, lexerName, parserName);
        writeTestFile(".", junitFileName+".java", buf.toString());
    }

    public StringBuffer compileToBuffer(String className, String lexerName, String parserName) {
        StringTemplateGroup group = StringTemplateGroup.loadGroup("junit");
        StringBuffer buf = new StringBuffer();
        buf.append(genClassHeader(group, className, lexerName, parserName));
        buf.append(genTestRuleMethods(group));
        buf.append("\n\n}");
        return buf;
    }

    protected String genClassHeader(StringTemplateGroup group, String junitFileName, String lexerName, String parserName) {
        StringTemplate classHeaderST = group.getInstanceOf("classHeader");
        if ( grammarInfo.getTestPackage()!=null ) {	// Set up class package if there is
            classHeaderST.setAttribute("header", "package "+grammarInfo.getTestPackage()+";");
        }
        classHeaderST.setAttribute("junitFileName", junitFileName);

        String lexerPath = null;
        String parserPath = null;
        String treeParserPath = null;
        String packagePath = null;
        boolean isTreeGrammar = false;
        boolean hasPackage = false;
        /** Set up appropriate class path for parser/tree parser if using package */
        if ( grammarInfo.getGrammarPackage()!=null ) {
            hasPackage = true;
            packagePath = "./"+grammarInfo.getGrammarPackage().replace('.', '/');
            lexerPath = grammarInfo.getGrammarPackage()+"."+lexerName;
            parserPath = grammarInfo.getGrammarPackage()+"."+parserName;
            if ( grammarInfo.getTreeGrammarName()!=null ) {
                treeParserPath = grammarInfo.getGrammarPackage()+"."+grammarInfo.getTreeGrammarName();
                isTreeGrammar = true;
            }
        }
        else {
            lexerPath = lexerName;
            parserPath = parserName;
            if ( grammarInfo.getTreeGrammarName()!=null ) {
                treeParserPath = grammarInfo.getTreeGrammarName();
                isTreeGrammar = true;
            }
        }
        // also set up custom tree adaptor if necessary
        String treeAdaptorPath = null;
        boolean hasTreeAdaptor = false;
        if ( grammarInfo.getAdaptor()!=null ) {
            hasTreeAdaptor = true;
            treeAdaptorPath = grammarInfo.getAdaptor();
        }
        classHeaderST.setAttribute("hasTreeAdaptor", hasTreeAdaptor);
        classHeaderST.setAttribute("treeAdaptorPath", treeAdaptorPath);
        classHeaderST.setAttribute("hasPackage", hasPackage);
        classHeaderST.setAttribute("packagePath", packagePath);
        classHeaderST.setAttribute("lexerPath", lexerPath);
        classHeaderST.setAttribute("parserPath", parserPath);
        classHeaderST.setAttribute("treeParserPath", treeParserPath);
        classHeaderST.setAttribute("isTreeGrammar", isTreeGrammar);
        return classHeaderST.toString();
    }

    protected String genTestRuleMethods(StringTemplateGroup group) {
        StringBuffer buf = new StringBuffer();
        if ( grammarInfo.getTreeGrammarName()!=null ) {	// Generate junit codes of for tree grammar rule
            genTreeMethods(group, buf);
        }
        else {	// Generate junit codes of for grammar rule
            genParserMethods(group, buf);
        }
        return buf.toString();
    }

    private void genParserMethods(StringTemplateGroup group, StringBuffer buf) {
        for ( gUnitTestSuite ts: grammarInfo.getRuleTestSuites() ) {
            int i = 0;
            for ( gUnitTestInput input: ts.testSuites.keySet() ) {	// each rule may contain multiple tests
                i++;
                StringTemplate testRuleMethodST;
                /** If rule has multiple return values or ast*/
                if ( ts.testSuites.get(input).getType()== gUnitParser.ACTION && ruleWithReturn.containsKey(ts.getRuleName()) ) {
                    testRuleMethodST = group.getInstanceOf("testRuleMethod2");
                    String outputString = ts.testSuites.get(input).getText();
                    testRuleMethodST.setAttribute("methodName", "test"+changeFirstCapital(ts.getRuleName())+i);
                    testRuleMethodST.setAttribute("testRuleName", '"'+ts.getRuleName()+'"');
                    testRuleMethodST.setAttribute("test", input);
                    testRuleMethodST.setAttribute("returnType", ruleWithReturn.get(ts.getRuleName()));
                    testRuleMethodST.setAttribute("expecting", outputString);
                }
                else {
                    String testRuleName;
                    // need to determine whether it's a test for parser rule or lexer rule
                    if ( ts.isLexicalRule() ) testRuleName = ts.getLexicalRuleName();
                    else testRuleName = ts.getRuleName();
                    testRuleMethodST = group.getInstanceOf("testRuleMethod");
                    String outputString = ts.testSuites.get(input).getText();
                    testRuleMethodST.setAttribute("isLexicalRule", ts.isLexicalRule());
                    testRuleMethodST.setAttribute("methodName", "test"+changeFirstCapital(testRuleName)+i);
                    testRuleMethodST.setAttribute("testRuleName", '"'+testRuleName+'"');
                    testRuleMethodST.setAttribute("test", input);
                    testRuleMethodST.setAttribute("tokenType", getTypeString(ts.testSuites.get(input).getType()));

                    // normalize whitespace
                    outputString = normalizeTreeSpec(outputString);

                    if ( ts.testSuites.get(input).getType()==gUnitParser.ACTION ) {	// trim ';' at the end of ACTION if there is...
                        //testRuleMethodST.setAttribute("expecting", outputString.substring(0, outputString.length()-1));
                        testRuleMethodST.setAttribute("expecting", outputString);
                    }
                    else if ( ts.testSuites.get(input).getType()==gUnitParser.RETVAL ) {	// Expected: RETVAL
                        testRuleMethodST.setAttribute("expecting", outputString);
                    }
                    else {	// Attach "" to expected STRING or AST
                        // strip newlines for (...) tree stuff
                        outputString = outputString.replaceAll("\n", "");
                        testRuleMethodST.setAttribute("expecting", '"'+escapeForJava(outputString)+'"');
                    }
                }
                buf.append(testRuleMethodST.toString());
            }
        }
    }

    private void genTreeMethods(StringTemplateGroup group, StringBuffer buf) {
        for ( gUnitTestSuite ts: grammarInfo.getRuleTestSuites() ) {
            int i = 0;
            for ( gUnitTestInput input: ts.testSuites.keySet() ) {	// each rule may contain multiple tests
                i++;
                StringTemplate testRuleMethodST;
                /** If rule has multiple return values or ast*/
                if ( ts.testSuites.get(input).getType()== gUnitParser.ACTION && ruleWithReturn.containsKey(ts.getTreeRuleName()) ) {
                    testRuleMethodST = group.getInstanceOf("testTreeRuleMethod2");
                    String outputString = ts.testSuites.get(input).getText();
                    testRuleMethodST.setAttribute("methodName", "test"+changeFirstCapital(ts.getTreeRuleName())+"_walks_"+
                                                                changeFirstCapital(ts.getRuleName())+i);
                    testRuleMethodST.setAttribute("testTreeRuleName", '"'+ts.getTreeRuleName()+'"');
                    testRuleMethodST.setAttribute("testRuleName", '"'+ts.getRuleName()+'"');
                    testRuleMethodST.setAttribute("test", input);
                    testRuleMethodST.setAttribute("returnType", ruleWithReturn.get(ts.getTreeRuleName()));
                    testRuleMethodST.setAttribute("expecting", outputString);
                }
                else {
                    testRuleMethodST = group.getInstanceOf("testTreeRuleMethod");
                    String outputString = ts.testSuites.get(input).getText();
                    testRuleMethodST.setAttribute("methodName", "test"+changeFirstCapital(ts.getTreeRuleName())+"_walks_"+
                                                                changeFirstCapital(ts.getRuleName())+i);
                    testRuleMethodST.setAttribute("testTreeRuleName", '"'+ts.getTreeRuleName()+'"');
                    testRuleMethodST.setAttribute("testRuleName", '"'+ts.getRuleName()+'"');
                    testRuleMethodST.setAttribute("test", input);
                    testRuleMethodST.setAttribute("tokenType", getTypeString(ts.testSuites.get(input).getType()));

                    if ( ts.testSuites.get(input).getType()==gUnitParser.ACTION ) {	// trim ';' at the end of ACTION if there is...
                        //testRuleMethodST.setAttribute("expecting", outputString.substring(0, outputString.length()-1));
                        testRuleMethodST.setAttribute("expecting", outputString);
                    }
                    else if ( ts.testSuites.get(input).getType()==gUnitParser.RETVAL ) {	// Expected: RETVAL
                        testRuleMethodST.setAttribute("expecting", outputString);
                    }
                    else {	// Attach "" to expected STRING or AST
                        testRuleMethodST.setAttribute("expecting", '"'+escapeForJava(outputString)+'"');
                    }
                }
                buf.append(testRuleMethodST.toString());
            }
        }
    }

    // return a meaningful gUnit token type name instead of using the magic number
    public String getTypeString(int type) {
        String typeText;
        switch (type) {
            case gUnitParser.OK :
                typeText = "org.antlr.gunit.gUnitParser.OK";
                break;
            case gUnitParser.FAIL :
                typeText = "org.antlr.gunit.gUnitParser.FAIL";
                break;
            case gUnitParser.STRING :
                typeText = "org.antlr.gunit.gUnitParser.STRING";
                break;
            case gUnitParser.ML_STRING :
                typeText = "org.antlr.gunit.gUnitParser.ML_STRING";
                break;
            case gUnitParser.RETVAL :
                typeText = "org.antlr.gunit.gUnitParser.RETVAL";
                break;
            case gUnitParser.AST :
                typeText = "org.antlr.gunit.gUnitParser.AST";
                break;
            default :
                typeText = "org.antlr.gunit.gUnitParser.EOF";
                break;
        }
        return typeText;
    }

    protected void writeTestFile(String dir, String fileName, String content) {
        try {
            File f = new File(dir, fileName);
            FileWriter w = new FileWriter(f);
            BufferedWriter bw = new BufferedWriter(w);
            bw.write(content);
            bw.close();
            w.close();
        }
        catch (IOException ioe) {
            logger.log(Level.SEVERE, "can't write file", ioe);
        }
    }

    public static String escapeForJava(String inputString) {
        // Gotta escape literal backslash before putting in specials that use escape.
        inputString = inputString.replace("\\", "\\\\");
        // Then double quotes need escaping (singles are OK of course).
        inputString = inputString.replace("\"", "\\\"");
        // note: replace newline to String ".\n", replace tab to String ".\t"
        inputString = inputString.replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r").replace("\b", "\\b").replace("\f", "\\f");

        return inputString;
    }

    protected String changeFirstCapital(String ruleName) {
        String firstChar = String.valueOf(ruleName.charAt(0));
        return firstChar.toUpperCase()+ruleName.substring(1);
    }

    public static String normalizeTreeSpec(String t) {
        List<String> words = new ArrayList<String>();
        int i = 0;
        StringBuilder word = new StringBuilder();
        while ( i<t.length() ) {
            if ( t.charAt(i)=='(' || t.charAt(i)==')' ) {
                if ( word.length()>0 ) {
                    words.add(word.toString());
                    word.setLength(0);
                }
                words.add(String.valueOf(t.charAt(i)));
                i++;
                continue;
            }
            if ( Character.isWhitespace(t.charAt(i)) ) {
                // upon WS, save word
                if ( word.length()>0 ) {
                    words.add(word.toString());
                    word.setLength(0);
                }
                i++;
                continue;
            }

            // ... "x" or ...("x"
            if ( t.charAt(i)=='"' && (i-1)>=0 &&
                 (t.charAt(i-1)=='(' || Character.isWhitespace(t.charAt(i-1))) )
            {
                i++;
                while ( i<t.length() && t.charAt(i)!='"' ) {
                    if ( t.charAt(i)=='\\' &&
                         (i+1)<t.length() && t.charAt(i+1)=='"' ) // handle \"
                    {
                        word.append('"');
                        i+=2;
                        continue;
                    }
                    word.append(t.charAt(i));
                    i++;
                }
                i++; // skip final "
                words.add(word.toString());
                word.setLength(0);
                continue;
            }
            word.append(t.charAt(i));
            i++;
        }
        if ( word.length()>0 ) {
            words.add(word.toString());
        }
        //System.out.println("words="+words);
        StringBuilder buf = new StringBuilder();
        for (int j=0; j<words.size(); j++) {
            if ( j>0 && !words.get(j).equals(")") &&
                 !words.get(j-1).equals("(") ) {
                buf.append(' ');
            }
            buf.append(words.get(j));
        }
        return buf.toString();
    }

}
