// $ANTLR 3.4 /Users/acondit/source/antlr/code/antlr3/runtime/ObjC/Framework/examples/simplecTreeParser/SimpleCWalker.g 2012-02-16 17:56:35

/* =============================================================================
 * Standard antlr OBJC runtime definitions
 */
#import <Foundation/Foundation.h>
#import <ANTLR/ANTLR.h>
/* End of standard antlr3 runtime definitions
 * =============================================================================
 */

/* treeParserHeaderFile */
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
#pragma mark Dynamic Global Scopes globalAttributeScopeInterface
/* globalAttributeScopeInterface */
@interface Symbols_Scope : SymbolsScope {
CommonTree * tree;
 }
/* start of globalAttributeScopeInterface properties */
@property (assign, getter=gettree, setter=settree:) CommonTree * tree;
/* end globalAttributeScopeInterface properties */
+ (Symbols_Scope *)newSymbols_Scope;
- (id) init;
/* start of globalAttributeScopeInterface methodsDecl */
- (CommonTree *)gettree;
- (void)settree:(CommonTree *)aVal;
/* End of globalAttributeScopeInterface methodsDecl */
@end /* end of Symbols_Scope interface */

#pragma mark Dynamic Rule Scopes ruleAttributeScopeInterface
#pragma mark Rule Return Scopes returnScopeInterface
/* returnScopeInterface SimpleCWalker_expr_return */
@interface SimpleCWalker_expr_return : TreeRuleReturnScope { /* returnScopeInterface line 1838 */
 /* ObjC start of memVars() */

}
/* start property declarations */


/* start of method declarations */

+ (SimpleCWalker_expr_return *)newSimpleCWalker_expr_return;
/* this is start of set and get methods */
  /* methodsDecl */

@end /* end of returnScopeInterface interface */



/* Interface grammar class */
@interface SimpleCWalker  : TreeParser { /* line 572 */
#pragma mark Dynamic Rule Scopes ruleAttributeScopeDecl
#pragma mark Dynamic Global Rule Scopes globalAttributeScopeMemVar
/* globalAttributeScopeMemVar */
SymbolStack *Symbols_stack;
Symbols_Scope *Symbols_scope;


/* ObjC start of actions.(actionScope).memVars */
/* ObjC end of actions.(actionScope).memVars */
/* ObjC start of memVars */
/* ObjC end of memVars */

 }

/* ObjC start of actions.(actionScope).properties */
/* ObjC end of actions.(actionScope).properties */
/* ObjC start of properties */
/* ObjC end of properties */

+ (void) initialize;
+ (id) newSimpleCWalker:(id<TreeNodeStream>)aStream;
/* ObjC start of actions.(actionScope).methodsDecl */
/* ObjC end of actions.(actionScope).methodsDecl */

/* ObjC start of methodsDecl */
/* ObjC end of methodsDecl */

- (void)program; 
- (void)declaration; 
- (void)variable; 
- (void)declarator; 
- (void)functionHeader; 
- (void)formalParameter; 
- (void)type; 
- (void)block; 
- (void)stat; 
- (void)forStat; 
- (SimpleCWalker_expr_return *)expr; 
- (void)atom; 


@end /* end of SimpleCWalker interface */

