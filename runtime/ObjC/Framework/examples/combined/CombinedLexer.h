// $ANTLR 3.2 Aug 24, 2010 10:45:57 Combined.g 2010-08-24 13:53:42

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
#define INT 5
#define WS 6
#define ID 4
#define EOF -1
@interface CombinedLexer : ANTLRLexer { // line 283
// start of actions.lexer.memVars
// start of action-actionScope-memVars
}
+ (CombinedLexer *)newCombinedLexerWithCharStream:(id<ANTLRCharStream>)anInput;

- (void)mID; 
- (void)mINT; 
- (void)mWS; 
- (void)mTokens; 

@end /* end of CombinedLexer interface */
