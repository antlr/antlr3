parser grammar JavaStat;

@includes
{
	#include "UserTraits.hpp"
}
@namespace
{
	User
}
methodBody
    :   block
    ;

block
	:	'{' blockStatement* '}'
	;
	
blockStatement
	:	localVariableDeclaration
	|	classOrInterfaceDeclaration
    	|	statement
	;
	
localVariableDeclaration
	:	variableModifier* type variableDeclarators ';'
	;
	
statement
	: block
    | 'assert' expression (':' expression)? ';'
    | 'if' parExpression statement (options {k=1; backtrack=false;}:'else' statement)?
    | 'for' '(' forControl ')' statement
    | 'while' parExpression statement
    | 'do' statement 'while' parExpression ';'
    | 'try' block
      (	catches 'finally' block
      | catches
      | 'finally' block
      )
    | 'switch' parExpression '{' switchBlockStatementGroups '}'
    | 'synchronized' parExpression block
    | 'return' expression? ';'
    | 'throw' expression ';'
    | 'break' Identifier? ';'
    | 'continue' Identifier? ';'
    | ';'
    | statementExpression ';'
    | Identifier ':' statement
	;
	
catches
	:	catchClause (catchClause)*
	;
	
catchClause
	:	'catch' '(' formalParameter ')' block
	;

formalParameter
	:	variableModifier* type variableDeclaratorId
	;
		
switchBlockStatementGroups
	:	(switchBlockStatementGroup)*
	;
	
switchBlockStatementGroup
	:	switchLabel blockStatement*
	;
	
switchLabel
	:	'case' constantExpression ':'
	|   'case' enumConstantName ':'
	|   'default' ':'
	;
	
moreStatementExpressions
	:	(',' statementExpression)*
	;

forControl
options {k=3;} // be efficient for common case: for (ID ID : ID) ...
	:	forVarControl
	|	forInit? ';' expression? ';' forUpdate?
	;

forInit
	:	variableModifier* type variableDeclarators
	|	expressionList
	;
	
forVarControl
	:	variableModifier* type Identifier ':' expression
	;

forUpdate
	:	expressionList
	;

