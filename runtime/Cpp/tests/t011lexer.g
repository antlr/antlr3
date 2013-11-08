lexer grammar t011lexer;
options {
  language =Cpp;
}

@lexer::includes
{
#include "UserTestTraits.hpp"
#include <iostream>
}
@lexer::namespace
{ Antlr3Test }

IDENTIFIER: 
        ('a'..'z'|'A'..'Z'|'_') 
        ('a'..'z'
        |'A'..'Z'
        |'0'..'9'
        |'_'
            { 
              std::cout << "Underscore";
              std::cout << "foo";
            }
        )*
    ;

WS: (' ' | '\n')+;
