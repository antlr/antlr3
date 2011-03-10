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

public class TestCase {

    private ITestCaseInput input;
    private ITestCaseOutput output;
    private boolean pass;

    public boolean isPass() {
        return pass;
    }

    public void setPass(boolean value) {
        pass = value;
    }

    public ITestCaseInput getInput() {
        return this.input;
    }

    public ITestCaseOutput getOutput() {
        return this.output;
    }

    public TestCase(ITestCaseInput input, ITestCaseOutput output) {
        this.input = input;
        this.output = output;
    }

    @Override
    public String toString() {
        return String.format("[%s]->[%s]", input.getScript(), output.getScript());
    }

    public void setInput(ITestCaseInput in) {
        this.input = in;
    }

    public void setOutput(ITestCaseOutput out) {
        this.output = out;
    }

    public static String convertPreservedChars(String input) {
        //return input.replace("\"", "\\\"");
        return input;
    }

}
