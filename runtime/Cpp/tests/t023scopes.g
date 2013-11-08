grammar t023scopes;

options {
    language=Cpp;
}

@lexer::includes
{
#include "UserTestTraits.hpp"
}
@lexer::namespace
{ Antlr3Test }

@parser::includes {
#include "UserTestTraits.hpp"
}
@parser::namespace
{ Antlr3Test }

prog
scope {
name
}
    :   ID {$prog::name=$ID.text;}
    ;

ID  :   ('a'..'z')+
    ;

WS  :   (' '|'\n'|'\r')+ {$channel=HIDDEN}
    ;
