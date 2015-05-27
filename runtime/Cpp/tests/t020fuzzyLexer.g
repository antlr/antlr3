lexer grammar t020fuzzyLexer;
options {
    language=Cpp;
    filter=true;
}

@lexer::includes
{
#include "UserTestTraits.hpp"
}
@lexer::namespace
{ Antlr3Test }

@lexer::context {
	ImplTraits::StringStreamType outbuf;
}

IMPORT
	:	'import' WS name=QIDStar WS? ';'
	;
	
/** Avoids having "return foo;" match as a field */
RETURN
	:	'return' (options {greedy=false;}:.)* ';'
	;

CLASS
	:	'class' WS name=ID WS? ('extends' WS QID WS?)?
		('implements' WS QID WS? (',' WS? QID WS?)*)? '{'
        { outbuf << "found class " << $name->getText() << "\n"; }
	;
	
METHOD
    :   TYPE WS name=ID WS? '(' ( ARG WS? (',' WS? ARG WS?)* )? ')' WS? 
       ('throws' WS QID WS? (',' WS? QID WS?)*)? '{'
        { outbuf << "found method " << $name->getText() << "\n"; } 
    ;

FIELD
    :   TYPE WS name=ID '[]'? WS? (';'|'=')
        { outbuf << "found var " << $name->getText() << "\n"; }                
    ;

STAT:	('if'|'while'|'switch'|'for') WS? '(' ;
	
CALL
    :   name=QID WS? '('
        { outbuf << "found call " << $name->getText() << "\n"; }                
    ;

COMMENT
    :   '/*' (options {greedy=false;} : . )* '*/'
        { outbuf << "found comment " << getText() << "\n"; } 
    ;

SL_COMMENT
    :   '//' (options {greedy=false;} : . )* '\n'
        { outbuf << "found // comment " << getText() << "\n"; } 
    ;
	
STRING
	:	'"' (options {greedy=false;}: ESC | .)* '"'
	;

CHAR
	:	'\'' (options {greedy=false;}: ESC | .)* '\''
	;

WS  :   (' '|'\t'|'\n')+
    ;

fragment
QID :	ID ('.' ID)*
	;
	
/** QID cannot see beyond end of token so using QID '.*'? somewhere won't
 *  ever match since k=1 lookahead in the QID loop of '.' will make it loop.
 *  I made this rule to compensate.
 */
fragment
QIDStar
	:	ID ('.' ID)* '.*'?
	;

fragment
TYPE:   QID '[]'?
    ;
    
fragment
ARG :   TYPE WS ID
    ;

fragment
ID  :   ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'_'|'0'..'9')*
    ;

fragment
ESC	:	'\\' ('"'|'\''|'\\')
	;
