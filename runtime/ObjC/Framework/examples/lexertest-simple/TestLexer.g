lexer grammar TestLexer;
options {
	language=ObjC;
}

@header {}

ID	:	LETTER (LETTER | DIGIT)*
	;

fragment DIGIT	:	'0'..'9'
	;

fragment LETTER
	:	'a'..'z' | 'A'..'Z'
	;
