lexer grammar t038lexerRuleLabel;
options {
  language =Cpp;
}

@lexer::includes
{
#include "UserTestTraits.hpp"
}
@lexer::namespace
{ Antlr3Test }

A: 'a'..'z' WS '0'..'9'
        {
            print($WS)
            print($WS.type)
            print($WS.line)
            print($WS.pos)
            print($WS.channel)
            print($WS.index)
            print($WS.text)
        }
    ;

fragment WS  :
        (   ' '
        |   '\t'
        |  ( '\n'
            |	'\r\n'
            |	'\r'
            )
        )+
        { $channel = HIDDEN }
    ;    

