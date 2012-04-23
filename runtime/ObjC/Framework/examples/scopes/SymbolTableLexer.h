// $ANTLR 3.4 /Users/acondit/source/antlr/code/antlr3/runtime/ObjC/Framework/examples/scopes/SymbolTable.g 2012-02-16 17:50:30

/* =============================================================================
 * Standard antlr OBJC runtime definitions
 */
#import <Foundation/Foundation.h>
#import <ANTLR/ANTLR.h>
/* End of standard antlr3 runtime definitions
 * =============================================================================
 */

/* Start cyclicDFAInterface */

#pragma mark Rule return scopes Interface start
#pragma mark Rule return scopes Interface end
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
/* interface lexer class */
@interface SymbolTableLexer : Lexer { // line 283
/* ObjC start of actions.lexer.memVars */
/* ObjC end of actions.lexer.memVars */
}
+ (void) initialize;
+ (SymbolTableLexer *)newSymbolTableLexerWithCharStream:(id<CharStream>)anInput;
/* ObjC start actions.lexer.methodsDecl */
/* ObjC end actions.lexer.methodsDecl */
- (void) mT__7 ; 
- (void) mT__8 ; 
- (void) mT__9 ; 
- (void) mT__10 ; 
- (void) mT__11 ; 
- (void) mT__12 ; 
- (void) mT__13 ; 
- (void) mT__14 ; 
- (void) mID ; 
- (void) mINT ; 
- (void) mWS ; 
- (void) mTokens ; 

@end /* end of SymbolTableLexer interface */

