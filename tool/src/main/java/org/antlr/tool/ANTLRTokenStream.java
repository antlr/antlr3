package org.antlr.tool;

import antlr.TokenStream;
import antlr.TokenStreamRewriteEngine;
import org.antlr.grammar.v2.ANTLRParser;

/** A rewrite stream that flips BLOCK back to '(' when we want original string. */
public class ANTLRTokenStream extends TokenStreamRewriteEngine {
	public ANTLRTokenStream(TokenStream upstream) {
		super(upstream);
	}

	@Override
	public String toOriginalString(int start, int end) {
		StringBuffer buf = new StringBuffer();
		for (int i=start; i>=MIN_TOKEN_INDEX && i<=end && i<tokens.size(); i++) {
			String s = getToken(i).getText();
			if ( getToken(i).getType()== ANTLRParser.BLOCK ) s = "(";
			buf.append(s);
		}
		return buf.toString();
	}
}
