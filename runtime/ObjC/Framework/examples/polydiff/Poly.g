grammar Poly;
options {
    output=AST;
    language=ObjC;
    }
tokens { MULT; } // imaginary token

poly: term ('+'^ term)*
    ;

term: INT ID  -> ^(MULT[@"*"] INT ID)
    | INT exp -> ^(MULT[@"*"] INT exp)
    | exp
    | INT
	| ID
    ;

exp : ID '^'^ INT
    ;
    
ID  returns [NSString *value]
    : 'a'..'z'+ ;

INT  returns [NSString *value]
    : '0'..'9'+ ;

WS	: (' '|'\t'|'\r'|'\n')+ { $channel=HIDDEN; } ;
