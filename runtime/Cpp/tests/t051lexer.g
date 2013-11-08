// Lexer grammar using synpreds
lexer grammar t051lexer;

options {
	language=Cpp;
}

@lexer::includes
{
#include "UserTestTraits.hpp"
}
@lexer::namespace
{ Antlr3Test }

fragment
POINT
	:	'.'
	;
NUMBER
	: (	( NUM POINT NUM ) => NUM POINT NUM
		|	POINT NUM
		|	NUM
		)
    ;
fragment
NUM
	: '0' .. '9' ( '0' .. '9' )*
	;
