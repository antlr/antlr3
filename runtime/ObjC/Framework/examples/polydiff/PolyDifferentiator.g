tree grammar PolyDifferentiator;
options {
	tokenVocab=Poly;
    language=ObjC;
	ASTLabelType=CommonTree;
	output=AST;
//	rewrite=true; // works either in rewrite or normal mode
}

poly:	^('+' poly poly)
	|	^(MULT INT ID)		-> INT
	|	^(MULT c=INT ^('^' ID e=INT))
		{
		NSString *c2 = [NSString stringWithFormat:@"\%d", $c.int*$e.int];
		NSString *e2 = [NSString stringWithFormat:@"\%d", $e.int-1];
		}
							-> ^(MULT[@"*"] INT[c2] ^('^' ID INT[e2]))
	|	^('^' ID e=INT)
		{
		NSString *c2 = [NSString stringWithFormat:@"\%d", $e.int];
		NSString *e2 = [NSString stringWithFormat:@"\%d", $e.int-1];
		}
							-> ^(MULT[@"*"] INT[c2] ^('^' ID INT[e2]))
	|	INT					-> INT[@"0"]
	|	ID					-> INT[@"1"]
	;
