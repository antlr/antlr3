// $ANTLR 3.2 Aug 07, 2010 22:08:38 /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/lexertest-simple/Test.g 2010-08-11 13:24:39

/* =============================================================================
 * Standard antlr3 OBJC runtime definitions
 */
#import <Cocoa/Cocoa.h>
#import "antlr3.h"
/* End of standard antlr3 runtime definitions
 * =============================================================================
 */


#pragma mark Rule return scopes start
#pragma mark Rule return scopes end
#pragma mark Tokens
#define DIGIT 5
#define ID 6
#define EOF -1
#define LETTER 4
@interface TestLexer : ANTLRLexer {
}
- (void) mID; 
- (void) mDIGIT; 
- (void) mLETTER; 
- (void) mTokens; 
@end // end of Test interface