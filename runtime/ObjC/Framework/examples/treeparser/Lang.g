grammar Lang;
options {
	output=AST;
	language = ObjC;
	ASTLabelType=ANTLRCommonTree;
}

tokens {DECL;} // an imaginary node

start : decl ;

decl : type ID ';' -> ^(DECL type ID)
     ;
type : INTTYPE  // automatic tree construction builds a node for this rule
     | FLOATTYPE
     ;

INTTYPE : 'int' ;
FLOATTYPE : 'float' ;
ID : 'a'..'z'+ ;
INT : '0'..'9'+ ;
WS : (' '|'\n') {$channel=HIDDEN;} ;
