tree grammar SimpleCTP;
options {
    tokenVocab = SimpleC;
	language = ObjC;
	ASTLabelType = ANTLRCommonTree;
}

scope Symbols
{
ANTLRCommonTree *tree;
}

program
    :   declaration+
    ;

declaration
    :   variable
    |   ^(FUNC_DECL functionHeader)
    |   ^(FUNC_DEF functionHeader block)
    ;

variable
    :   ^(VAR_DEF type declarator)
    ;

declarator
    :   K_ID 
    ;

functionHeader
    :   ^(FUNC_HDR type K_ID formalParameter+)
    ;

formalParameter
    :   ^(ARG_DEF type declarator)
    ;

type
    :   K_INT_TYPE
    |   K_CHAR  
    |   K_VOID
    |   K_ID        
    ;

block
    :   ^(BLOCK variable* stat*)
    ;

stat: forStat
    | expr
    | block
    ;

forStat
    :   ^(K_FOR expr expr expr block)
    ;

expr:   ^(K_EQEQ expr expr)
    |   ^(K_LT expr expr)
    |   ^(K_PLUS expr expr)
    |   ^(K_EQ K_ID e=expr) { NSLog(@"assigning \%@ to variable \%@", $e.text, $K_ID.text); }
    |   atom
    ;

atom
    : K_ID      
    | K_INT      
    ; 
