grammar t050decorate;
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
        
@header {
    def logme(func):
        def decorated(self, *args, **kwargs):
            self.events.append('before')
            try:
                return func(self, *args, **kwargs)
            finally:
                self.events.append('after')

        return decorated
}

@parser::init {
self.events = []
}

document
@decorate {
    @logme
}
    : IDENTIFIER
    ;

IDENTIFIER: ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;
