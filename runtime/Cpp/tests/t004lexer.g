lexer grammar t004lexer;
options {
  language =Cpp;
}

@lexer::includes
{
#include "UserTestTraits.hpp"
}
@lexer::namespace
{ Antlr3Test }

FOO: 'f' f=OO;

fragment
OO: 'o'*;
