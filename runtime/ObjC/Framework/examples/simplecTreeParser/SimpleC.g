grammar SimpleC;
options {
    output=AST;
    language=ObjC;
}

tokens {
    VAR_DEF;
    ARG_DEF;
    FUNC_HDR;
    FUNC_DECL;
    FUNC_DEF;
    BLOCK;
}

program
    :   declaration+
    ;

declaration
    :   variable
    |   functionHeader K_SEMICOLON -> ^(FUNC_DECL functionHeader)
    |   functionHeader block -> ^(FUNC_DEF functionHeader block)
    ;

variable
    :   type declarator K_SEMICOLON -> ^(VAR_DEF type declarator)
    ;

declarator
    :   K_ID 
    ;

functionHeader
    :   type K_ID K_LCURVE ( formalParameter ( K_COMMA formalParameter )* )? K_RCURVE
        -> ^(FUNC_HDR type K_ID formalParameter+)
    ;

formalParameter
    :   type declarator -> ^(ARG_DEF type declarator)
    ;

type
    :   K_INT_TYPE   
    |   K_CHAR  
    |   K_VOID
    |   K_ID        
    ;

block
    :   lc=K_LCURLY
            variable*
            stat*
        K_RCURLY
        -> ^(BLOCK[$lc,@"BLOCK"] variable* stat*)
    ;

stat: forStat
    | expr K_SEMICOLON!
    | block
    | assignStat K_SEMICOLON!
    | K_SEMICOLON!
    ;

forStat
    :   K_FOR K_LCURVE start=assignStat K_SEMICOLON expr K_SEMICOLON next=assignStat K_RCURVE block
        -> ^(K_FOR $start expr $next block)
    ;

assignStat
    :   K_ID K_EQ expr -> ^(K_EQ K_ID expr)
    ;

expr:   condExpr
    ;

condExpr
    :   aexpr ( (K_EQEQ^ | K_LT^) aexpr )?
    ;

aexpr
    :   atom ( K_PLUS^ atom )*
    ;

atom
    : K_ID      
    | K_INT      
    | K_LCURVE expr K_RCURVE -> expr
    ; 

K_FOR : 'for' ;
K_CHAR: 'char';
K_INT_TYPE : 'int' ;
K_VOID: 'void';

K_ID  :   ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
    ;

K_INT :	anInt+=('0'..'9')+ {NSLog(@"\%@", $anInt);}
    ;

K_LCURVE : '(';
K_RCURVE : ')';
K_PLUS : '+' ;
K_COMMA : ',';
K_SEMICOLON : ';';
K_LT   : '<' ;
K_EQ   : '=' ;
K_EQEQ : '==' ;
K_LCURLY : '{';
K_RCURLY : '}';

WS  :   (   ' '
        |   '\t'
        |   '\r'
        |   '\n'
        )+
        { $channel=HIDDEN; }
    ;    
