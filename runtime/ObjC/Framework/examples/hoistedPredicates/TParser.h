// $ANTLR ${project.version} ${buildNumber} T.g 2011-05-06 19:14:23

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

#pragma mark Tokens
#ifdef EOF
#undef EOF
#endif
#define EOF -1
#define T__7 7
#define ID 4
#define INT 5
#define WS 6
#pragma mark Dynamic Global Scopes
#pragma mark Dynamic Rule Scopes
#pragma mark Rule Return Scopes start

/* Interface grammar class */
@interface TParser : ANTLRParser { /* line 572 */
/* ObjC start of ruleAttributeScopeMemVar */


/* ObjC end of ruleAttributeScopeMemVar */
/* ObjC start of globalAttributeScopeMemVar */


/* ObjC end of globalAttributeScopeMemVar */
/* ObjC start of actions.(actionScope).memVars */

/* With this true, enum is seen as a keyword.  False, it's an identifier */
BOOL enableEnum;

/* ObjC end of actions.(actionScope).memVars */
/* ObjC start of memVars */
/* ObjC end of memVars */

 }

/* ObjC start of actions.(actionScope).properties */
/* ObjC end of actions.(actionScope).properties */
/* ObjC start of properties */
/* ObjC end of properties */

+ (void) initialize;
+ (id) newTParser:(id<ANTLRTokenStream>)aStream;
/* ObjC start of actions.(actionScope).methodsDecl */
/* ObjC end of actions.(actionScope).methodsDecl */

/* ObjC start of methodsDecl */
/* ObjC end of methodsDecl */

- (void)stat; 
- (void)identifier; 
- (void)enumAsKeyword; 
- (void)enumAsID; 


@end /* end of TParser interface */

/** Demonstrates how semantic predicates get hoisted out of the rule in 
 *  which they are found and used in other decisions.  This grammar illustrates
 *  how predicates can be used to distinguish between enum as a keyword and
 *  an ID *dynamically*. :)

 * Run "java org.antlr.Tool -dfa t.g" to generate DOT (graphviz) files.  See
 * the T_dec-1.dot file to see the predicates in action.
 */