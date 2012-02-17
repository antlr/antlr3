tree grammar Simplifier;
options {
	tokenVocab=Poly;
    language=ObjC;
	ASTLabelType=CommonTree;
	output=AST;
	backtrack=true;
//	rewrite=true; // works either in rewrite or normal mode
}

/** Match some common patterns that we can reduce via identity
 *  definitions.  Since this is only run once, it will not be
 *  perfect.  We'd need to run the tree into this until nothing
 *  changed to make it correct.
 */
poly:	^('+' a=INT b=INT)	-> INT[[NSString stringWithFormat:@"\%d", ($a.int+$b.int)\]]

	|	^('+' ^('+' a=INT p=poly) b=INT)
							-> ^('+' $p INT[[NSString stringWithFormat:@"\%d", ($a.int+$b.int)\]])
	
	|	^('+' ^('+' p=poly a=INT) b=INT)
							-> ^('+' $p INT[[NSString stringWithFormat:@"\%d", ($a.int+$b.int)\]])
	
	|	^('+' p=poly q=poly)-> { [[$p.tree toStringTree] isEqualToString:@"0"] }? $q
							-> { [[$q.tree toStringTree] isEqualToString:@"0"] }? $p
							-> ^('+' $p $q)

	|	^(MULT INT poly)	-> {$INT.int==1}? poly
							-> ^(MULT INT poly)

	|	^('^' ID e=INT)		-> {$e.int==1}? ID
							-> {$e.int==0}? INT[@"1"]
							-> ^('^' ID INT)

	|	INT
	|	ID
	;
