lexer grammar t025lexerRulePropertyRef;
options {
  language =Cpp;
}

@lexer::includes
{
#include "UserTestTraits.hpp"
}
@lexer::namespace
{ Antlr3Test }

@lexer::init {
self.properties = []
}

IDENTIFIER: 
        ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
        {
self.properties.append(
    ($text, $type, $line, $pos, $index, $channel, $start, $stop)
)
        }
    ;
WS: (' ' | '\n')+;
