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

import org.antlr.codegen.CodeGenerator;
import org.antlr.grammar.v3.ANTLRParser;
import org.antlr.tool.Grammar;
import org.antlr.tool.GrammarAST;
import org.stringtemplate.v4.ST;
import org.stringtemplate.v4.STGroup;

import java.util.*;

/** A binary tree structure used to record the semantic context in which
 *  an NFA configuration is valid.  It's either a single predicate or
 *  a tree representing an operation tree such as: p1&&p2 or p1||p2.
 *
 *  For NFA o-p1->o-p2->o, create tree AND(p1,p2).
 *  For NFA (1)-p1->(2)
 *           |       ^
 *           |       |
 *          (3)-p2----
 *  we will have to combine p1 and p2 into DFA state as we will be
 *  adding NFA configurations for state 2 with two predicates p1,p2.
 *  So, set context for combined NFA config for state 2: OR(p1,p2).
 *
 *  I have scoped the AND, NOT, OR, and Predicate subclasses of
 *  SemanticContext within the scope of this outer class.
 *
 *  July 7, 2006: TJP altered OR to be set of operands. the Binary tree
 *  made it really hard to reduce complicated || sequences to their minimum.
 *  Got huge repeated || conditions.
 */
public abstract class SemanticContext {
	/** Create a default value for the semantic context shared among all
	 *  NFAConfigurations that do not have an actual semantic context.
	 *  This prevents lots of if!=null type checks all over; it represents
	 *  just an empty set of predicates.
	 */
	public static final SemanticContext EMPTY_SEMANTIC_CONTEXT = new Predicate(Predicate.INVALID_PRED_VALUE);

	/** Given a semantic context expression tree, return a tree with all
	 *  nongated predicates set to true and then reduced.  So p&&(q||r) would
	 *  return p&&r if q is nongated but p and r are gated.
	 */
	public abstract SemanticContext getGatedPredicateContext();

	/** Generate an expression that will evaluate the semantic context,
	 *  given a set of output templates.
	 */
	public abstract ST genExpr(CodeGenerator generator,
										   STGroup templates,
										   DFA dfa);

	public abstract boolean hasUserSemanticPredicate(); // user-specified sempred {}? or {}?=>
	public abstract boolean isSyntacticPredicate();

	/** Notify the indicated grammar of any syn preds used within this context */
	public void trackUseOfSyntacticPredicates(Grammar g) {
	}

	public static class Predicate extends SemanticContext {
		/** The AST node in tree created from the grammar holding the predicate */
		public GrammarAST predicateAST;

		/** Is this a {...}?=> gating predicate or a normal disambiguating {..}?
		 *  If any predicate in expression is gated, then expression is considered
		 *  gated.
		 *
		 *  The simple Predicate object's predicate AST's type is used to set
		 *  gated to true if type==GATED_SEMPRED.
		 */
		protected boolean gated = false;

		/** syntactic predicates are converted to semantic predicates
		 *  but synpreds are generated slightly differently.
		 */
		protected boolean synpred = false;

		public static final int INVALID_PRED_VALUE = -2;
		public static final int FALSE_PRED = 0;
		public static final int TRUE_PRED = ~0;

		/** sometimes predicates are known to be true or false; we need
		 *  a way to represent this without resorting to a target language
		 *  value like true or TRUE.
		 */
		protected int constantValue = INVALID_PRED_VALUE;

		public Predicate(int constantValue) {
			predicateAST = new GrammarAST();
			this.constantValue=constantValue;
		}

		public Predicate(GrammarAST predicate) {
			this.predicateAST = predicate;
			this.gated =
				predicate.getType()==ANTLRParser.GATED_SEMPRED ||
				predicate.getType()==ANTLRParser.SYN_SEMPRED ;
			this.synpred =
				predicate.getType()==ANTLRParser.SYN_SEMPRED ||
				predicate.getType()==ANTLRParser.BACKTRACK_SEMPRED;
		}

		public Predicate(Predicate p) {
			this.predicateAST = p.predicateAST;
			this.gated = p.gated;
			this.synpred = p.synpred;
			this.constantValue = p.constantValue;
		}

		/** Two predicates are the same if they are literally the same
		 *  text rather than same node in the grammar's AST.
		 *  Or, if they have the same constant value, return equal.
		 *  As of July 2006 I'm not sure these are needed.
		 */
		public boolean equals(Object o) {
			if ( !(o instanceof Predicate) ) {
				return false;
			}

			Predicate other = (Predicate)o;
			if (this.constantValue != other.constantValue){
				return false;
			}

			if (this.constantValue != INVALID_PRED_VALUE){
				return true;
			}

			return predicateAST.getText().equals(other.predicateAST.getText());
		}

		public int hashCode() {
			if (constantValue != INVALID_PRED_VALUE){
				return constantValue;
			}

			if ( predicateAST ==null ) {
				return 0;
			}

			return predicateAST.getText().hashCode();
		}

		public ST genExpr(CodeGenerator generator,
									  STGroup templates,
									  DFA dfa)
		{
			ST eST = null;
			if ( templates!=null ) {
				if ( synpred ) {
					eST = templates.getInstanceOf("evalSynPredicate");
				}
				else {
					eST = templates.getInstanceOf("evalPredicate");
					generator.grammar.decisionsWhoseDFAsUsesSemPreds.add(dfa);
				}
				String predEnclosingRuleName = predicateAST.enclosingRuleName;
				/*
				String decisionEnclosingRuleName =
					dfa.getNFADecisionStartState().getEnclosingRule();
				// if these rulenames are diff, then pred was hoisted out of rule
				// Currently I don't warn you about this as it could be annoying.
				// I do the translation anyway.
				*/
				//eST.add("pred", this.toString());
				if ( generator!=null ) {
					eST.add("pred",
									 generator.translateAction(predEnclosingRuleName,predicateAST));
				}
			}
			else {
				eST = new ST("<pred>");
				eST.add("pred", this.toString());
				return eST;
			}
			if ( generator!=null ) {
				String description =
					generator.target.getTargetStringLiteralFromString(this.toString());
				eST.add("description", description);
			}
			return eST;
		}

		@Override
		public SemanticContext getGatedPredicateContext() {
			if ( gated ) {
				return this;
			}
			return null;
		}

		@Override
		public boolean hasUserSemanticPredicate() { // user-specified sempred
			return predicateAST !=null &&
				   ( predicateAST.getType()==ANTLRParser.GATED_SEMPRED ||
					 predicateAST.getType()==ANTLRParser.SEMPRED );
		}

		@Override
		public boolean isSyntacticPredicate() {
			return predicateAST !=null &&
				( predicateAST.getType()==ANTLRParser.SYN_SEMPRED ||
				  predicateAST.getType()==ANTLRParser.BACKTRACK_SEMPRED );
		}

		@Override
		public void trackUseOfSyntacticPredicates(Grammar g) {
			if ( synpred ) {
				g.synPredNamesUsedInDFA.add(predicateAST.getText());
			}
		}

		@Override
		public String toString() {
			if ( predicateAST ==null ) {
				return "<nopred>";
			}
			return predicateAST.getText();
		}
	}

	public static class TruePredicate extends Predicate {
		public TruePredicate() {
			super(TRUE_PRED);
		}

		@Override
		public ST genExpr(CodeGenerator generator,
									  STGroup templates,
									  DFA dfa)
		{
			if ( templates!=null ) {
				return templates.getInstanceOf("true_value");
			}
			return new ST("true");
		}

		@Override
		public boolean hasUserSemanticPredicate() {
			return false; // not user specified.
		}

		@Override
		public String toString() {
			return "true"; // not used for code gen, just DOT and print outs
		}
	}

	public static class FalsePredicate extends Predicate {
		public FalsePredicate() {
			super(FALSE_PRED);
		}

		@Override
		public ST genExpr(CodeGenerator generator,
									  STGroup templates,
									  DFA dfa)
		{
			if ( templates!=null ) {
				return templates.getInstanceOf("false");
			}
			return new ST("false");
		}

		@Override
		public boolean hasUserSemanticPredicate() {
			return false; // not user specified.
		}

		@Override
		public String toString() {
			return "false"; // not used for code gen, just DOT and print outs
		}
	}

	public static abstract class CommutativePredicate extends SemanticContext {
		protected final Set<SemanticContext> operands = new HashSet<SemanticContext>();
		protected int hashcode;

		public CommutativePredicate(SemanticContext a, SemanticContext b) {
			if (a.getClass() == this.getClass()){
				CommutativePredicate predicate = (CommutativePredicate)a;
				operands.addAll(predicate.operands);
			} else {
				operands.add(a);
			}

			if (b.getClass() == this.getClass()){
				CommutativePredicate predicate = (CommutativePredicate)b;
				operands.addAll(predicate.operands);
			} else {
				operands.add(b);
			}

			hashcode = calculateHashCode();
		}

		public CommutativePredicate(HashSet<SemanticContext> contexts){
			for (SemanticContext context : contexts){
				if (context.getClass() == this.getClass()){
					CommutativePredicate predicate = (CommutativePredicate)context;
					operands.addAll(predicate.operands);
				} else {
					operands.add(context);
				}
			}

			hashcode = calculateHashCode();
		}

		@Override
		public SemanticContext getGatedPredicateContext() {
			SemanticContext result = null;
			for (SemanticContext semctx : operands) {
				SemanticContext gatedPred = semctx.getGatedPredicateContext();
				if ( gatedPred!=null ) {
					result = combinePredicates(result, gatedPred);
				}
			}
			return result;
		}

		@Override
		public boolean hasUserSemanticPredicate() {
			for (SemanticContext semctx : operands) {
				if ( semctx.hasUserSemanticPredicate() ) {
					return true;
				}
			}
			return false;
		}

		@Override
		public boolean isSyntacticPredicate() {
			for (SemanticContext semctx : operands) {
				if ( semctx.isSyntacticPredicate() ) {
					return true;
				}
			}
			return false;
		}

		@Override
		public void trackUseOfSyntacticPredicates(Grammar g) {
			for (SemanticContext semctx : operands) {
				semctx.trackUseOfSyntacticPredicates(g);
			}
		}

		@Override
		public boolean equals(Object obj) {
			if (this == obj)
				return true;

			if (obj.getClass() == this.getClass()) {
				CommutativePredicate commutative = (CommutativePredicate)obj;
				Set<SemanticContext> otherOperands = commutative.operands;
				if (operands.size() != otherOperands.size())
					return false;

				return operands.containsAll(otherOperands);
			}

			if (obj instanceof NOT)
			{
				NOT not = (NOT)obj;
				if (not.ctx instanceof CommutativePredicate && not.ctx.getClass() != this.getClass()) {
					Set<SemanticContext> otherOperands = ((CommutativePredicate)not.ctx).operands;
					if (operands.size() != otherOperands.size())
						return false;

					ArrayList<SemanticContext> temp = new ArrayList<SemanticContext>(operands.size());
					for (SemanticContext context : otherOperands) {
						temp.add(not(context));
					}

					return operands.containsAll(temp);
				}
			}

			return false;
		}

		@Override
		public int hashCode(){
			return hashcode;
		}

		@Override
		public String toString() {
			StringBuffer buf = new StringBuffer();
			buf.append("(");
			int i = 0;
			for (SemanticContext semctx : operands) {
				if ( i>0 ) {
					buf.append(getOperandString());
				}
				buf.append(semctx.toString());
				i++;
			}
			buf.append(")");
			return buf.toString();
		}

		public abstract String getOperandString();

		public abstract SemanticContext combinePredicates(SemanticContext left, SemanticContext right);

		public abstract int calculateHashCode();
	}

	public static class AND extends CommutativePredicate {
		public AND(SemanticContext a, SemanticContext b) {
			super(a,b);
		}

		public AND(HashSet<SemanticContext> contexts) {
			super(contexts);
		}

		@Override
		public ST genExpr(CodeGenerator generator,
									  STGroup templates,
									  DFA dfa)
		{
			ST result = null;
			for (SemanticContext operand : operands) {
				if (result == null)
					result = operand.genExpr(generator, templates, dfa);

				ST eST = null;
				if ( templates!=null ) {
					eST = templates.getInstanceOf("andPredicates");
				}
				else {
					eST = new ST("(<left>&&<right>)");
				}
				eST.add("left", result);
				eST.add("right", operand.genExpr(generator,templates,dfa));
				result = eST;
			}

			return result;
		}

		@Override
		public String getOperandString() {
			return "&&";
		}

		@Override
		public SemanticContext combinePredicates(SemanticContext left, SemanticContext right) {
			return SemanticContext.and(left, right);
		}

		@Override
		public int calculateHashCode() {
			int hashcode = 0;
			for (SemanticContext context : operands) {
				hashcode = hashcode ^ context.hashCode();
			}

			return hashcode;
		}
	}

	public static class OR extends CommutativePredicate {
		public OR(SemanticContext a, SemanticContext b) {
			super(a,b);
		}

		public OR(HashSet<SemanticContext> contexts) {
			super(contexts);
		}

		@Override
		public ST genExpr(CodeGenerator generator,
									  STGroup templates,
									  DFA dfa)
		{
			ST eST = null;
			if ( templates!=null ) {
				eST = templates.getInstanceOf("orPredicates");
			}
			else {
				eST = new ST("(<first(operands)><rest(operands):{o | ||<o>}>)");
			}
			for (SemanticContext semctx : operands) {
				eST.add("operands", semctx.genExpr(generator,templates,dfa));
			}
			return eST;
		}

		@Override
		public String getOperandString() {
			return "||";
		}

		@Override
		public SemanticContext combinePredicates(SemanticContext left, SemanticContext right) {
			return SemanticContext.or(left, right);
		}

		@Override
		public int calculateHashCode() {
			int hashcode = 0;
			for (SemanticContext context : operands) {
				hashcode = ~hashcode ^ context.hashCode();
			}

			return hashcode;
		}
	}

	public static class NOT extends SemanticContext {
		protected SemanticContext ctx;
		public NOT(SemanticContext ctx) {
			this.ctx = ctx;
		}

		@Override
		public ST genExpr(CodeGenerator generator,
									  STGroup templates,
									  DFA dfa)
		{
			ST eST = null;
			if ( templates!=null ) {
				eST = templates.getInstanceOf("notPredicate");
			}
			else {
				eST = new ST("!(<pred>)");
			}
			eST.add("pred", ctx.genExpr(generator,templates,dfa));
			return eST;
		}

		@Override
		public SemanticContext getGatedPredicateContext() {
			SemanticContext p = ctx.getGatedPredicateContext();
			if ( p==null ) {
				return null;
			}
			return new NOT(p);
		}

		@Override
		public boolean hasUserSemanticPredicate() {
			return ctx.hasUserSemanticPredicate();
		}

		@Override
		public boolean isSyntacticPredicate() {
			return ctx.isSyntacticPredicate();
		}

		@Override
		public void trackUseOfSyntacticPredicates(Grammar g) {
			ctx.trackUseOfSyntacticPredicates(g);
		}

		@Override
		public boolean equals(Object object) {
			if ( !(object instanceof NOT) ) {
				return false;
			}
			return this.ctx.equals(((NOT)object).ctx);
		}

		@Override
		public int hashCode() {
			return ~ctx.hashCode();
		}

		@Override
		public String toString() {
			return "!("+ctx+")";
		}
	}

	public static SemanticContext and(SemanticContext a, SemanticContext b) {
		//System.out.println("AND: "+a+"&&"+b);
		SemanticContext[] terms = factorOr(a, b);
		SemanticContext commonTerms = terms[0];
		a = terms[1];
		b = terms[2];

		boolean factored = commonTerms != null && commonTerms != EMPTY_SEMANTIC_CONTEXT && !(commonTerms instanceof TruePredicate);
		if (factored) {
			return or(commonTerms, and(a, b));
		}
		
		//System.Console.Out.WriteLine( "AND: " + a + "&&" + b );
		if (a instanceof FalsePredicate || b instanceof FalsePredicate)
			return new FalsePredicate();

		if ( a==EMPTY_SEMANTIC_CONTEXT || a==null ) {
			return b;
		}
		if ( b==EMPTY_SEMANTIC_CONTEXT || b==null ) {
			return a;
		}

		if (a instanceof TruePredicate)
			return b;

		if (b instanceof TruePredicate)
			return a;

		//// Factoring takes care of this case
		//if (a.Equals(b))
		//    return a;

		//System.out.println("## have to AND");
		return new AND(a,b);
	}

	public static SemanticContext or(SemanticContext a, SemanticContext b) {
		//System.out.println("OR: "+a+"||"+b);
		SemanticContext[] terms = factorAnd(a, b);
		SemanticContext commonTerms = terms[0];
		a = terms[1];
		b = terms[2];
		boolean factored = commonTerms != null && commonTerms != EMPTY_SEMANTIC_CONTEXT && !(commonTerms instanceof FalsePredicate);
		if (factored) {
			return and(commonTerms, or(a, b));
		}

		if ( a==EMPTY_SEMANTIC_CONTEXT || a==null || a instanceof FalsePredicate ) {
			return b;
		}

		if ( b==EMPTY_SEMANTIC_CONTEXT || b==null || b instanceof FalsePredicate ) {
			return a;
		}

		if ( a instanceof TruePredicate || b instanceof TruePredicate || commonTerms instanceof TruePredicate ) {
			return new TruePredicate();
		}

		//// Factoring takes care of this case
		//if (a.equals(b))
		//    return a;

		if ( a instanceof NOT ) {
			NOT n = (NOT)a;
			// check for !p||p
			if ( n.ctx.equals(b) ) {
				return new TruePredicate();
			}
		}
		else if ( b instanceof NOT ) {
			NOT n = (NOT)b;
			// check for p||!p
			if ( n.ctx.equals(a) ) {
				return new TruePredicate();
			}
		}

		//System.out.println("## have to OR");
		OR result = new OR(a,b);
		if (result.operands.size() == 1)
			return result.operands.iterator().next();

		return result;
	}

	public static SemanticContext not(SemanticContext a) {
		if (a instanceof NOT) {
			return ((NOT)a).ctx;
		}

		if (a instanceof TruePredicate)
			return new FalsePredicate();
		else if (a instanceof FalsePredicate)
			return new TruePredicate();

		return new NOT(a);
	}

	// Factor so (a && b) == (result && a && b)
	public static SemanticContext[] factorAnd(SemanticContext a, SemanticContext b)
	{
		if (a == EMPTY_SEMANTIC_CONTEXT || a == null || a instanceof FalsePredicate)
			return new SemanticContext[] { EMPTY_SEMANTIC_CONTEXT, a, b };
		if (b == EMPTY_SEMANTIC_CONTEXT || b == null || b instanceof FalsePredicate)
			return new SemanticContext[] { EMPTY_SEMANTIC_CONTEXT, a, b };

		if (a instanceof TruePredicate || b instanceof TruePredicate)
		{
			return new SemanticContext[] { new TruePredicate(), EMPTY_SEMANTIC_CONTEXT, EMPTY_SEMANTIC_CONTEXT };
		}

		HashSet<SemanticContext> opsA = new HashSet<SemanticContext>(getAndOperands(a));
		HashSet<SemanticContext> opsB = new HashSet<SemanticContext>(getAndOperands(b));

		HashSet<SemanticContext> result = new HashSet<SemanticContext>(opsA);
		result.retainAll(opsB);
		if (result.size() == 0)
			return new SemanticContext[] { EMPTY_SEMANTIC_CONTEXT, a, b };

		opsA.removeAll(result);
		if (opsA.size() == 0)
			a = new TruePredicate();
		else if (opsA.size() == 1)
			a = opsA.iterator().next();
		else
			a = new AND(opsA);

		opsB.removeAll(result);
		if (opsB.size() == 0)
			b = new TruePredicate();
		else if (opsB.size() == 1)
			b = opsB.iterator().next();
		else
			b = new AND(opsB);

		if (result.size() == 1)
			return new SemanticContext[] { result.iterator().next(), a, b };

		return new SemanticContext[] { new AND(result), a, b };
	}

	// Factor so (a || b) == (result || a || b)
	public static SemanticContext[] factorOr(SemanticContext a, SemanticContext b)
	{
		HashSet<SemanticContext> opsA = new HashSet<SemanticContext>(getOrOperands(a));
		HashSet<SemanticContext> opsB = new HashSet<SemanticContext>(getOrOperands(b));

		HashSet<SemanticContext> result = new HashSet<SemanticContext>(opsA);
		result.retainAll(opsB);
		if (result.size() == 0)
			return new SemanticContext[] { EMPTY_SEMANTIC_CONTEXT, a, b };

		opsA.removeAll(result);
		if (opsA.size() == 0)
			a = new FalsePredicate();
		else if (opsA.size() == 1)
			a = opsA.iterator().next();
		else
			a = new OR(opsA);

		opsB.removeAll(result);
		if (opsB.size() == 0)
			b = new FalsePredicate();
		else if (opsB.size() == 1)
			b = opsB.iterator().next();
		else
			b = new OR(opsB);

		if (result.size() == 1)
			return new SemanticContext[] { result.iterator().next(), a, b };

		return new SemanticContext[] { new OR(result), a, b };
	}

	public static Collection<SemanticContext> getAndOperands(SemanticContext context)
	{
		if (context instanceof AND)
			return ((AND)context).operands;

		if (context instanceof NOT) {
			Collection<SemanticContext> operands = getOrOperands(((NOT)context).ctx);
			List<SemanticContext> result = new ArrayList<SemanticContext>(operands.size());
			for (SemanticContext operand : operands) {
				result.add(not(operand));
			}
			return result;
		}

		ArrayList<SemanticContext> result = new ArrayList<SemanticContext>();
		result.add(context);
		return result;
	}

	public static Collection<SemanticContext> getOrOperands(SemanticContext context)
	{
		if (context instanceof OR)
			return ((OR)context).operands;

		if (context instanceof NOT) {
			Collection<SemanticContext> operands = getAndOperands(((NOT)context).ctx);
			List<SemanticContext> result = new ArrayList<SemanticContext>(operands.size());
			for (SemanticContext operand : operands) {
				result.add(not(operand));
			}
			return result;
		}

		ArrayList<SemanticContext> result = new ArrayList<SemanticContext>();
		result.add(context);
		return result;
	}
}
