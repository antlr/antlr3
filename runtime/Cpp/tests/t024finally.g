grammar t024finally;

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

prog returns [events]
@init {events = []}
@after {events.append('after')}
    :   ID {raise RuntimeError}
    ;
    catch [RuntimeError] {events.append('catch')}
    finally {events.append('finally')}

ID  :   ('a'..'z')+
    ;

WS  :   (' '|'\n'|'\r')+ {$channel=HIDDEN}
    ;
