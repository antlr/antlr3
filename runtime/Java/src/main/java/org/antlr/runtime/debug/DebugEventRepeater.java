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

import org.antlr.runtime.Token;
import org.antlr.runtime.RecognitionException;

/** A simple event repeater (proxy) that delegates all functionality to the
 *  listener sent into the ctor.  Useful if you want to listen in on a few
 *  debug events w/o interrupting the debugger.  Just subclass the repeater
 *  and override the methods you want to listen in on.  Remember to call
 *  the method in this class so the event will continue on to the original
 *  recipient.
 *
 *  @see DebugEventHub
 */
public class DebugEventRepeater implements DebugEventListener {
	protected DebugEventListener listener;

	public DebugEventRepeater(DebugEventListener listener) {
		this.listener = listener;
	}
	
	@Override public void enterRule(String grammarFileName, String ruleName) { listener.enterRule(grammarFileName, ruleName); }
	@Override public void exitRule(String grammarFileName, String ruleName) { listener.exitRule(grammarFileName, ruleName); }
	@Override public void enterAlt(int alt) { listener.enterAlt(alt); }
	@Override public void enterSubRule(int decisionNumber) { listener.enterSubRule(decisionNumber); }
	@Override public void exitSubRule(int decisionNumber) { listener.exitSubRule(decisionNumber); }
	@Override public void enterDecision(int decisionNumber, boolean couldBacktrack) { listener.enterDecision(decisionNumber, couldBacktrack); }
	@Override public void exitDecision(int decisionNumber) { listener.exitDecision(decisionNumber); }
	@Override public void location(int line, int pos) { listener.location(line, pos); }
	@Override public void consumeToken(Token token) { listener.consumeToken(token); }
	@Override public void consumeHiddenToken(Token token) { listener.consumeHiddenToken(token); }
	@Override public void LT(int i, Token t) { listener.LT(i, t); }
	@Override public void mark(int i) { listener.mark(i); }
	@Override public void rewind(int i) { listener.rewind(i); }
	@Override public void rewind() { listener.rewind(); }
	@Override public void beginBacktrack(int level) { listener.beginBacktrack(level); }
	@Override public void endBacktrack(int level, boolean successful) { listener.endBacktrack(level, successful); }
	@Override public void recognitionException(RecognitionException e) { listener.recognitionException(e); }
	@Override public void beginResync() { listener.beginResync(); }
	@Override public void endResync() { listener.endResync(); }
	@Override public void semanticPredicate(boolean result, String predicate) { listener.semanticPredicate(result, predicate); }
	@Override public void commence() { listener.commence(); }
	@Override public void terminate() { listener.terminate(); }

	// Tree parsing stuff

	@Override public void consumeNode(Object t) { listener.consumeNode(t); }
	@Override public void LT(int i, Object t) { listener.LT(i, t); }

	// AST Stuff

	@Override public void nilNode(Object t) { listener.nilNode(t); }
	@Override public void errorNode(Object t) { listener.errorNode(t); }
	@Override public void createNode(Object t) { listener.createNode(t); }
	@Override public void createNode(Object node, Token token) { listener.createNode(node, token); }
	@Override public void becomeRoot(Object newRoot, Object oldRoot) { listener.becomeRoot(newRoot, oldRoot); }
	@Override public void addChild(Object root, Object child) { listener.addChild(root, child); }
	@Override public void setTokenBoundaries(Object t, int tokenStartIndex, int tokenStopIndex) {
		listener.setTokenBoundaries(t, tokenStartIndex, tokenStopIndex);
	}
}
