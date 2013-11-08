lexer grammar t048rewrite2;
options {
    language=Cpp;
}

@lexer::includes
{
#include "UserTestTraits.hpp"
}
@lexer::namespace
{ Antlr3Test }

ID : 'a'..'z'+;
INT : '0'..'9'+;
SEMI : ';';
PLUS : '+';
MUL : '*';
ASSIGN : '=';
WS : ' '+;
