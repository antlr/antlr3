lexer grammar t027eof;

options {
    language=Cpp;
}

@lexer::includes
{
#include "UserTestTraits.hpp"
}
@lexer::namespace
{ Antlr3Test }

END: EOF;
SPACE: ' ';
