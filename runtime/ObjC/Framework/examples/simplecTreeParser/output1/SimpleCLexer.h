// $ANTLR 3.2 Aug 23, 2010 07:48:06 /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g 2010-08-23 07:54:47

/* =============================================================================
 * Standard antlr3 OBJC runtime definitions
 */
#import <Cocoa/Cocoa.h>
#import "antlr3.h"
/* End of standard antlr3 runtime definitions
 * =============================================================================
 */

/* Start cyclicDFAInterface */
#pragma mark Cyclic DFA interface start DFA4
@interface DFA4 : ANTLRDFA {
}
+ newDFA4WithRecognizer:(ANTLRBaseRecognizer *)theRecognizer;
- initWithRecognizer:(ANTLRBaseRecognizer *)recognizer;
@end /* end of DFA4 interface  */

#pragma mark Cyclic DFA interface end DFA4

#pragma mark Rule return scopes start
#pragma mark Rule return scopes end
#pragma mark Tokens
#define K_ID 10
#define T__26 26
#define T__25 25
#define T__24 24
#define T__23 23
#define K_EQEQ 16
#define T__22 22
#define K_INT 11
#define T__21 21
#define K_FOR 14
#define FUNC_HDR 6
#define FUNC_DEF 8
#define EOF -1
#define K_INT_TYPE 19
#define FUNC_DECL 7
#define ARG_DEF 5
#define WS 20
#define K_EQ 15
#define BLOCK 9
#define K_LT 17
#define K_CHAR 12
#define K_VOID 13
#define VAR_DEF 4
#define K_PLUS 18
@interface SimpleCLexer : ANTLRLexer { // line 283
DFA4 *dfa4;
// start of actions.lexer.memVars
// start of action-actionScope-memVars
}
+ (SimpleCLexer *)newSimpleCLexer:(id<ANTLRCharStream>)anInput;

- (void)mT__21; 
- (void)mT__22; 
- (void)mT__23; 
- (void)mT__24; 
- (void)mT__25; 
- (void)mT__26; 
- (void)mK_FOR; 
- (void)mK_INT_TYPE; 
- (void)mK_CHAR; 
- (void)mK_VOID; 
- (void)mK_ID; 
- (void)mK_INT; 
- (void)mK_EQ; 
- (void)mK_EQEQ; 
- (void)mK_LT; 
- (void)mK_PLUS; 
- (void)mWS; 
- (void)mTokens; 

@end /* end of SimpleCLexer interface */
