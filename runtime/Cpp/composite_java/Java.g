/** Exact same grammar as examples-v3/java/Java.g but broken into
 *  multiple pieces to illustrate composing grammars via import statement.
 *  Results in multiple classes with Java referring to others via
 *  delegation pattern.  Run ANTLR only once on this root grammar:
 *
 *		java org.antlr.Tool Java.g
 */
grammar Java;
options {language=Cpp; k=2; backtrack=true; memoize=true;}

import JavaDecl, JavaAnnotations, JavaExpr, JavaStat, JavaLexerRules;

@lexer::includes
{
	#include "UserTraits.hpp"
}

@parser::includes
{
	#include "JavaLexer.hpp"
}
@lexer::namespace { User }
@parser::namespace { User }

compilationUnit
	:	annotations?
		packageDeclaration?
        importDeclaration*
        typeDeclaration*
	;
