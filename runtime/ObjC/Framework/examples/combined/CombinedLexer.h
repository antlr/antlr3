// $ANTLR 3.4 /Users/acondit/source/antlr/code/antlr3/runtime/ObjC/Framework/examples/combined/Combined.g 2012-02-16 17:33:49

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
#define ID 4
#define INT 5
#define WS 6
/* interface lexer class */
@interface CombinedLexer : Lexer { // line 283
/* ObjC start of actions.lexer.memVars */
/* ObjC end of actions.lexer.memVars */
}
+ (void) initialize;
+ (CombinedLexer *)newCombinedLexerWithCharStream:(id<CharStream>)anInput;
/* ObjC start actions.lexer.methodsDecl */
/* ObjC end actions.lexer.methodsDecl */
- (void) mID ; 
- (void) mINT ; 
- (void) mWS ; 
- (void) mTokens ; 

@end /* end of CombinedLexer interface */

