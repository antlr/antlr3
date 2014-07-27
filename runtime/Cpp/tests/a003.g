grammar a003;

options {
	language=Cpp;
	output=AST;
}

@lexer::includes 
{
#include "ATestTraits.hpp"
}
@lexer::namespace 
{ Antlr3Test }

@parser::includes {
#include "ATestTraits.hpp"
#include "a003Lexer.hpp"
}
@parser::namespace 
{ Antlr3Test }

test1
    :	A^ B C D E F G
    |	B^ C D E F G
	;

test2
    : A^ bcd2 E F G
	| bcd2 E F G
	;
bcd2: B C D;

test3
    : A^ bcd3 E F G
	| bcd3 E F G
    ;
bcd3: B C^ D;

test4
    : A bcd2 E^ F G 'H'
	| bcd2 E^ F G 'H'
    ;

test5
    : A bcd3 E F G 'H'^
    | bcd3 E F G 'H'^
    ;

A: 'A';
B: 'B';
C: 'C';
D: 'D';
E: 'E';
F: 'F';
G: 'G';
