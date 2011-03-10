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

import java.util.ArrayList;
import java.util.List;
import javax.swing.DefaultListModel;

/**
 * ANTLR v3 Rule Information.
 * @author scai
 */
public class Rule extends DefaultListModel {

    private String name;

    public Rule(String name) {
        this.name = name;
    }

    public String getName() { return name; }

    public boolean getNotEmpty() {
        return !this.isEmpty();
    }

    @Override
    public String toString() {
        return this.name;
    }

    public void addTestCase(TestCase newItem) {
        this.addElement(newItem);
    }
    
    // for string template
    public List<TestCase> getTestCases() {
        List<TestCase> result = new ArrayList<TestCase>();
        for(int i=0; i<this.size(); i++) {
            result.add((TestCase)this.getElementAt(i));
        }
        return result;
    }
}
