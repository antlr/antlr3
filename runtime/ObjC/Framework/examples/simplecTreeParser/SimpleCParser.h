// $ANTLR ${project.version} ${buildNumber} SimpleC.g 2011-05-06 15:09:17

/* =============================================================================
 * Standard antlr3 OBJC runtime definitions
 */
#import <Cocoa/Cocoa.h>
#import <ANTLR/ANTLR.h>
/* End of standard antlr3 runtime definitions
 * =============================================================================
 */

/* parserHeaderFile */
#ifndef ANTLR3TokenTypeAlreadyDefined
#define ANTLR3TokenTypeAlreadyDefined
typedef enum {
    ANTLR_EOF = -1,
    INVALID,
    EOR,
    DOWN,
    UP,
    MIN
} ANTLR3TokenType;
#endif

#pragma mark Cyclic DFA interface start DFA2
@interface DFA2 : ANTLRDFA {
}
+ newDFA2WithRecognizer:(ANTLRBaseRecognizer *)theRecognizer;
- initWithRecognizer:(ANTLRBaseRecognizer *)recognizer;
@end /* end of DFA2 interface  */

#pragma mark Cyclic DFA interface end DFA2

#pragma mark Tokens
#ifdef EOF
#undef EOF
#endif
#define EOF -1
#define ARG_DEF 4
#define BLOCK 5
#define FUNC_DECL 6
#define FUNC_DEF 7
#define FUNC_HDR 8
#define K_CHAR 9
#define K_COMMA 10
#define K_EQ 11
#define K_EQEQ 12
#define K_FOR 13
#define K_ID 14
#define K_INT 15
#define K_INT_TYPE 16
#define K_LCURLY 17
#define K_LCURVE 18
#define K_LT 19
#define K_PLUS 20
#define K_RCURLY 21
#define K_RCURVE 22
#define K_SEMICOLON 23
#define K_VOID 24
#define VAR_DEF 25
#define WS 26
#pragma mark Dynamic Global Scopes
#pragma mark Dynamic Rule Scopes
#pragma mark Rule Return Scopes start
/* returnScopeInterface SimpleCParser_program_return */
@interface SimpleCParser_program_return :ANTLRParserRuleReturnScope { /* returnScopeInterface line 1838 */
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; /* ObjC start of memVars() */
}
/* start properties */
/* AST returnScopeInterface.properties */
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_program_return *)newSimpleCParser_program_return;
/* this is start of set and get methods */
/* AST returnScopeInterface.methodsDecl */
- (ANTLRCommonTree *)getTree;

- (void) setTree:(ANTLRCommonTree *)aTree;
  /* methodsDecl */
@end /* end of returnScopeInterface interface */



/* returnScopeInterface SimpleCParser_declaration_return */
@interface SimpleCParser_declaration_return :ANTLRParserRuleReturnScope { /* returnScopeInterface line 1838 */
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; /* ObjC start of memVars() */
}
/* start properties */
/* AST returnScopeInterface.properties */
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_declaration_return *)newSimpleCParser_declaration_return;
/* this is start of set and get methods */
/* AST returnScopeInterface.methodsDecl */
- (ANTLRCommonTree *)getTree;

- (void) setTree:(ANTLRCommonTree *)aTree;
  /* methodsDecl */
@end /* end of returnScopeInterface interface */



/* returnScopeInterface SimpleCParser_variable_return */
@interface SimpleCParser_variable_return :ANTLRParserRuleReturnScope { /* returnScopeInterface line 1838 */
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; /* ObjC start of memVars() */
}
/* start properties */
/* AST returnScopeInterface.properties */
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_variable_return *)newSimpleCParser_variable_return;
/* this is start of set and get methods */
/* AST returnScopeInterface.methodsDecl */
- (ANTLRCommonTree *)getTree;

- (void) setTree:(ANTLRCommonTree *)aTree;
  /* methodsDecl */
@end /* end of returnScopeInterface interface */



/* returnScopeInterface SimpleCParser_declarator_return */
@interface SimpleCParser_declarator_return :ANTLRParserRuleReturnScope { /* returnScopeInterface line 1838 */
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; /* ObjC start of memVars() */
}
/* start properties */
/* AST returnScopeInterface.properties */
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_declarator_return *)newSimpleCParser_declarator_return;
/* this is start of set and get methods */
/* AST returnScopeInterface.methodsDecl */
- (ANTLRCommonTree *)getTree;

- (void) setTree:(ANTLRCommonTree *)aTree;
  /* methodsDecl */
@end /* end of returnScopeInterface interface */



/* returnScopeInterface SimpleCParser_functionHeader_return */
@interface SimpleCParser_functionHeader_return :ANTLRParserRuleReturnScope { /* returnScopeInterface line 1838 */
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; /* ObjC start of memVars() */
}
/* start properties */
/* AST returnScopeInterface.properties */
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_functionHeader_return *)newSimpleCParser_functionHeader_return;
/* this is start of set and get methods */
/* AST returnScopeInterface.methodsDecl */
- (ANTLRCommonTree *)getTree;

- (void) setTree:(ANTLRCommonTree *)aTree;
  /* methodsDecl */
@end /* end of returnScopeInterface interface */



/* returnScopeInterface SimpleCParser_formalParameter_return */
@interface SimpleCParser_formalParameter_return :ANTLRParserRuleReturnScope { /* returnScopeInterface line 1838 */
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; /* ObjC start of memVars() */
}
/* start properties */
/* AST returnScopeInterface.properties */
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_formalParameter_return *)newSimpleCParser_formalParameter_return;
/* this is start of set and get methods */
/* AST returnScopeInterface.methodsDecl */
- (ANTLRCommonTree *)getTree;

- (void) setTree:(ANTLRCommonTree *)aTree;
  /* methodsDecl */
@end /* end of returnScopeInterface interface */



/* returnScopeInterface SimpleCParser_type_return */
@interface SimpleCParser_type_return :ANTLRParserRuleReturnScope { /* returnScopeInterface line 1838 */
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; /* ObjC start of memVars() */
}
/* start properties */
/* AST returnScopeInterface.properties */
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_type_return *)newSimpleCParser_type_return;
/* this is start of set and get methods */
/* AST returnScopeInterface.methodsDecl */
- (ANTLRCommonTree *)getTree;

- (void) setTree:(ANTLRCommonTree *)aTree;
  /* methodsDecl */
@end /* end of returnScopeInterface interface */



/* returnScopeInterface SimpleCParser_block_return */
@interface SimpleCParser_block_return :ANTLRParserRuleReturnScope { /* returnScopeInterface line 1838 */
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; /* ObjC start of memVars() */
}
/* start properties */
/* AST returnScopeInterface.properties */
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_block_return *)newSimpleCParser_block_return;
/* this is start of set and get methods */
/* AST returnScopeInterface.methodsDecl */
- (ANTLRCommonTree *)getTree;

- (void) setTree:(ANTLRCommonTree *)aTree;
  /* methodsDecl */
@end /* end of returnScopeInterface interface */



/* returnScopeInterface SimpleCParser_stat_return */
@interface SimpleCParser_stat_return :ANTLRParserRuleReturnScope { /* returnScopeInterface line 1838 */
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; /* ObjC start of memVars() */
}
/* start properties */
/* AST returnScopeInterface.properties */
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_stat_return *)newSimpleCParser_stat_return;
/* this is start of set and get methods */
/* AST returnScopeInterface.methodsDecl */
- (ANTLRCommonTree *)getTree;

- (void) setTree:(ANTLRCommonTree *)aTree;
  /* methodsDecl */
@end /* end of returnScopeInterface interface */



/* returnScopeInterface SimpleCParser_forStat_return */
@interface SimpleCParser_forStat_return :ANTLRParserRuleReturnScope { /* returnScopeInterface line 1838 */
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; /* ObjC start of memVars() */
}
/* start properties */
/* AST returnScopeInterface.properties */
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_forStat_return *)newSimpleCParser_forStat_return;
/* this is start of set and get methods */
/* AST returnScopeInterface.methodsDecl */
- (ANTLRCommonTree *)getTree;

- (void) setTree:(ANTLRCommonTree *)aTree;
  /* methodsDecl */
@end /* end of returnScopeInterface interface */



/* returnScopeInterface SimpleCParser_assignStat_return */
@interface SimpleCParser_assignStat_return :ANTLRParserRuleReturnScope { /* returnScopeInterface line 1838 */
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; /* ObjC start of memVars() */
}
/* start properties */
/* AST returnScopeInterface.properties */
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_assignStat_return *)newSimpleCParser_assignStat_return;
/* this is start of set and get methods */
/* AST returnScopeInterface.methodsDecl */
- (ANTLRCommonTree *)getTree;

- (void) setTree:(ANTLRCommonTree *)aTree;
  /* methodsDecl */
@end /* end of returnScopeInterface interface */



/* returnScopeInterface SimpleCParser_expr_return */
@interface SimpleCParser_expr_return :ANTLRParserRuleReturnScope { /* returnScopeInterface line 1838 */
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; /* ObjC start of memVars() */
}
/* start properties */
/* AST returnScopeInterface.properties */
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_expr_return *)newSimpleCParser_expr_return;
/* this is start of set and get methods */
/* AST returnScopeInterface.methodsDecl */
- (ANTLRCommonTree *)getTree;

- (void) setTree:(ANTLRCommonTree *)aTree;
  /* methodsDecl */
@end /* end of returnScopeInterface interface */



/* returnScopeInterface SimpleCParser_condExpr_return */
@interface SimpleCParser_condExpr_return :ANTLRParserRuleReturnScope { /* returnScopeInterface line 1838 */
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; /* ObjC start of memVars() */
}
/* start properties */
/* AST returnScopeInterface.properties */
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_condExpr_return *)newSimpleCParser_condExpr_return;
/* this is start of set and get methods */
/* AST returnScopeInterface.methodsDecl */
- (ANTLRCommonTree *)getTree;

- (void) setTree:(ANTLRCommonTree *)aTree;
  /* methodsDecl */
@end /* end of returnScopeInterface interface */



/* returnScopeInterface SimpleCParser_aexpr_return */
@interface SimpleCParser_aexpr_return :ANTLRParserRuleReturnScope { /* returnScopeInterface line 1838 */
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; /* ObjC start of memVars() */
}
/* start properties */
/* AST returnScopeInterface.properties */
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_aexpr_return *)newSimpleCParser_aexpr_return;
/* this is start of set and get methods */
/* AST returnScopeInterface.methodsDecl */
- (ANTLRCommonTree *)getTree;

- (void) setTree:(ANTLRCommonTree *)aTree;
  /* methodsDecl */
@end /* end of returnScopeInterface interface */



/* returnScopeInterface SimpleCParser_atom_return */
@interface SimpleCParser_atom_return :ANTLRParserRuleReturnScope { /* returnScopeInterface line 1838 */
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; /* ObjC start of memVars() */
}
/* start properties */
/* AST returnScopeInterface.properties */
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_atom_return *)newSimpleCParser_atom_return;
/* this is start of set and get methods */
/* AST returnScopeInterface.methodsDecl */
- (ANTLRCommonTree *)getTree;

- (void) setTree:(ANTLRCommonTree *)aTree;
  /* methodsDecl */
@end /* end of returnScopeInterface interface */




/* Interface grammar class */
@interface SimpleCParser : ANTLRParser { /* line 572 */
/* ObjC start of ruleAttributeScopeMemVar */


/* ObjC end of ruleAttributeScopeMemVar */
/* ObjC start of globalAttributeScopeMemVar */


/* ObjC end of globalAttributeScopeMemVar */
/* ObjC start of actions.(actionScope).memVars */
/* ObjC end of actions.(actionScope).memVars */
/* ObjC start of memVars */
/* AST parserHeaderFile.memVars */
NSInteger ruleLevel;
NSArray *ruleNames;
  /* AST super.memVars */
/* AST parserMemVars */
id<ANTLRTreeAdaptor> treeAdaptor;   /* AST parserMemVars */
/* ObjC end of memVars */

DFA2 *dfa2;
 }

/* ObjC start of actions.(actionScope).properties */
/* ObjC end of actions.(actionScope).properties */
/* ObjC start of properties */
/* AST parserHeaderFile.properties */
  /* AST super.properties */
/* AST parserProperties */
@property (retain, getter=getTreeAdaptor, setter=setTreeAdaptor:) id<ANTLRTreeAdaptor> treeAdaptor;   /* AST parserproperties */
/* ObjC end of properties */

+ (void) initialize;
+ (id) newSimpleCParser:(id<ANTLRTokenStream>)aStream;
/* ObjC start of actions.(actionScope).methodsDecl */
/* ObjC end of actions.(actionScope).methodsDecl */

/* ObjC start of methodsDecl */
/* AST parserHeaderFile.methodsDecl */
  /* AST super.methodsDecl */
/* AST parserMethodsDecl */
- (id<ANTLRTreeAdaptor>) getTreeAdaptor;
- (void) setTreeAdaptor:(id<ANTLRTreeAdaptor>)theTreeAdaptor;   /* AST parsermethodsDecl */
/* ObjC end of methodsDecl */

- (SimpleCParser_program_return *)program; 
- (SimpleCParser_declaration_return *)declaration; 
- (SimpleCParser_variable_return *)variable; 
- (SimpleCParser_declarator_return *)declarator; 
- (SimpleCParser_functionHeader_return *)functionHeader; 
- (SimpleCParser_formalParameter_return *)formalParameter; 
- (SimpleCParser_type_return *)type; 
- (SimpleCParser_block_return *)block; 
- (SimpleCParser_stat_return *)stat; 
- (SimpleCParser_forStat_return *)forStat; 
- (SimpleCParser_assignStat_return *)assignStat; 
- (SimpleCParser_expr_return *)expr; 
- (SimpleCParser_condExpr_return *)condExpr; 
- (SimpleCParser_aexpr_return *)aexpr; 
- (SimpleCParser_atom_return *)atom; 


@end /* end of SimpleCParser interface */

