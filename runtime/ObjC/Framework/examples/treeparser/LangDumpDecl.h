// $ANTLR ${project.version} ${buildNumber} LangDumpDecl.g 2011-05-06 17:39:09

/* =============================================================================
 * Standard antlr3 OBJC runtime definitions
 */
#import <Cocoa/Cocoa.h>
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
#pragma mark Dynamic Global Scopes
#pragma mark Dynamic Rule Scopes
#pragma mark Rule Return Scopes start
/* returnScopeInterface LangDumpDecl_declarator_return */
@interface LangDumpDecl_declarator_return :ANTLRTreeRuleReturnScope { /* returnScopeInterface line 1838 */
 /* ObjC start of memVars() */
}
/* start properties */
+ (LangDumpDecl_declarator_return *)newLangDumpDecl_declarator_return;
/* this is start of set and get methods */
  /* methodsDecl */
@end /* end of returnScopeInterface interface */




/* Interface grammar class */
@interface LangDumpDecl : ANTLRTreeParser { /* line 572 */
/* ObjC start of ruleAttributeScopeMemVar */


/* ObjC end of ruleAttributeScopeMemVar */
/* ObjC start of globalAttributeScopeMemVar */


/* ObjC end of globalAttributeScopeMemVar */
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
+ (id) newLangDumpDecl:(id<ANTLRTreeNodeStream>)aStream;
/* ObjC start of actions.(actionScope).methodsDecl */
/* ObjC end of actions.(actionScope).methodsDecl */

/* ObjC start of methodsDecl */
/* ObjC end of methodsDecl */

- (void)decl; 
- (void)type; 
- (LangDumpDecl_declarator_return *)declarator; 


@end /* end of LangDumpDecl interface */

