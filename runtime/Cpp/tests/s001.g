grammar s001;

options {
	language=Cpp;
	//backtrack=true;
	//memoize=true;
	//output=AST;
}

tokens {
    BLOCK = 'block';
}

@lexer::includes 
{
#include "UserTestTraits.hpp"
}
@lexer::namespace 
{ Antlr3Test }

@parser::includes {
#include "UserTestTraits.hpp"
#include "s001Lexer.hpp"
}
@parser::namespace 
{ Antlr3Test }

start_rule : if_statement;

if_statement
    : /*ifSt=*/IF LEFT_PAREN  /*cond=*/expression RIGHT_PAREN if_then if_else?
      //->  ^(IF_ST[$ifSt] $cond if_then if_else?)
    ;
if_then
    : th=LEFT_BRACE /*thexpr=*/script? RIGHT_BRACE //-> ^(BLOCK[$th] $thexpr?)
    | /*cs=*/script //-> ^(BLOCK $cs)
    ;

if_else
    : el=ELSE LEFT_BRACE elexpr=script? RIGHT_BRACE  //-> ^(BLOCK[$el] $elexpr?)
    | el=ELSE /*cs=*/script//-> ^(BLOCK[$el] $cs)
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

