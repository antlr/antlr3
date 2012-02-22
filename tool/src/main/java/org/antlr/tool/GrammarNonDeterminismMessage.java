/*
 * [The "BSD license"]
 *  Copyright (c) 2010 Terence Parr
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *  1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *  3. The name of the author may not be used to endorse or promote products
 *      derived from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 *  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 *  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 *  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 *  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 *  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package org.antlr.tool;

import org.antlr.analysis.DFAState;
import org.antlr.analysis.DecisionProbe;
import org.antlr.analysis.Label;
import org.antlr.analysis.NFAState;
import org.stringtemplate.v4.ST;

import java.util.Iterator;
import java.util.List;
import java.util.Set;

/** Reports a potential parsing issue with a decision; the decision is
 *  nondeterministic in some way.
 */
public class GrammarNonDeterminismMessage extends Message {
	public DecisionProbe probe;
    public DFAState problemState;

	public GrammarNonDeterminismMessage(DecisionProbe probe,
										DFAState problemState)
	{
		super(ErrorManager.MSG_GRAMMAR_NONDETERMINISM);
		this.probe = probe;
		this.problemState = problemState;
		// flip msg ID if alts are actually token refs in Tokens rule
		if ( probe.dfa.isTokensRuleDecision() ) {
			setMessageID(ErrorManager.MSG_TOKEN_NONDETERMINISM);
		}
	}

	@Override
	public String toString() {
		GrammarAST decisionASTNode = probe.dfa.getDecisionASTNode();
		line = decisionASTNode.getLine();
		column = decisionASTNode.getCharPositionInLine();
		String fileName = probe.dfa.nfa.grammar.getFileName();
		if ( fileName!=null ) {
			file = fileName;
		}

		ST st = getMessageTemplate();
		// Now fill template with information about problemState
		List<Label> labels = probe.getSampleNonDeterministicInputSequence(problemState);
		String input = probe.getInputSequenceDisplay(labels);
		st.add("input", input);

		if ( probe.dfa.isTokensRuleDecision() ) {
			Set<Integer> disabledAlts = probe.getDisabledAlternatives(problemState);
			for (Integer altI : disabledAlts) {
				String tokenName =
					probe.getTokenNameForTokensRuleAlt(altI);
				// reset the line/col to the token definition (pick last one)
				NFAState ruleStart =
					probe.dfa.nfa.grammar.getRuleStartState(tokenName);
				line = ruleStart.associatedASTNode.getLine();
				column = ruleStart.associatedASTNode.getCharPositionInLine();
				st.add("disabled", tokenName);
			}
		}
		else {
			st.add("disabled", probe.getDisabledAlternatives(problemState));
		}

		List<Integer> nondetAlts = probe.getNonDeterministicAltsForState(problemState);
		NFAState nfaStart = probe.dfa.getNFADecisionStartState();
		// all state paths have to begin with same NFA state
		int firstAlt = 0;
		if ( nondetAlts!=null ) {
			for (Integer displayAltI : nondetAlts) {
				if ( DecisionProbe.verbose ) {
					int tracePathAlt =
						nfaStart.translateDisplayAltToWalkAlt(displayAltI);
					if ( firstAlt == 0 ) {
						firstAlt = tracePathAlt;
					}
					List<? extends NFAState> path =
						probe.getNFAPathStatesForAlt(firstAlt,
													 tracePathAlt,
													 labels);
					st.addAggr("paths.{alt, states}", displayAltI, path);
				}
				else {
					if ( probe.dfa.isTokensRuleDecision() ) {
						// alts are token rules, convert to the names instead of numbers
						String tokenName =
							probe.getTokenNameForTokensRuleAlt(displayAltI);
						st.add("conflictingTokens", tokenName);
					}
					else {
						st.add("conflictingAlts", displayAltI);
					}
				}
			}
		}
		st.add("hasPredicateBlockedByAction", problemState.dfa.hasPredicateBlockedByAction);
		return super.toString(st);
	}

}
