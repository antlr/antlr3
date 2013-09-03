grammar t046rewrite;
options {
    language=Cpp;
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

program
@init {
    start = self.input.LT(1)
}
    :   method+
        {
        self.input.insertBefore(start,"public class Wrapper {\n")
        self.input.insertAfter($method.stop, "\n}\n")
        }
    ;

method
    :   m='method' ID '(' ')' body
        {self.input.replace($m, "public void");}
    ; 

body
scope {
    decls
}
@init {
    $body::decls = set()
}
    :   lcurly='{' stat* '}'
        {
        for it in $body::decls:
            self.input.insertAfter($lcurly, "\nint "+it+";")
        }
    ;

stat:   ID '=' expr ';' {$body::decls.add($ID.text);}
    ;

expr:   mul ('+' mul)* 
    ;

mul :   atom ('*' atom)*
    ;

atom:   ID
    |   INT
    ;

ID  :   ('a'..'z'|'A'..'Z')+ ;

INT :   ('0'..'9')+ ;

WS  :   (' '|'\t'|'\n')+ {$channel=HIDDEN;}
    ;
