tree grammar LangDumpDecl;
options {
    tokenVocab=Lang;
	language = ObjC;
    ASTLabelType = ANTLRCommonTree;
}

decl : ^(DECL type declarator)
       // label.start, label.start, label.text
       { NSLog(@"int \%@", $declarator.text);}
     ;

type : INTTYPE ;

declarator
     : ID
     ;
