lexer grammar t006lexer;
options {
  language =Cpp;
}

@lexer::includes
{
#include "UserTestTraits.hpp"
}
@lexer::namespace
{ Antlr3Test }

FOO: 'f' ('o' | 'a')*;
