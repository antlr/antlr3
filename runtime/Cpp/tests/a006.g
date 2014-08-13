grammar a006;

options {
	language=Cpp;
	output=AST;
}

tokens {
    T_A = 'token A';
    P_R = 'token pivot root';
    S_R = 'token sample root';
    E_R = 'token expression root';
}

@lexer::includes 
{
#include "ATestTraits.hpp"
}
@lexer::namespace 
{ Antlr3Test }

@parser::includes {
#include "ATestTraits.hpp"
#include "a006Lexer.hpp"
}
@parser::namespace 
{ Antlr3Test }

test1 // see unpivot_in_elements
    :   (    column_name
        |    '(' column_name (',' column_name)* ')'
        )
        (     'AS'
            (    constant
            |    ('(')=> '(' constant (',' constant)* ')'
            )
        )?
        -> column_name+ ^(P_R constant*)
    ;

test2 // see unpivot_in_elements
    :   (    column_name
        |    '(' column_name (',' column_name)* ')'
        )
        (     'AS'
            (    constant
            |    ('(')=> '(' constant (',' constant)* ')'
            )
        )?
        -> column_name+ ^(P_R constant)*
    ;


test3 //sample_clause
    :	s='SAMPLE' 'BLOCK'? 
        '(' c1=constant (',' c2=constant)? ')'
        -> ^(S_R[$s] 'BLOCK'? ^(E_R $c1) ^(E_R $c2)?)
    ;

column_name
	:	T_COLUMN_NAME;

constant
	:	T_CONSTANT;

T_COLUMN_NAME
	:	('A'..'Z')+;

T_CONSTANT
	:	('0'..'9')+;

WS
    : ' '+  { $channel = HIDDEN; };
