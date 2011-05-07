// $ANTLR ${project.version} ${buildNumber} SymbolTable.g 2011-05-06 15:04:43

/* =============================================================================
 * Standard antlr3 OBJC runtime definitions
 */
#import <Cocoa/Cocoa.h>
#import <ANTLR/ANTLR.h>
/* End of standard antlr3 runtime definitions
 * =============================================================================
 */

/* Start cyclicDFAInterface */

#pragma mark Rule return scopes start
#pragma mark Rule return scopes end
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
@interface SymbolTableLexer : ANTLRLexer { // line 283
/* ObjC start of actions.lexer.memVars */
/* ObjC end of actions.lexer.memVars */
}
+ (void) initialize;
+ (SymbolTableLexer *)newSymbolTableLexerWithCharStream:(id<ANTLRCharStream>)anInput;
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

