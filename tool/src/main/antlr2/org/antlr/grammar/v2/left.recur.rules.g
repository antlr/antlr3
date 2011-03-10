header {
/*
 [The "BSD license"]
 Copyright (c) 2010 Terence Parr
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
	package org.antlr.grammar.v2;
	import java.util.*;
	import org.antlr.analysis.*;
	import org.antlr.misc.*;
	import java.io.*;
    import org.antlr.tool.*;
    import antlr.TokenWithIndex;
}

/** Find left-recursive rules */
class LeftRecursiveRuleWalker extends TreeParser;

options {
	importVocab = ANTLR;
	ASTLabelType = "GrammarAST";
    codeGenBitsetTestThreshold=999;
}

{
    public void reportError(RecognitionException ex) {
		Token token = null;
		if ( ex instanceof MismatchedTokenException ) {
			token = ((MismatchedTokenException)ex).token;
		}
		else if ( ex instanceof NoViableAltException ) {
			token = ((NoViableAltException)ex).token;
		}
        ErrorManager.syntaxError(
            ErrorManager.MSG_SYNTAX_ERROR,
            grammar,
            token,
            "assign.types: "+ex.toString(),
            ex);
    }


protected Grammar grammar;
String ruleName;
int outerAlt; // which outer alt of rule?
public int numAlts;  // how many alts for this rule total?
public void setTokenPrec(GrammarAST t, int alt) {;}

public void binaryAlt(GrammarAST altTree, GrammarAST rewriteTree, int alt) {;}
public void ternaryAlt(GrammarAST altTree, GrammarAST rewriteTree, int alt) {;}
public void prefixAlt(GrammarAST altTree, GrammarAST rewriteTree, int alt) {;}
public void suffixAlt(GrammarAST altTree, GrammarAST rewriteTree, int alt) {;}
public void otherAlt(GrammarAST altTree, GrammarAST rewriteTree, int alt) {;}
public void setReturnValues(GrammarAST t) {;}
}

optionsSpec
    :   #( OPTIONS (option)+ )
    ;

option
    :   #( ASSIGN id:ID optionValue )
    ;

optionValue
    :   id:ID
    |   s:STRING_LITERAL
    |   c:CHAR_LITERAL
    |   i:INT
    ;

charSetElement
	:   c:CHAR_LITERAL
	|   #( OR c1:CHAR_LITERAL c2:CHAR_LITERAL )
	|   #( RANGE c3:CHAR_LITERAL c4:CHAR_LITERAL )
	;

rec_rule[Grammar g] returns [boolean isLeftRec=false]
{
	grammar = g;
	outerAlt = 1;
}
    :   #( r:RULE id:ID {ruleName=#id.getText();}
           (m:modifier)?
           #(ARG (arg:ARG_ACTION)?)
           #(RET (ret:ARG_ACTION {setReturnValues(#ret);})?)
           (optionsSpec)?
           (ruleScopeSpec)?
       	   (AMPERSAND)*
           isLeftRec=ruleBlock
           (exceptionGroup)?
           EOR
         )
         {if ( isLeftRec ) r.setType(PREC_RULE);}
    ;

modifier
	:	"protected"
	|	"public"
	|	"private"
	|	"fragment"
	;

ruleScopeSpec
 	:	#( "scope" (ACTION)? ( ID )* )
 	;

ruleBlock returns [boolean isLeftRec=false]
{boolean lr=false; this.numAlts = #ruleBlock.getNumberOfChildren();}
    :   #(  BLOCK
            (optionsSpec)?
            (
                lr=outerAlternative
                {if ( lr ) isLeftRec = true;}
                (r:rewrite | {#r=null;})
                {
                outerAlt++;
                }
            )+
            EOB
         )
    ;

block
    :   #(  BLOCK
            (optionsSpec)?
            ( #( ALT (element)+ EOA ) (rewrite)? )+
            EOB
         )
    ;

/** An alt is either prefix, suffix, binary, or ternary operation or "other" */
outerAlternative returns [boolean isLeftRec=false]
{
GrammarAST alt=#outerAlternative, rew=(GrammarAST)alt.getNextSibling();
if ( rew.getType()!=REWRITES ) rew = null;
//System.out.println("alt "+alt.toStringTree());
}
    :   (binaryMultipleOp)=> binaryMultipleOp
                             {binaryAlt(alt, rew, outerAlt); isLeftRec=true;}
    |   (binary)=>           b:binary
                             {binaryAlt(alt, rew, outerAlt); isLeftRec=true;}
    |   (ternary)=>          ternary
                             {ternaryAlt(alt, rew, outerAlt); isLeftRec=true;}
    |   (prefix)=>           prefix
                             {prefixAlt(alt, rew, outerAlt);}
                             // prefix alone not enough to trigger match
    |   (suffix)=>           s:suffix
                             {suffixAlt(alt, rew, outerAlt); isLeftRec=true;}
    |   #( ALT (element)+ EOA ) // "other" case
                             {otherAlt(alt, rew, outerAlt);}
    ;

binary
{GrammarAST op=null;}
    :   #( ALT (BACKTRACK_SEMPRED)? recurseNoLabel op=token recurse EOA ) {setTokenPrec(op, outerAlt);}
    ;

binaryMultipleOp
{GrammarAST op=null;}
    :   #( ALT (BACKTRACK_SEMPRED)? recurseNoLabel #( BLOCK ( #( ALT op=token EOA {setTokenPrec(op, outerAlt);} ) )+ EOB ) recurse EOA )
    ;

ternary
{GrammarAST op=null;}
    : #( ALT (BACKTRACK_SEMPRED)? recurseNoLabel op=token recurse token recurse EOA ) {setTokenPrec(op, outerAlt);}
    ;

prefix : #( ALT (BACKTRACK_SEMPRED)? {setTokenPrec((GrammarAST)_t, outerAlt);} ({!_t.getText().equals(ruleName)}? element)+ recurse EOA ) ;

suffix : #( ALT (BACKTRACK_SEMPRED)? recurseNoLabel {setTokenPrec((GrammarAST)_t, outerAlt);} (e:element)+  EOA ) ;

recurse
    :   #(ASSIGN ID recurseNoLabel)
    |   #(PLUS_ASSIGN ID recurseNoLabel)
    |   recurseNoLabel
    ;

recurseNoLabel : {_t.getText().equals(ruleName)}? RULE_REF;

/*
elementNotRecursiveRule
    :   {_t.findFirstType(RULE_REF)!=null && _t.findFirstType(RULE_REF).getText().equals(ruleName)}?
        e:element
    ;
*/

token returns [GrammarAST t=null]
    :   #(ASSIGN ID t=token)
    |   #(PLUS_ASSIGN ID t=token)
    |   #(ROOT t=token)
    |   #(BANG t=token)
    |   a:CHAR_LITERAL      {t = a;}
    |   b:STRING_LITERAL    {t = b;}
    |   c:TOKEN_REF         {t = c;}
    ;

exceptionGroup
	:	( exceptionHandler )+ (finallyClause)?
	|	finallyClause
    ;

exceptionHandler
    :    #("catch" ARG_ACTION ACTION)
    ;

finallyClause
    :    #("finally" ACTION)
    ;

rewrite
	:	#(REWRITES ( #( REWRITE (SEMPRED)? (ALT|TEMPLATE|ACTION|ETC) ) )* )
	;

element
    :   #(ROOT element)
    |   #(BANG element)
    |   atom
    |   #(NOT element)
    |   #(RANGE atom atom)
    |	#(ASSIGN ID element)
    |	#(PLUS_ASSIGN ID element)
    |   ebnf
    |   tree
    |   #( SYNPRED block )
    |   FORCED_ACTION
    |   ACTION
    |   SEMPRED
    |   SYN_SEMPRED
    |   BACKTRACK_SEMPRED
    |   GATED_SEMPRED
    |   EPSILON
    ;

ebnf:   block
    |   #( OPTIONAL block )
    |   #( CLOSURE block )
    |   #( POSITIVE_CLOSURE block )
    ;

tree:   #(TREE_BEGIN  element (element)*  )
    ;


atom
    :   #( rr:RULE_REF (rarg:ARG_ACTION)? )
    |   #( t:TOKEN_REF (targ:ARG_ACTION )? )
    |   c:CHAR_LITERAL
    |   s:STRING_LITERAL
    |   WILDCARD
    |   #(DOT ID atom) // scope override on rule
    ;

ast_suffix
	:	ROOT
	|	BANG
	;
