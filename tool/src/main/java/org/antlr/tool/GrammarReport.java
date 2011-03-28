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

import org.antlr.analysis.DFA;
import org.antlr.grammar.v3.ANTLRParser;
import org.antlr.misc.Utils;
import org.antlr.runtime.misc.Stats;

import java.lang.reflect.Field;
import java.util.*;

public class GrammarReport {
	/** Because I may change the stats, I need to track version for later
	 *  computations to be consistent.
	 */
	public static final String Version = "5";
	public static final String GRAMMAR_STATS_FILENAME = "grammar.stats";

	public static class ReportData {
		String version;
		String gname;
		String gtype;
		String language;
		int numRules;
		int numOuterProductions;
		int numberOfDecisionsInRealRules;
		int numberOfDecisions;
		int numberOfCyclicDecisions;
		int numberOfFixedKDecisions;
		int numLL1;
		int mink;
		int maxk;
		double avgk;
		int numTokens;
		long DFACreationWallClockTimeInMS;
		int numberOfSemanticPredicates;
		int numberOfManualLookaheadOptions; // TODO: verify
		int numNonLLStarDecisions;
		int numNondeterministicDecisions;
		int numNondeterministicDecisionNumbersResolvedWithPredicates;
		int errors;
		int warnings;
		int infos;
		//int num_synpreds;
		int blocksWithSynPreds;
		int decisionsWhoseDFAsUsesSynPreds;
		int blocksWithSemPreds;
		int decisionsWhoseDFAsUsesSemPreds;
		String output;
		String grammarLevelk;
		String grammarLevelBacktrack;
	}

	public static final String newline = System.getProperty("line.separator");

	public Grammar grammar;

	public GrammarReport(Grammar grammar) {
		this.grammar = grammar;
	}

	public static ReportData getReportData(Grammar g) {
		ReportData data = new ReportData();
		data.version = Version;
		data.gname = g.name;

		data.gtype = g.getGrammarTypeString();

		data.language = (String) g.getOption("language");
		data.output = (String) g.getOption("output");
		if ( data.output==null ) {
			data.output = "none";
		}

		String k = (String) g.getOption("k");
		if ( k==null ) {
			k = "none";
		}
		data.grammarLevelk = k;

		String backtrack = (String) g.getOption("backtrack");
		if ( backtrack==null ) {
			backtrack = "false";
		}
		data.grammarLevelBacktrack = backtrack;

		int totalNonSynPredProductions = 0;
		int totalNonSynPredRules = 0;
		Collection rules = g.getRules();
		for (Iterator it = rules.iterator(); it.hasNext();) {
			Rule r = (Rule) it.next();
			if ( !r.name.toUpperCase()
				.startsWith(Grammar.SYNPRED_RULE_PREFIX.toUpperCase()) )
			{
				totalNonSynPredProductions += r.numberOfAlts;
				totalNonSynPredRules++;
			}
		}

		data.numRules = totalNonSynPredRules;
		data.numOuterProductions = totalNonSynPredProductions;

		int numACyclicDecisions =
			g.getNumberOfDecisions()- g.getNumberOfCyclicDecisions();
		List<Integer> depths = new ArrayList<Integer>();
		int[] acyclicDFAStates = new int[numACyclicDecisions];
		int[] cyclicDFAStates = new int[g.getNumberOfCyclicDecisions()];
		int acyclicIndex = 0;
		int cyclicIndex = 0;
		int numLL1 = 0;
		int blocksWithSynPreds = 0;
		int dfaWithSynPred = 0;
		int numDecisions = 0;
		int numCyclicDecisions = 0;
		for (int i=1; i<= g.getNumberOfDecisions(); i++) {
			Grammar.Decision d = g.getDecision(i);
			if( d.dfa==null ) {
				//System.out.println("dec "+d.decision+" has no AST");
				continue;
			}
			Rule r = d.dfa.decisionNFAStartState.enclosingRule;
			if ( r.name.toUpperCase()
				.startsWith(Grammar.SYNPRED_RULE_PREFIX.toUpperCase()) )
			{
				//System.out.println("dec "+d.decision+" is a synpred");
				continue;
			}

			numDecisions++;
			if ( blockHasSynPred(d.blockAST) ) blocksWithSynPreds++;
			//if ( g.decisionsWhoseDFAsUsesSynPreds.contains(d.dfa) ) dfaWithSynPred++;
			if ( d.dfa.hasSynPred() ) dfaWithSynPred++;
			
//			NFAState decisionStartState = grammar.getDecisionNFAStartState(d.decision);
//			int nalts = grammar.getNumberOfAltsForDecisionNFA(decisionStartState);
//			for (int alt = 1; alt <= nalts; alt++) {
//				int walkAlt =
//					decisionStartState.translateDisplayAltToWalkAlt(alt);
//				NFAState altLeftEdge = grammar.getNFAStateForAltOfDecision(decisionStartState, walkAlt);
//			}
//			int nalts = grammar.getNumberOfAltsForDecisionNFA(d.dfa.decisionNFAStartState);
//			for (int a=1; a<nalts; a++) {
//				NFAState altStart =
//					grammar.getNFAStateForAltOfDecision(d.dfa.decisionNFAStartState, a);
//			}
			if ( !d.dfa.isCyclic() ) {
				if ( d.dfa.isClassicDFA() ) {
					int maxk = d.dfa.getMaxLookaheadDepth();
					//System.out.println("decision "+d.dfa.decisionNumber+" k="+maxk);
					if ( maxk==1 ) numLL1++;
					depths.add( maxk );
				}
				else {
					acyclicDFAStates[acyclicIndex] = d.dfa.getNumberOfStates();
					acyclicIndex++;
				}
			}
			else {
				//System.out.println("CYCLIC decision "+d.dfa.decisionNumber);
				numCyclicDecisions++;
				cyclicDFAStates[cyclicIndex] = d.dfa.getNumberOfStates();
				cyclicIndex++;
			}
		}

		data.numLL1 = numLL1;
		data.numberOfFixedKDecisions = depths.size();
		data.mink = Stats.min(depths);
		data.maxk = Stats.max(depths);
		data.avgk = Stats.avg(depths);

		data.numberOfDecisionsInRealRules = numDecisions;
		data.numberOfDecisions = g.getNumberOfDecisions();
		data.numberOfCyclicDecisions = numCyclicDecisions;

//		Map synpreds = grammar.getSyntacticPredicates();
//		int num_synpreds = synpreds!=null ? synpreds.size() : 0;
//		data.num_synpreds = num_synpreds;
		data.blocksWithSynPreds = blocksWithSynPreds;
		data.decisionsWhoseDFAsUsesSynPreds = dfaWithSynPred;

//
//		data. = Stats.stddev(depths);
//
//		data. = Stats.min(acyclicDFAStates);
//
//		data. = Stats.max(acyclicDFAStates);
//
//		data. = Stats.avg(acyclicDFAStates);
//
//		data. = Stats.stddev(acyclicDFAStates);
//
//		data. = Stats.sum(acyclicDFAStates);
//
//		data. = Stats.min(cyclicDFAStates);
//
//		data. = Stats.max(cyclicDFAStates);
//
//		data. = Stats.avg(cyclicDFAStates);
//
//		data. = Stats.stddev(cyclicDFAStates);
//
//		data. = Stats.sum(cyclicDFAStates);

		data.numTokens = g.getTokenTypes().size();

		data.DFACreationWallClockTimeInMS = g.DFACreationWallClockTimeInMS;

		// includes true ones and preds in synpreds I think; strip out. 
		data.numberOfSemanticPredicates = g.numberOfSemanticPredicates;

		data.numberOfManualLookaheadOptions = g.numberOfManualLookaheadOptions;

		data.numNonLLStarDecisions = g.numNonLLStar;
		data.numNondeterministicDecisions = g.setOfNondeterministicDecisionNumbers.size();
		data.numNondeterministicDecisionNumbersResolvedWithPredicates =
			g.setOfNondeterministicDecisionNumbersResolvedWithPredicates.size();

		data.errors = ErrorManager.getErrorState().errors;
		data.warnings = ErrorManager.getErrorState().warnings;
		data.infos = ErrorManager.getErrorState().infos;

		data.blocksWithSemPreds = g.blocksWithSemPreds.size();

		data.decisionsWhoseDFAsUsesSemPreds = g.decisionsWhoseDFAsUsesSemPreds.size();

		return data;
	}
	
	/** Create a single-line stats report about this grammar suitable to
	 *  send to the notify page at antlr.org
	 */
	public String toNotifyString() {
		StringBuffer buf = new StringBuffer();
		ReportData data = getReportData(grammar);
		Field[] fields = ReportData.class.getDeclaredFields();
		int i = 0;
		for (Field f : fields) {
			try {
				Object v = f.get(data);
				String s = v!=null ? v.toString() : "null";
				if (i>0) buf.append('\t');
				buf.append(s);
			}
			catch (Exception e) {
				ErrorManager.internalError("Can't get data", e);
			}
			i++;
		}
		return buf.toString();
	}

	public String getBacktrackingReport() {
		StringBuffer buf = new StringBuffer();
		buf.append("Backtracking report:");
		buf.append(newline);
		buf.append("Number of decisions that backtrack: ");
		buf.append(grammar.decisionsWhoseDFAsUsesSynPreds.size());
		buf.append(newline);
		buf.append(getDFALocations(grammar.decisionsWhoseDFAsUsesSynPreds));
		return buf.toString();
	}

	protected String getDFALocations(Set dfas) {
		Set decisions = new HashSet();
		StringBuffer buf = new StringBuffer();
		Iterator it = dfas.iterator();
		while ( it.hasNext() ) {
			DFA dfa = (DFA) it.next();
			// if we aborted a DFA and redid with k=1, the backtrackin
			if ( decisions.contains(Utils.integer(dfa.decisionNumber)) ) {
				continue;
			}
			decisions.add(Utils.integer(dfa.decisionNumber));
			buf.append("Rule ");
			buf.append(dfa.decisionNFAStartState.enclosingRule.name);
			buf.append(" decision ");
			buf.append(dfa.decisionNumber);
			buf.append(" location ");
			GrammarAST decisionAST =
				dfa.decisionNFAStartState.associatedASTNode;
			buf.append(decisionAST.getLine());
			buf.append(":");
			buf.append(decisionAST.getCharPositionInLine());
			buf.append(newline);
		}
		return buf.toString();
	}

	/** Given a stats line suitable for sending to the antlr.org site,
	 *  return a human-readable version.  Return null if there is a
	 *  problem with the data.
	 */
	public String toString() {
		return toString(toNotifyString());
	}

	protected static ReportData decodeReportData(String dataS) {
		ReportData data = new ReportData();
		StringTokenizer st = new StringTokenizer(dataS, "\t");
		Field[] fields = ReportData.class.getDeclaredFields();
		for (Field f : fields) {
			String v = st.nextToken();
			try {
				if ( f.getType() == String.class ) {
					f.set(data, v);
				}
				else if ( f.getType() == double.class ) {
					f.set(data, Double.valueOf(v));					
				}
				else {
					f.set(data, Integer.valueOf(v));					
				}
			}
			catch (Exception e) {
				ErrorManager.internalError("Can't get data", e);
			}
		}
		return data;
	}

	public static String toString(String notifyDataLine) {
		ReportData data = decodeReportData(notifyDataLine);
		if ( data ==null ) {
			return null;
		}
		StringBuffer buf = new StringBuffer();
		buf.append("ANTLR Grammar Report; Stats Version ");
		buf.append(data.version);
		buf.append('\n');
		buf.append("Grammar: ");
		buf.append(data.gname);
		buf.append('\n');
		buf.append("Type: ");
		buf.append(data.gtype);
		buf.append('\n');
		buf.append("Target language: ");
		buf.append(data.language);
		buf.append('\n');
		buf.append("Output: ");
		buf.append(data.output);
		buf.append('\n');
		buf.append("Grammar option k: ");
		buf.append(data.grammarLevelk);
		buf.append('\n');
		buf.append("Grammar option backtrack: ");
		buf.append(data.grammarLevelBacktrack);
		buf.append('\n');
		buf.append("Rules: ");
		buf.append(data.numRules);
		buf.append('\n');
		buf.append("Outer productions: ");
		buf.append(data.numOuterProductions);
		buf.append('\n');
		buf.append("Decisions: ");
		buf.append(data.numberOfDecisions);
		buf.append('\n');
		buf.append("Decisions (ignoring decisions in synpreds): ");
		buf.append(data.numberOfDecisionsInRealRules);
		buf.append('\n');
		buf.append("Fixed k DFA decisions: ");
		buf.append(data.numberOfFixedKDecisions);
		buf.append('\n');
		buf.append("Cyclic DFA decisions: ");
		buf.append(data.numberOfCyclicDecisions);
		buf.append('\n');
		buf.append("LL(1) decisions: "); buf.append(data.numLL1);
		buf.append('\n');
		buf.append("Min fixed k: "); buf.append(data.mink);
		buf.append('\n');
		buf.append("Max fixed k: "); buf.append(data.maxk);
		buf.append('\n');
		buf.append("Average fixed k: "); buf.append(data.avgk);
		buf.append('\n');
//		buf.append("Standard deviation of fixed k: "); buf.append(fields[12]);
//		buf.append('\n');
//		buf.append("Min acyclic DFA states: "); buf.append(fields[13]);
//		buf.append('\n');
//		buf.append("Max acyclic DFA states: "); buf.append(fields[14]);
//		buf.append('\n');
//		buf.append("Average acyclic DFA states: "); buf.append(fields[15]);
//		buf.append('\n');
//		buf.append("Standard deviation of acyclic DFA states: "); buf.append(fields[16]);
//		buf.append('\n');
//		buf.append("Total acyclic DFA states: "); buf.append(fields[17]);
//		buf.append('\n');
//		buf.append("Min cyclic DFA states: "); buf.append(fields[18]);
//		buf.append('\n');
//		buf.append("Max cyclic DFA states: "); buf.append(fields[19]);
//		buf.append('\n');
//		buf.append("Average cyclic DFA states: "); buf.append(fields[20]);
//		buf.append('\n');
//		buf.append("Standard deviation of cyclic DFA states: "); buf.append(fields[21]);
//		buf.append('\n');
//		buf.append("Total cyclic DFA states: "); buf.append(fields[22]);
//		buf.append('\n');
		buf.append("DFA creation time in ms: ");
		buf.append(data.DFACreationWallClockTimeInMS);
		buf.append('\n');

//		buf.append("Number of syntactic predicates available (including synpred rules): ");
//		buf.append(data.num_synpreds);
//		buf.append('\n');
		buf.append("Decisions with available syntactic predicates (ignoring synpred rules): ");
		buf.append(data.blocksWithSynPreds);
		buf.append('\n');
		buf.append("Decision DFAs using syntactic predicates (ignoring synpred rules): ");
		buf.append(data.decisionsWhoseDFAsUsesSynPreds);
		buf.append('\n');

		buf.append("Number of semantic predicates found: ");
		buf.append(data.numberOfSemanticPredicates);
		buf.append('\n');
		buf.append("Decisions with semantic predicates: ");
		buf.append(data.blocksWithSemPreds);
		buf.append('\n');
		buf.append("Decision DFAs using semantic predicates: ");
		buf.append(data.decisionsWhoseDFAsUsesSemPreds);
		buf.append('\n');

		buf.append("Number of (likely) non-LL(*) decisions: ");
		buf.append(data.numNonLLStarDecisions);
		buf.append('\n');
		buf.append("Number of nondeterministic decisions: ");
		buf.append(data.numNondeterministicDecisions);
		buf.append('\n');
		buf.append("Number of nondeterministic decisions resolved with predicates: ");
		buf.append(data.numNondeterministicDecisionNumbersResolvedWithPredicates);
		buf.append('\n');

		buf.append("Number of manual or forced fixed lookahead k=value options: ");
		buf.append(data.numberOfManualLookaheadOptions);
		buf.append('\n');

		buf.append("Vocabulary size: ");
		buf.append(data.numTokens);
		buf.append('\n');
		buf.append("Number of errors: ");
		buf.append(data.errors);
		buf.append('\n');
		buf.append("Number of warnings: ");
		buf.append(data.warnings);
		buf.append('\n');
		buf.append("Number of infos: ");
		buf.append(data.infos);
		buf.append('\n');
		return buf.toString();
	}

	public static boolean blockHasSynPred(GrammarAST blockAST) {
		GrammarAST c1 = blockAST.findFirstType(ANTLRParser.SYN_SEMPRED);
		GrammarAST c2 = blockAST.findFirstType(ANTLRParser.BACKTRACK_SEMPRED);
		if ( c1!=null || c2!=null ) return true;
//		System.out.println(blockAST.enclosingRuleName+
//						   " "+blockAST.getLine()+":"+blockAST.getColumn()+" no preds AST="+blockAST.toStringTree());
		return false;
	}

}
