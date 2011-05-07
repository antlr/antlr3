// $ANTLR ${project.version} ${buildNumber} SymbolTable.g 2011-05-06 15:04:42

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
#pragma mark Dynamic Global Scopes
/* globalAttributeScopeInterface */
@interface Symbols_Scope : ANTLRSymbolsScope {
ANTLRPtrBuffer * names;

}
/* start of globalAttributeScopeInterface properties */

@property (assign, getter=getnames, setter=setnames:) ANTLRPtrBuffer * names;

/* end globalAttributeScopeInterface properties */


+ (Symbols_Scope *)newSymbols_Scope;
- (id) init;
/* start of globalAttributeScopeInterface methodsDecl */

- (ANTLRPtrBuffer *)getnames;
- (void)setnames:(ANTLRPtrBuffer *)aVal;

/* End of globalAttributeScopeInterface methodsDecl */

@end /* end of Symbols_Scope interface */

#pragma mark Dynamic Rule Scopes
#pragma mark Rule Return Scopes start

/* Interface grammar class */
@interface SymbolTableParser : ANTLRParser { /* line 572 */
/* ObjC start of ruleAttributeScopeMemVar */


/* ObjC end of ruleAttributeScopeMemVar */
/* ObjC start of globalAttributeScopeMemVar */
/* globalAttributeScopeMemVar */
//ANTLRSymbolStack *gStack;
ANTLRSymbolStack *Symbols_stack;
Symbols_Scope *Symbols_scope;

/* ObjC end of globalAttributeScopeMemVar */
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
+ (id) newSymbolTableParser:(id<ANTLRTokenStream>)aStream;
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

