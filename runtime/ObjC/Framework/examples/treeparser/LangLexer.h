// $ANTLR 3.4 /Users/acondit/source/antlr/code/antlr3/runtime/ObjC/Framework/examples/treeparser/Lang.g 2012-02-16 17:58:54

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
#define T__10 10
#define DECL 4
#define FLOATTYPE 5
#define ID 6
#define INT 7
#define INTTYPE 8
#define WS 9
/* interface lexer class */
@interface LangLexer : Lexer { // line 283
/* ObjC start of actions.lexer.memVars */
/* ObjC end of actions.lexer.memVars */
}
+ (void) initialize;
+ (LangLexer *)newLangLexerWithCharStream:(id<CharStream>)anInput;
/* ObjC start actions.lexer.methodsDecl */
/* ObjC end actions.lexer.methodsDecl */
- (void) mT__10 ; 
- (void) mINTTYPE ; 
- (void) mFLOATTYPE ; 
- (void) mID ; 
- (void) mINT ; 
- (void) mWS ; 
- (void) mTokens ; 

@end /* end of LangLexer interface */

