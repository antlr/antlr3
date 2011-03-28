/*
 * [The "BSD license"]
 * Copyright (c) 2011 Terence Parr
 * All rights reserved.
 *
 * Grammar conversion to ANTLR v3:
 * Copyright (c) 2011 Sam Harwell
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/** Find left-recursive rules */
tree grammar LeftRecursiveRuleWalker;

options {
	tokenVocab=ANTLR;
    ASTLabelType=GrammarAST;
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
protected Grammar grammar;
private String ruleName;
private int outerAlt; // which outer alt of rule?
public int numAlts;  // how many alts for this rule total?

@Override
public void reportError(RecognitionException ex)
{
    Token token = null;
    if (ex instanceof MismatchedTokenException)
    {
        token = ((MismatchedTokenException)ex).token;
    }
    else if (ex instanceof NoViableAltException)
    {
        token = ((NoViableAltException)ex).token;
    }

    ErrorManager.syntaxError(
        ErrorManager.MSG_SYNTAX_ERROR,
        grammar,
        token,
        "assign.types: " + ex.toString(),
        ex);
}

public void setTokenPrec(GrammarAST t, int alt) {}
public void binaryAlt(GrammarAST altTree, GrammarAST rewriteTree, int alt) {}
public void ternaryAlt(GrammarAST altTree, GrammarAST rewriteTree, int alt) {}
public void prefixAlt(GrammarAST altTree, GrammarAST rewriteTree, int alt) {}
public void suffixAlt(GrammarAST altTree, GrammarAST rewriteTree, int alt) {}
public void otherAlt(GrammarAST altTree, GrammarAST rewriteTree, int alt) {}
public void setReturnValues(GrammarAST t) {}
}

optionsSpec
	:	^(OPTIONS option+)
	;

option
	:	^(ASSIGN ID optionValue)
	;

optionValue
	:	ID
	|	STRING_LITERAL
	|	CHAR_LITERAL
	|	INT
	;

charSetElement
	:	CHAR_LITERAL
	|	^(OR CHAR_LITERAL CHAR_LITERAL)
	|	^(RANGE CHAR_LITERAL CHAR_LITERAL)
	;

public
rec_rule[Grammar g] returns [boolean isLeftRec]
@init
{
	grammar = g;
	outerAlt = 1;
}
	:	^(	r=RULE id=ID {ruleName=$id.getText();}
			modifier?
			^(ARG ARG_ACTION?)
			^(RET ARG_ACTION?)
			optionsSpec?
			ruleScopeSpec?
			(^(AMPERSAND .*))*
			ruleBlock {$isLeftRec = $ruleBlock.isLeftRec;}
			exceptionGroup?
			EOR
		)
		{if ($ruleBlock.isLeftRec) $r.setType(PREC_RULE);}
	;

modifier
	:	'protected'
	|	'public'
	|	'private'
	|	'fragment'
	;

ruleScopeSpec
 	:	^('scope' ACTION? ID*)
 	;

ruleBlock returns [boolean isLeftRec]
@init{boolean lr=false; this.numAlts = $start.getChildCount();}
	:	^(	BLOCK
			optionsSpec?
			(	outerAlternative
				{if ($outerAlternative.isLeftRec) $isLeftRec = true;}
				rewrite?
				{outerAlt++;}
			)+
			EOB
		)
	;

block
    :   ^(  BLOCK
            optionsSpec?
            ( ^(ALT element+ EOA) rewrite? )+
            EOB   
         )
    ;

/** An alt is either prefix, suffix, binary, or ternary operation or "other" */
outerAlternative returns [boolean isLeftRec]
@init
{
GrammarAST rew=(GrammarAST)$start.getNextSibling();
if (rew.getType() != REWRITES)
	rew = null;
}
    :   (binaryMultipleOp)=> binaryMultipleOp
                             {binaryAlt($start, rew, outerAlt); $isLeftRec=true;}
    |   (binary)=>           binary       
                             {binaryAlt($start, rew, outerAlt); $isLeftRec=true;}
    |   (ternary)=>          ternary
                             {ternaryAlt($start, rew, outerAlt); $isLeftRec=true;}
    |   (prefix)=>           prefix
                             {prefixAlt($start, rew, outerAlt);}
    |   (suffix)=>           suffix
                             {suffixAlt($start, rew, outerAlt); $isLeftRec=true;}
    |   ^(ALT element+ EOA) // "other" case
                             {otherAlt($start, rew, outerAlt);}
    ;

binary
	:	^( ALT (^(BACKTRACK_SEMPRED .*))? recurseNoLabel op=token recurse EOA ) {setTokenPrec($op.t, outerAlt);}
	;

binaryMultipleOp
	:	^( ALT (^(BACKTRACK_SEMPRED .*))? recurseNoLabel ^( BLOCK ( ^( ALT op=token EOA {setTokenPrec($op.t, outerAlt);} ) )+ EOB ) recurse EOA )
	;

ternary
	:	^( ALT (^(BACKTRACK_SEMPRED .*))? recurseNoLabel op=token recurse token recurse EOA ) {setTokenPrec($op.t, outerAlt);}
	;

prefix : ^( ALT (^(BACKTRACK_SEMPRED .*))? {setTokenPrec((GrammarAST)input.LT(1), outerAlt);} ({!((CommonTree)input.LT(1)).getText().equals(ruleName)}? element)+ recurse EOA ) ;

suffix : ^( ALT (^(BACKTRACK_SEMPRED .*))? recurseNoLabel {setTokenPrec((GrammarAST)input.LT(1), outerAlt);} element+  EOA ) ;

recurse
	:	^(ASSIGN ID recurseNoLabel)
	|	^(PLUS_ASSIGN ID recurseNoLabel)
	|	recurseNoLabel
	;

recurseNoLabel : {((CommonTree)input.LT(1)).getText().equals(ruleName)}? RULE_REF;

/*
elementNotRecursiveRule
    :   {_t.findFirstType(RULE_REF)!=null && _t.findFirstType(RULE_REF).getText().equals(ruleName)}?
        e:element
    ;
*/

token returns [GrammarAST t=null]
	:	^(ASSIGN ID s=token {$t = $s.t;})
	|	^(PLUS_ASSIGN ID s=token {$t = $s.t;})
	|	^(ROOT s=token {$t = $s.t;})
	|	^(BANG s=token {$t = $s.t;})
	|	a=CHAR_LITERAL      {$t = $a;}
	|	b=STRING_LITERAL    {$t = $b;}
	|	c=TOKEN_REF         {$t = $c;}
	;

exceptionGroup
	:	exceptionHandler+ finallyClause?
	|	finallyClause
    ;

exceptionHandler
	:	^('catch' ARG_ACTION ACTION)
	;

finallyClause
	:	^('finally' ACTION)
	;

rewrite
	:	^(REWRITES ( ^( REWRITE SEMPRED? (^(ALT .*)|^(TEMPLATE .*)|ACTION|ETC) ) )* )
	;

element
	:	^(ROOT element)
	|	^(BANG element)
	|	atom
	|	^(NOT element)
	|	^(RANGE atom atom)
	|	^(ASSIGN ID element)
	|	^(PLUS_ASSIGN ID element)
	|	ebnf
	|	tree_
	|	^(SYNPRED block) 
	|	FORCED_ACTION
	|	ACTION
	|	SEMPRED
	|	SYN_SEMPRED
	|	BACKTRACK_SEMPRED
	|	GATED_SEMPRED
	|	EPSILON 
	;

ebnf:   block
    |   ^( OPTIONAL block ) 
    |   ^( CLOSURE block )  
    |   ^( POSITIVE_CLOSURE block ) 
    ;

tree_
	:	^(TREE_BEGIN element+)
	;

atom
	:	^(RULE_REF ARG_ACTION?)
	|	^(TOKEN_REF ARG_ACTION?)
	|	CHAR_LITERAL
	|	STRING_LITERAL
	|	WILDCARD
	|	^(DOT ID atom) // scope override on rule
	;

ast_suffix
	:	ROOT
	|	BANG
	;
