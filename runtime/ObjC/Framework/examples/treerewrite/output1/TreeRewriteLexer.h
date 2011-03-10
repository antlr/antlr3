// $ANTLR 3.2 Aug 20, 2010 15:00:19 /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/treerewrite/TreeRewrite.g 2010-08-20 15:03:14

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
+ (TreeRewriteLexer *)newTreeRewriteLexer:(id<ANTLRCharStream>)anInput;

- (void)mINT; 
- (void)mWS; 
- (void)mTokens; 

@end /* end of TreeRewriteLexer interface */
