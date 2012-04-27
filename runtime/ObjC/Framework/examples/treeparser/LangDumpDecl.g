tree grammar LangDumpDecl;
options {
    tokenVocab=Lang;
	language = ObjC;
    ASTLabelType = CommonTree;
}

decl : ^(DECL type declarator)
       // label.start, label.start, label.text
       { NSLog(@"int \%@", $declarator.text);}
     ;

type : INTTYPE ;

declarator
     : ID
     ;
