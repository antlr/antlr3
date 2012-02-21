/*
 [The "BSD license"]
 Copyright (c) 2005-2009 Terence Parr
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
package org.antlr.runtime.debug;

import org.antlr.runtime.RecognitionException;
import org.antlr.runtime.Token;

/** A blank listener that does nothing; useful for real classes so
 *  they don't have to have lots of blank methods and are less
 *  sensitive to updates to debug interface.
 */
public class BlankDebugEventListener implements DebugEventListener {
	@Override public void enterRule(String grammarFileName, String ruleName) {}
	@Override public void exitRule(String grammarFileName, String ruleName) {}
	@Override public void enterAlt(int alt) {}
	@Override public void enterSubRule(int decisionNumber) {}
	@Override public void exitSubRule(int decisionNumber) {}
	@Override public void enterDecision(int decisionNumber, boolean couldBacktrack) {}
	@Override public void exitDecision(int decisionNumber) {}
	@Override public void location(int line, int pos) {}
	@Override public void consumeToken(Token token) {}
	@Override public void consumeHiddenToken(Token token) {}
	@Override public void LT(int i, Token t) {}
	@Override public void mark(int i) {}
	@Override public void rewind(int i) {}
	@Override public void rewind() {}
	@Override public void beginBacktrack(int level) {}
	@Override public void endBacktrack(int level, boolean successful) {}
	@Override public void recognitionException(RecognitionException e) {}
	@Override public void beginResync() {}
	@Override public void endResync() {}
	@Override public void semanticPredicate(boolean result, String predicate) {}
	@Override public void commence() {}
	@Override public void terminate() {}

	// Tree parsing stuff

	@Override public void consumeNode(Object t) {}
	@Override public void LT(int i, Object t) {}

	// AST Stuff

	@Override public void nilNode(Object t) {}
	@Override public void errorNode(Object t) {}
	@Override public void createNode(Object t) {}
	@Override public void createNode(Object node, Token token) {}
	@Override public void becomeRoot(Object newRoot, Object oldRoot) {}
	@Override public void addChild(Object root, Object child) {}
	@Override public void setTokenBoundaries(Object t, int tokenStartIndex, int tokenStopIndex) {}
}


