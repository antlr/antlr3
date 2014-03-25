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
package org.antlr.analysis;

import org.antlr.grammar.v3.ANTLRParser;
import org.antlr.misc.MultiMap;
import org.antlr.misc.Utils;
import org.antlr.runtime.Token;
import org.antlr.tool.ErrorManager;
import org.antlr.tool.Grammar;
import org.antlr.tool.GrammarAST;

import java.util.*;

/** Collection of information about what is wrong with a decision as
 *  discovered while building the DFA predictor.
 *
 *  The information is collected during NFA&rarr;DFA conversion and, while
 *  some of this is available elsewhere, it is nice to have it all tracked
 *  in one spot so a great error message can be easily had.  I also like
 *  the fact that this object tracks it all for later perusing to make an
 *  excellent error message instead of lots of imprecise on-the-fly warnings
 *  (during conversion).
 *
 *  A decision normally only has one problem; e.g., some input sequence
 *  can be matched by multiple alternatives.  Unfortunately, some decisions
 *  such as
 *
 *  a : ( A | B ) | ( A | B ) | A ;
 *
 *  have multiple problems.  So in general, you should approach a decision
 *  as having multiple flaws each one uniquely identified by a DFAState.
 *  For example, statesWithSyntacticallyAmbiguousAltsSet tracks the set of
 *  all DFAStates where ANTLR has discovered a problem.  Recall that a decision
 *  is represented internall with a DFA comprised of multiple states, each of
 *  which could potentially have problems.
 *
 *  Because of this, you need to iterate over this list of DFA states.  You'll
 *  note that most of the informational methods like
 *  getSampleNonDeterministicInputSequence() require a DFAState.  This state
 *  will be one of the iterated states from stateToSyntacticallyAmbiguousAltsSet.
 *
 *  This class is not thread safe due to shared use of visited maps etc...
 *  Only one thread should really need to access one DecisionProbe anyway.
 */
public class DecisionProbe {
	public DFA dfa;

	/** Track all DFA states with nondeterministic alternatives.
	 *  By reaching the same DFA state, a path through the NFA for some input
	 *  is able to reach the same NFA state by starting at more than one
	 *  alternative's left edge.  Though, later, we may find that predicates
	 *  resolve the issue, but track info anyway.
	 *  Note that from the DFA state, you can ask for
	 *  which alts are nondeterministic.
	 */
	protected Set<DFAState> statesWithSyntacticallyAmbiguousAltsSet = new HashSet<DFAState>();

	/** Track just like stateToSyntacticallyAmbiguousAltsMap, but only
	 *  for nondeterminisms that arise in the Tokens rule such as keyword vs
	 *  ID rule.  The state maps to the list of Tokens rule alts that are
	 *  in conflict.
	 */
	protected Map<DFAState, Set<Integer>> stateToSyntacticallyAmbiguousTokensRuleAltsMap =
		new HashMap<DFAState, Set<Integer>>();

	/** Was a syntactic ambiguity resolved with predicates?  Any DFA
	 *  state that predicts more than one alternative, must be resolved
	 *  with predicates or it should be reported to the user.
	 */
	protected Set<DFAState> statesResolvedWithSemanticPredicatesSet = new HashSet<DFAState>();

	/** Track the predicates for each alt per DFA state;
	 *  more than one DFA state might have syntactically ambig alt prediction.
	 *  Maps DFA state to another map, mapping alt number to a
	 *  SemanticContext (pred(s) to execute to resolve syntactic ambiguity).
	 */
	protected Map<DFAState, Map<Integer,SemanticContext>> stateToAltSetWithSemanticPredicatesMap =
		new HashMap<DFAState, Map<Integer,SemanticContext>>();

	/** Tracks alts insufficiently covered.
	 *  For example, p1||true gets reduced to true and so leaves
	 *  whole alt uncovered.  This maps DFA state to the set of alts
	 */
	protected Map<DFAState,Map<Integer, Set<Token>>> stateToIncompletelyCoveredAltsMap =
		new HashMap<DFAState,Map<Integer, Set<Token>>>();

	/** The set of states w/o emanating edges and w/o resolving sem preds. */
	protected Set<DFAState> danglingStates = new HashSet<DFAState>();

	/** The overall list of alts within the decision that have at least one
	 *  conflicting input sequence.
	 */
	protected Set<Integer> altsWithProblem = new HashSet<Integer>();

	/** If decision with &gt; 1 alt has recursion in &gt; 1 alt, it's (likely) nonregular
	 *  lookahead.  The decision cannot be made with a DFA.
	 *  the alts are stored in altsWithProblem.
	 */
	public boolean nonLLStarDecision = false;

	/** Recursion is limited to a particular depth.  If that limit is exceeded
	 *  the proposed new NFAConfiguration is recorded for the associated DFA state.
	 */
	protected MultiMap<Integer, NFAConfiguration> stateToRecursionOverflowConfigurationsMap =
		new MultiMap<Integer, NFAConfiguration>();
	/*
	protected Map<Integer, List<NFAConfiguration>> stateToRecursionOverflowConfigurationsMap =
		new HashMap<Integer, List<NFAConfiguration>>();
		*/

	/** Left recursion discovered.  The proposed new NFAConfiguration
	 *  is recorded for the associated DFA state.
	protected Map<Integer,List<NFAConfiguration>> stateToLeftRecursiveConfigurationsMap =
		new HashMap<Integer,List<NFAConfiguration>>();
	 */

	/** Did ANTLR have to terminate early on the analysis of this decision? */
	protected boolean timedOut = false;

	/** Used to find paths through syntactically ambiguous DFA. If we've
	 *  seen statement number before, what did we learn?
	 */
	protected Map<Integer, Integer> stateReachable;

	public static final Integer REACHABLE_BUSY = Utils.integer(-1);
	public static final Integer REACHABLE_NO = Utils.integer(0);
	public static final Integer REACHABLE_YES = Utils.integer(1);

	/** Used while finding a path through an NFA whose edge labels match
	 *  an input sequence.  Tracks the input position
	 *  we were at the last time at this node.  If same input position, then
	 *  we'd have reached same state without consuming input...probably an
	 *  infinite loop.  Stop.  Set&lt;String&gt;.  The strings look like
	 *  stateNumber_labelIndex.
	 */
	protected Set<String> statesVisitedAtInputDepth;

	protected Set<Integer> statesVisitedDuringSampleSequence;

	public static boolean verbose = false;

	public DecisionProbe(DFA dfa) {
		this.dfa = dfa;
	}

	// I N F O R M A T I O N  A B O U T  D E C I S I O N

	/** Return a string like "3:22: ( A {;} | B )" that describes this
	 *  decision.
	 */
	public String getDescription() {
		return dfa.getNFADecisionStartState().getDescription();
	}

	public boolean isReduced() {
		return dfa.isReduced();
	}

	public boolean isCyclic() {
		return dfa.isCyclic();
	}

	/** If no states are dead-ends, no alts are unreachable, there are
	 *  no nondeterminisms unresolved by syn preds, all is ok with decision.
	 */
	public boolean isDeterministic() {
		if ( danglingStates.isEmpty() &&
			 statesWithSyntacticallyAmbiguousAltsSet.isEmpty() &&
			 dfa.getUnreachableAlts().isEmpty() )
		{
			return true;
		}

		if ( statesWithSyntacticallyAmbiguousAltsSet.size()>0 ) {
			for (DFAState d : statesWithSyntacticallyAmbiguousAltsSet) {
				if ( !statesResolvedWithSemanticPredicatesSet.contains(d) ) {
					return false;
				}
			}
			// no syntactically ambig alts were left unresolved by predicates
			return true;
		}
		return false;
	}

	/** Did the analysis complete it's work? */
//	public boolean analysisTimedOut() {
//		return timedOut;
//	}

	/** Took too long to analyze a DFA */
	public boolean analysisOverflowed() {
		return stateToRecursionOverflowConfigurationsMap.size()>0;
	}

	/** Found recursion in &gt; 1 alt */
	public boolean isNonLLStarDecision() {
		return nonLLStarDecision;
	}

	/** How many states does the DFA predictor have? */
	public int getNumberOfStates() {
		return dfa.getNumberOfStates();
	}

	/** Get a list of all unreachable alternatives for this decision.  There
	 *  may be multiple alternatives with ambiguous input sequences, but this
	 *  is the overall list of unreachable alternatives (either due to
	 *  conflict resolution or alts w/o accept states).
	 */
	public List<Integer> getUnreachableAlts() {
		return dfa.getUnreachableAlts();
	}

	/** return set of states w/o emanating edges and w/o resolving sem preds.
	 *  These states come about because the analysis algorithm had to
	 *  terminate early to avoid infinite recursion for example (due to
	 *  left recursion perhaps).
	 */
	public Set<DFAState> getDanglingStates() {
		return danglingStates;
	}

    public Set<Integer> getNonDeterministicAlts() {
        return altsWithProblem;
	}

	/** Return the sorted list of alts that conflict within a single state.
	 *  Note that predicates may resolve the conflict.
	 */
	public List<Integer> getNonDeterministicAltsForState(DFAState targetState) {
		Set<Integer> nondetAlts = targetState.getNonDeterministicAlts();
		if ( nondetAlts==null ) {
			return null;
		}
		List<Integer> sorted = new LinkedList<Integer>();
		sorted.addAll(nondetAlts);
		Collections.sort(sorted); // make sure it's 1, 2, ...
		return sorted;
	}

	/** Return all DFA states in this DFA that have NFA configurations that
	 *  conflict.  You must report a problem for each state in this set
	 *  because each state represents a different input sequence.
	 */
	public Set<DFAState> getDFAStatesWithSyntacticallyAmbiguousAlts() {
		return statesWithSyntacticallyAmbiguousAltsSet;
	}

	/** Which alts were specifically turned off to resolve nondeterminisms?
	 *  This is different than the unreachable alts.  Disabled doesn't mean that
	 *  the alternative is totally unreachable necessarily, it just means
	 *  that for this DFA state, that alt is disabled.  There may be other
	 *  accept states for that alt that make an alt reachable.
	 */
	public Set<Integer> getDisabledAlternatives(DFAState d) {
		return d.getDisabledAlternatives();
	}

	/** If a recursion overflow is resolve with predicates, then we need
	 *  to shut off the warning that would be generated.
	 */
	public void removeRecursiveOverflowState(DFAState d) {
		Integer stateI = Utils.integer(d.stateNumber);
		stateToRecursionOverflowConfigurationsMap.remove(stateI);
	}

	/** Return a List&lt;Label&gt; indicating an input sequence that can be matched
	 *  from the start state of the DFA to the targetState (which is known
	 *  to have a problem).
	 */
	public List<Label> getSampleNonDeterministicInputSequence(DFAState targetState) {
		Set<DFAState> dfaStates = getDFAPathStatesToTarget(targetState);
		statesVisitedDuringSampleSequence = new HashSet<Integer>();
		List<Label> labels = new ArrayList<Label>(); // may access ith element; use array
		if ( dfa==null || dfa.startState==null ) {
			return labels;
		}
		getSampleInputSequenceUsingStateSet(dfa.startState,
											targetState,
											dfaStates,
											labels);
		return labels;
	}

	/** Given List&lt;Label&gt;, return a String with a useful representation
	 *  of the associated input string.  One could show something different
	 *  for lexers and parsers, for example.
	 */
	public String getInputSequenceDisplay(List<? extends Label> labels) {
        Grammar g = dfa.nfa.grammar;
		StringBuilder buf = new StringBuilder();
		for (Iterator<? extends Label> it = labels.iterator(); it.hasNext();) {
			Label label = it.next();
			buf.append(label.toString(g));
			if ( it.hasNext() && g.type!=Grammar.LEXER ) {
				buf.append(' ');
			}
		}
		return buf.toString();
	}

    /** Given an alternative associated with a nondeterministic DFA state,
	 *  find the path of NFA states associated with the labels sequence.
	 *  Useful tracing where in the NFA, a single input sequence can be
	 *  matched.  For different alts, you should get different NFA paths.
	 *
	 *  The first NFA state for all NFA paths will be the same: the starting
	 *  NFA state of the first nondeterministic alt.  Imagine (A|B|A|A):
	 *
	 * 	5-&gt;9-A-&gt;o
	 *  |
	 *  6-&gt;10-B-&gt;o
	 *  |
	 *  7-&gt;11-A-&gt;o
	 *  |
	 *  8-&gt;12-A-&gt;o
	 *
	 *  There are 3 nondeterministic alts.  The paths should be:
	 *  5 9 ...
	 *  5 6 7 11 ...
	 *  5 6 7 8 12 ...
	 *
	 *  The NFA path matching the sample input sequence (labels) is computed
	 *  using states 9, 11, and 12 rather than 5, 7, 8 because state 5, for
	 *  example can get to all ambig paths.  Must isolate for each alt (hence,
	 *  the extra state beginning each alt in my NFA structures).  Here,
	 *  firstAlt=1.
	 */
	public List<? extends NFAState> getNFAPathStatesForAlt(int firstAlt,
									   int alt,
									   List<? extends Label> labels)
	{
		NFAState nfaStart = dfa.getNFADecisionStartState();
		List<NFAState> path = new LinkedList<NFAState>();
		// first add all NFA states leading up to altStart state
		for (int a=firstAlt; a<=alt; a++) {
			NFAState s =
				dfa.nfa.grammar.getNFAStateForAltOfDecision(nfaStart,a);
			path.add(s);
		}

		// add first state of actual alt
		NFAState altStart = dfa.nfa.grammar.getNFAStateForAltOfDecision(nfaStart,alt);
		NFAState isolatedAltStart = (NFAState)altStart.transition[0].target;
		path.add(isolatedAltStart);

		// add the actual path now
		statesVisitedAtInputDepth = new HashSet<String>();
		getNFAPath(isolatedAltStart,
				   0,
				   labels,
				   path);
        return path;
	}

	/** Each state in the DFA represents a different input sequence for an
	 *  alt of the decision.  Given a DFA state, what is the semantic
	 *  predicate context for a particular alt.
	 */
    public SemanticContext getSemanticContextForAlt(DFAState d, int alt) {
		Map<Integer, SemanticContext> altToPredMap = stateToAltSetWithSemanticPredicatesMap.get(d);
		if ( altToPredMap==null ) {
			return null;
		}
		return altToPredMap.get(Utils.integer(alt));
	}

	/** At least one alt refs a sem or syn pred */
	public boolean hasPredicate() {
		return stateToAltSetWithSemanticPredicatesMap.size()>0;
	}

	public Set<DFAState> getNondeterministicStatesResolvedWithSemanticPredicate() {
		return statesResolvedWithSemanticPredicatesSet;
	}

	/** Return a list of alts whose predicate context was insufficient to
	 *  resolve a nondeterminism for state d.
	 */
	public Map<Integer, Set<Token>> getIncompletelyCoveredAlts(DFAState d) {
		return stateToIncompletelyCoveredAltsMap.get(d);
	}

	public void issueWarnings() {
		// NONREGULAR DUE TO RECURSION > 1 ALTS
		// Issue this before aborted analysis, which might also occur
		// if we take too long to terminate
		if ( nonLLStarDecision && !dfa.getAutoBacktrackMode() ) {
			ErrorManager.nonLLStarDecision(this);
		}

		issueRecursionWarnings();

		// generate a separate message for each problem state in DFA
		Set<DFAState> resolvedStates = getNondeterministicStatesResolvedWithSemanticPredicate();
		Set<DFAState> problemStates = getDFAStatesWithSyntacticallyAmbiguousAlts();
		if ( problemStates.size()>0 ) {
			Iterator<DFAState> it =
				problemStates.iterator();
			while (	it.hasNext() && !dfa.nfa.grammar.NFAToDFAConversionExternallyAborted() ) {
				DFAState d = it.next();
				Map<Integer, Set<Token>> insufficientAltToLocations = getIncompletelyCoveredAlts(d);
				if ( insufficientAltToLocations!=null && insufficientAltToLocations.size()>0 ) {
					ErrorManager.insufficientPredicates(this,d,insufficientAltToLocations);
				}
				// don't report problem if resolved
				if ( resolvedStates==null || !resolvedStates.contains(d) ) {
					// first strip last alt from disableAlts if it's wildcard
					// then don't print error if no more disable alts
					Set<Integer> disabledAlts = getDisabledAlternatives(d);
					stripWildCardAlts(disabledAlts);
					if ( disabledAlts.size()>0 ) {
						// nondeterminism; same input predicts multiple alts.
						// but don't emit error if greedy=true explicitly set
						boolean explicitlyGreedy = false;
						GrammarAST blockAST =
							d.dfa.nfa.grammar.getDecisionBlockAST(d.dfa.decisionNumber);
						if ( blockAST!=null ) {
							String greedyS = (String)blockAST.getBlockOption("greedy");
							if ( greedyS!=null && greedyS.equals("true") ) explicitlyGreedy = true;
						}
						if ( !explicitlyGreedy) ErrorManager.nondeterminism(this,d);
					}
				}
			}
		}

		Set<DFAState> danglingStates = getDanglingStates();
		if ( danglingStates.size()>0 ) {
			//System.err.println("no emanating edges for states: "+danglingStates);
			for (DFAState d : danglingStates) {
				ErrorManager.danglingState(this,d);
			}
		}

		if ( !nonLLStarDecision ) {
			List<Integer> unreachableAlts = dfa.getUnreachableAlts();
			if ( unreachableAlts!=null && unreachableAlts.size()>0 ) {
				// give different msg if it's an empty Tokens rule from delegate
				boolean isInheritedTokensRule = false;
				if ( dfa.isTokensRuleDecision() ) {
					for (Integer altI : unreachableAlts) {
						GrammarAST decAST = dfa.getDecisionASTNode();
						GrammarAST altAST = (GrammarAST)decAST.getChild(altI-1);
						GrammarAST delegatedTokensAlt =
							(GrammarAST)altAST.getFirstChildWithType(ANTLRParser.DOT);
						if ( delegatedTokensAlt !=null ) {
							isInheritedTokensRule = true;
							ErrorManager.grammarWarning(ErrorManager.MSG_IMPORTED_TOKENS_RULE_EMPTY,
														dfa.nfa.grammar,
														null,
														dfa.nfa.grammar.name,
														delegatedTokensAlt.getChild(0).getText());
						}
					}
				}
				if ( isInheritedTokensRule ) {
				}
				else {
					ErrorManager.unreachableAlts(this,unreachableAlts);
				}
			}
		}
	}

	/** Get the last disabled alt number and check in the grammar to see
	 *  if that alt is a simple wildcard.  If so, treat like an else clause
	 *  and don't emit the error.  Strip out the last alt if it's wildcard.
	 */
	protected void stripWildCardAlts(Set<Integer> disabledAlts) {
		List<Integer> sortedDisableAlts = new ArrayList<Integer>(disabledAlts);
		Collections.sort(sortedDisableAlts);
		Integer lastAlt =
			sortedDisableAlts.get(sortedDisableAlts.size()-1);
		GrammarAST blockAST =
			dfa.nfa.grammar.getDecisionBlockAST(dfa.decisionNumber);
		//System.out.println("block with error = "+blockAST.toStringTree());
		GrammarAST lastAltAST;
		if ( blockAST.getChild(0).getType()==ANTLRParser.OPTIONS ) {
			// if options, skip first child: ( options { ( = greedy false ) )
			lastAltAST = (GrammarAST)blockAST.getChild(lastAlt.intValue());
		}
		else {
			lastAltAST = (GrammarAST)blockAST.getChild(lastAlt -1);
		}
		//System.out.println("last alt is "+lastAltAST.toStringTree());
		// if last alt looks like ( ALT . <end-of-alt> ) then wildcard
		// Avoid looking at optional blocks etc... that have last alt
		// as the EOB:
		// ( BLOCK ( ALT 'else' statement <end-of-alt> ) <end-of-block> )
		if ( lastAltAST.getType()!=ANTLRParser.EOB &&
			 lastAltAST.getChild(0).getType()== ANTLRParser.WILDCARD &&
			 lastAltAST.getChild(1).getType()== ANTLRParser.EOA )
		{
			//System.out.println("wildcard");
			disabledAlts.remove(lastAlt);
		}
	}

	protected void issueRecursionWarnings() {
		// RECURSION OVERFLOW
		Set<Integer> dfaStatesWithRecursionProblems =
			stateToRecursionOverflowConfigurationsMap.keySet();
		// now walk truly unique (unaliased) list of dfa states with inf recur
		// Goal: create a map from alt to map<target,List<callsites>>
		// Map<Map<String target, List<NFAState call sites>>
		Map<Integer, Map<String, Set<NFAState>>> altToTargetToCallSitesMap =
			new HashMap<Integer, Map<String, Set<NFAState>>>();
		// track a single problem DFA state for each alt
		Map<Integer, DFAState> altToDFAState = new HashMap<Integer, DFAState>();
		computeAltToProblemMaps(dfaStatesWithRecursionProblems,
								stateToRecursionOverflowConfigurationsMap,
								altToTargetToCallSitesMap, // output param
								altToDFAState);            // output param

		// walk each alt with recursion overflow problems and generate error
		Set<Integer> alts = altToTargetToCallSitesMap.keySet();
		List<Integer> sortedAlts = new ArrayList<Integer>(alts);
		Collections.sort(sortedAlts);
		for (Integer altI : sortedAlts) {
			Map<String, Set<NFAState>> targetToCallSiteMap =
				altToTargetToCallSitesMap.get(altI);
			Set<String> targetRules = targetToCallSiteMap.keySet();
			Collection<Set<NFAState>> callSiteStates = targetToCallSiteMap.values();
			DFAState sampleBadState = altToDFAState.get(altI);
			ErrorManager.recursionOverflow(this,
										   sampleBadState,
										   altI,
										   targetRules,
										   callSiteStates);
		}
	}

	private void computeAltToProblemMaps(Set<Integer> dfaStatesUnaliased,
										 Map<Integer, List<NFAConfiguration>> configurationsMap,
										 Map<Integer, Map<String, Set<NFAState>>> altToTargetToCallSitesMap,
										 Map<Integer, DFAState> altToDFAState)
	{
		for (Integer stateI : dfaStatesUnaliased) {
			// walk this DFA's config list
			List<? extends NFAConfiguration> configs = configurationsMap.get(stateI);
			for (int i = 0; i < configs.size(); i++) {
				NFAConfiguration c = configs.get(i);
				NFAState ruleInvocationState = dfa.nfa.getState(c.state);
				Transition transition0 = ruleInvocationState.transition[0];
				RuleClosureTransition ref = (RuleClosureTransition)transition0;
				String targetRule = ((NFAState) ref.target).enclosingRule.name;
				Integer altI = Utils.integer(c.alt);
				Map<String, Set<NFAState>> targetToCallSiteMap =
					altToTargetToCallSitesMap.get(altI);
				if ( targetToCallSiteMap==null ) {
					targetToCallSiteMap = new HashMap<String, Set<NFAState>>();
					altToTargetToCallSitesMap.put(altI, targetToCallSiteMap);
				}
				Set<NFAState> callSites =
					targetToCallSiteMap.get(targetRule);
				if ( callSites==null ) {
					callSites = new HashSet<NFAState>();
					targetToCallSiteMap.put(targetRule, callSites);
				}
				callSites.add(ruleInvocationState);
				// track one problem DFA state per alt
				if ( altToDFAState.get(altI)==null ) {
					DFAState sampleBadState = dfa.getState(stateI);
					altToDFAState.put(altI, sampleBadState);
				}
			}
		}
	}

	private Set<Integer> getUnaliasedDFAStateSet(Set<Integer> dfaStatesWithRecursionProblems) {
		Set<Integer> dfaStatesUnaliased = new HashSet<Integer>();
		for (Integer stateI : dfaStatesWithRecursionProblems) {
			DFAState d = dfa.getState(stateI);
			dfaStatesUnaliased.add(Utils.integer(d.stateNumber));
		}
		return dfaStatesUnaliased;
	}


	// T R A C K I N G  M E T H O D S

    /** Report the fact that DFA state d is not a state resolved with
     *  predicates and yet it has no emanating edges.  Usually this
     *  is a result of the closure/reach operations being unable to proceed
     */
	public void reportDanglingState(DFAState d) {
		danglingStates.add(d);
	}

//	public void reportAnalysisTimeout() {
//		timedOut = true;
//		dfa.nfa.grammar.setOfDFAWhoseAnalysisTimedOut.add(dfa);
//	}

	/** Report that at least 2 alts have recursive constructs.  There is
	 *  no way to build a DFA so we terminated.
	 */
	public void reportNonLLStarDecision(DFA dfa) {
		/*
		System.out.println("non-LL(*) DFA "+dfa.decisionNumber+", alts: "+
						   dfa.recursiveAltSet.toList());
						   */
		nonLLStarDecision = true;
		dfa.nfa.grammar.numNonLLStar++;
		altsWithProblem.addAll(dfa.recursiveAltSet.toList());
	}

	public void reportRecursionOverflow(DFAState d,
										NFAConfiguration recursionNFAConfiguration)
	{
		// track the state number rather than the state as d will change
		// out from underneath us; hash wouldn't return any value

		// left-recursion is detected in start state.  Since we can't
		// call resolveNondeterminism() on the start state (it would
		// not look k=1 to get min single token lookahead), we must
		// prevent errors derived from this state.  Avoid start state
		if ( d.stateNumber > 0 ) {
			Integer stateI = Utils.integer(d.stateNumber);
			stateToRecursionOverflowConfigurationsMap.map(stateI, recursionNFAConfiguration);
		}
	}

	public void reportNondeterminism(DFAState d, Set<Integer> nondeterministicAlts) {
		altsWithProblem.addAll(nondeterministicAlts); // track overall list
		statesWithSyntacticallyAmbiguousAltsSet.add(d);
		dfa.nfa.grammar.setOfNondeterministicDecisionNumbers.add(
			Utils.integer(dfa.getDecisionNumber())
		);
	}

	/** Currently the analysis reports issues between token definitions, but
	 *  we don't print out warnings in favor of just picking the first token
	 *  definition found in the grammar ala lex/flex.
	 */
	public void reportLexerRuleNondeterminism(DFAState d, Set<Integer> nondeterministicAlts) {
		stateToSyntacticallyAmbiguousTokensRuleAltsMap.put(d,nondeterministicAlts);
	}

	public void reportNondeterminismResolvedWithSemanticPredicate(DFAState d) {
		// First, prevent a recursion warning on this state due to
		// pred resolution
		if ( d.abortedDueToRecursionOverflow ) {
			d.dfa.probe.removeRecursiveOverflowState(d);
		}
		statesResolvedWithSemanticPredicatesSet.add(d);
		//System.out.println("resolved with pred: "+d);
		dfa.nfa.grammar.setOfNondeterministicDecisionNumbersResolvedWithPredicates.add(
			Utils.integer(dfa.getDecisionNumber())
		);
	}

	/** Report the list of predicates found for each alternative; copy
	 *  the list because this set gets altered later by the method
	 *  tryToResolveWithSemanticPredicates() while flagging NFA configurations
	 *  in d as resolved.
	 */
	public void reportAltPredicateContext(DFAState d, Map<Integer, ? extends SemanticContext> altPredicateContext) {
		Map<Integer, SemanticContext> copy = new HashMap<Integer, SemanticContext>();
		copy.putAll(altPredicateContext);
		stateToAltSetWithSemanticPredicatesMap.put(d,copy);
	}

	public void reportIncompletelyCoveredAlts(DFAState d,
											  Map<Integer, Set<Token>> altToLocationsReachableWithoutPredicate)
	{
		stateToIncompletelyCoveredAltsMap.put(d, altToLocationsReachableWithoutPredicate);
	}

	// S U P P O R T

	/** Given a start state and a target state, return true if start can reach
	 *  target state.  Also, compute the set of DFA states
	 *  that are on a path from start to target; return in states parameter.
	 */
	protected boolean reachesState(DFAState startState,
								   DFAState targetState,
								   Set<DFAState> states) {
		if ( startState==targetState ) {
			states.add(targetState);
			//System.out.println("found target DFA state "+targetState.getStateNumber());
			stateReachable.put(startState.stateNumber, REACHABLE_YES);
			return true;
		}

		DFAState s = startState;
		// avoid infinite loops
		stateReachable.put(s.stateNumber, REACHABLE_BUSY);

		// look for a path to targetState among transitions for this state
		// stop when you find the first one; I'm pretty sure there is
		// at most one path to any DFA state with conflicting predictions
		for (int i=0; i<s.getNumberOfTransitions(); i++) {
			Transition t = s.transition(i);
			DFAState edgeTarget = (DFAState)t.target;
			Integer targetStatus = stateReachable.get(edgeTarget.stateNumber);
			if ( targetStatus==REACHABLE_BUSY ) { // avoid cycles; they say nothing
				continue;
			}
			if ( targetStatus==REACHABLE_YES ) { // return success!
				stateReachable.put(s.stateNumber, REACHABLE_YES);
				return true;
			}
			if ( targetStatus==REACHABLE_NO ) { // try another transition
				continue;
			}
			// if null, target must be REACHABLE_UNKNOWN (i.e., unvisited)
			if ( reachesState(edgeTarget, targetState, states) ) {
				states.add(s);
				stateReachable.put(s.stateNumber, REACHABLE_YES);
				return true;
			}
		}

		stateReachable.put(s.stateNumber, REACHABLE_NO);
		return false; // no path to targetState found.
	}

	protected Set<DFAState> getDFAPathStatesToTarget(DFAState targetState) {
		Set<DFAState> dfaStates = new HashSet<DFAState>();
		stateReachable = new HashMap<Integer, Integer>();
		if ( dfa==null || dfa.startState==null ) {
			return dfaStates;
		}
		boolean reaches = reachesState(dfa.startState, targetState, dfaStates);
		return dfaStates;
	}

	/** Given a start state and a final state, find a list of edge labels
	 *  between the two ignoring epsilon.  Limit your scan to a set of states
	 *  passed in.  This is used to show a sample input sequence that is
	 *  nondeterministic with respect to this decision.  Return List&lt;Label&gt; as
	 *  a parameter.  The incoming states set must be all states that lead
	 *  from startState to targetState and no others so this algorithm doesn't
	 *  take a path that eventually leads to a state other than targetState.
	 *  Don't follow loops, leading to short (possibly shortest) path.
	 */
	protected void getSampleInputSequenceUsingStateSet(State startState,
													   State targetState,
													   Set<DFAState> states,
													   List<Label> labels)
	{
		statesVisitedDuringSampleSequence.add(startState.stateNumber);

		// pick the first edge in states as the one to traverse
		for (int i=0; i<startState.getNumberOfTransitions(); i++) {
			Transition t = startState.transition(i);
			DFAState edgeTarget = (DFAState)t.target;
			if ( states.contains(edgeTarget) &&
				 !statesVisitedDuringSampleSequence.contains(edgeTarget.stateNumber) )
			{
				labels.add(t.label); // traverse edge and track label
				if ( edgeTarget!=targetState ) {
					// get more labels if not at target
					getSampleInputSequenceUsingStateSet(edgeTarget,
														targetState,
														states,
														labels);
				}
				// done with this DFA state as we've found a good path to target
				return;
			}
		}
		labels.add(new Label(Label.EPSILON)); // indicate no input found
		// this happens on a : {p1}? a | A ;
		//ErrorManager.error(ErrorManager.MSG_CANNOT_COMPUTE_SAMPLE_INPUT_SEQ);
	}

	/** Given a sample input sequence, you usually would like to know the
	 *  path taken through the NFA.  Return the list of NFA states visited
	 *  while matching a list of labels.  This cannot use the usual
	 *  interpreter, which does a deterministic walk.  We need to be able to
	 *  take paths that are turned off during nondeterminism resolution. So,
	 *  just do a depth-first walk traversing edges labeled with the current
	 *  label.  Return true if a path was found emanating from state s.
	 */
	protected boolean getNFAPath(NFAState s,     // starting where?
								 int labelIndex, // 0..labels.size()-1
								 List<? extends Label> labels,    // input sequence
								 List<? super NFAState> path)      // output list of NFA states
	{
		// track a visit to state s at input index labelIndex if not seen
		String thisStateKey = getStateLabelIndexKey(s.stateNumber,labelIndex);
		if ( statesVisitedAtInputDepth.contains(thisStateKey) ) {
			/*
			System.out.println("### already visited "+s.stateNumber+" previously at index "+
						   labelIndex);
			*/
			return false;
		}
		statesVisitedAtInputDepth.add(thisStateKey);

		/*
		System.out.println("enter state "+s.stateNumber+" visited states: "+
						   statesVisitedAtInputDepth);
        */

		// pick the first edge whose target is in states and whose
		// label is labels[labelIndex]
		for (int i=0; i<s.getNumberOfTransitions(); i++) {
			Transition t = s.transition[i];
			NFAState edgeTarget = (NFAState)t.target;
			Label label = (Label)labels.get(labelIndex);
			/*
			System.out.println(s.stateNumber+"-"+
							   t.label.toString(dfa.nfa.grammar)+"->"+
							   edgeTarget.stateNumber+" =="+
							   label.toString(dfa.nfa.grammar)+"?");
			*/
			if ( t.label.isEpsilon() || t.label.isSemanticPredicate() ) {
				// nondeterministically backtrack down epsilon edges
				path.add(edgeTarget);
				boolean found =
					getNFAPath(edgeTarget, labelIndex, labels, path);
				if ( found ) {
					statesVisitedAtInputDepth.remove(thisStateKey);
					return true; // return to "calling" state
				}
				path.remove(path.size()-1); // remove; didn't work out
				continue; // look at the next edge
			}
			if ( t.label.matches(label) ) {
				path.add(edgeTarget);
				/*
				System.out.println("found label "+
								   t.label.toString(dfa.nfa.grammar)+
								   " at state "+s.stateNumber+"; labelIndex="+labelIndex);
				*/
				if ( labelIndex==labels.size()-1 ) {
					// found last label; done!
					statesVisitedAtInputDepth.remove(thisStateKey);
					return true;
				}
				// otherwise try to match remaining input
				boolean found =
					getNFAPath(edgeTarget, labelIndex+1, labels, path);
				if ( found ) {
					statesVisitedAtInputDepth.remove(thisStateKey);
					return true;
				}
				/*
				System.out.println("backtrack; path from "+s.stateNumber+"->"+
								   t.label.toString(dfa.nfa.grammar)+" didn't work");
				*/
				path.remove(path.size()-1); // remove; didn't work out
				continue; // keep looking for a path for labels
			}
		}
		//System.out.println("no epsilon or matching edge; removing "+thisStateKey);
		// no edge was found matching label; is ok, some state will have it
		statesVisitedAtInputDepth.remove(thisStateKey);
		return false;
	}

	protected String getStateLabelIndexKey(int s, int i) {
		StringBuilder buf = new StringBuilder();
		buf.append(s);
		buf.append('_');
		buf.append(i);
		return buf.toString();
	}

	/** From an alt number associated with artificial Tokens rule, return
	 *  the name of the token that is associated with that alt.
	 */ 
	public String getTokenNameForTokensRuleAlt(int alt) {
		NFAState decisionState = dfa.getNFADecisionStartState();
		NFAState altState =
			dfa.nfa.grammar.getNFAStateForAltOfDecision(decisionState,alt);
		NFAState decisionLeft = (NFAState)altState.transition[0].target;
		RuleClosureTransition ruleCallEdge =
			(RuleClosureTransition)decisionLeft.transition[0];
		NFAState ruleStartState = (NFAState)ruleCallEdge.target;
		//System.out.println("alt = "+decisionLeft.getEnclosingRule());
		return ruleStartState.enclosingRule.name;
	}

	public void reset() {
		stateToRecursionOverflowConfigurationsMap.clear();
	}
}
