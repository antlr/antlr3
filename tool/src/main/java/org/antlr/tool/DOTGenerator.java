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

import org.antlr.Tool;
import org.antlr.analysis.*;
import org.antlr.grammar.v3.ANTLRParser;
import org.antlr.misc.Utils;
import org.stringtemplate.v4.ST;
import org.stringtemplate.v4.STGroup;
import org.stringtemplate.v4.STGroupDir;

import java.util.*;

/** The DOT (part of graphviz) generation aspect. */
public class DOTGenerator {
	public static final boolean STRIP_NONREDUCED_STATES = false;

	protected String arrowhead="normal";
	protected String rankdir="LR";

	/** Library of output templates; use <attrname> format */
    public static STGroup stlib = new STGroupDir("org/antlr/tool/templates/dot/dfa");

    /** To prevent infinite recursion when walking state machines, record
     *  which states we've visited.  Make a new set every time you start
     *  walking in case you reuse this object.
     */
    protected Set markedStates = null;

    protected Grammar grammar;

    /** This aspect is associated with a grammar */
	public DOTGenerator(Grammar grammar) {
		this.grammar = grammar;
	}

    /** Return a String containing a DOT description that, when displayed,
     *  will show the incoming state machine visually.  All nodes reachable
     *  from startState will be included.
     */
    public String getDOT(State startState) {
		if ( startState==null ) {
			return null;
		}
		// The output DOT graph for visualization
		ST dot = null;
		markedStates = new HashSet();
        if ( startState instanceof DFAState ) {
            dot = stlib.getInstanceOf("dfa");
			dot.add("startState",
					Utils.integer(startState.stateNumber));
			dot.add("useBox",
					Boolean.valueOf(Tool.internalOption_ShowNFAConfigsInDFA));
			walkCreatingDFADOT(dot, (DFAState)startState);
        }
        else {
            dot = stlib.getInstanceOf("nfa");
			dot.add("startState",
					Utils.integer(startState.stateNumber));
			walkRuleNFACreatingDOT(dot, startState);
        }
		dot.add("rankdir", rankdir);
        return dot.toString();
    }

    /** Return a String containing a DOT description that, when displayed,
     *  will show the incoming state machine visually.  All nodes reachable
     *  from startState will be included.
    public String getRuleNFADOT(State startState) {
        // The output DOT graph for visualization
        ST dot = stlib.getInstanceOf("nfa");

        markedStates = new HashSet();
        dot.add("startState",
                Utils.integer(startState.stateNumber));
        walkRuleNFACreatingDOT(dot, startState);
        return dot.toString();
    }
	 */

    /** Do a depth-first walk of the state machine graph and
     *  fill a DOT description template.  Keep filling the
     *  states and edges attributes.
     */
    protected void walkCreatingDFADOT(ST dot,
									  DFAState s)
    {
		if ( markedStates.contains(Utils.integer(s.stateNumber)) ) {
			return; // already visited this node
        }

		markedStates.add(Utils.integer(s.stateNumber)); // mark this node as completed.

        // first add this node
        ST st;
        if ( s.isAcceptState() ) {
            st = stlib.getInstanceOf("stopstate");
        }
        else {
            st = stlib.getInstanceOf("state");
        }
        st.add("name", getStateLabel(s));
        dot.add("states", st);

        // make a DOT edge for each transition
		for (int i = 0; i < s.getNumberOfTransitions(); i++) {
			Transition edge = (Transition) s.transition(i);
			/*
			System.out.println("dfa "+s.dfa.decisionNumber+
				" edge from s"+s.stateNumber+" ["+i+"] of "+s.getNumberOfTransitions());
			*/
			if ( STRIP_NONREDUCED_STATES ) {
				if ( edge.target instanceof DFAState &&
					((DFAState)edge.target).getAcceptStateReachable()!=DFA.REACHABLE_YES )
				{
					continue; // don't generate nodes for terminal states
				}
			}
			st = stlib.getInstanceOf("edge");
			st.add("label", getEdgeLabel(edge));
			st.add("src", getStateLabel(s));
            st.add("target", getStateLabel(edge.target));
			st.add("arrowhead", arrowhead);
            dot.add("edges", st);
            walkCreatingDFADOT(dot, (DFAState)edge.target); // keep walkin'
        }
    }

    /** Do a depth-first walk of the state machine graph and
     *  fill a DOT description template.  Keep filling the
     *  states and edges attributes.  We know this is an NFA
     *  for a rule so don't traverse edges to other rules and
     *  don't go past rule end state.
     */
    protected void walkRuleNFACreatingDOT(ST dot,
                                          State s)
    {
        if ( markedStates.contains(s) ) {
            return; // already visited this node
        }

        markedStates.add(s); // mark this node as completed.

        // first add this node
        ST stateST;
        if ( s.isAcceptState() ) {
            stateST = stlib.getInstanceOf("stopstate");
        }
        else {
            stateST = stlib.getInstanceOf("state");
        }
        stateST.add("name", getStateLabel(s));
        dot.add("states", stateST);

        if ( s.isAcceptState() )  {
            return; // don't go past end of rule node to the follow states
        }

        // special case: if decision point, then line up the alt start states
        // unless it's an end of block
		if ( ((NFAState)s).isDecisionState() ) {
			GrammarAST n = ((NFAState)s).associatedASTNode;
			if ( n!=null && n.getType()!=ANTLRParser.EOB ) {
				ST rankST = stlib.getInstanceOf("decision-rank");
				NFAState alt = (NFAState)s;
				while ( alt!=null ) {
					rankST.add("states", getStateLabel(alt));
					if ( alt.transition[1] !=null ) {
						alt = (NFAState)alt.transition[1].target;
					}
					else {
						alt=null;
					}
				}
				dot.add("decisionRanks", rankST);
			}
		}

        // make a DOT edge for each transition
		ST edgeST = null;
		for (int i = 0; i < s.getNumberOfTransitions(); i++) {
            Transition edge = (Transition) s.transition(i);
            if ( edge instanceof RuleClosureTransition ) {
                RuleClosureTransition rr = ((RuleClosureTransition)edge);
                // don't jump to other rules, but display edge to follow node
                edgeST = stlib.getInstanceOf("edge");
				if ( rr.rule.grammar != grammar ) {
					edgeST.add("label", "<" + rr.rule.grammar.name + "." + rr.rule.name + ">");
				}
				else {
					edgeST.add("label", "<" + rr.rule.name + ">");
				}
				edgeST.add("src", getStateLabel(s));
				edgeST.add("target", getStateLabel(rr.followState));
				edgeST.add("arrowhead", arrowhead);
                dot.add("edges", edgeST);
				walkRuleNFACreatingDOT(dot, rr.followState);
                continue;
            }
			if ( edge.isAction() ) {
				edgeST = stlib.getInstanceOf("action-edge");
			}
			else if ( edge.isEpsilon() ) {
				edgeST = stlib.getInstanceOf("epsilon-edge");
			}
			else {
				edgeST = stlib.getInstanceOf("edge");
			}
			edgeST.add("label", getEdgeLabel(edge));
            edgeST.add("src", getStateLabel(s));
			edgeST.add("target", getStateLabel(edge.target));
			edgeST.add("arrowhead", arrowhead);
            dot.add("edges", edgeST);
            walkRuleNFACreatingDOT(dot, edge.target); // keep walkin'
        }
    }

    /*
	public void writeDOTFilesForAllRuleNFAs() throws IOException {
        Collection rules = grammar.getRules();
        for (Iterator itr = rules.iterator(); itr.hasNext();) {
			Grammar.Rule r = (Grammar.Rule) itr.next();
            String ruleName = r.name;
            writeDOTFile(
                    ruleName,
                    getRuleNFADOT(grammar.getRuleStartState(ruleName)));
        }
    }
    */

    /*
	public void writeDOTFilesForAllDecisionDFAs() throws IOException {
        // for debugging, create a DOT file for each decision in
        // a directory named for the grammar.
        File grammarDir = new File(grammar.name+"_DFAs");
        grammarDir.mkdirs();
        List decisionList = grammar.getDecisionNFAStartStateList();
        if ( decisionList==null ) {
            return;
        }
        int i = 1;
        Iterator iter = decisionList.iterator();
        while (iter.hasNext()) {
            NFAState decisionState = (NFAState)iter.next();
            DFA dfa = decisionState.getDecisionASTNode().getLookaheadDFA();
            if ( dfa!=null ) {
                String dot = getDOT( dfa.startState );
                writeDOTFile(grammarDir+"/dec-"+i, dot);
            }
            i++;
        }
    }
    */

    /** Fix edge strings so they print out in DOT properly;
	 *  generate any gated predicates on edge too.
	 */
    protected String getEdgeLabel(Transition edge) {
		String label = edge.label.toString(grammar);
		label = Utils.replace(label,"\\", "\\\\");
		label = Utils.replace(label,"\"", "\\\"");
		label = Utils.replace(label,"\n", "\\\\n");
		label = Utils.replace(label,"\r", "");
		if ( label.equals(Label.EPSILON_STR) ) {
            label = "e";
        }
		State target = edge.target;
		if ( !edge.isSemanticPredicate() && target instanceof DFAState ) {
			// look for gated predicates; don't add gated to simple sempred edges
			SemanticContext preds =
				((DFAState)target).getGatedPredicatesInNFAConfigurations();
			if ( preds!=null ) {
				String predsStr = "";
				predsStr = "&&{"+
					preds.genExpr(grammar.generator,
								  grammar.generator.getTemplates(), null).toString()
					+"}?";
				label += predsStr;
			}
		}
        return label;
    }

    protected String getStateLabel(State s) {
        if ( s==null ) {
            return "null";
        }
        String stateLabel = String.valueOf(s.stateNumber);
		if ( s instanceof DFAState ) {
            StringBuffer buf = new StringBuffer(250);
			buf.append('s');
			buf.append(s.stateNumber);
			if ( Tool.internalOption_ShowNFAConfigsInDFA ) {
				if ( s instanceof DFAState ) {
					if ( ((DFAState)s).abortedDueToRecursionOverflow ) {
						buf.append("\\n");
						buf.append("abortedDueToRecursionOverflow");
					}
				}
				Set alts = ((DFAState)s).getAltSet();
				if ( alts!=null ) {
					buf.append("\\n");
					// separate alts
					List altList = new ArrayList();
					altList.addAll(alts);
					Collections.sort(altList);
					Set configurations = ((DFAState) s).nfaConfigurations;
					for (int altIndex = 0; altIndex < altList.size(); altIndex++) {
						Integer altI = (Integer) altList.get(altIndex);
						int alt = altI.intValue();
						if ( altIndex>0 ) {
							buf.append("\\n");
						}
						buf.append("alt");
						buf.append(alt);
						buf.append(':');
						// get a list of configs for just this alt
						// it will help us print better later
						List configsInAlt = new ArrayList();
						for (Iterator it = configurations.iterator(); it.hasNext();) {
							NFAConfiguration c = (NFAConfiguration) it.next();
							if ( c.alt!=alt ) continue;
							configsInAlt.add(c);
						}
						int n = 0;
						for (int cIndex = 0; cIndex < configsInAlt.size(); cIndex++) {
							NFAConfiguration c =
								(NFAConfiguration)configsInAlt.get(cIndex);
							n++;
							buf.append(c.toString(false));
							if ( (cIndex+1)<configsInAlt.size() ) {
								buf.append(", ");
							}
							if ( n%5==0 && (configsInAlt.size()-cIndex)>3 ) {
								buf.append("\\n");
							}
						}
					}
				}
			}
            stateLabel = buf.toString();
        }
		if ( (s instanceof NFAState) && ((NFAState)s).isDecisionState() ) {
			stateLabel = stateLabel+",d="+
					((NFAState)s).getDecisionNumber();
			if ( ((NFAState)s).endOfBlockStateNumber!=State.INVALID_STATE_NUMBER ) {
				stateLabel += ",eob="+((NFAState)s).endOfBlockStateNumber;
			}
		}
		else if ( (s instanceof NFAState) &&
			((NFAState)s).endOfBlockStateNumber!=State.INVALID_STATE_NUMBER)
		{
			NFAState n = ((NFAState)s);
			stateLabel = stateLabel+",eob="+n.endOfBlockStateNumber;
		}
        else if ( s instanceof DFAState && ((DFAState)s).isAcceptState() ) {
            stateLabel = stateLabel+
                    "=>"+((DFAState)s).getUniquelyPredictedAlt();
        }
        return '"'+stateLabel+'"';
    }

	public String getArrowheadType() {
		return arrowhead;
	}

	public void setArrowheadType(String arrowhead) {
		this.arrowhead = arrowhead;
	}

	public String getRankdir() {
		return rankdir;
	}

	public void setRankdir(String rankdir) {
		this.rankdir = rankdir;
	}
}
