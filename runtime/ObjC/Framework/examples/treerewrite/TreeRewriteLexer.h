// $ANTLR 3.2 Aug 24, 2010 10:45:57 TreeRewrite.g 2010-08-24 14:18:09

/* =============================================================================
 * Standard antlr3 OBJC runtime definitions
 */
#import <Cocoa/Cocoa.h>
#import "antlr3.h"
/* End of standard antlr3 runtime definitions
 * =============================================================================
 */

/* Start cyclicDFAInterface */

#pragma mark Rule return scopes start
#pragma mark Rule return scopes end
#pragma mark Tokens
#define INT 4
#define WS 5
#define EOF -1
@interface TreeRewriteLexer : ANTLRLexer { // line 283
// start of actions.lexer.memVars
// start of action-actionScope-memVars
}
+ (TreeRewriteLexer *)newTreeRewriteLexerWithCharStream:(id<ANTLRCharStream>)anInput;

- (void)mINT; 
- (void)mWS; 
- (void)mTokens; 

@end /* end of TreeRewriteLexer interface */
