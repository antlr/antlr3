// $ANTLR ${project.version} ${buildNumber} SimpleC.g 2011-05-06 15:09:17

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
#define ARG_DEF 4
#define BLOCK 5
#define FUNC_DECL 6
#define FUNC_DEF 7
#define FUNC_HDR 8
#define K_CHAR 9
#define K_COMMA 10
#define K_EQ 11
#define K_EQEQ 12
#define K_FOR 13
#define K_ID 14
#define K_INT 15
#define K_INT_TYPE 16
#define K_LCURLY 17
#define K_LCURVE 18
#define K_LT 19
#define K_PLUS 20
#define K_RCURLY 21
#define K_RCURVE 22
#define K_SEMICOLON 23
#define K_VOID 24
#define VAR_DEF 25
#define WS 26
/* interface lexer class */
@interface SimpleCLexer : ANTLRLexer { // line 283
/* ObjC start of actions.lexer.memVars */
/* ObjC end of actions.lexer.memVars */
}
+ (void) initialize;
+ (SimpleCLexer *)newSimpleCLexerWithCharStream:(id<ANTLRCharStream>)anInput;
/* ObjC start actions.lexer.methodsDecl */
/* ObjC end actions.lexer.methodsDecl */
- (void) mK_FOR ; 
- (void) mK_CHAR ; 
- (void) mK_INT_TYPE ; 
- (void) mK_VOID ; 
- (void) mK_ID ; 
- (void) mK_INT ; 
- (void) mK_LCURVE ; 
- (void) mK_RCURVE ; 
- (void) mK_PLUS ; 
- (void) mK_COMMA ; 
- (void) mK_SEMICOLON ; 
- (void) mK_LT ; 
- (void) mK_EQ ; 
- (void) mK_EQEQ ; 
- (void) mK_LCURLY ; 
- (void) mK_RCURLY ; 
- (void) mWS ; 
- (void) mTokens ; 

@end /* end of SimpleCLexer interface */

