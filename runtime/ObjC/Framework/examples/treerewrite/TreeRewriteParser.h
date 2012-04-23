// $ANTLR 3.4 /Users/acondit/source/antlr/code/antlr3/runtime/ObjC/Framework/examples/treerewrite/TreeRewrite.g 2012-02-16 17:42:35

/* =============================================================================
 * Standard antlr OBJC runtime definitions
 */
#import <Foundation/Foundation.h>
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

#pragma mark Tokens
#ifdef EOF
#undef EOF
#endif
#define EOF -1
#define INT 4
#define WS 5
#pragma mark Dynamic Global Scopes globalAttributeScopeInterface
#pragma mark Dynamic Rule Scopes ruleAttributeScopeInterface
#pragma mark Rule Return Scopes returnScopeInterface
/* returnScopeInterface TreeRewriteParser_rule_return */
@interface TreeRewriteParser_rule_return : ParserRuleReturnScope { /* returnScopeInterface line 1838 */
/* AST returnScopeInterface.memVars */
CommonTree *tree; /* ObjC start of memVars() */

}
/* start property declarations */
/* AST returnScopeInterface.properties */
@property (retain, getter=getTree, setter=setTree:) CommonTree *tree;

/* start of method declarations */

+ (TreeRewriteParser_rule_return *)newTreeRewriteParser_rule_return;
/* this is start of set and get methods */
/* AST returnScopeInterface.methodsDecl */
- (CommonTree *)getTree;

- (void) setTree:(CommonTree *)aTree;
  /* methodsDecl */

@end /* end of returnScopeInterface interface */


/* returnScopeInterface TreeRewriteParser_subrule_return */
@interface TreeRewriteParser_subrule_return : ParserRuleReturnScope { /* returnScopeInterface line 1838 */
/* AST returnScopeInterface.memVars */
CommonTree *tree; /* ObjC start of memVars() */

}
/* start property declarations */
/* AST returnScopeInterface.properties */
@property (retain, getter=getTree, setter=setTree:) CommonTree *tree;

/* start of method declarations */

+ (TreeRewriteParser_subrule_return *)newTreeRewriteParser_subrule_return;
/* this is start of set and get methods */
/* AST returnScopeInterface.methodsDecl */
- (CommonTree *)getTree;

- (void) setTree:(CommonTree *)aTree;
  /* methodsDecl */

@end /* end of returnScopeInterface interface */



/* Interface grammar class */
@interface TreeRewriteParser  : Parser { /* line 572 */
#pragma mark Dynamic Rule Scopes ruleAttributeScopeDecl
#pragma mark Dynamic Global Rule Scopes globalAttributeScopeMemVar


/* ObjC start of actions.(actionScope).memVars */
/* ObjC end of actions.(actionScope).memVars */
/* ObjC start of memVars */
/* AST parserHeaderFile.memVars */
NSInteger ruleLevel;
NSArray *ruleNames;
  /* AST super.memVars */
/* AST parserMemVars */
id<TreeAdaptor> treeAdaptor;   /* AST parserMemVars */
/* ObjC end of memVars */

 }

/* ObjC start of actions.(actionScope).properties */
/* ObjC end of actions.(actionScope).properties */
/* ObjC start of properties */
/* AST parserHeaderFile.properties */
  /* AST super.properties */
/* AST parserProperties */
@property (retain, getter=getTreeAdaptor, setter=setTreeAdaptor:) id<TreeAdaptor> treeAdaptor;   /* AST parserproperties */
/* ObjC end of properties */

+ (void) initialize;
+ (id) newTreeRewriteParser:(id<TokenStream>)aStream;
/* ObjC start of actions.(actionScope).methodsDecl */
/* ObjC end of actions.(actionScope).methodsDecl */

/* ObjC start of methodsDecl */
/* AST parserHeaderFile.methodsDecl */
  /* AST super.methodsDecl */
/* AST parserMethodsDecl */
- (id<TreeAdaptor>) getTreeAdaptor;
- (void) setTreeAdaptor:(id<TreeAdaptor>)theTreeAdaptor;   /* AST parsermethodsDecl */
/* ObjC end of methodsDecl */

- (TreeRewriteParser_rule_return *)rule; 
- (TreeRewriteParser_subrule_return *)subrule; 


@end /* end of TreeRewriteParser interface */

