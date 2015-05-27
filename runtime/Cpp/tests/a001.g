grammar a001;

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
#include "a001Lexer.hpp"
}
@parser::namespace 
{ Antlr3Test }

test1: A B C D E F G;

test2: A bcd E F G;
bcd: B C D;

test3: A bcd E F G 'H';

A: 'A';
B: 'B';
C: 'C';
D: 'D';
E: 'E';
F: 'F';
G: 'G';
