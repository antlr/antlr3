grammar t037rulePropertyRef;
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

a returns [bla]
@after {
    $bla = $start, $stop, $text
}
    : A+
    ;

A: 'a'..'z';

WS: ' '+  { $channel = HIDDEN };
