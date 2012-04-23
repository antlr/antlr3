// $ANTLR 3.4 /Users/acondit/source/antlr/code/antlr3/runtime/ObjC/Framework/examples/treeparser/LangDumpDecl.g 2012-02-16 17:59:08

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
#define T__10 10
#define DECL 4
#define FLOATTYPE 5
#define ID 6
#define INT 7
#define INTTYPE 8
#define WS 9
#pragma mark Dynamic Global Scopes globalAttributeScopeInterface
#pragma mark Dynamic Rule Scopes ruleAttributeScopeInterface
#pragma mark Rule Return Scopes returnScopeInterface
/* returnScopeInterface LangDumpDecl_declarator_return */
@interface LangDumpDecl_declarator_return : TreeRuleReturnScope { /* returnScopeInterface line 1838 */
 /* ObjC start of memVars() */

}
/* start property declarations */


/* start of method declarations */

+ (LangDumpDecl_declarator_return *)newLangDumpDecl_declarator_return;
/* this is start of set and get methods */
  /* methodsDecl */

@end /* end of returnScopeInterface interface */



/* Interface grammar class */
@interface LangDumpDecl  : TreeParser { /* line 572 */
#pragma mark Dynamic Rule Scopes ruleAttributeScopeDecl
#pragma mark Dynamic Global Rule Scopes globalAttributeScopeMemVar


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
+ (id) newLangDumpDecl:(id<TreeNodeStream>)aStream;
/* ObjC start of actions.(actionScope).methodsDecl */
/* ObjC end of actions.(actionScope).methodsDecl */

/* ObjC start of methodsDecl */
/* ObjC end of methodsDecl */

- (void)decl; 
- (void)type; 
- (LangDumpDecl_declarator_return *)declarator; 


@end /* end of LangDumpDecl interface */

