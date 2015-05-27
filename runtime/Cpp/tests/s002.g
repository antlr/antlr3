grammar s002;

options {
	language=Cpp;
	//backtrack=true;
	//memoize=true;
	output=AST;
}

tokens {
    BLOCK = 'block';
    IF_ST = 'if_st';
}

scope GlobalOne {
	std::string globalFoo;
}

@lexer::includes 
{
#include "UserTestTraits.hpp"
}
@lexer::namespace 
{ Antlr3Test }

@parser::includes {
#include "UserTestTraits.hpp"
#include "s002Lexer.hpp"
#include <string>
}
@parser::namespace 
{ Antlr3Test }


start_rule
scope {
	std::string localFoo;
}
scope GlobalOne;
@init {
}
: if_statement_alt1;

if_statement_alt0
    : ifSt=IF^ (LEFT_PAREN  cond=expression^ RIGHT_PAREN) if_then1 if_else?
    ;

if_statement_alt1
    : ifSt=IF LEFT_PAREN  expression RIGHT_PAREN if_then1 if_else?
        ->  ^(IF_ST[$ifSt] expression if_then1 if_else?)
    ;

if_statement_alt2
    : ifSt=IF LEFT_PAREN cond=expression RIGHT_PAREN if_then2 if_else?
	{
		$GlobalOne::globalFoo.append(".").append($ifSt->getText());
		$start_rule::localFoo.append(".").append($ifSt->getText());
	} 
        ->  ^(IF_ST[$ifSt] $cond if_then2 if_else?)
    ;

if_then1
    : th=LEFT_BRACE script? RIGHT_BRACE -> ^(BLOCK[$th] $th script?)
    | script -> ^(BLOCK script)
    ;

if_then2
    : th=LEFT_BRACE thexpr=script? RIGHT_BRACE -> ^(BLOCK[$th] $th $thexpr?)
    | cs=script -> ^(BLOCK $cs)
    ;

if_else
    : el=ELSE LEFT_BRACE elexpr=script? RIGHT_BRACE -> ^(BLOCK[$el] $elexpr?)
    | el=ELSE cs=script -> ^(BLOCK[$el] $cs)
    ;

script
		: COMMAND SEMI 
		; 

expression
		: EXPRESSION
		;
		
COMMAND: 'COMMAND';

EXPRESSION: 'EXPRESSION';

SEMI: ';';

ELSE: 'ELSE';

IF: 'IF';

LEFT_PAREN: '(';

RIGHT_PAREN: ')';

LEFT_BRACE: '{';

RIGHT_BRACE: '}';

