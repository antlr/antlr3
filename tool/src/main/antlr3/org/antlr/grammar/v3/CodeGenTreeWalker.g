/*
 [The "BSD license"]
 Copyright (c) 2011 Terence Parr
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

/** Walk a grammar and generate code by gradually building up
 *  a bigger and bigger ST.
 *
 *  Terence Parr
 *  University of San Francisco
 *  June 15, 2004
 */
tree grammar CodeGenTreeWalker;

options {
	tokenVocab = ANTLR;
	ASTLabelType=GrammarAST;
}

@header {
package org.antlr.grammar.v3;

import org.antlr.analysis.*;
import org.antlr.misc.*;
import org.antlr.tool.*;
import org.antlr.codegen.*;

import java.util.HashSet;
import java.util.Set;
import java.util.Collection;
import org.antlr.runtime.BitSet;
import org.antlr.runtime.DFA;
import org.stringtemplate.v4.ST;
import org.stringtemplate.v4.STGroup;
}

@members {
protected static final int RULE_BLOCK_NESTING_LEVEL = 0;
protected static final int OUTER_REWRITE_NESTING_LEVEL = 0;

private String currentRuleName = null;
protected int blockNestingLevel = 0;
protected int rewriteBlockNestingLevel = 0;
private int outerAltNum = 0;
protected ST currentBlockST = null;
protected boolean currentAltHasASTRewrite = false;
protected int rewriteTreeNestingLevel = 0;
protected HashSet<Object> rewriteRuleRefs = null;

public String getCurrentRuleName() {
    return currentRuleName;
}

public void setCurrentRuleName(String value) {
    currentRuleName = value;
}

public int getOuterAltNum() {
    return outerAltNum;
}

public void setOuterAltNum(int value) {
    outerAltNum = value;
}

@Override
public void reportError(RecognitionException ex) {
    Token token = null;
    if (ex instanceof MismatchedTokenException) {
        token = ((MismatchedTokenException)ex).token;
    } else if (ex instanceof NoViableAltException) {
        token = ((NoViableAltException)ex).token;
    }

    ErrorManager.syntaxError(
        ErrorManager.MSG_SYNTAX_ERROR,
        grammar,
        token,
        "codegen: " + ex.toString(),
        ex );
}

public final void reportError(String s) {
    System.out.println("codegen: error: " + s);
}

protected CodeGenerator generator;
protected Grammar grammar;
protected STGroup templates;

/** The overall lexer/parser template; simulate dynamically scoped
 *  attributes by making this an instance var of the walker.
 */
protected ST recognizerST;

protected ST outputFileST;
protected ST headerFileST;

protected String outputOption = "";

protected final ST getWildcardST(GrammarAST elementAST, GrammarAST ast_suffix, String label) {
    String name = "wildcard";
    if (grammar.type == Grammar.LEXER) {
        name = "wildcardChar";
    }
    return getTokenElementST(name, name, elementAST, ast_suffix, label);
}

protected final ST getRuleElementST( String name,
                                          String ruleTargetName,
                                          GrammarAST elementAST,
                                          GrammarAST ast_suffix,
                                          String label ) {
	Rule r = grammar.getRule( currentRuleName );
	String suffix = getSTSuffix(elementAST, ast_suffix, label);
	if ( !r.isSynPred ) {
		name += suffix;
	}
	// if we're building trees and there is no label, gen a label
	// unless we're in a synpred rule.
	if ( ( grammar.buildAST() || suffix.length() > 0 ) && label == null &&
		 ( r == null || !r.isSynPred ) ) {
		// we will need a label to do the AST or tracking, make one
		label = generator.createUniqueLabel( ruleTargetName );
		CommonToken labelTok = new CommonToken( ANTLRParser.ID, label );
		grammar.defineRuleRefLabel( currentRuleName, labelTok, elementAST );
	}

	ST elementST = templates.getInstanceOf( name );
	if ( label != null ) {
		elementST.add( "label", label );
	}


	return elementST;
}

protected final ST getTokenElementST( String name,
                                           String elementName,
                                           GrammarAST elementAST,
                                           GrammarAST ast_suffix,
                                           String label ) {
    boolean tryUnchecked = false;
    if (name == "matchSet" && elementAST.enclosingRuleName != null && elementAST.enclosingRuleName.length() > 0 && Rule.getRuleType(elementAST.enclosingRuleName) == Grammar.LEXER)
    {
        if ( ( elementAST.getParent().getType() == ANTLRLexer.ALT && elementAST.getParent().getParent().getParent().getType() == RULE && elementAST.getParent().getParent().getChildCount() == 2 )
            || ( elementAST.getParent().getType() == ANTLRLexer.NOT && elementAST.getParent().getParent().getParent().getParent().getType() == RULE && elementAST.getParent().getParent().getParent().getChildCount() == 2 ) ) {
            // single alt at the start of the rule needs to be checked
        } else {
            tryUnchecked = true;
        }
    }

    String suffix = getSTSuffix( elementAST, ast_suffix, label );
    // if we're building trees and there is no label, gen a label
    // unless we're in a synpred rule.
    Rule r = grammar.getRule( currentRuleName );
    if ( ( grammar.buildAST() || suffix.length() > 0 ) && label == null &&
         ( r == null || !r.isSynPred ) )
    {
        label = generator.createUniqueLabel( elementName );
        CommonToken labelTok = new CommonToken( ANTLRParser.ID, label );
        grammar.defineTokenRefLabel( currentRuleName, labelTok, elementAST );
    }

    ST elementST = null;
    if ( tryUnchecked && templates.isDefined( name + "Unchecked" + suffix ) )
        elementST = templates.getInstanceOf( name + "Unchecked" + suffix );
    if ( elementST == null )
        elementST = templates.getInstanceOf( name + suffix );

    if ( label != null )
    {
        elementST.add( "label", label );
    }
    return elementST;
}

public final boolean isListLabel(String label) {
    boolean hasListLabel = false;
    if ( label != null ) {
        Rule r = grammar.getRule( currentRuleName );
        //String stName = null;
        if ( r != null )
        {
            Grammar.LabelElementPair pair = r.getLabel( label );
            if ( pair != null &&
                 ( pair.type == Grammar.TOKEN_LIST_LABEL ||
                  pair.type == Grammar.RULE_LIST_LABEL ||
                  pair.type == Grammar.WILDCARD_TREE_LIST_LABEL ) )
            {
                hasListLabel = true;
            }
        }
    }
    return hasListLabel;
}

/** Return a non-empty template name suffix if the token is to be
 *  tracked, added to a tree, or both.
 */
protected final String getSTSuffix(GrammarAST elementAST, GrammarAST ast_suffix, String label) {
    if ( grammar.type == Grammar.LEXER )
    {
        return "";
    }
    // handle list label stuff; make element use "Track"

    String operatorPart = "";
    String rewritePart = "";
    String listLabelPart = "";
    Rule ruleDescr = grammar.getRule( currentRuleName );
    if ( ast_suffix != null && !ruleDescr.isSynPred )
    {
        if ( ast_suffix.getType() == ANTLRParser.ROOT )
        {
            operatorPart = "RuleRoot";
        }
        else if ( ast_suffix.getType() == ANTLRParser.BANG )
        {
            operatorPart = "Bang";
        }
    }
    if ( currentAltHasASTRewrite && elementAST.getType() != WILDCARD )
    {
        rewritePart = "Track";
    }
    if ( isListLabel( label ) )
    {
        listLabelPart = "AndListLabel";
    }
    String STsuffix = operatorPart + rewritePart + listLabelPart;
    //JSystem.@out.println("suffix = "+STsuffix);

    return STsuffix;
}

/** Convert rewrite AST lists to target labels list */
protected final List<String> getTokenTypesAsTargetLabels(Collection<GrammarAST> refs)
{
    if ( refs == null || refs.size() == 0 )
        return null;

    List<String> labels = new ArrayList<String>( refs.size() );
    for ( GrammarAST t : refs )
    {
        String label;
        if ( t.getType() == ANTLRParser.RULE_REF || t.getType() == ANTLRParser.TOKEN_REF || t.getType() == ANTLRParser.LABEL)
        {
            label = t.getText();
        }
        else
        {
            // must be char or String literal
            label = generator.getTokenTypeAsTargetLabel(grammar.getTokenType(t.getText()));
        }
        labels.add( label );
    }
    return labels;
}

public final void init( Grammar g ) {
    this.grammar = g;
    this.generator = grammar.getCodeGenerator();
    this.templates = generator.getTemplates();
}
}

public
grammar_[Grammar g,
		ST recognizerST,
		ST outputFileST,
		ST headerFileST]
@init
{
	if ( state.backtracking == 0 )
	{
		init(g);
		this.recognizerST = recognizerST;
		this.outputFileST = outputFileST;
		this.headerFileST = headerFileST;
		String superClass = (String)g.getOption("superClass");
		outputOption = (String)g.getOption("output");
		if ( superClass!=null ) recognizerST.add("superClass", superClass);
		if ( g.type!=Grammar.LEXER ) {
		    Object lt = g.getOption("ASTLabelType");
			if ( lt!=null ) recognizerST.add("ASTLabelType", lt);
		}
		if ( g.type==Grammar.TREE_PARSER && g.getOption("ASTLabelType")==null ) {
			ErrorManager.grammarWarning(ErrorManager.MSG_MISSING_AST_TYPE_IN_TREE_GRAMMAR,
									   g,
									   null,
									   g.name);
		}
		if ( g.type!=Grammar.TREE_PARSER ) {
		    Object lt = g.getOption("TokenLabelType");
			if ( lt!=null ) recognizerST.add("labelType", lt);
		}
		$recognizerST.add("numRules", grammar.getRules().size());
		$outputFileST.add("numRules", grammar.getRules().size());
		$headerFileST.add("numRules", grammar.getRules().size());
	}
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
	:   name=ID
		(	cmt=DOC_COMMENT
			{
				outputFileST.add("docComment", $cmt.text);
				headerFileST.add("docComment", $cmt.text);
			}
		)?
		{
			recognizerST.add("name", grammar.getRecognizerName());
			outputFileST.add("name", grammar.getRecognizerName());
			headerFileST.add("name", grammar.getRecognizerName());
			recognizerST.add("scopes", grammar.getGlobalScopes());
			headerFileST.add("scopes", grammar.getGlobalScopes());
		}
		( ^(OPTIONS .*) )?
		( ^(IMPORT .*) )?
		( ^(TOKENS .*) )?
		(attrScope)*
		( ^(AMPERSAND .*) )*
		rules[recognizerST]
	;

rules[ST recognizerST]
@init
{
	String ruleName = ((GrammarAST)input.LT(1)).getChild(0).getText();
	boolean generated = grammar.generateMethodForRule(ruleName);
}
	:	(	(	options {k=1;} :
				{generated}? =>
				rST=rule
				{
					if ( $rST.code != null )
					{
						recognizerST.add("rules", $rST.code);
						outputFileST.add("rules", $rST.code);
						headerFileST.add("rules", $rST.code);
					}
				}
			|	^(RULE .*)
			|	^(PREC_RULE .*) // ignore
			)
			{{
				if ( input.LA(1) == RULE )
				{
					ruleName = ((GrammarAST)input.LT(1)).getChild(0).getText();
					//System.Diagnostics.Debug.Assert( ruleName == ((GrammarAST)input.LT(1)).enclosingRuleName );
					generated = grammar.generateMethodForRule(ruleName);
				}
			}}
		)+
	;

rule returns [ST code=null]
@init
{
	String initAction = null;
	// get the dfa for the BLOCK
	GrammarAST block2=(GrammarAST)$start.getFirstChildWithType(BLOCK);
	org.antlr.analysis.DFA dfa = block2.getLookaheadDFA();
	// init blockNestingLevel so it's block level RULE_BLOCK_NESTING_LEVEL
	// for alts of rule
	blockNestingLevel = RULE_BLOCK_NESTING_LEVEL-1;
	Rule ruleDescr = grammar.getRule($start.getChild(0).getText());
	currentRuleName = $start.getChild(0).getText();

	// For syn preds, we don't want any AST code etc... in there.
	// Save old templates ptr and restore later.  Base templates include Dbg.
	STGroup saveGroup = templates;
	if ( ruleDescr.isSynPred )
	{
		templates = generator.getBaseTemplates();
	}

	String description = "";
}
	:	^(	RULE id=ID
			{assert currentRuleName == $id.text;}
			(mod=modifier)?
			^(ARG (ARG_ACTION)?)
			^(RET (ARG_ACTION)?)
			(throwsSpec)?
			( ^(OPTIONS .*) )?
			(ruleScopeSpec)?
			( ^(AMPERSAND .*) )*
			b=block["ruleBlock", dfa]
			{
				description =
					grammar.grammarTreeToString((GrammarAST)$start.getFirstChildWithType(BLOCK),
												false);
				description =
					generator.target.getTargetStringLiteralFromString(description);
				$b.code.add("description", description);
				// do not generate lexer rules in combined grammar
				String stName = null;
				if ( ruleDescr.isSynPred )
				{
					stName = "synpredRule";
				}
				else if ( grammar.type==Grammar.LEXER )
				{
					if ( currentRuleName.equals(Grammar.ARTIFICIAL_TOKENS_RULENAME) )
					{
						stName = "tokensRule";
					}
					else
					{
						stName = "lexerRule";
					}
				}
				else
				{
					if ( !(grammar.type==Grammar.COMBINED &&
						 Rule.getRuleType(currentRuleName) == Grammar.LEXER) )
					{
						stName = "rule";
					}
				}
				$code = templates.getInstanceOf(stName);
				if ( $code.getName().equals("/rule") )
				{
					$code.add("emptyRule", grammar.isEmptyRule(block2));
				}
				$code.add("ruleDescriptor", ruleDescr);
				String memo = (String)grammar.getBlockOption($start,"memoize");
				if ( memo==null )
				{
					memo = (String)grammar.getOption("memoize");
				}
				if ( memo!=null && memo.equals("true") &&
					 (stName.equals("rule")||stName.equals("lexerRule")) )
				{
					$code.add("memoize", memo!=null && memo.equals("true"));
				}
			}

			(exceptionGroup[$code])?
			EOR
		)
		{
			if ( $code!=null )
			{
				if ( grammar.type==Grammar.LEXER )
				{
					boolean naked =
						currentRuleName.equals(Grammar.ARTIFICIAL_TOKENS_RULENAME) ||
						($mod.start!=null&&$mod.start.getText().equals(Grammar.FRAGMENT_RULE_MODIFIER));
					$code.add("nakedBlock", naked);
				}
				else
				{
					description = grammar.grammarTreeToString($start,false);
					description = generator.target.getTargetStringLiteralFromString(description);
					$code.add("description", description);
				}
				Rule theRule = grammar.getRule(currentRuleName);
				generator.translateActionAttributeReferencesForSingleScope(
					theRule,
					theRule.getActions()
				);
				$code.add("ruleName", currentRuleName);
				$code.add("block", $b.code);
				if ( initAction!=null )
				{
					$code.add("initAction", initAction);
				}
			}
		}
	;
finally { templates = saveGroup; }

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

block[String blockTemplateName, org.antlr.analysis.DFA dfa]
	 returns [ST code=null]
options { k=1; }
@init
{
	int altNum = 0;

	blockNestingLevel++;
	if ( state.backtracking == 0 )
	{
		ST decision = null;
		if ( $dfa != null )
		{
			$code = templates.getInstanceOf($blockTemplateName);
			decision = generator.genLookaheadDecision(recognizerST,$dfa);
			$code.add("decision", decision);
			$code.add("decisionNumber", $dfa.getDecisionNumber());
			$code.add("maxK",$dfa.getMaxLookaheadDepth());
			$code.add("maxAlt",$dfa.getNumberOfAlts());
		}
		else
		{
			$code = templates.getInstanceOf($blockTemplateName+"SingleAlt");
		}
		$code.add("blockLevel", blockNestingLevel);
		$code.add("enclosingBlockLevel", blockNestingLevel-1);
		altNum = 1;
		if ( this.blockNestingLevel==RULE_BLOCK_NESTING_LEVEL ) {
			this.outerAltNum=1;
		}
	}
}
	:	{$start.getSetValue()!=null}? => setBlock
		{
			$code.add("alts",$setBlock.code);
		}

	|	^(  BLOCK
			( ^(OPTIONS .*) )? // ignore
			( alt=alternative rew=rewrite
				{
					if ( this.blockNestingLevel==RULE_BLOCK_NESTING_LEVEL )
					{
						this.outerAltNum++;
					}
					// add the rewrite code as just another element in the alt :)
					// (unless it's a " -> ..." rewrite
					// ( -> ... )
					GrammarAST firstRewriteAST = (GrammarAST)$rew.start.findFirstType(REWRITE);
					boolean etc =
						$rew.start.getType()==REWRITES &&
						firstRewriteAST.getChild(0)!=null &&
						firstRewriteAST.getChild(0).getType()==ETC;
					if ( $rew.code!=null && !etc )
					{
						$alt.code.add("rew", $rew.code);
					}
					// add this alt to the list of alts for this block
					$code.add("alts",$alt.code);
					$alt.code.add("altNum", altNum);
					$alt.code.add("outerAlt", blockNestingLevel==RULE_BLOCK_NESTING_LEVEL);
					altNum++;
				}
			)+
			EOB
		 )
	;
finally { blockNestingLevel--; }

setBlock returns [ST code=null]
@init
{
	ST setcode = null;
	if ( state.backtracking == 0 )
	{
		if ( blockNestingLevel==RULE_BLOCK_NESTING_LEVEL && grammar.buildAST() )
		{
			Rule r = grammar.getRule(currentRuleName);
			currentAltHasASTRewrite = r.hasRewrite(outerAltNum);
			if ( currentAltHasASTRewrite )
			{
				r.trackTokenReferenceInAlt($start, outerAltNum);
			}
		}
	}
}
	:	^(s=BLOCK .*)
		{
			int i = ((CommonToken)$s.getToken()).getTokenIndex();
			if ( blockNestingLevel==RULE_BLOCK_NESTING_LEVEL )
			{
				setcode = getTokenElementST("matchRuleBlockSet", "set", $s, null, null);
			}
			else
			{
				setcode = getTokenElementST("matchSet", "set", $s, null, null);
			}
			setcode.add("elementIndex", i);
			//if ( grammar.type!=Grammar.LEXER )
			//{
			//	generator.generateLocalFOLLOW($s,"set",currentRuleName,i);
			//}
			setcode.add("s",
				generator.genSetExpr(templates,$s.getSetValue(),1,false));
			ST altcode=templates.getInstanceOf("alt");
			altcode.addAggr("elements.{el,line,pos}",
								 setcode,
								 $s.getLine(),
								 $s.getCharPositionInLine() + 1
								);
			altcode.add("altNum", 1);
			altcode.add("outerAlt", blockNestingLevel==RULE_BLOCK_NESTING_LEVEL);
			if ( !currentAltHasASTRewrite && grammar.buildAST() )
			{
				altcode.add("autoAST", true);
			}
			altcode.add("treeLevel", rewriteTreeNestingLevel);
			$code = altcode;
		}
	;

setAlternative
	:	^(ALT setElement+ EOA)
	;

exceptionGroup[ST ruleST]
	:	( exceptionHandler[$ruleST] )+ (finallyClause[$ruleST])?
	|	finallyClause[$ruleST]
	;

exceptionHandler[ST ruleST]
	:	^('catch' ARG_ACTION ACTION)
		{
			List chunks = generator.translateAction(currentRuleName,$ACTION);
			$ruleST.addAggr("exceptions.{decl,action}",$ARG_ACTION.text,chunks);
		}
	;

finallyClause[ST ruleST]
	:	^('finally' ACTION)
		{
			List chunks = generator.translateAction(currentRuleName,$ACTION);
			$ruleST.add("finally",chunks);
		}
	;

alternative returns [ST code]
@init
{
	if ( state.backtracking == 0 )
	{
		$code = templates.getInstanceOf("alt");
		if ( blockNestingLevel==RULE_BLOCK_NESTING_LEVEL && grammar.buildAST() )
		{
			Rule r = grammar.getRule(currentRuleName);
			currentAltHasASTRewrite = r.hasRewrite(outerAltNum);
		}
		String description = grammar.grammarTreeToString($start, false);
		description = generator.target.getTargetStringLiteralFromString(description);
		$code.add("description", description);
		$code.add("treeLevel", rewriteTreeNestingLevel);
		if ( !currentAltHasASTRewrite && grammar.buildAST() )
		{
			$code.add("autoAST", true);
		}
	}
}
	:	^(	a=ALT
			(
				e=element[null,null]
				{
					if (e != null && e.code != null)
					{
						$code.addAggr("elements.{el,line,pos}",
										  $e.code,
										  $e.start.getLine(),
										  $e.start.getCharPositionInLine() + 1
										 );
					}
				}
			)+
			EOA
		)
	;

element[GrammarAST label, GrammarAST astSuffix] returns [ST code=null]
options { k=1; }
@init
{
	IntSet elements=null;
	GrammarAST ast = null;
}
	:	^(ROOT e=element[label,$ROOT])
		{ $code = $e.code; }

	|	^(BANG e=element[label,$BANG])
		{ $code = $e.code; }

	|	^( n=NOT notElement[$n, $label, $astSuffix] )
		{ $code = $notElement.code; }

	|	^( ASSIGN alabel=ID e=element[$alabel,$astSuffix] )
		{ $code = $e.code; }

	|	^( PLUS_ASSIGN label2=ID e=element[$label2,$astSuffix] )
		{ $code = $e.code; }

	|	^(CHAR_RANGE a=CHAR_LITERAL b=CHAR_LITERAL)
		{
			$code = templates.getInstanceOf("charRangeRef");
			String low = generator.target.getTargetCharLiteralFromANTLRCharLiteral(generator,$a.text);
			String high = generator.target.getTargetCharLiteralFromANTLRCharLiteral(generator,$b.text);
			$code.add("a", low);
			$code.add("b", high);
			if ( label!=null )
			{
				$code.add("label", $label.getText());
			}
		}

	|	({((GrammarAST)input.LT(1)).getSetValue()==null}? (BLOCK|OPTIONAL|CLOSURE|POSITIVE_CLOSURE)) => /*{$start.getSetValue()==null}?*/ ebnf
		{ $code = $ebnf.code; }

	|	atom[null, $label, $astSuffix]
		{ $code = $atom.code; }

	|	tree_
		{ $code = $tree_.code; }

	|	element_action
		{ $code = $element_action.code; }

	|   (sp=SEMPRED|sp=GATED_SEMPRED)
		{
			$code = templates.getInstanceOf("validateSemanticPredicate");
			$code.add("pred", generator.translateAction(currentRuleName,$sp));
			String description = generator.target.getTargetStringLiteralFromString($sp.text);
			$code.add("description", description);
		}

	|	SYN_SEMPRED // used only in lookahead; don't generate validating pred

	|	^(SYNPRED .*)

	|	^(BACKTRACK_SEMPRED .*)

	|   EPSILON
	;

element_action returns [ST code=null]
	:	act=ACTION
		{
			$code = templates.getInstanceOf("execAction");
			$code.add("action", generator.translateAction(currentRuleName,$act));
		}
	|	act2=FORCED_ACTION
		{
			$code = templates.getInstanceOf("execForcedAction");
			$code.add("action", generator.translateAction(currentRuleName,$act2));
		}
	;

notElement[GrammarAST n, GrammarAST label, GrammarAST astSuffix] returns [ST code=null]
@init
{
	IntSet elements=null;
	String labelText = null;
	if ( label!=null )
	{
		labelText = label.getText();
	}
}
	:	(	assign_c=CHAR_LITERAL
			{
				int ttype=0;
				if ( grammar.type==Grammar.LEXER )
				{
					ttype = Grammar.getCharValueFromGrammarCharLiteral($assign_c.text);
				}
				else
				{
					ttype = grammar.getTokenType($assign_c.text);
				}
				elements = grammar.complement(ttype);
			}
		|	assign_s=STRING_LITERAL
			{
				int ttype=0;
				if ( grammar.type==Grammar.LEXER )
				{
					// TODO: error!
				}
				else
				{
					ttype = grammar.getTokenType($assign_s.text);
				}
				elements = grammar.complement(ttype);
			}
		|	assign_t=TOKEN_REF
			{
				int ttype = grammar.getTokenType($assign_t.text);
				elements = grammar.complement(ttype);
			}
		|	^(assign_st=BLOCK .*)
			{
				elements = $assign_st.getSetValue();
				elements = grammar.complement(elements);
			}
		)
		{
			$code = getTokenElementST("matchSet",
									 "set",
									 (GrammarAST)$n.getChild(0),
									 astSuffix,
									 labelText);
			$code.add("s",generator.genSetExpr(templates,elements,1,false));
			int i = ((CommonToken)n.getToken()).getTokenIndex();
			$code.add("elementIndex", i);
			if ( grammar.type!=Grammar.LEXER )
			{
				generator.generateLocalFOLLOW(n,"set",currentRuleName,i);
			}
		}
	;

ebnf returns [ST code=null]
@init
{
	org.antlr.analysis.DFA dfa=null;
	GrammarAST b = (GrammarAST)$start.getChild(0);
	GrammarAST eob = (GrammarAST)b.getLastChild(); // loops will use EOB DFA
}
	:	(	{ dfa = $start.getLookaheadDFA(); }
			blk=block["block", dfa]
			{ $code = $blk.code; }
		|	{ dfa = $start.getLookaheadDFA(); }
			^( OPTIONAL blk=block["optionalBlock", dfa] )
			{ $code = $blk.code; }
		|	{ dfa = eob.getLookaheadDFA(); }
			^( CLOSURE blk=block["closureBlock", dfa] )
			{ $code = $blk.code; }
		|	{ dfa = eob.getLookaheadDFA(); }
			^( POSITIVE_CLOSURE blk=block["positiveClosureBlock", dfa] )
			{ $code = $blk.code; }
		)
		{
			String description = grammar.grammarTreeToString($start, false);
			description = generator.target.getTargetStringLiteralFromString(description);
			$code.add("description", description);
		}
	;

tree_ returns [ST code]
@init
{
	rewriteTreeNestingLevel++;
	GrammarAST rootSuffix = null;
	if ( state.backtracking == 0 )
	{
		$code = templates.getInstanceOf("tree");
		NFAState afterDOWN = (NFAState)$start.NFATreeDownState.transition(0).target;
		LookaheadSet s = grammar.LOOK(afterDOWN);
		if ( s.member(Label.UP) ) {
			// nullable child list if we can see the UP as the next token
			// we need an "if ( input.LA(1)==Token.DOWN )" gate around
			// the child list.
			$code.add("nullableChildList", "true");
		}
		$code.add("enclosingTreeLevel", rewriteTreeNestingLevel-1);
		$code.add("treeLevel", rewriteTreeNestingLevel);
		Rule r = grammar.getRule(currentRuleName);
		if ( grammar.buildAST() && !r.hasRewrite(outerAltNum) ) {
			rootSuffix = new GrammarAST(ROOT,"ROOT");
		}
	}
}
	:	^(	TREE_BEGIN
			el=element[null,rootSuffix]
			{
				$code.addAggr("root.{el,line,pos}",
								  $el.code,
								  $el.start.getLine(),
								  $el.start.getCharPositionInLine() + 1
								  );
			}
			// push all the immediately-following actions out before children
			// so actions aren't guarded by the "if (input.LA(1)==Token.DOWN)"
			// guard in generated code.
			(	(element_action) =>
				act=element_action
				{
					$code.addAggr("actionsAfterRoot.{el,line,pos}",
									  $act.code,
									  $act.start.getLine(),
									  $act.start.getCharPositionInLine() + 1
									);
				}
			)*
			(	 el=element[null,null]
				 {
				 $code.addAggr("children.{el,line,pos}",
								  $el.code,
								  $el.start.getLine(),
								  $el.start.getCharPositionInLine() + 1
								  );
				 }
			)*
		)
	;
finally { rewriteTreeNestingLevel--; }

atom[GrammarAST scope, GrammarAST label, GrammarAST astSuffix]
	returns [ST code=null]
@init
{
	String labelText=null;
	if ( state.backtracking == 0 )
	{
		if ( label!=null )
		{
			labelText = label.getText();
		}
		if ( grammar.type!=Grammar.LEXER &&
			 ($start.getType()==RULE_REF||$start.getType()==TOKEN_REF||
			  $start.getType()==CHAR_LITERAL||$start.getType()==STRING_LITERAL) )
		{
			Rule encRule = grammar.getRule(((GrammarAST)$start).enclosingRuleName);
			if ( encRule!=null && encRule.hasRewrite(outerAltNum) && astSuffix!=null )
			{
				ErrorManager.grammarError(ErrorManager.MSG_AST_OP_IN_ALT_WITH_REWRITE,
										  grammar,
										  ((GrammarAST)$start).getToken(),
										  ((GrammarAST)$start).enclosingRuleName,
										  outerAltNum);
				astSuffix = null;
			}
		}
	}
}
	:   ^( r=RULE_REF (rarg=ARG_ACTION)? )
		{
			grammar.checkRuleReference(scope, $r, $rarg, currentRuleName);
			String scopeName = null;
			if ( scope!=null ) {
				scopeName = scope.getText();
			}
			Rule rdef = grammar.getRule(scopeName, $r.text);
			// don't insert label=r() if $label.attr not used, no ret value, ...
			if ( !rdef.getHasReturnValue() ) {
				labelText = null;
			}
			$code = getRuleElementST("ruleRef", $r.text, $r, astSuffix, labelText);
			$code.add("rule", rdef);
			if ( scope!=null ) { // scoped rule ref
				Grammar scopeG = grammar.composite.getGrammar(scope.getText());
				$code.add("scope", scopeG);
			}
			else if ( rdef.grammar != this.grammar ) { // nonlocal
				// if rule definition is not in this grammar, it's nonlocal
				List<Grammar> rdefDelegates = rdef.grammar.getDelegates();
				if ( rdefDelegates.contains(this.grammar) ) {
					$code.add("scope", rdef.grammar);
				}
				else {
					// defining grammar is not a delegate, scope all the
					// back to root, which has delegate methods for all
					// rules.  Don't use scope if we are root.
					if ( this.grammar != rdef.grammar.composite.delegateGrammarTreeRoot.grammar ) {
						$code.add("scope",
										  rdef.grammar.composite.delegateGrammarTreeRoot.grammar);
					}
				}
			}

			if ( $rarg!=null ) {
				List args = generator.translateAction(currentRuleName,$rarg);
				$code.add("args", args);
			}
			int i = ((CommonToken)r.getToken()).getTokenIndex();
			$code.add("elementIndex", i);
			generator.generateLocalFOLLOW($r,$r.text,currentRuleName,i);
			$r.code = $code;
		}

	|	^( t=TOKEN_REF (targ=ARG_ACTION)? )
		{
			if ( currentAltHasASTRewrite && $t.terminalOptions!=null &&
				$t.terminalOptions.get(Grammar.defaultTokenOption)!=null )
			{
				ErrorManager.grammarError(ErrorManager.MSG_HETERO_ILLEGAL_IN_REWRITE_ALT,
										grammar,
										((GrammarAST)($t)).getToken(),
										$t.text);
			}
			grammar.checkRuleReference(scope, $t, $targ, currentRuleName);
			if ( grammar.type==Grammar.LEXER )
			{
				if ( grammar.getTokenType($t.text)==Label.EOF )
				{
					$code = templates.getInstanceOf("lexerMatchEOF");
				}
				else
				{
					$code = templates.getInstanceOf("lexerRuleRef");
					if ( isListLabel(labelText) )
					{
						$code = templates.getInstanceOf("lexerRuleRefAndListLabel");
					}
					String scopeName = null;
					if ( scope!=null )
					{
						scopeName = scope.getText();
					}
					Rule rdef2 = grammar.getRule(scopeName, $t.text);
					$code.add("rule", rdef2);
					if ( scope!=null )
					{ // scoped rule ref
						Grammar scopeG = grammar.composite.getGrammar(scope.getText());
						$code.add("scope", scopeG);
					}
					else if ( rdef2.grammar != this.grammar )
					{ // nonlocal
						// if rule definition is not in this grammar, it's nonlocal
						$code.add("scope", rdef2.grammar);
					}
					if ( $targ!=null )
					{
						List args = generator.translateAction(currentRuleName,$targ);
						$code.add("args", args);
					}
				}
				int i = ((CommonToken)$t.getToken()).getTokenIndex();
				$code.add("elementIndex", i);
				if ( label!=null )
					$code.add("label", labelText);
			}
			else
			{
				$code = getTokenElementST("tokenRef", $t.text, $t, astSuffix, labelText);
				String tokenLabel =
					generator.getTokenTypeAsTargetLabel(grammar.getTokenType(t.getText()));
				$code.add("token",tokenLabel);
				if ( !currentAltHasASTRewrite && $t.terminalOptions!=null )
				{
					$code.add("terminalOptions", $t.terminalOptions);
				}
				int i = ((CommonToken)$t.getToken()).getTokenIndex();
				$code.add("elementIndex", i);
				generator.generateLocalFOLLOW($t,tokenLabel,currentRuleName,i);
			}
			$t.code = $code;
		}

	|	c=CHAR_LITERAL
		{
			if ( grammar.type==Grammar.LEXER )
			{
				$code = templates.getInstanceOf("charRef");
				$code.add("char",
				   generator.target.getTargetCharLiteralFromANTLRCharLiteral(generator,$c.text));
				if ( label!=null )
				{
					$code.add("label", labelText);
				}
			}
			else { // else it's a token type reference
				$code = getTokenElementST("tokenRef", "char_literal", $c, astSuffix, labelText);
				String tokenLabel = generator.getTokenTypeAsTargetLabel(grammar.getTokenType($c.text));
				$code.add("token",tokenLabel);
				if ( $c.terminalOptions!=null ) {
					$code.add("terminalOptions",$c.terminalOptions);
				}
				int i = ((CommonToken)$c.getToken()).getTokenIndex();
				$code.add("elementIndex", i);
				generator.generateLocalFOLLOW($c,tokenLabel,currentRuleName,i);
			}
		}

	|	s=STRING_LITERAL
		{
			int i = ((CommonToken)$s.getToken()).getTokenIndex();
			if ( grammar.type==Grammar.LEXER )
			{
				$code = templates.getInstanceOf("lexerStringRef");
				$code.add("string",
					generator.target.getTargetStringLiteralFromANTLRStringLiteral(generator,$s.text));
				$code.add("elementIndex", i);
				if ( label!=null )
				{
					$code.add("label", labelText);
				}
			}
			else
			{
				// else it's a token type reference
				$code = getTokenElementST("tokenRef", "string_literal", $s, astSuffix, labelText);
				String tokenLabel =
					generator.getTokenTypeAsTargetLabel(grammar.getTokenType($s.text));
				$code.add("token",tokenLabel);
				if ( $s.terminalOptions!=null )
				{
					$code.add("terminalOptions",$s.terminalOptions);
				}
				$code.add("elementIndex", i);
				generator.generateLocalFOLLOW($s,tokenLabel,currentRuleName,i);
			}
		}

	|	w=WILDCARD
		{
			$code = getWildcardST($w,astSuffix,labelText);
			$code.add("elementIndex", ((CommonToken)$w.getToken()).getTokenIndex());
		}

	|	^(DOT ID a=atom[$ID, label, astSuffix]) // scope override on rule or token
		{ $code = $a.code; }

	|	set[label,astSuffix]
		{ $code = $set.code; }
	;

ast_suffix
	:	ROOT
	|	BANG
	;

set[GrammarAST label, GrammarAST astSuffix] returns [ST code=null]
@init
{
	String labelText=null;
	if ( $label!=null )
	{
		labelText = $label.getText();
	}
}
	:	^(s=BLOCK .*) // only care that it's a BLOCK with setValue!=null
		{
			$code = getTokenElementST("matchSet", "set", $s, astSuffix, labelText);
			int i = ((CommonToken)$s.getToken()).getTokenIndex();
			$code.add("elementIndex", i);
			if ( grammar.type!=Grammar.LEXER )
			{
				generator.generateLocalFOLLOW($s,"set",currentRuleName,i);
			}
			$code.add("s", generator.genSetExpr(templates,$s.getSetValue(),1,false));
		}
	;

setElement
	:	CHAR_LITERAL
	|	TOKEN_REF
	|	STRING_LITERAL
	|	^(CHAR_RANGE CHAR_LITERAL CHAR_LITERAL)
	;

// REWRITE stuff

rewrite returns [ST code=null]
@init
{
	if ( state.backtracking == 0 )
	{
		if ( $start.getType()==REWRITES )
		{
			if ( generator.grammar.buildTemplate() )
			{
				$code = templates.getInstanceOf("rewriteTemplate");
			}
			else
			{
				$code = templates.getInstanceOf("rewriteCode");
				$code.add("treeLevel", OUTER_REWRITE_NESTING_LEVEL);
				$code.add("rewriteBlockLevel", OUTER_REWRITE_NESTING_LEVEL);
				$code.add("referencedElementsDeep",
								  getTokenTypesAsTargetLabels($start.rewriteRefsDeep));
				Set<String> tokenLabels =
					grammar.getLabels($start.rewriteRefsDeep, Grammar.TOKEN_LABEL);
				Set<String> tokenListLabels =
					grammar.getLabels($start.rewriteRefsDeep, Grammar.TOKEN_LIST_LABEL);
				Set<String> ruleLabels =
					grammar.getLabels($start.rewriteRefsDeep, Grammar.RULE_LABEL);
				Set<String> ruleListLabels =
					grammar.getLabels($start.rewriteRefsDeep, Grammar.RULE_LIST_LABEL);
				Set<String> wildcardLabels =
					grammar.getLabels($start.rewriteRefsDeep, Grammar.WILDCARD_TREE_LABEL);
				Set<String> wildcardListLabels =
					grammar.getLabels($start.rewriteRefsDeep, Grammar.WILDCARD_TREE_LIST_LABEL);
				// just in case they ref $r for "previous value", make a stream
				// from retval.tree
				ST retvalST = templates.getInstanceOf("prevRuleRootRef");
				ruleLabels.add(retvalST.render());
				$code.add("referencedTokenLabels", tokenLabels);
				$code.add("referencedTokenListLabels", tokenListLabels);
				$code.add("referencedRuleLabels", ruleLabels);
				$code.add("referencedRuleListLabels", ruleListLabels);
				$code.add("referencedWildcardLabels", wildcardLabels);
				$code.add("referencedWildcardListLabels", wildcardListLabels);
			}
		}
		else
		{
				$code = templates.getInstanceOf("noRewrite");
				$code.add("treeLevel", OUTER_REWRITE_NESTING_LEVEL);
				$code.add("rewriteBlockLevel", OUTER_REWRITE_NESTING_LEVEL);
		}
	}
}
	:	^(	REWRITES
			(
				{rewriteRuleRefs = new HashSet<Object>();}
				^( r=REWRITE (pred=SEMPRED)? alt=rewrite_alternative)
				{
					rewriteBlockNestingLevel = OUTER_REWRITE_NESTING_LEVEL;
					List predChunks = null;
					if ( $pred!=null )
					{
						//predText = #pred.getText();
						predChunks = generator.translateAction(currentRuleName,$pred);
					}
					String description =
						grammar.grammarTreeToString($r,false);
					description = generator.target.getTargetStringLiteralFromString(description);
					$code.addAggr("alts.{pred,alt,description}",
									  predChunks,
									  alt,
									  description);
					pred=null;
				}
			)*
		)
	|
	;

rewrite_block[String blockTemplateName] returns [ST code=null]
@init
{
	rewriteBlockNestingLevel++;
	ST save_currentBlockST = currentBlockST;
	if ( state.backtracking == 0 )
	{
		$code = templates.getInstanceOf(blockTemplateName);
		currentBlockST = $code;
		$code.add("rewriteBlockLevel", rewriteBlockNestingLevel);
	}
}
	:	^(	BLOCK
			{
				currentBlockST.add("referencedElementsDeep",
					getTokenTypesAsTargetLabels($BLOCK.rewriteRefsDeep));
				currentBlockST.add("referencedElements",
					getTokenTypesAsTargetLabels($BLOCK.rewriteRefsShallow));
			}
			alt=rewrite_alternative
			EOB
		)
		{
			$code.add("alt", $alt.code);
		}
	;
finally { rewriteBlockNestingLevel--; currentBlockST = save_currentBlockST; }

rewrite_alternative returns [ST code=null]
	:	{generator.grammar.buildAST()}?
		^(	a=ALT {$code=templates.getInstanceOf("rewriteElementList");}
			(	(
					el=rewrite_element
					{$code.addAggr("elements.{el,line,pos}",
										$el.code,
										$el.start.getLine(),
										$el.start.getCharPositionInLine() + 1
										);
					}
				)+
			|	EPSILON
				{$code.addAggr("elements.{el,line,pos}",
								   templates.getInstanceOf("rewriteEmptyAlt"),
								   $a.getLine(),
								   $a.getCharPositionInLine() + 1
								   );
				}
			)
			EOA
		 )

	|	{generator.grammar.buildTemplate()}? rewrite_template
		{ $code = $rewrite_template.code; }

	|	// reproduce same input (only AST at moment)
		ETC
	;

rewrite_element returns [ST code=null]
@init
{
	IntSet elements=null;
	GrammarAST ast = null;
}
	:	rewrite_atom[false]
		{ $code = $rewrite_atom.code; }
	|	rewrite_ebnf
		{ $code = $rewrite_ebnf.code; }
	|	rewrite_tree
		{ $code = $rewrite_tree.code; }
	;

rewrite_ebnf returns [ST code=null]
	:	^( OPTIONAL rewrite_block["rewriteOptionalBlock"] )
		{ $code = $rewrite_block.code; }
		{
			String description = grammar.grammarTreeToString($start, false);
			description = generator.target.getTargetStringLiteralFromString(description);
			$code.add("description", description);
		}
	|	^( CLOSURE rewrite_block["rewriteClosureBlock"] )
		{ $code = $rewrite_block.code; }
		{
			String description = grammar.grammarTreeToString($start, false);
			description = generator.target.getTargetStringLiteralFromString(description);
			$code.add("description", description);
		}
	|	^( POSITIVE_CLOSURE rewrite_block["rewritePositiveClosureBlock"] )
		{ $code = $rewrite_block.code; }
		{
			String description = grammar.grammarTreeToString($start, false);
			description = generator.target.getTargetStringLiteralFromString(description);
			$code.add("description", description);
		}
	;

rewrite_tree returns [ST code]
@init
{
	rewriteTreeNestingLevel++;
	if ( state.backtracking == 0 )
	{
		$code = templates.getInstanceOf("rewriteTree");
		$code.add("treeLevel", rewriteTreeNestingLevel);
		$code.add("enclosingTreeLevel", rewriteTreeNestingLevel-1);
	}
}
	:	^(	TREE_BEGIN
			r=rewrite_atom[true]
			{
				$code.addAggr("root.{el,line,pos}",
								   $r.code,
								   $r.start.getLine(),
								   $r.start.getCharPositionInLine() + 1
								  );
			}
			(
			  el=rewrite_element
			  {
				$code.addAggr("children.{el,line,pos}",
									$el.code,
									$el.start.getLine(),
									$el.start.getCharPositionInLine() + 1
									);
			  }
			)*
		)
		{
			String description = grammar.grammarTreeToString($start, false);
			description = generator.target.getTargetStringLiteralFromString(description);
			$code.add("description", description);
		}
	;
finally { rewriteTreeNestingLevel--; }

rewrite_atom[boolean isRoot] returns [ST code=null]
	:   r=RULE_REF
		{
			String ruleRefName = $r.text;
			String stName = "rewriteRuleRef";
			if ( isRoot )
			{
				stName += "Root";
			}
			$code = templates.getInstanceOf(stName);
			$code.add("rule", ruleRefName);
			if ( grammar.getRule(ruleRefName)==null )
			{
				ErrorManager.grammarError(ErrorManager.MSG_UNDEFINED_RULE_REF,
										  grammar,
										  ((GrammarAST)($r)).getToken(),
										  ruleRefName);
				$code = new ST(""); // blank; no code gen
			}
			else if ( grammar.getRule(currentRuleName)
						 .getRuleRefsInAlt(ruleRefName,outerAltNum)==null )
			{
				ErrorManager.grammarError(ErrorManager.MSG_REWRITE_ELEMENT_NOT_PRESENT_ON_LHS,
										  grammar,
										  ((GrammarAST)($r)).getToken(),
										  ruleRefName);
				$code = new ST(""); // blank; no code gen
			}
			else
			{
				// track all rule refs as we must copy 2nd ref to rule and beyond
				if ( !rewriteRuleRefs.contains(ruleRefName) )
				{
					rewriteRuleRefs.add(ruleRefName);
				}
			}
		}

	|
		(	^(tk=TOKEN_REF (arg=ARG_ACTION)?)
		|	cl=CHAR_LITERAL
		|	sl=STRING_LITERAL
		)
		{
			GrammarAST term = $tk;
			if (term == null) term = $cl;
			if (term == null) term = $sl;
			String tokenName = $start.getToken().getText();
			String stName = "rewriteTokenRef";
			Rule rule = grammar.getRule(currentRuleName);
			Collection<String> tokenRefsInAlt = rule.getTokenRefsInAlt(outerAltNum);
			boolean createNewNode = !tokenRefsInAlt.contains(tokenName) || $arg!=null;
			if ( createNewNode )
			{
				stName = "rewriteImaginaryTokenRef";
			}
			if ( isRoot )
			{
				stName += "Root";
			}
			$code = templates.getInstanceOf(stName);
			$code.add("terminalOptions",term.terminalOptions);
			if ( $arg!=null )
			{
				List args = generator.translateAction(currentRuleName,$arg);
				$code.add("args", args);
			}
			$code.add("elementIndex", ((CommonToken)$start.getToken()).getTokenIndex());
			int ttype = grammar.getTokenType(tokenName);
			String tok = generator.getTokenTypeAsTargetLabel(ttype);
			$code.add("token", tok);
			if ( grammar.getTokenType(tokenName)==Label.INVALID )
			{
				ErrorManager.grammarError(ErrorManager.MSG_UNDEFINED_TOKEN_REF_IN_REWRITE,
										  grammar,
										  ((GrammarAST)($start)).getToken(),
										  tokenName);
				$code = new ST(""); // blank; no code gen
			}
		}

	|	LABEL
		{
			String labelName = $LABEL.text;
			Rule rule = grammar.getRule(currentRuleName);
			Grammar.LabelElementPair pair = rule.getLabel(labelName);
			if ( labelName.equals(currentRuleName) )
			{
				// special case; ref to old value via $ rule
				if ( rule.hasRewrite(outerAltNum) &&
					 rule.getRuleRefsInAlt(outerAltNum).contains(labelName) )
				{
					ErrorManager.grammarError(ErrorManager.MSG_RULE_REF_AMBIG_WITH_RULE_IN_ALT,
											  grammar,
											  ((GrammarAST)($LABEL)).getToken(),
											  labelName);
				}
				ST labelST = templates.getInstanceOf("prevRuleRootRef");
				$code = templates.getInstanceOf("rewriteRuleLabelRef"+(isRoot?"Root":""));
				$code.add("label", labelST);
			}
			else if ( pair==null )
			{
				ErrorManager.grammarError(ErrorManager.MSG_UNDEFINED_LABEL_REF_IN_REWRITE,
										  grammar,
										  ((GrammarAST)($LABEL)).getToken(),
										  labelName);
				$code = new ST("");
			}
			else
			{
				String stName = null;
				switch ( pair.type )
				{
				case Grammar.TOKEN_LABEL :
					stName = "rewriteTokenLabelRef";
					break;
				case Grammar.WILDCARD_TREE_LABEL :
					stName = "rewriteWildcardLabelRef";
					break;
				case Grammar.WILDCARD_TREE_LIST_LABEL:
					stName = "rewriteRuleListLabelRef"; // acts like rule ref list for ref
					break;
				case Grammar.RULE_LABEL :
					stName = "rewriteRuleLabelRef";
					break;
				case Grammar.TOKEN_LIST_LABEL :
					stName = "rewriteTokenListLabelRef";
					break;
				case Grammar.RULE_LIST_LABEL :
					stName = "rewriteRuleListLabelRef";
					break;
				}
				if ( isRoot )
				{
					stName += "Root";
				}
				$code = templates.getInstanceOf(stName);
				$code.add("label", labelName);
			}
		}

	|	ACTION
		{
			// actions in rewrite rules yield a tree object
			String actText = $ACTION.text;
			List chunks = generator.translateAction(currentRuleName,$ACTION);
			$code = templates.getInstanceOf("rewriteNodeAction"+(isRoot?"Root":""));
			$code.add("action", chunks);
		}
	;

public
rewrite_template returns [ST code=null]
	:	^( ALT EPSILON EOA ) {$code=templates.getInstanceOf("rewriteEmptyTemplate");}
	|	^(	TEMPLATE (id=ID|ind=ACTION)
			{
				if ( $id!=null && $id.text.equals("template") )
				{
						$code = templates.getInstanceOf("rewriteInlineTemplate");
				}
				else if ( $id!=null )
				{
						$code = templates.getInstanceOf("rewriteExternalTemplate");
						$code.add("name", $id.text);
				}
				else if ( $ind!=null )
				{ // must be \%({expr})(args)
					$code = templates.getInstanceOf("rewriteIndirectTemplate");
					List chunks=generator.translateAction(currentRuleName,$ind);
					$code.add("expr", chunks);
				}
			}
			^(	ARGLIST
				(	^( ARG arg=ID a=ACTION
					{
						// must set alt num here rather than in define.g
						// because actions like \%foo(name={\$ID.text}) aren't
						// broken up yet into trees.
						$a.outerAltNum = this.outerAltNum;
						List chunks = generator.translateAction(currentRuleName,$a);
						$code.addAggr("args.{name,value}", $arg.text, chunks);
					}
					)
				)*
			)
			(	DOUBLE_QUOTE_STRING_LITERAL
				{
					String sl = $DOUBLE_QUOTE_STRING_LITERAL.text;
					String t = sl.substring( 1, sl.length() - 1 ); // strip quotes
					t = generator.target.getTargetStringLiteralFromString(t);
					$code.add("template",t);
				}
			|	DOUBLE_ANGLE_STRING_LITERAL
				{
					String sl = $DOUBLE_ANGLE_STRING_LITERAL.text;
					String t = sl.substring( 2, sl.length() - 2 ); // strip double angle quotes
					t = generator.target.getTargetStringLiteralFromString(t);
					$code.add("template",t);
				}
			)?
		)

	|	act=ACTION
		{
			// set alt num for same reason as ARGLIST above
			$act.outerAltNum = this.outerAltNum;
			$code=templates.getInstanceOf("rewriteAction");
			$code.add("action",
							  generator.translateAction(currentRuleName,$act));
		}
	;
