// $ANTLR 3.4 /Users/acondit/source/antlr/code/antlr3/runtime/ObjC/Framework/examples/polydiff/Poly.g 2012-02-16 18:10:11

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
#define T__8 8
#define T__9 9
#define ID 4
#define INT 5
#define MULT 6
#define WS 7
/* interface lexer class */
@interface PolyLexer : Lexer { // line 283
/* ObjC start of actions.lexer.memVars */
/* ObjC end of actions.lexer.memVars */
}
+ (void) initialize;
+ (PolyLexer *)newPolyLexerWithCharStream:(id<CharStream>)anInput;
/* ObjC start actions.lexer.methodsDecl */
/* ObjC end actions.lexer.methodsDecl */
- (void) mT__8 ; 
- (void) mT__9 ; 
- (NSString *) mID ; 
- (NSString *) mINT ; 
- (void) mWS ; 
- (void) mTokens ; 

@end /* end of PolyLexer interface */

