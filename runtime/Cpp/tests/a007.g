grammar a007;

options {
	language=Cpp;
	output=AST;
}

tokens {
    T_A = 'token A';
    P_R = 'token pivot root';
    S_R = 'token sample root';
    E_R = 'token expression root';

    T_ADHOC_ENUM_VAL = 'ad-hoc generated enum constant';
}

@lexer::includes 
{
#include "A007TestTraits.hpp"
}
@lexer::namespace 
{ Antlr3Test }

@parser::includes {
#include "A007TestTraits.hpp"
#include "a007Lexer.hpp"
}
@parser::namespace 
{ Antlr3Test }

test1 // see unpivot_in_elements
    :   (    column_name[T_ADHOC_ENUM_VAL]
        |    '(' column_name[0] (',' column_name[0])* ')'
        )
        (     'AS'
            (    constant
            |    ('(')=> '(' constant (',' constant)* ')'
            )
        )?
        -> column_name+ ^(P_R constant*)
    ;

test2 // see unpivot_in_elements
    :   (    column_name[T_ADHOC_ENUM_VAL]
        |    '(' column_name[0] (',' column_name[0])* ')'
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

column_name[int identifierClass]
	:	t=T_COLUMN_NAME
        {
            // We have to get over const correctness here:
            // const_cast<CommonTokenType*>($t)->set_type(ID);
            const_cast<CommonTokenType*>($t)->UserData.identifierClass = identifierClass;            
        }
    ;

constant
	:	T_CONSTANT;

T_COLUMN_NAME
	:	('A'..'Z')+;

T_CONSTANT
	:	('0'..'9')+;

WS
    : ' '+  { $channel = HIDDEN; };
