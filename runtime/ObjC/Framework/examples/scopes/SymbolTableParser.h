// $ANTLR 3.2 Aug 24, 2010 10:45:57 SymbolTable.g 2010-08-24 13:53:46

/* =============================================================================
 * Standard antlr3 OBJC runtime definitions
 */
#import <Cocoa/Cocoa.h>
#import "antlr3.h"
/* End of standard antlr3 runtime definitions
 * =============================================================================
 */

/* parserHeaderFile */
#pragma mark Tokens
#define WS 6
#define T__12 12
#define T__11 11
#define T__14 14
#define T__13 13
#define T__10 10
#define INT 5
#define ID 4
#define EOF -1
#define T__9 9
#define T__8 8
#define T__7 7
#pragma mark Dynamic Global Scopes
@interface Symbols_Scope : ANTLRSymbolsScope {  /* globalAttributeScopeDecl */
ANTLRHashMap * names;
}
/* start of properties */

@property (retain, getter=getnames, setter=setnames:) ANTLRHashMap * names;

/* end properties */

+ (Symbols_Scope *)newSymbols_Scope;
/* start of iterated get and set functions */

- (ANTLRHashMap *)getnames;
- (void)setnames:(ANTLRHashMap *)aVal;

/* End of iterated get and set functions */

@end /* end of Symbols_Scope interface */

#pragma mark Dynamic Rule Scopes
#pragma mark Rule Return Scopes start
#pragma mark Rule return scopes end
@interface SymbolTableParser : ANTLRParser { /* line 572 */
// start of globalAttributeScopeMemVar
/* globalAttributeScopeMemVar */
ANTLRSymbolStack *gStack;
Symbols_Scope *Symbols_scope;

// start of action-actionScope-memVars

int level;

// start of ruleAttributeScopeMemVar


// Start of memVars

 }

// start of action-actionScope-methodsDecl


- (void)prog; 
- (void)globals; 
- (void)method; 
- (void)block; 
- (void)stat; 
- (void)decl; 


@end /* end of SymbolTableParser interface */
