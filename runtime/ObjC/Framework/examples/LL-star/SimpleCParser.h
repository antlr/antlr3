// $ANTLR 3.2 Aug 24, 2010 10:45:57 SimpleC.g 2010-08-24 13:53:43

/* =============================================================================
 * Standard antlr3 OBJC runtime definitions
 */
#import <Cocoa/Cocoa.h>
#import "antlr3.h"
/* End of standard antlr3 runtime definitions
 * =============================================================================
 */

/* parserHeaderFile */
#pragma mark Cyclic DFA interface start DFA2
@interface DFA2 : ANTLRDFA {
}
+ newDFA2WithRecognizer:(ANTLRBaseRecognizer *)theRecognizer;
- initWithRecognizer:(ANTLRBaseRecognizer *)recognizer;
@end /* end of DFA2 interface  */

#pragma mark Cyclic DFA interface end DFA2
#pragma mark Tokens
#define T__20 20
#define INT 5
#define ID 4
#define EOF -1
#define T__9 9
#define T__8 8
#define T__7 7
#define T__19 19
#define WS 6
#define T__16 16
#define T__15 15
#define T__18 18
#define T__17 17
#define T__12 12
#define T__11 11
#define T__14 14
#define T__13 13
#define T__10 10
#pragma mark Dynamic Global Scopes
#pragma mark Dynamic Rule Scopes
#pragma mark Rule Return Scopes start
#pragma mark Rule return scopes end
@interface SimpleCParser : ANTLRParser { /* line 572 */
// start of globalAttributeScopeMemVar


// start of action-actionScope-memVars
// start of ruleAttributeScopeMemVar


// Start of memVars

DFA2 *dfa2;
 }

// start of action-actionScope-methodsDecl


- (void)program; 
- (void)declaration; 
- (void)variable; 
- (void)declarator; 
- (NSString*)functionHeader; 
- (void)formalParameter; 
- (void)type; 
- (void)block; 
- (void)stat; 
- (void)forStat; 
- (void)assignStat; 
- (void)expr; 
- (void)condExpr; 
- (void)aexpr; 
- (void)atom; 


@end /* end of SimpleCParser interface */
