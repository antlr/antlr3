// $ANTLR 3.2 Aug 19, 2010 17:16:04 /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/scopes/SymbolTable.g 2010-08-19 17:16:47

/* =============================================================================
 * Standard antlr3 OBJC runtime definitions
 */
#import <Cocoa/Cocoa.h>
#import "antlr3.h"
/* End of standard antlr3 runtime definitions
 * =============================================================================
 */

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

@end
#pragma mark Dynamic Rule Scopes
#pragma mark Rule Return Scopes start
#pragma mark Rule return scopes end
@interface SymbolTableParser : ANTLRParser { // line 529
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


@end // end of SymbolTableParser