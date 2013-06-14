grammar t041parameters;
options {
  language =Cpp;
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

a[arg1, arg2] returns [l]
    : A+ EOF
        { 
            l = ($arg1, $arg2) 
            $arg1 = "gnarz"
        }
    ;

A: 'a'..'z';

WS: ' '+  { $channel = HIDDEN };
