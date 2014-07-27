grammar a004;

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
#include "a004Lexer.hpp"
}
@parser::namespace 
{ Antlr3Test }

test1
    :	A B C D E F G  -> ^(A B C D E F G)
	;

// TODO: the "D" letter here leaks memory
test2
    : A bcd2 E F G     -> ^(A bcd2 D E F G)
	;
bcd2: B C D;

test3
    : A bcd3 E F G     -> ^(A bcd3 E F G)
    ;
bcd3
	: B C D            -> ^(C B D)
	;        

test4
    : A bcd2 E F G 'H' -> ^('H' A bcd2 E F G)
    ;

test5
    : A bcd3 E F G 'H' -> ^('H' A bcd3 E F G)
    ;

test6
    : A B C D E F G    -> ^(A A B C D E F G A B C D E F G)
    ;

A: 'A';
B: 'B';
C: 'C';
D: 'D';
E: 'E';
F: 'F';
G: 'G';
