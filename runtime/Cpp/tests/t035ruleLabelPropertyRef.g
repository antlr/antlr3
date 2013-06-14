grammar t035ruleLabelPropertyRef;
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

a returns [bla]: t=b
        {
            $bla = $t.start, $t.stop, $t.text
        }
    ;

b: A+;

A: 'a'..'z';

WS: ' '+  { $channel = HIDDEN };
