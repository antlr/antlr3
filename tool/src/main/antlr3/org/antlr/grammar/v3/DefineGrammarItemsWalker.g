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
tree grammar DefineGrammarItemsWalker;

options {
	tokenVocab = ANTLR;
	ASTLabelType = GrammarAST;
}

scope AttributeScopeActions {
	HashMap<GrammarAST, GrammarAST> actions;
}

@header {
package org.antlr.grammar.v3;
import org.antlr.tool.*;
import java.util.HashSet;
import java.util.Set;
}

@members {
protected Grammar grammar;
protected GrammarAST root;
protected String currentRuleName;
protected GrammarAST currentRewriteBlock;
protected GrammarAST currentRewriteRule;
protected int outerAltNum = 0;
protected int blockLevel = 0;

public final int countAltsForRule( CommonTree t ) {
    CommonTree block = (CommonTree)t.getFirstChildWithType(BLOCK);
    int altCount = 0;
    for (int i = 0; i < block.getChildCount(); i++) {
        if (block.getChild(i).getType() == ALT)
            altCount++;
    }
    return altCount;
}

protected final void finish() {
    trimGrammar();
}

/** Remove any lexer rules from a COMBINED; already passed to lexer */
protected final void trimGrammar() {
    if ( grammar.type != Grammar.COMBINED ) {
        return;
    }
    // form is (header ... ) ( grammar ID (scope ...) ... ( rule ... ) ( rule ... ) ... )
    GrammarAST p = root;
    // find the grammar spec
    while ( !p.getText().equals( "grammar" ) ) {
        p = (GrammarAST)p.getNextSibling();
    }
    for ( int i = 0; i < p.getChildCount(); i++ ) {
        if ( p.getChild( i ).getType() != RULE )
            continue;

        String ruleName = p.getChild(i).getChild(0).getText();
        //Console.Out.WriteLine( "rule " + ruleName + " prev=" + prev.getText() );
        if (Rule.getRuleType(ruleName) == Grammar.LEXER) {
            // remove lexer rule
            p.deleteChild( i );
            i--;
        }
    }
    //Console.Out.WriteLine( "root after removal is: " + root.ToStringList() );
}

protected final void trackInlineAction( GrammarAST actionAST ) {
    Rule r = grammar.getRule( currentRuleName );
    if ( r != null ) {
        r.trackInlineAction( actionAST );
    }
}
}

public
grammar_[Grammar g]
@init
{
grammar = $g;
root = $start;
}
@after
{
finish();
}
	:	^( LEXER_GRAMMAR	{grammar.type = Grammar.LEXER;} 		grammarSpec )
	|	^( PARSER_GRAMMAR	{grammar.type = Grammar.PARSER;}		grammarSpec )
	|	^( TREE_GRAMMAR		{grammar.type = Grammar.TREE_PARSER;}	grammarSpec )
	|	^( COMBINED_GRAMMAR	{grammar.type = Grammar.COMBINED;}		grammarSpec )
	;

attrScope
scope AttributeScopeActions;
@init
{
	$AttributeScopeActions::actions = new HashMap<GrammarAST, GrammarAST>();
}
	:	^( 'scope' name=ID attrScopeAction* attrs=ACTION )
		{
			AttributeScope scope = grammar.defineGlobalScope($name.text,$attrs.getToken());
			scope.isDynamicGlobalScope = true;
			scope.addAttributes($attrs.text, ';');
			for (GrammarAST action : $AttributeScopeActions::actions.keySet())
				scope.defineNamedAction(action, $AttributeScopeActions::actions.get(action));
		}
	;

attrScopeAction
	:	^(AMPERSAND ID ACTION)
		{
			$AttributeScopeActions::actions.put( $ID, $ACTION );
		}
	;

grammarSpec
	:	id=ID
		(cmt=DOC_COMMENT)?
		( optionsSpec )?
		(delegateGrammars)?
		(tokensSpec)?
		(attrScope)*
		(actions)?
		rules
	;

actions
	:	( action )+
	;

action
@init
{
	String scope=null;
	GrammarAST nameAST=null, actionAST=null;
}
	:	^(amp=AMPERSAND id1=ID
			( id2=ID a1=ACTION
			  {scope=$id1.text; nameAST=$id2; actionAST=$a1;}
			| a2=ACTION
			  {scope=null; nameAST=$id1; actionAST=$a2;}
			)
		 )
		 {
		 grammar.defineNamedAction($amp,scope,nameAST,actionAST);
		 }
	;

optionsSpec
	:	^(OPTIONS .*)
	;

delegateGrammars
	:	^( 'import' ( ^(ASSIGN ID ID) | ID )+ )
	;

tokensSpec
	:	^(TOKENS tokenSpec*)
	;

tokenSpec
	:	t=TOKEN_REF
	|	^(	ASSIGN
			TOKEN_REF
			(	STRING_LITERAL
			|	CHAR_LITERAL
			)
		 )
	;

rules
	:	(rule | ^(PREC_RULE .*))+
	;

rule
@init
{
	String name=null;
	Map<String, Object> opts=null;
	Rule r = null;
}
	:		^( RULE id=ID {opts = $RULE.getBlockOptions();}
			(modifier)?
			^( ARG (args=ARG_ACTION)? )
			^( RET (ret=ARG_ACTION)? )
			(throwsSpec)?
			(optionsSpec)?
			{
				name = $id.text;
				currentRuleName = name;
				if ( Rule.getRuleType(name) == Grammar.LEXER && grammar.type==Grammar.COMBINED )
				{
					// a merged grammar spec, track lexer rules and send to another grammar
					grammar.defineLexerRuleFoundInParser($id.getToken(), $start);
				}
				else
				{
					int numAlts = countAltsForRule($start);
					grammar.defineRule($id.getToken(), $modifier.mod, opts, $start, $args, numAlts);
					r = grammar.getRule(name);
					if ( $args!=null )
					{
						r.parameterScope = grammar.createParameterScope(name,$args.getToken());
						r.parameterScope.addAttributes($args.text, ',');
					}
					if ( $ret!=null )
					{
						r.returnScope = grammar.createReturnScope(name,$ret.getToken());
						r.returnScope.addAttributes($ret.text, ',');
					}
					if ( $throwsSpec.exceptions != null )
					{
						for (String exception : $throwsSpec.exceptions)
							r.throwsSpec.add( exception );
					}
				}
			}
			(ruleScopeSpec[r])?
			(ruleAction[r])*
			{ this.blockLevel=0; }
			b=block
			(exceptionGroup)?
			EOR
			{
				// copy rule options into the block AST, which is where
				// the analysis will look for k option etc...
				$b.start.setBlockOptions(opts);
			}
		)
	;

ruleAction[Rule r]
	:	^(amp=AMPERSAND id=ID a=ACTION ) {if (r!=null) r.defineNamedAction($amp,$id,$a);}
	;

modifier returns [String mod]
@init
{
	$mod = $start.getToken().getText();
}
	:	'protected'
	|	'public'
	|	'private'
	|	'fragment'
	;

throwsSpec returns [HashSet<String> exceptions]
@init
{
	$exceptions = new HashSet<String>();
}
	:	^('throws' (ID {$exceptions.add($ID.text);})+ )
	;

ruleScopeSpec[Rule r]
scope AttributeScopeActions;
@init
{
	$AttributeScopeActions::actions = new HashMap<GrammarAST, GrammarAST>();
}
	:	^(	'scope'
			(	attrScopeAction* attrs=ACTION
				{
					r.ruleScope = grammar.createRuleScope(r.name,$attrs.getToken());
					r.ruleScope.isDynamicRuleScope = true;
					r.ruleScope.addAttributes($attrs.text, ';');
					for (GrammarAST action : $AttributeScopeActions::actions.keySet())
						r.ruleScope.defineNamedAction(action, $AttributeScopeActions::actions.get(action));
				}
			)?
			(	uses=ID
				{
					if ( grammar.getGlobalScope($uses.text)==null ) {
					ErrorManager.grammarError(ErrorManager.MSG_UNKNOWN_DYNAMIC_SCOPE,
					grammar,
					$uses.getToken(),
					$uses.text);
					}
					else {
					if ( r.useScopes==null ) {r.useScopes=new ArrayList<String>();}
					r.useScopes.add($uses.text);
					}
				}
			)*
		)
	;

block
@init
{
	// must run during backtracking
	this.blockLevel++;
	if ( blockLevel == 1 )
		this.outerAltNum=1;
}
	:	^(	BLOCK
			(optionsSpec)?
			(blockAction)*
			(	alternative rewrite
				{{
					if ( this.blockLevel == 1 )
						this.outerAltNum++;
				}}
			)+
			EOB
		 )
	;
finally { blockLevel--; }

// TODO: this does nothing now! subrules cannot have init actions. :(
blockAction
	:	^(amp=AMPERSAND id=ID a=ACTION ) // {r.defineAction(#amp,#id,#a);}
	;

alternative
//@init
//{
//	if ( state.backtracking == 0 )
//	{
//		if ( grammar.type!=Grammar.LEXER && grammar.GetOption("output")!=null && blockLevel==1 )
//		{
//			GrammarAST aRewriteNode = $start.FindFirstType(REWRITE); // alt itself has rewrite?
//			GrammarAST rewriteAST = (GrammarAST)$start.Parent.getChild($start.ChildIndex + 1);
//			// we have a rewrite if alt uses it inside subrule or this alt has one
//			// but don't count -> ... rewrites, which mean "do default auto construction"
//			if ( aRewriteNode!=null||
//				 (firstRewriteAST!=null &&
//				  firstRewriteAST.getType()==REWRITE &&
//				  firstRewriteAST.getChild(0)!=null &&
//				  firstRewriteAST.getChild(0).getType()!=ETC) )
//			{
//				Rule r = grammar.getRule(currentRuleName);
//				r.TrackAltsWithRewrites($start,this.outerAltNum);
//			}
//		}
//	}
//}
	:	^( ALT (element)+ EOA )
	;

exceptionGroup
	:	( exceptionHandler )+ (finallyClause)?
	|	finallyClause
	;

exceptionHandler
	:   ^('catch' ARG_ACTION ACTION) {trackInlineAction($ACTION);}
	;

finallyClause
	:    ^('finally' ACTION) {trackInlineAction($ACTION);}
	;

element
	:   ^(ROOT element)
	|   ^(BANG element)
	|   atom[null]
	|   ^(NOT element)
	|   ^(RANGE atom[null] atom[null])
	|   ^(CHAR_RANGE atom[null] atom[null])
	|	^(	ASSIGN id=ID el=element)
			{
				GrammarAST e = $el.start;
				if ( e.getType()==ANTLRParser.ROOT || e.getType()==ANTLRParser.BANG )
				{
					e = (GrammarAST)e.getChild(0);
				}
				if ( e.getType()==RULE_REF)
				{
					grammar.defineRuleRefLabel(currentRuleName,$id.getToken(),e);
				}
				else if ( e.getType()==WILDCARD && grammar.type==Grammar.TREE_PARSER )
				{
					grammar.defineWildcardTreeLabel(currentRuleName,$id.getToken(),e);
				}
				else
				{
					grammar.defineTokenRefLabel(currentRuleName,$id.getToken(),e);
				}
			}
	|	^(	PLUS_ASSIGN id2=ID a2=element
			{
				GrammarAST a = $a2.start;
				if ( a.getType()==ANTLRParser.ROOT || a.getType()==ANTLRParser.BANG )
				{
					a = (GrammarAST)a.getChild(0);
				}
				if ( a.getType()==RULE_REF )
				{
					grammar.defineRuleListLabel(currentRuleName,$id2.getToken(),a);
				}
				else if ( a.getType() == WILDCARD && grammar.type == Grammar.TREE_PARSER )
				{
					grammar.defineWildcardTreeListLabel( currentRuleName, $id2.getToken(), a );
				}
				else
				{
					grammar.defineTokenListLabel(currentRuleName,$id2.getToken(),a);
				}
			}
		 )
	|   ebnf
	|   tree_
	|   ^( SYNPRED block )
	|   act=ACTION
		{
			$act.outerAltNum = this.outerAltNum;
			trackInlineAction($act);
		}
	|   act2=FORCED_ACTION
		{
			$act2.outerAltNum = this.outerAltNum;
			trackInlineAction($act2);
		}
	|   SEMPRED
		{
			$SEMPRED.outerAltNum = this.outerAltNum;
			trackInlineAction($SEMPRED);
		}
	|   SYN_SEMPRED
	|   ^(BACKTRACK_SEMPRED .*)
	|   GATED_SEMPRED
		{
			$GATED_SEMPRED.outerAltNum = this.outerAltNum;
			trackInlineAction($GATED_SEMPRED);
		}
	|   EPSILON 
	;

ebnf
	:	(dotLoop) => dotLoop // .* or .+
	|	block
	|	^( OPTIONAL block )
	|	^( CLOSURE block )
	|	^( POSITIVE_CLOSURE block )
	;

/** Track the .* and .+ idioms and make them nongreedy by default.
 */
dotLoop
	:	(	^( CLOSURE dotBlock )
		|	^( POSITIVE_CLOSURE dotBlock )
		)
		{
			GrammarAST block = (GrammarAST)$start.getChild(0);
			Map<String, Object> opts = new HashMap<String, Object>();
			opts.put("greedy", "false");
			if ( grammar.type!=Grammar.LEXER )
			{
				// parser grammars assume k=1 for .* loops
				// otherwise they (analysis?) look til EOF!
				opts.put("k", 1);
			}
			block.setOptions(grammar,opts);
		}
	;

dotBlock
	:	^( BLOCK ^( ALT WILDCARD EOA ) EOB )
	;

tree_
	:	^(TREE_BEGIN element+)
	;

atom[GrammarAST scope_]
	:	^( rr=RULE_REF (rarg=ARG_ACTION)? )
		{
			grammar.altReferencesRule( currentRuleName, $scope_, $rr, this.outerAltNum );
			if ( $rarg != null )
			{
				$rarg.outerAltNum = this.outerAltNum;
				trackInlineAction($rarg);
			}
		}
	|	^( t=TOKEN_REF (targ=ARG_ACTION )? )
		{
			if ( $targ != null )
			{
				$targ.outerAltNum = this.outerAltNum;
				trackInlineAction($targ);
			}
			if ( grammar.type == Grammar.LEXER )
			{
				grammar.altReferencesRule( currentRuleName, $scope_, $t, this.outerAltNum );
			}
			else
			{
				grammar.altReferencesTokenID( currentRuleName, $t, this.outerAltNum );
			}
		}
	|	c=CHAR_LITERAL
		{
			if ( grammar.type != Grammar.LEXER )
			{
				Rule rule = grammar.getRule(currentRuleName);
				if ( rule != null )
					rule.trackTokenReferenceInAlt($c, outerAltNum);
			}
		}
	|	s=STRING_LITERAL 
		{
			if ( grammar.type != Grammar.LEXER )
			{
				Rule rule = grammar.getRule(currentRuleName);
				if ( rule!=null )
					rule.trackTokenReferenceInAlt($s, outerAltNum);
			}
		}
	|	WILDCARD
	|	^(DOT ID atom[$ID]) // scope override on rule
	;

ast_suffix
	:	ROOT
	|	BANG
	;

rewrite
@init
{
	// track top level REWRITES node, store stuff there
	currentRewriteRule = $start; // has to execute during backtracking
	if ( state.backtracking == 0 )
	{
		if ( grammar.buildAST() )
			currentRewriteRule.rewriteRefsDeep = new HashSet<GrammarAST>();
	}
}
	:	^(	REWRITES
			(	^( REWRITE (pred=SEMPRED)? rewrite_alternative )
				{
					if ( $pred != null )
					{
						$pred.outerAltNum = this.outerAltNum;
						trackInlineAction($pred);
					}
				}
			)*
		)
		//{System.out.println("-> refs = "+currentRewriteRule.rewriteRefsDeep);}
	|
	;

rewrite_block
@init
{
	GrammarAST enclosingBlock = currentRewriteBlock;
	if ( state.backtracking == 0 )
	{
		// don't do if guessing
		currentRewriteBlock=$start; // pts to BLOCK node
		currentRewriteBlock.rewriteRefsShallow = new HashSet<GrammarAST>();
		currentRewriteBlock.rewriteRefsDeep = new HashSet<GrammarAST>();
	}
}
	:   ^( BLOCK rewrite_alternative EOB )
		//{System.out.println("atoms="+currentRewriteBlock.rewriteRefs);}
		{
			// copy the element refs in this block to the surrounding block
			if ( enclosingBlock != null )
			{
				for (GrammarAST item : currentRewriteBlock.rewriteRefsShallow)
					enclosingBlock.rewriteRefsDeep.add( item );
			}
			//currentRewriteBlock = enclosingBlock; // restore old BLOCK ptr
		}
	;
finally { currentRewriteBlock = enclosingBlock; }

rewrite_alternative
	:	{grammar.buildAST()}? => ^( a=ALT ( ( rewrite_element )+ | EPSILON ) EOA )
	|	{grammar.buildTemplate()}? => rewrite_template
	|	ETC {this.blockLevel==1}? // only valid as outermost rewrite
	;

rewrite_element
	:	rewrite_atom
	|	rewrite_ebnf
	|	rewrite_tree
	;

rewrite_ebnf
	:	^( OPTIONAL rewrite_block )
	|	^( CLOSURE rewrite_block )
	|	^( POSITIVE_CLOSURE rewrite_block )
	;

rewrite_tree
	:   ^(	TREE_BEGIN rewrite_atom ( rewrite_element )* )
	;

rewrite_atom
@init
{
	if ( state.backtracking == 0 )
	{
		Rule r = grammar.getRule(currentRuleName);
		Set tokenRefsInAlt = r.getTokenRefsInAlt(outerAltNum);
		boolean imaginary =
			$start.getType()==TOKEN_REF &&
			!tokenRefsInAlt.contains($start.getText());
		if ( !imaginary && grammar.buildAST() &&
			 ($start.getType()==RULE_REF ||
			  $start.getType()==LABEL ||
			  $start.getType()==TOKEN_REF ||
			  $start.getType()==CHAR_LITERAL ||
			  $start.getType()==STRING_LITERAL) )
		{
			// track per block and for entire rewrite rule
			if ( currentRewriteBlock!=null )
			{
				currentRewriteBlock.rewriteRefsShallow.add($start);
				currentRewriteBlock.rewriteRefsDeep.add($start);
			}

			//System.out.println("adding "+$start.getText()+" to "+currentRewriteRule.getText());
			currentRewriteRule.rewriteRefsDeep.add($start);
		}
	}
}
	:	RULE_REF 
	|	(	^(	TOKEN_REF
				(	ARG_ACTION
					{
						$ARG_ACTION.outerAltNum = this.outerAltNum;
						trackInlineAction($ARG_ACTION);
					}
				)?
			)
		|	CHAR_LITERAL
		|	STRING_LITERAL
		)
	|	LABEL
	|	ACTION
		{
			$ACTION.outerAltNum = this.outerAltNum;
			trackInlineAction($ACTION);
		}
	;

rewrite_template
	:	^(	ALT EPSILON EOA )
	|	^(	TEMPLATE (id=ID|ind=ACTION)
			^( ARGLIST
				(	^( ARG arg=ID a=ACTION )
					{
						$a.outerAltNum = this.outerAltNum;
						trackInlineAction($a);
					}
				)*
			)
			{
				if ( $ind!=null )
				{
					$ind.outerAltNum = this.outerAltNum;
					trackInlineAction($ind);
				}
			}
			(	DOUBLE_QUOTE_STRING_LITERAL
			|	DOUBLE_ANGLE_STRING_LITERAL
			)?
		)
	|	act=ACTION
		{
			$act.outerAltNum = this.outerAltNum;
			trackInlineAction($act);
		}
	;
