tree grammar PolyPrinter;
options {
	tokenVocab=Poly;
    language=ObjC;
	ASTLabelType=CommonTree;
	output=template;
}

poly:	^('+'  a=poly b=poly)	-> template(a={$a.st} b:b={$b.st}) "<a>+<b>"
	|	^(MULT a=poly b=poly)	-> template(a={$a.st} b:b={$b.st}) "<a><b>"
	|	^('^'  a=poly b=poly)	-> template(a={$a.st} b:b={$b.st}) "<a>^<b>"
	|	INT						-> {%{$INT.text}}
	|	ID						-> {%{$ID.text}}
	;
