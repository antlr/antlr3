grammar t014parser;
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

@parser::init {
self.events = []
self.reportedErrors = []
}

@parser::members {
def emitErrorMessage(self, msg):
    self.reportedErrors.append(msg)
}
        

document:
        ( declaration
        | call
        )*
        EOF
    ;

declaration:
        'var' t=IDENTIFIER ';'
        {self.events.append(('decl', $t.text))}
    ;

call:
        t=IDENTIFIER '(' ')' ';'
        {self.events.append(('call', $t.text))}
    ;

IDENTIFIER: ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;
WS:  (' '|'\r'|'\t'|'\n') {$channel=HIDDEN;};
