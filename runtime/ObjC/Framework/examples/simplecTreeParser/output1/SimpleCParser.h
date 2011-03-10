// $ANTLR 3.2 Aug 23, 2010 07:48:06 /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g 2010-08-23 07:54:46

/* =============================================================================
 * Standard antlr3 OBJC runtime definitions
 */
#import <Cocoa/Cocoa.h>
#import "antlr3.h"
/* End of standard antlr3 runtime definitions
 * =============================================================================
 */

#pragma mark Cyclic DFA interface start DFA2
@interface DFA2 : ANTLRDFA {
}
+ newDFA2WithRecognizer:(ANTLRBaseRecognizer *)theRecognizer;
- initWithRecognizer:(ANTLRBaseRecognizer *)recognizer;
@end /* end of DFA2 interface  */

#pragma mark Cyclic DFA interface end DFA2
#pragma mark Tokens
#define K_ID 10
#define T__26 26
#define T__25 25
#define T__24 24
#define T__23 23
#define K_EQEQ 16
#define T__22 22
#define K_INT 11
#define T__21 21
#define K_FOR 14
#define FUNC_HDR 6
#define FUNC_DEF 8
#define EOF -1
#define K_INT_TYPE 19
#define FUNC_DECL 7
#define ARG_DEF 5
#define WS 20
#define K_EQ 15
#define BLOCK 9
#define K_LT 17
#define K_CHAR 12
#define K_VOID 13
#define VAR_DEF 4
#define K_PLUS 18
#pragma mark Dynamic Global Scopes
#pragma mark Dynamic Rule Scopes
#pragma mark Rule Return Scopes start
@interface SimpleCParser_program_return :ANTLRParserRuleReturnScope { // line 1672
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; // start of memVars()
}

// start properties
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_program_return *)newSimpleCParser_program_return;
// this is start of set and get methods
/* AST returnScopeInterface.methodsdecl */
- (ANTLRCommonTree *)getTree;
- (void) setTree:(ANTLRCommonTree *)aTree;
  // methodsDecl
@end /* end of returnScopeInterface interface */
@interface SimpleCParser_declaration_return :ANTLRParserRuleReturnScope { // line 1672
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; // start of memVars()
}

// start properties
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_declaration_return *)newSimpleCParser_declaration_return;
// this is start of set and get methods
/* AST returnScopeInterface.methodsdecl */
- (ANTLRCommonTree *)getTree;
- (void) setTree:(ANTLRCommonTree *)aTree;
  // methodsDecl
@end /* end of returnScopeInterface interface */
@interface SimpleCParser_variable_return :ANTLRParserRuleReturnScope { // line 1672
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; // start of memVars()
}

// start properties
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_variable_return *)newSimpleCParser_variable_return;
// this is start of set and get methods
/* AST returnScopeInterface.methodsdecl */
- (ANTLRCommonTree *)getTree;
- (void) setTree:(ANTLRCommonTree *)aTree;
  // methodsDecl
@end /* end of returnScopeInterface interface */
@interface SimpleCParser_declarator_return :ANTLRParserRuleReturnScope { // line 1672
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; // start of memVars()
}

// start properties
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_declarator_return *)newSimpleCParser_declarator_return;
// this is start of set and get methods
/* AST returnScopeInterface.methodsdecl */
- (ANTLRCommonTree *)getTree;
- (void) setTree:(ANTLRCommonTree *)aTree;
  // methodsDecl
@end /* end of returnScopeInterface interface */
@interface SimpleCParser_functionHeader_return :ANTLRParserRuleReturnScope { // line 1672
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; // start of memVars()
}

// start properties
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_functionHeader_return *)newSimpleCParser_functionHeader_return;
// this is start of set and get methods
/* AST returnScopeInterface.methodsdecl */
- (ANTLRCommonTree *)getTree;
- (void) setTree:(ANTLRCommonTree *)aTree;
  // methodsDecl
@end /* end of returnScopeInterface interface */
@interface SimpleCParser_formalParameter_return :ANTLRParserRuleReturnScope { // line 1672
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; // start of memVars()
}

// start properties
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_formalParameter_return *)newSimpleCParser_formalParameter_return;
// this is start of set and get methods
/* AST returnScopeInterface.methodsdecl */
- (ANTLRCommonTree *)getTree;
- (void) setTree:(ANTLRCommonTree *)aTree;
  // methodsDecl
@end /* end of returnScopeInterface interface */
@interface SimpleCParser_type_return :ANTLRParserRuleReturnScope { // line 1672
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; // start of memVars()
}

// start properties
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_type_return *)newSimpleCParser_type_return;
// this is start of set and get methods
/* AST returnScopeInterface.methodsdecl */
- (ANTLRCommonTree *)getTree;
- (void) setTree:(ANTLRCommonTree *)aTree;
  // methodsDecl
@end /* end of returnScopeInterface interface */
@interface SimpleCParser_block_return :ANTLRParserRuleReturnScope { // line 1672
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; // start of memVars()
}

// start properties
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_block_return *)newSimpleCParser_block_return;
// this is start of set and get methods
/* AST returnScopeInterface.methodsdecl */
- (ANTLRCommonTree *)getTree;
- (void) setTree:(ANTLRCommonTree *)aTree;
  // methodsDecl
@end /* end of returnScopeInterface interface */
@interface SimpleCParser_stat_return :ANTLRParserRuleReturnScope { // line 1672
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; // start of memVars()
}

// start properties
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_stat_return *)newSimpleCParser_stat_return;
// this is start of set and get methods
/* AST returnScopeInterface.methodsdecl */
- (ANTLRCommonTree *)getTree;
- (void) setTree:(ANTLRCommonTree *)aTree;
  // methodsDecl
@end /* end of returnScopeInterface interface */
@interface SimpleCParser_forStat_return :ANTLRParserRuleReturnScope { // line 1672
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; // start of memVars()
}

// start properties
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_forStat_return *)newSimpleCParser_forStat_return;
// this is start of set and get methods
/* AST returnScopeInterface.methodsdecl */
- (ANTLRCommonTree *)getTree;
- (void) setTree:(ANTLRCommonTree *)aTree;
  // methodsDecl
@end /* end of returnScopeInterface interface */
@interface SimpleCParser_assignStat_return :ANTLRParserRuleReturnScope { // line 1672
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; // start of memVars()
}

// start properties
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_assignStat_return *)newSimpleCParser_assignStat_return;
// this is start of set and get methods
/* AST returnScopeInterface.methodsdecl */
- (ANTLRCommonTree *)getTree;
- (void) setTree:(ANTLRCommonTree *)aTree;
  // methodsDecl
@end /* end of returnScopeInterface interface */
@interface SimpleCParser_expr_return :ANTLRParserRuleReturnScope { // line 1672
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; // start of memVars()
}

// start properties
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_expr_return *)newSimpleCParser_expr_return;
// this is start of set and get methods
/* AST returnScopeInterface.methodsdecl */
- (ANTLRCommonTree *)getTree;
- (void) setTree:(ANTLRCommonTree *)aTree;
  // methodsDecl
@end /* end of returnScopeInterface interface */
@interface SimpleCParser_condExpr_return :ANTLRParserRuleReturnScope { // line 1672
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; // start of memVars()
}

// start properties
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_condExpr_return *)newSimpleCParser_condExpr_return;
// this is start of set and get methods
/* AST returnScopeInterface.methodsdecl */
- (ANTLRCommonTree *)getTree;
- (void) setTree:(ANTLRCommonTree *)aTree;
  // methodsDecl
@end /* end of returnScopeInterface interface */
@interface SimpleCParser_aexpr_return :ANTLRParserRuleReturnScope { // line 1672
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; // start of memVars()
}

// start properties
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_aexpr_return *)newSimpleCParser_aexpr_return;
// this is start of set and get methods
/* AST returnScopeInterface.methodsdecl */
- (ANTLRCommonTree *)getTree;
- (void) setTree:(ANTLRCommonTree *)aTree;
  // methodsDecl
@end /* end of returnScopeInterface interface */
@interface SimpleCParser_atom_return :ANTLRParserRuleReturnScope { // line 1672
/* AST returnScopeInterface.memVars */
ANTLRCommonTree *tree; // start of memVars()
}

// start properties
@property (retain, getter=getTree, setter=setTree:) ANTLRCommonTree *tree;
+ (SimpleCParser_atom_return *)newSimpleCParser_atom_return;
// this is start of set and get methods
/* AST returnScopeInterface.methodsdecl */
- (ANTLRCommonTree *)getTree;
- (void) setTree:(ANTLRCommonTree *)aTree;
  // methodsDecl
@end /* end of returnScopeInterface interface */

#pragma mark Rule return scopes end
@interface SimpleCParser : ANTLRParser { // line 529
// start of globalAttributeScopeMemVar


// start of action-actionScope-memVars
// start of ruleAttributeScopeMemVar


// Start of memVars
/* AST parserHeaderFile.memVars */
/* AST parsermemVars */
id<ANTLRTreeAdaptor> treeAdaptor;

DFA2 *dfa2;
 }

// start of action-actionScope-methodsDecl

/* AST parserHeaderFile.methodsdecl */
/* AST parserMethodsDecl */
- (id<ANTLRTreeAdaptor>) getTreeAdaptor;
- (void) setTreeAdaptor:(id<ANTLRTreeAdaptor>)theTreeAdaptor;

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
