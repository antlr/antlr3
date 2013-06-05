grammar C;

options {
    language = Cpp;
}

@lexer::includes {
#include <iostream>
}

@lexer::traits 
{
    class CLexer;
    class CParser;
    typedef antlr3::Traits<CLexer, CParser> CLexerTraits;
    typedef CLexerTraits CParserTraits;
}

@lexer::context {
    bool insideImport_;
}

@lexer::apifuncs {
    insideImport_ = false;
}

@lexer::members {

static bool isValidCharAfterFloatDot(ANTLR_UCHAR c)
{
    return (c >= '0' && c <= '9') || (c == 'E') || (c == 'e');
}

}

@parser::includes {
#include "CLexer.hpp"
}

@parser::members {


}

main : ( t=( DOT
           | RANGE
           | IMPORT
           | AT
           | PACKAGE_REVISION
           | BOOL
           | INT
           | FLOAT
           | COMMENT
           | NEWLINE
           | STRING
           | ID
           | LPAREN
           | RPAREN
           | LBRACK
           | RBRACK
           | LCURLY
           | RCURLY
           | ':'
           | '=')
        {
          std::cout << CParserTokenNames[t->getType()];
          switch (t->getType())
          {
          case PACKAGE_REVISION:
          case BOOL:
          case INT:
          case FLOAT:
          case COMMENT:
          case STRING:
          case ID:
              std::cout << "=\"" << t->getText() << "\"";
          }
          std::cout << std::endl;
        }
    )+;

DOT
    : '.'
    ;
    
RANGE
    : '..'
    ;

IMPORT
    : 'import' { insideImport_ = true; }
    ;

AT
    : {!insideImport_}? => '@'
    ;

PACKAGE_REVISION
    : {insideImport_}? => '@' HEX_DIGIT+ { insideImport_ = false; }
    ;

BOOL
    : 'yes'
    | 'no'
    ;

INT
    : ('0d')? '0'..'9'+
    | '0b' '0'..'1'+
    | '0c' '0'..'7'+
    | '0x' HEX_DIGIT+
    ;

FLOAT
    : DIGIT+
      ( { isValidCharAfterFloatDot(LA(2)) }?=> '.' DIGIT+ EXPONENT?
      | EXPONENT
      | { $type = INT; }
      )
    ;

COMMENT
    : '//' ~('\n'|'\r')* {$channel=HIDDEN;}
    ;

NEWLINE
    : ('\u000C')? '\r'? '\n' { insideImport_ = false; }
    ;

WS
    : ( ' ' | '\t' )+ {$channel=HIDDEN;}
    ;
    
STRING
    : '"' ( ESC_SEQ | ~('\\'|'"') )* '"'
    ;

ID
    : ID_LETTER (ID_LETTER|DIGIT)*
    ;
    
LPAREN
    : '('
    ;
RPAREN
    : ')'
    ;
LBRACK
    : '[' { insideImport_ = false; }
    ;
RBRACK
    : ']'
    ;
LCURLY
    : '{'
    ;
RCURLY
    : '}'
    ;
    
fragment
ID_LETTER 
    : 'a'..'z'|'A'..'Z'|'_'
    ;
    
fragment
DIGIT
    : '0'..'9'
    ;

fragment
EXPONENT
    : ('e'|'E') ('+'|'-')? ('0'..'9')+
    ;

fragment
HEX_DIGIT
    : ('0'..'9'|'a'..'f'|'A'..'F')
    ;

fragment
ESC_SEQ
    :   '\\' ('a'|'b'|'f'|'n'|'r'|'t'|'v'|'\''|'\"'|'\\')
    |   UNICODE_ESC
    ;

fragment
UNICODE_ESC
    :   '\\' 'u' HEX_DIGIT+
    ;
