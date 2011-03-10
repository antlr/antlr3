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

import java.io.*;
import java.util.*;
import org.antlr.runtime.*;

public class TestSuite {

    protected List<Rule> rules ;
    protected String grammarName ;
    protected CommonTokenStream tokens;
    protected File testSuiteFile;      

    protected TestSuite(String gname, File testFile) {
        grammarName = gname;
        testSuiteFile = testFile;
        rules = new ArrayList<Rule>();
    }
    
    /* Get the gUnit test suite file name. */
    public File getTestSuiteFile() {
        return testSuiteFile;
    }       

    public void addRule(Rule currentRule) {
        if(currentRule == null) throw new IllegalArgumentException("Null rule");
        rules.add(currentRule);
    }

    // test rule name
    public boolean hasRule(Rule rule) {
        for(Rule r: rules) {
            if(r.getName().equals(rule.getName())) {
                return true;
            }
        }
        return false;
    }

    public int getRuleCount() {
        return rules.size();
    }
    
    public void setRules(List<Rule> newRules) {
        rules.clear();
        rules.addAll(newRules);
    }

    /* GETTERS AND SETTERS */

    public void setGrammarName(String name) { grammarName = name;}

    public String getGrammarName() { return grammarName; }

    public Rule getRule(int index) { return rules.get(index); }

    public CommonTokenStream getTokens() { return tokens; }
    
    public void setTokens(CommonTokenStream ts) { tokens = ts; }

    public Rule getRule(String name) {
        for(Rule rule: rules) {
            if(rule.getName().equals(name)) {
                return rule;
            }
        }
        return null;
    }
    
    // only for stringtemplate use
    public List getRulesForStringTemplate() {return rules;}
    
}
