// $ANTLR 3.4 /Users/acondit/source/antlr/code/antlr3/runtime/ObjC/Framework/examples/scopes/SymbolTable.g 2012-02-16 17:50:30

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
#define T__7 7
#define T__8 8
#define T__9 9
#define T__10 10
#define T__11 11
#define T__12 12
#define T__13 13
#define T__14 14
#define ID 4
#define INT 5
#define WS 6
#pragma mark Dynamic Global Scopes globalAttributeScopeInterface
/* globalAttributeScopeInterface */
@interface Symbols_Scope : SymbolsScope {
PtrBuffer * names;
 }
/* start of globalAttributeScopeInterface properties */
@property (assign, getter=getnames, setter=setnames:) PtrBuffer * names;
/* end globalAttributeScopeInterface properties */
+ (Symbols_Scope *)newSymbols_Scope;
- (id) init;
/* start of globalAttributeScopeInterface methodsDecl */
- (PtrBuffer *)getnames;
- (void)setnames:(PtrBuffer *)aVal;
/* End of globalAttributeScopeInterface methodsDecl */
@end /* end of Symbols_Scope interface */

#pragma mark Dynamic Rule Scopes ruleAttributeScopeInterface
#pragma mark Rule Return Scopes returnScopeInterface

/* Interface grammar class */
@interface SymbolTableParser  : Parser { /* line 572 */
#pragma mark Dynamic Rule Scopes ruleAttributeScopeDecl
#pragma mark Dynamic Global Rule Scopes globalAttributeScopeMemVar
/* globalAttributeScopeMemVar */
SymbolStack *Symbols_stack;
Symbols_Scope *Symbols_scope;


/* ObjC start of actions.(actionScope).memVars */

int level;

/* ObjC end of actions.(actionScope).memVars */
/* ObjC start of memVars */
/* ObjC end of memVars */

 }

/* ObjC start of actions.(actionScope).properties */
/* ObjC end of actions.(actionScope).properties */
/* ObjC start of properties */
/* ObjC end of properties */

+ (void) initialize;
+ (id) newSymbolTableParser:(id<TokenStream>)aStream;
/* ObjC start of actions.(actionScope).methodsDecl */
/* ObjC end of actions.(actionScope).methodsDecl */

/* ObjC start of methodsDecl */
/* ObjC end of methodsDecl */

- (void)prog; 
- (void)globals; 
- (void)method; 
- (void)block; 
- (void)stat; 
- (void)decl; 


@end /* end of SymbolTableParser interface */

