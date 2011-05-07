// $ANTLR ${project.version} ${buildNumber} SimpleC.g 2011-05-06 13:53:12

/* =============================================================================
 * Standard antlr3 OBJC runtime definitions
 */
#import <Cocoa/Cocoa.h>
#import <ANTLR/ANTLR.h>
/* End of standard antlr3 runtime definitions
 * =============================================================================
 */

/* parserHeaderFile */
#ifndef ANTLR3TokenTypeAlreadyDefined
#define ANTLR3TokenTypeAlreadyDefined
typedef enum {
    ANTLR_EOF = -1,
    INVALID,
    EOR,
    DOWN,
    UP,
    MIN
} ANTLR3TokenType;
#endif

#pragma mark Cyclic DFA interface start DFA2
@interface DFA2 : ANTLRDFA {
}
+ newDFA2WithRecognizer:(ANTLRBaseRecognizer *)theRecognizer;
- initWithRecognizer:(ANTLRBaseRecognizer *)recognizer;
@end /* end of DFA2 interface  */

#pragma mark Cyclic DFA interface end DFA2

#pragma mark Tokens
#ifdef EOF
#undef EOF
#endif
#define EOF -1
#define T__7 7
#define T__8 8
#define T__9 9
#define T__10 10
#define T__11 11
#define T__12 12
#define T__13 13
#define T__14 14
#define T__15 15
#define T__16 16
#define T__17 17
#define T__18 18
#define T__19 19
#define T__20 20
#define ID 4
#define INT 5
#define WS 6
#pragma mark Dynamic Global Scopes
#pragma mark Dynamic Rule Scopes
#pragma mark Rule Return Scopes start

/* Interface grammar class */
@interface SimpleCParser : ANTLRParser { /* line 572 */
/* ObjC start of ruleAttributeScopeMemVar */


/* ObjC end of ruleAttributeScopeMemVar */
/* ObjC start of globalAttributeScopeMemVar */


/* ObjC end of globalAttributeScopeMemVar */
/* ObjC start of actions.(actionScope).memVars */
/* ObjC end of actions.(actionScope).memVars */
/* ObjC start of memVars */
/* ObjC end of memVars */

DFA2 *dfa2;
 }

/* ObjC start of actions.(actionScope).properties */
/* ObjC end of actions.(actionScope).properties */
/* ObjC start of properties */
/* ObjC end of properties */

+ (void) initialize;
+ (id) newSimpleCParser:(id<ANTLRTokenStream>)aStream;
/* ObjC start of actions.(actionScope).methodsDecl */
/* ObjC end of actions.(actionScope).methodsDecl */

/* ObjC start of methodsDecl */
/* ObjC end of methodsDecl */

- (void)program; 
- (void)declaration; 
- (void)variable; 
- (void)declarator; 
- (NSString *)functionHeader; 
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

