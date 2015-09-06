grammar a005;

options {
	language=Cpp;
	output=AST;
}

tokens {
    T_A = 'token A';
}

@lexer::includes 
{
#include "ATestTraits.hpp"
}
@lexer::namespace 
{ Antlr3Test }

@parser::includes {
#include "ATestTraits.hpp"
#include "a005Lexer.hpp"
}
@parser::namespace 
{ Antlr3Test }

test1
    :	a=A b=B c=C -> ^($a $b $c)
	;

test2
    :	a1=A a2=A b1=B b2=B c1=C c2=C -> ^($a1 $b1 $c1)
	;

test3
    :	a1=A A b1=B B c1=C C -> ^($a1 $b1 $c1)
	;

test4
    :	a1=A b1=B c1=C -> ^(T_A[$a1] $a1 $b1 $c1)
	;

test5
@init	{    int mode = 0;    }
	:	aa (bb {mode = 1;} | cc) dd ee
        -> {mode == 1}? ^( aa bb? cc? dd ee)
        -> ^( aa bb? cc? dd ee)
    ;
aa: A;
bb: B;
cc: C;
dd: D;
ee: E;

test6
@init	{    int mode = 0;    }
	:	A (B {mode = 1;} | C) D E
        -> {mode == 1}? ^( A B? C? D E)
        -> ^( A B? C? D E)
    ;

A: 'A';
B: 'B';
C: 'C';
D: 'D';
E: 'E';
F: 'F';
G: 'G';
