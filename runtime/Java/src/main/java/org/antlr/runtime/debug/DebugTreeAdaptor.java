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
import org.antlr.runtime.TokenStream;
import org.antlr.runtime.RecognitionException;
import org.antlr.runtime.tree.TreeAdaptor;

/** A TreeAdaptor proxy that fires debugging events to a DebugEventListener
 *  delegate and uses the TreeAdaptor delegate to do the actual work.  All
 *  AST events are triggered by this adaptor; no code gen changes are needed
 *  in generated rules.  Debugging events are triggered *after* invoking
 *  tree adaptor routines.
 *
 *  Trees created with actions in rewrite actions like "-&gt; ^(ADD {foo} {bar})"
 *  cannot be tracked as they might not use the adaptor to create foo, bar.
 *  The debug listener has to deal with tree node IDs for which it did
 *  not see a createNode event.  A single &lt;unknown&gt; node is sufficient even
 *  if it represents a whole tree.
 */
public class DebugTreeAdaptor implements TreeAdaptor {
	protected DebugEventListener dbg;
	protected TreeAdaptor adaptor;

	public DebugTreeAdaptor(DebugEventListener dbg, TreeAdaptor adaptor) {
		this.dbg = dbg;
		this.adaptor = adaptor;
	}

	@Override
	public Object create(Token payload) {
		if ( payload.getTokenIndex() < 0 ) {
			// could be token conjured up during error recovery
			return create(payload.getType(), payload.getText());
		}
		Object node = adaptor.create(payload);
		dbg.createNode(node, payload);
		return node;
	}

	@Override
	public Object errorNode(TokenStream input, Token start, Token stop,
							RecognitionException e)
	{
		Object node = adaptor.errorNode(input, start, stop, e);
		if ( node!=null ) {
			dbg.errorNode(node);
		}
		return node;
	}

	@Override
	public Object dupTree(Object tree) {
		Object t = adaptor.dupTree(tree);
		// walk the tree and emit create and add child events
		// to simulate what dupTree has done. dupTree does not call this debug
		// adapter so I must simulate.
		simulateTreeConstruction(t);
		return t;
	}

	/** ^(A B C): emit create A, create B, add child, ...*/
	protected void simulateTreeConstruction(Object t) {
		dbg.createNode(t);
		int n = adaptor.getChildCount(t);
		for (int i=0; i<n; i++) {
			Object child = adaptor.getChild(t, i);
			simulateTreeConstruction(child);
			dbg.addChild(t, child);
		}
	}

	@Override
	public Object dupNode(Object treeNode) {
		Object d = adaptor.dupNode(treeNode);
		dbg.createNode(d);
		return d;
	}

	@Override
	public Object nil() {
		Object node = adaptor.nil();
		dbg.nilNode(node);
		return node;
	}

	@Override
	public boolean isNil(Object tree) {
		return adaptor.isNil(tree);
	}

	@Override
	public void addChild(Object t, Object child) {
		if ( t==null || child==null ) {
			return;
		}
		adaptor.addChild(t,child);
		dbg.addChild(t, child);
	}

	@Override
	public Object becomeRoot(Object newRoot, Object oldRoot) {
		Object n = adaptor.becomeRoot(newRoot, oldRoot);
		dbg.becomeRoot(newRoot, oldRoot);
		return n;
	}

	@Override
	public Object rulePostProcessing(Object root) {
		return adaptor.rulePostProcessing(root);
	}

	public void addChild(Object t, Token child) {
		Object n = this.create(child);
		this.addChild(t, n);
	}

	@Override
	public Object becomeRoot(Token newRoot, Object oldRoot) {
		Object n = this.create(newRoot);
		adaptor.becomeRoot(n, oldRoot);
		dbg.becomeRoot(newRoot, oldRoot);
		return n;
	}

	@Override
	public Object create(int tokenType, Token fromToken) {
		Object node = adaptor.create(tokenType, fromToken);
		dbg.createNode(node);
		return node;
	}

	@Override
	public Object create(int tokenType, Token fromToken, String text) {
		Object node = adaptor.create(tokenType, fromToken, text);
		dbg.createNode(node);
		return node;
	}

	@Override
	public Object create(int tokenType, String text) {
		Object node = adaptor.create(tokenType, text);
		dbg.createNode(node);
		return node;
	}

	@Override
	public int getType(Object t) {
		return adaptor.getType(t);
	}

	@Override
	public void setType(Object t, int type) {
		adaptor.setType(t, type);
	}

	@Override
	public String getText(Object t) {
		return adaptor.getText(t);
	}

	@Override
	public void setText(Object t, String text) {
		adaptor.setText(t, text);
	}

	@Override
	public Token getToken(Object t) {
		return adaptor.getToken(t);
	}

	@Override
	public void setTokenBoundaries(Object t, Token startToken, Token stopToken) {
		adaptor.setTokenBoundaries(t, startToken, stopToken);
		if ( t!=null && startToken!=null && stopToken!=null ) {
			dbg.setTokenBoundaries(
				t, startToken.getTokenIndex(),
				stopToken.getTokenIndex());
		}
	}

	@Override
	public int getTokenStartIndex(Object t) {
		return adaptor.getTokenStartIndex(t);
	}

	@Override
	public int getTokenStopIndex(Object t) {
		return adaptor.getTokenStopIndex(t);
	}

	@Override
	public Object getChild(Object t, int i) {
		return adaptor.getChild(t, i);
	}

	@Override
	public void setChild(Object t, int i, Object child) {
		adaptor.setChild(t, i, child);
	}

	@Override
	public Object deleteChild(Object t, int i) {
		return adaptor.deleteChild(t, i);
	}

	@Override
	public int getChildCount(Object t) {
		return adaptor.getChildCount(t);
	}

	@Override
	public int getUniqueID(Object node) {
		return adaptor.getUniqueID(node);
	}

	@Override
	public Object getParent(Object t) {
		return adaptor.getParent(t);
	}

	@Override
	public int getChildIndex(Object t) {
		return adaptor.getChildIndex(t);
	}

	@Override
	public void setParent(Object t, Object parent) {
		adaptor.setParent(t, parent);
	}

	@Override
	public void setChildIndex(Object t, int index) {
		adaptor.setChildIndex(t, index);
	}

	@Override
	public void replaceChildren(Object parent, int startChildIndex, int stopChildIndex, Object t) {
		adaptor.replaceChildren(parent, startChildIndex, stopChildIndex, t);
	}

	// support

	public DebugEventListener getDebugListener() {
		return dbg;
	}

	public void setDebugListener(DebugEventListener dbg) {
		this.dbg = dbg;
	}

	public TreeAdaptor getTreeAdaptor() {
		return adaptor;
	}
}
