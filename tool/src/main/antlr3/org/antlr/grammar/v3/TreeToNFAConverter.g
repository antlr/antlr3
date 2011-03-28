/*
 [The "BSD license"]
 Copyright (c) 2005-2011 Terence Parr
 All rights reserved.

 Grammar conversion to ANTLR v3:
 Copyright (c) 2011 Sam Harwell
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

/** Build an NFA from a tree representing an ANTLR grammar. */
tree grammar TreeToNFAConverter;

options {
	tokenVocab = ANTLR;
	ASTLabelType = GrammarAST;
}

@header {
package org.antlr.grammar.v3;

import org.antlr.analysis.*;
import org.antlr.misc.*;
import org.antlr.tool.*;

import org.antlr.runtime.BitSet;
import org.antlr.runtime.DFA;
}

@members {
/** Factory used to create nodes and submachines */
protected NFAFactory factory = null;

/** Which NFA object are we filling in? */
protected NFA nfa = null;

/** Which grammar are we converting an NFA for? */
protected Grammar grammar = null;

protected String currentRuleName = null;

protected int outerAltNum = 0;
protected int blockLevel = 0;

protected int inTest = 0;

public TreeToNFAConverter(TreeNodeStream input, Grammar g, NFA nfa, NFAFactory factory) {
    this(input);
    this.grammar = g;
    this.nfa = nfa;
    this.factory = factory;
}

public final IntSet setRule(GrammarAST t) throws RecognitionException {
    TreeToNFAConverter other = new TreeToNFAConverter( new CommonTreeNodeStream( t ), grammar, nfa, factory );

    other.currentRuleName = currentRuleName;
    other.outerAltNum = outerAltNum;
    other.blockLevel = blockLevel;

    return other.setRule();
}

public final int testBlockAsSet( GrammarAST t ) throws RecognitionException {
    Rule r = grammar.getLocallyDefinedRule( currentRuleName );
    if ( r.hasRewrite( outerAltNum ) )
        return -1;

    TreeToNFAConverter other = new TreeToNFAConverter( new CommonTreeNodeStream( t ), grammar, nfa, factory );

    other.state.backtracking++;
    other.currentRuleName = currentRuleName;
    other.outerAltNum = outerAltNum;
    other.blockLevel = blockLevel;

    int result = other.testBlockAsSet();
    if ( other.state.failed )
        return -1;

    return result;
}

public final int testSetRule( GrammarAST t ) throws RecognitionException {
    TreeToNFAConverter other = new TreeToNFAConverter( new CommonTreeNodeStream( t ), grammar, nfa, factory );

    other.state.backtracking++;
    other.currentRuleName = currentRuleName;
    other.outerAltNum = outerAltNum;
    other.blockLevel = blockLevel;

    int result = other.testSetRule();
    if ( other.state.failed )
        state.failed = true;

    return result;
}

protected void addFollowTransition( String ruleName, NFAState following ) {
    //System.Console.Out.WriteLine( "adding follow link to rule " + ruleName );
    // find last link in FOLLOW chain emanating from rule
    Rule r = grammar.getRule( ruleName );
    NFAState end = r.stopState;
    while ( end.transition( 1 ) != null )
    {
        end = (NFAState)end.transition( 1 ).target;
    }
    if ( end.transition( 0 ) != null )
    {
        // already points to a following node
        // gotta add another node to keep edges to a max of 2
        NFAState n = factory.newState();
        Transition e = new Transition( Label.EPSILON, n );
        end.addTransition( e );
        end = n;
    }
    Transition followEdge = new Transition( Label.EPSILON, following );
    end.addTransition( followEdge );
}

protected void finish() {
    int numEntryPoints = factory.build_EOFStates( grammar.getRules() );
    if ( numEntryPoints == 0 )
    {
        ErrorManager.grammarWarning( ErrorManager.MSG_NO_GRAMMAR_START_RULE,
                                   grammar,
                                   null,
                                   grammar.name );
    }
}

@Override
public void reportError(RecognitionException ex) {
    if ( inTest > 0 )
        throw new IllegalStateException(ex);

    Token token = null;
    if ( ex instanceof MismatchedTokenException )
    {
        token = ( (MismatchedTokenException)ex ).token;
    }
    else if ( ex instanceof NoViableAltException )
    {
        token = ( (NoViableAltException)ex ).token;
    }

    ErrorManager.syntaxError(
        ErrorManager.MSG_SYNTAX_ERROR,
        grammar,
        token,
        "buildnfa: " + ex.toString(),
        ex );
}

private boolean hasElementOptions(GrammarAST node) {
    if (node == null)
        throw new NullPointerException("node");
    return node.terminalOptions != null && node.terminalOptions.size() > 0;
}
}

public
grammar_
@after
{
	finish();
}
	:	(	^( LEXER_GRAMMAR grammarSpec )
		|	^( PARSER_GRAMMAR grammarSpec )
		|	^( TREE_GRAMMAR grammarSpec )
		|	^( COMBINED_GRAMMAR grammarSpec )
		)
	;

attrScope
	:	^( 'scope' ID ( ^(AMPERSAND .*) )* ACTION )
	;

grammarSpec
	:	ID
		(cmt=DOC_COMMENT)?
		( ^(OPTIONS .*) )?
		( ^(IMPORT .*) )?
		( ^(TOKENS .*) )?
		(attrScope)*
		( ^(AMPERSAND .*) )* // skip actions
		rules
	;

rules
	:	(rule | ^(PREC_RULE .*))+
	;

rule
	:	^(	RULE id=ID
			{
				currentRuleName = $id.text;
				factory.setCurrentRule(grammar.getLocallyDefinedRule(currentRuleName));
			}
			(modifier)?
			^(ARG (ARG_ACTION)?)
			^(RET (ARG_ACTION)?)
			(throwsSpec)?
			( ^(OPTIONS .*) )?
			( ruleScopeSpec )?
			( ^(AMPERSAND .*) )*
			b=block
			(exceptionGroup)?
			EOR
			{
				StateCluster g = $b.g;
				if ($b.start.getSetValue() != null)
				{
					// if block comes back as a set not BLOCK, make it
					// a single ALT block
					g = factory.build_AlternativeBlockFromSet(g);
				}
				if (Rule.getRuleType(currentRuleName) == Grammar.PARSER || grammar.type==Grammar.LEXER)
				{
					// attach start node to block for this rule
					Rule thisR = grammar.getLocallyDefinedRule(currentRuleName);
					NFAState start = thisR.startState;
					start.associatedASTNode = $id;
					start.addTransition(new Transition(Label.EPSILON, g.left));

					// track decision if > 1 alts
					if ( grammar.getNumberOfAltsForDecisionNFA(g.left)>1 )
					{
						g.left.setDescription(grammar.grammarTreeToString($start, false));
						g.left.setDecisionASTNode($b.start);
						int d = grammar.assignDecisionNumber( g.left );
						grammar.setDecisionNFA( d, g.left );
						grammar.setDecisionBlockAST(d, $b.start);
					}

					// hook to end of rule node
					NFAState end = thisR.stopState;
					g.right.addTransition(new Transition(Label.EPSILON,end));
				}
			}
		)
	;

modifier
	:	'protected'
	|	'public'
	|	'private'
	|	'fragment'
	;

throwsSpec
	:	^('throws' ID+)
	;

ruleScopeSpec
	:	^( 'scope' ( ^(AMPERSAND .*) )* (ACTION)? ( ID )* )
	;

block returns [StateCluster g = null]
@init
{
	List<StateCluster> alts = new ArrayList<StateCluster>();
	this.blockLevel++;
	if ( this.blockLevel==1 )
		this.outerAltNum=1;
}
	:	{grammar.isValidSet(this,$start) &&
		 !currentRuleName.equals(Grammar.ARTIFICIAL_TOKENS_RULENAME)}? =>
		set {$g = $set.g;}

	|	^(	BLOCK ( ^(OPTIONS .*) )?
			(	a=alternative rewrite
				{
					alts.add($a.g);
				}
				{{
					if ( blockLevel == 1 )
						outerAltNum++;
				}}
			)+
			EOB
		)
		{$g = factory.build_AlternativeBlock(alts);}
	;
finally { blockLevel--; }

alternative returns [StateCluster g=null]
	:	^( ALT (e=element {$g = factory.build_AB($g,$e.g);} )+ EOA )
		{
			if ($g==null) { // if alt was a list of actions or whatever
				$g = factory.build_Epsilon();
			}
			else {
				factory.optimizeAlternative($g);
			}
		}
	;

exceptionGroup
	:	( exceptionHandler )+ (finallyClause)?
	|	finallyClause
	;

exceptionHandler
	:    ^('catch' ARG_ACTION ACTION)
	;

finallyClause
	:    ^('finally' ACTION)
	;

rewrite
	:	^(	REWRITES
			(
				{
					if ( grammar.getOption("output")==null )
					{
						ErrorManager.grammarError(ErrorManager.MSG_REWRITE_OR_OP_WITH_NO_OUTPUT_OPTION,
												  grammar, $start.getToken(), currentRuleName);
					}
				}
				^(REWRITE .*)
			)*
		)
	|
	;

element returns [StateCluster g=null]
	:   ^(ROOT e=element {$g = $e.g;})
	|   ^(BANG e=element {$g = $e.g;})
	|	^(ASSIGN ID e=element {$g = $e.g;})
	|	^(PLUS_ASSIGN ID e=element {$g = $e.g;})
	|   ^(RANGE a=atom[null] b=atom[null])
		{$g = factory.build_Range(grammar.getTokenType($a.text),
								 grammar.getTokenType($b.text));}
	|   ^(CHAR_RANGE c1=CHAR_LITERAL c2=CHAR_LITERAL)
		{
		if ( grammar.type==Grammar.LEXER ) {
			$g = factory.build_CharRange($c1.text, $c2.text);
		}
		}
	|   atom_or_notatom {$g = $atom_or_notatom.g;}
	|   ebnf {$g = $ebnf.g;}
	|   tree_ {$g = $tree_.g;}
	|   ^( SYNPRED block )
	|   ACTION {$g = factory.build_Action($ACTION);}
	|   FORCED_ACTION {$g = factory.build_Action($FORCED_ACTION);}
	|   pred=SEMPRED {$g = factory.build_SemanticPredicate($pred);}
	|   spred=SYN_SEMPRED {$g = factory.build_SemanticPredicate($spred);}
	|   ^(bpred=BACKTRACK_SEMPRED .*) {$g = factory.build_SemanticPredicate($bpred);}
	|   gpred=GATED_SEMPRED {$g = factory.build_SemanticPredicate($gpred);}
	|   EPSILON {$g = factory.build_Epsilon();}
	;

ebnf returns [StateCluster g=null]
@init
{
	GrammarAST blk = $start;
	if (blk.getType() != BLOCK) {
		blk = (GrammarAST)blk.getChild(0);
	}
	GrammarAST eob = blk.getLastChild();
}
	:	{grammar.isValidSet(this,$start)}? => set {$g = $set.g;}

	|	b=block
		{
			// track decision if > 1 alts
			if ( grammar.getNumberOfAltsForDecisionNFA($b.g.left)>1 )
			{
				$b.g.left.setDescription(grammar.grammarTreeToString(blk, false));
				$b.g.left.setDecisionASTNode(blk);
				int d = grammar.assignDecisionNumber( $b.g.left );
				grammar.setDecisionNFA( d, $b.g.left );
				grammar.setDecisionBlockAST(d, blk);
			}
			$g = $b.g;
		}
	|	^( OPTIONAL b=block )
		{
			StateCluster bg = $b.g;
			if ( blk.getSetValue()!=null )
			{
				// if block comes back SET not BLOCK, make it
				// a single ALT block
				bg = factory.build_AlternativeBlockFromSet(bg);
			}
			$g = factory.build_Aoptional(bg);
			$g.left.setDescription(grammar.grammarTreeToString($start, false));
			// there is always at least one alt even if block has just 1 alt
			int d = grammar.assignDecisionNumber( $g.left );
			grammar.setDecisionNFA(d, $g.left);
			grammar.setDecisionBlockAST(d, blk);
			$g.left.setDecisionASTNode($start);
		}
	|	^( CLOSURE b=block )
		{
			StateCluster bg = $b.g;
			if ( blk.getSetValue()!=null )
			{
				bg = factory.build_AlternativeBlockFromSet(bg);
			}
			$g = factory.build_Astar(bg);
			// track the loop back / exit decision point
			bg.right.setDescription("()* loopback of "+grammar.grammarTreeToString($start, false));
			int d = grammar.assignDecisionNumber( bg.right );
			grammar.setDecisionNFA(d, bg.right);
			grammar.setDecisionBlockAST(d, blk);
			bg.right.setDecisionASTNode(eob);
			// make block entry state also have same decision for interpreting grammar
			NFAState altBlockState = (NFAState)$g.left.transition(0).target;
			altBlockState.setDecisionASTNode($start);
			altBlockState.setDecisionNumber(d);
			$g.left.setDecisionNumber(d); // this is the bypass decision (2 alts)
			$g.left.setDecisionASTNode($start);
		}
	|	^( POSITIVE_CLOSURE b=block )
		{
			StateCluster bg = $b.g;
			if ( blk.getSetValue()!=null )
			{
				bg = factory.build_AlternativeBlockFromSet(bg);
			}
			$g = factory.build_Aplus(bg);
			// don't make a decision on left edge, can reuse loop end decision
			// track the loop back / exit decision point
			bg.right.setDescription("()+ loopback of "+grammar.grammarTreeToString($start, false));
			int d = grammar.assignDecisionNumber( bg.right );
			grammar.setDecisionNFA(d, bg.right);
			grammar.setDecisionBlockAST(d, blk);
			bg.right.setDecisionASTNode(eob);
			// make block entry state also have same decision for interpreting grammar
			NFAState altBlockState = (NFAState)$g.left.transition(0).target;
			altBlockState.setDecisionASTNode($start);
			altBlockState.setDecisionNumber(d);
		}
	;

tree_ returns [StateCluster g=null]
@init
{
	StateCluster down=null, up=null;
}
	:	^(	TREE_BEGIN
			e=element { $g = $e.g; }
			{
				down = factory.build_Atom(Label.DOWN, $e.start);
				// TODO set following states for imaginary nodes?
				//el.followingNFAState = down.right;
				$g = factory.build_AB($g,down);
			}
			( e=element {$g = factory.build_AB($g,$e.g);} )*
			{
				up = factory.build_Atom(Label.UP, $e.start);
				//el.followingNFAState = up.right;
				$g = factory.build_AB($g,up);
				// tree roots point at right edge of DOWN for LOOK computation later
				$start.NFATreeDownState = down.left;
			}
		)
	;

atom_or_notatom returns [StateCluster g=null]
	:	atom[null] {$g = $atom.g;}
	|	^(	n=NOT
			(	c=CHAR_LITERAL (ast1=ast_suffix)?
				{
					int ttype=0;
					if ( grammar.type==Grammar.LEXER )
					{
						ttype = Grammar.getCharValueFromGrammarCharLiteral($c.text);
					}
					else
					{
						ttype = grammar.getTokenType($c.text);
					}
					IntSet notAtom = grammar.complement(ttype);
					if ( notAtom.isNil() )
					{
						ErrorManager.grammarError(
							ErrorManager.MSG_EMPTY_COMPLEMENT,
							grammar,
							$c.getToken(),
							$c.text);
					}
					$g=factory.build_Set(notAtom,$n);
				}
			|	t=TOKEN_REF (ast3=ast_suffix)?
				{
					int ttype=0;
					IntSet notAtom = null;
					if ( grammar.type==Grammar.LEXER )
					{
						notAtom = grammar.getSetFromRule(this,$t.text);
						if ( notAtom==null )
						{
							ErrorManager.grammarError(
								ErrorManager.MSG_RULE_INVALID_SET,
								grammar,
								$t.getToken(),
								$t.text);
						}
						else
						{
							notAtom = grammar.complement(notAtom);
						}
					}
					else
					{
						ttype = grammar.getTokenType($t.text);
						notAtom = grammar.complement(ttype);
					}
					if ( notAtom==null || notAtom.isNil() )
					{
						ErrorManager.grammarError(
							ErrorManager.MSG_EMPTY_COMPLEMENT,
							grammar,
							$t.getToken(),
							$t.text);
					}
					$g=factory.build_Set(notAtom,$n);
				}
			|	set {$g = $set.g;}
				{
					GrammarAST stNode = (GrammarAST)$n.getChild(0);
					//IntSet notSet = grammar.complement(stNode.getSetValue());
					// let code generator complement the sets
					IntSet s = stNode.getSetValue();
					stNode.setSetValue(s);
					// let code gen do the complement again; here we compute
					// for NFA construction
					s = grammar.complement(s);
					if ( s.isNil() )
					{
						ErrorManager.grammarError(
							ErrorManager.MSG_EMPTY_COMPLEMENT,
							grammar,
							$n.getToken());
					}
					$g=factory.build_Set(s,$n);
				}
			)
			{$n.followingNFAState = $g.right;}
		)
	;

atom[String scopeName] returns [StateCluster g=null]
	:	^( r=RULE_REF (rarg=ARG_ACTION)? (as1=ast_suffix)? )
		{
			NFAState start = grammar.getRuleStartState(scopeName,$r.text);
			if ( start!=null )
			{
				Rule rr = grammar.getRule(scopeName,$r.text);
				$g = factory.build_RuleRef(rr, start);
				r.followingNFAState = $g.right;
				r.NFAStartState = $g.left;
				if ( $g.left.transition(0) instanceof RuleClosureTransition
					&& grammar.type!=Grammar.LEXER )
				{
					addFollowTransition($r.text, $g.right);
				}
				// else rule ref got inlined to a set
			}
		}

	|	^( t=TOKEN_REF  (targ=ARG_ACTION)? (as2=ast_suffix)? )
		{
			if ( grammar.type==Grammar.LEXER )
			{
				NFAState start = grammar.getRuleStartState(scopeName,$t.text);
				if ( start!=null )
				{
					Rule rr = grammar.getRule(scopeName,t.getText());
					$g = factory.build_RuleRef(rr, start);
					t.NFAStartState = $g.left;
					// don't add FOLLOW transitions in the lexer;
					// only exact context should be used.
				}
			}
			else
			{
				$g = factory.build_Atom(t);
				t.followingNFAState = $g.right;
			}
		}

	|	^( c=CHAR_LITERAL  (as3=ast_suffix)? )
		{
			if ( grammar.type==Grammar.LEXER )
			{
				$g = factory.build_CharLiteralAtom(c);
			}
			else
			{
				$g = factory.build_Atom(c);
				c.followingNFAState = $g.right;
			}
		}

	|	^( s=STRING_LITERAL  (as4=ast_suffix)? )
		{
			if ( grammar.type==Grammar.LEXER )
			{
				$g = factory.build_StringLiteralAtom(s);
			}
			else
			{
				$g = factory.build_Atom(s);
				s.followingNFAState = $g.right;
			}
		}

	|	^(	w=WILDCARD (as5=ast_suffix)? )
			{
				if ( nfa.grammar.type == Grammar.TREE_PARSER
					&& (w.getChildIndex() > 0 || w.getParent().getChild(1).getType() == EOA) )
				{
					$g = factory.build_WildcardTree( $w );
				}
				else
				{
					$g = factory.build_Wildcard( $w );
				}
			}

	|	^( DOT scope_=ID a=atom[$scope_.text] {$g = $a.g;} ) // scope override
	;

ast_suffix
	:	ROOT
	|	BANG
	;

set returns [StateCluster g=null]
@init
{
	IntSet elements=new IntervalSet();
	if ( state.backtracking == 0 )
		$start.setSetValue(elements); // track set for use by code gen
}
	:	^( b=BLOCK
		   (^(ALT ( ^(BACKTRACK_SEMPRED .*) )? setElement[elements] EOA))+
		   EOB
		 )
		{
		$g = factory.build_Set(elements,$b);
		$b.followingNFAState = $g.right;
		$b.setSetValue(elements); // track set value of this block
		}
		//{System.out.println("set elements="+elements.toString(grammar));}
	;

setRule returns [IntSet elements=new IntervalSet()]
@init
{
	IntSet s=null;
}
	:	^( RULE id=ID (modifier)? ARG RET ( ^(OPTIONS .*) )? ( ruleScopeSpec )?
			( ^(AMPERSAND .*) )*
			^( BLOCK ( ^(OPTIONS .*) )?
			   ( ^(ALT (BACKTRACK_SEMPRED)? setElement[elements] EOA) )+
			   EOB
			 )
			(exceptionGroup)?
			EOR
		 )
	;
catch[RecognitionException re] { throw re; }

setElement[IntSet elements]
@init
{
	int ttype;
	IntSet ns=null;
}
	:	c=CHAR_LITERAL
		{
			if ( grammar.type==Grammar.LEXER )
			{
				ttype = Grammar.getCharValueFromGrammarCharLiteral($c.text);
			}
			else
			{
				ttype = grammar.getTokenType($c.text);
			}
			if ( elements.member(ttype) )
			{
				ErrorManager.grammarError(
					ErrorManager.MSG_DUPLICATE_SET_ENTRY,
					grammar,
					$c.getToken(),
					$c.text);
			}
			elements.add(ttype);
		}
	|	t=TOKEN_REF
		{
			if ( grammar.type==Grammar.LEXER )
			{
				// recursively will invoke this rule to match elements in target rule ref
				IntSet ruleSet = grammar.getSetFromRule(this,$t.text);
				if ( ruleSet==null )
				{
					ErrorManager.grammarError(
						ErrorManager.MSG_RULE_INVALID_SET,
						grammar,
						$t.getToken(),
						$t.text);
				}
				else
				{
					elements.addAll(ruleSet);
				}
			}
			else
			{
				ttype = grammar.getTokenType($t.text);
				if ( elements.member(ttype) )
				{
					ErrorManager.grammarError(
						ErrorManager.MSG_DUPLICATE_SET_ENTRY,
						grammar,
						$t.getToken(),
						$t.text);
				}
				elements.add(ttype);
			}
		}

	|	s=STRING_LITERAL
		{
			ttype = grammar.getTokenType($s.text);
			if ( elements.member(ttype) )
			{
				ErrorManager.grammarError(
					ErrorManager.MSG_DUPLICATE_SET_ENTRY,
					grammar,
					$s.getToken(),
					$s.text);
			}
			elements.add(ttype);
		}
	|	^(CHAR_RANGE c1=CHAR_LITERAL c2=CHAR_LITERAL)
		{
			if ( grammar.type==Grammar.LEXER )
			{
				int a = Grammar.getCharValueFromGrammarCharLiteral($c1.text);
				int b = Grammar.getCharValueFromGrammarCharLiteral($c2.text);
				elements.addAll(IntervalSet.of(a,b));
			}
		}

	|	gset=set
		{
			Transition setTrans = $gset.g.left.transition(0);
			elements.addAll(setTrans.label.getSet());
		}

	|	^(	NOT {ns=new IntervalSet();}
			setElement[ns]
			{
				IntSet not = grammar.complement(ns);
				elements.addAll(not);
			}
		)
	;

/** Check to see if this block can be a set.  Can't have actions
 *  etc...  Also can't be in a rule with a rewrite as we need
 *  to track what's inside set for use in rewrite.
 *
 *  This should only be called from the helper function in TreeToNFAConverterHelper.cs
 *  and from the rule testSetElement below.
 */
testBlockAsSet returns [int alts=0]
options { backtrack = true; }
@init
{
	inTest++;
}
	:	^(	BLOCK
			(	^(ALT (BACKTRACK_SEMPRED)? testSetElement {{$alts += $testSetElement.alts;}} EOA)
			)+
			EOB
		)
	;
catch[RecognitionException re] { throw re; }
finally { inTest--; }

testSetRule returns [int alts=0]
@init
{
	inTest++;
}
	:	^(	RULE id=ID (modifier)? ARG RET ( ^(OPTIONS .*) )? ( ruleScopeSpec )?
			( ^(AMPERSAND .*) )*
			^(	BLOCK
				(	^(ALT (BACKTRACK_SEMPRED)? testSetElement {{$alts += $testSetElement.alts;}} EOA)
				)+
				EOB
			)
			(exceptionGroup)?
			EOR
		)
	;
catch[RecognitionException re] { throw re; }
finally { inTest--; }

/** Match just an element; no ast suffix etc.. */
testSetElement returns [int alts=1]
	:	c=CHAR_LITERAL {!hasElementOptions($c)}?
	|	t=TOKEN_REF {!hasElementOptions($t)}?
		{{
			if ( grammar.type==Grammar.LEXER )
			{
				Rule rule = grammar.getRule($t.text);
				if ( rule==null )
				{
					//throw new RecognitionException("invalid rule");
					throw new RecognitionException();
				}
				// recursively will invoke this rule to match elements in target rule ref
				$alts += testSetRule(rule.tree);
			}
		}}
	|   {grammar.type!=Grammar.LEXER}? => s=STRING_LITERAL
	|	^(CHAR_RANGE c1=CHAR_LITERAL c2=CHAR_LITERAL)
		{{ $alts = IntervalSet.of( Grammar.getCharValueFromGrammarCharLiteral($c1.text), Grammar.getCharValueFromGrammarCharLiteral($c2.text) ).size(); }}
	|   testBlockAsSet
		{{ $alts = $testBlockAsSet.alts; }}
	|   ^( NOT tse=testSetElement )
		{{ $alts = grammar.getTokenTypes().size() - $tse.alts; }}
	;
catch[RecognitionException re] { throw re; }
