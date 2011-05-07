// $ANTLR ${project.version} ${buildNumber} /Users/acondit/source/antlr3/acondit_localhost/code/antlr/antlr3-main/runtime/ObjC/Framework/examples/fuzzy/Fuzzy.g 2011-05-05 22:05:01

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
#define ARG 4
#define CALL 5
#define CHAR 6
#define CLASS 7
#define COMMENT 8
#define ESC 9
#define FIELD 10
#define ID 11
#define IMPORT 12
#define METHOD 13
#define QID 14
#define QIDStar 15
#define RETURN 16
#define SL_COMMENT 17
#define STAT 18
#define STRING 19
#define TYPE 20
#define WS 21
/* interface lexer class */
@interface Fuzzy : ANTLRLexer { // line 283
SEL synpred9_FuzzySelector;
SEL synpred2_FuzzySelector;
SEL synpred7_FuzzySelector;
SEL synpred4_FuzzySelector;
SEL synpred8_FuzzySelector;
SEL synpred6_FuzzySelector;
SEL synpred5_FuzzySelector;
SEL synpred3_FuzzySelector;
SEL synpred1_FuzzySelector;
/* ObjC start of actions.lexer.memVars */
/* ObjC end of actions.lexer.memVars */
}
+ (void) initialize;
+ (Fuzzy *)newFuzzyWithCharStream:(id<ANTLRCharStream>)anInput;
/* ObjC start actions.lexer.methodsDecl */
/* ObjC end actions.lexer.methodsDecl */
- (void) mIMPORT ; 
- (void) mRETURN ; 
- (void) mCLASS ; 
- (void) mMETHOD ; 
- (void) mFIELD ; 
- (void) mSTAT ; 
- (void) mCALL ; 
- (void) mCOMMENT ; 
- (void) mSL_COMMENT ; 
- (void) mSTRING ; 
- (void) mCHAR ; 
- (void) mWS ; 
- (void) mQID ; 
- (void) mQIDStar ; 
- (void) mTYPE ; 
- (void) mARG ; 
- (void) mID ; 
- (void) mESC ; 
- (void) mTokens ; 
- (void) synpred1_Fuzzy_fragment ; 
- (void) synpred2_Fuzzy_fragment ; 
- (void) synpred3_Fuzzy_fragment ; 
- (void) synpred4_Fuzzy_fragment ; 
- (void) synpred5_Fuzzy_fragment ; 
- (void) synpred6_Fuzzy_fragment ; 
- (void) synpred7_Fuzzy_fragment ; 
- (void) synpred8_Fuzzy_fragment ; 
- (void) synpred9_Fuzzy_fragment ; 

@end /* end of Fuzzy interface */

