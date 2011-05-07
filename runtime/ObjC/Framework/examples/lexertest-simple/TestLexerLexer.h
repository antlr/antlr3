// $ANTLR ${project.version} ${buildNumber} TestLexer.g 2011-05-06 19:16:22

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
#define DIGIT 4
#define ID 5
#define LETTER 6
/* interface lexer class */
@interface TestLexer : ANTLRLexer { // line 283
/* ObjC start of actions.lexer.memVars */
/* ObjC end of actions.lexer.memVars */
}
+ (void) initialize;
+ (TestLexer *)newTestLexerWithCharStream:(id<ANTLRCharStream>)anInput;
/* ObjC start actions.lexer.methodsDecl */
/* ObjC end actions.lexer.methodsDecl */
- (void) mID ; 
- (void) mDIGIT ; 
- (void) mLETTER ; 
- (void) mTokens ; 

@end /* end of TestLexer interface */

