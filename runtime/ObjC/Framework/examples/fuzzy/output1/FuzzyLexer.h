// $ANTLR 3.2 Aug 20, 2010 13:39:32 /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/fuzzy/Fuzzy.g 2010-08-20 13:40:15

/* =============================================================================
 * Standard antlr3 OBJC runtime definitions
 */
#import <Cocoa/Cocoa.h>
#import "antlr3.h"
/* End of standard antlr3 runtime definitions
 * =============================================================================
 */

/* Start cyclicDFAInterface */
#pragma mark Cyclic DFA interface start DFA38
@interface DFA38 : ANTLRDFA {
}
+ newDFA38WithRecognizer:(ANTLRBaseRecognizer *)theRecognizer;
- initWithRecognizer:(ANTLRBaseRecognizer *)recognizer;
@end

#pragma mark Cyclic DFA interface end DFA38

#pragma mark Rule return scopes start
#pragma mark Rule return scopes end
#pragma mark Tokens
#define STAT 15
#define CLASS 10
#define ESC 19
#define CHAR 21
#define ID 8
#define EOF -1
#define QID 9
#define TYPE 11
#define IMPORT 6
#define WS 4
#define ARG 12
#define QIDStar 5
#define SL_COMMENT 18
#define RETURN 7
#define FIELD 14
#define CALL 16
#define COMMENT 17
#define METHOD 13
#define STRING 20
@interface Fuzzy : ANTLRLexer { // line 283
    DFA38 *dfa38;
    SEL synpred9_FuzzySelector;
    SEL synpred2_FuzzySelector;
    SEL synpred7_FuzzySelector;
    SEL synpred4_FuzzySelector;
    SEL synpred8_FuzzySelector;
    SEL synpred6_FuzzySelector;
    SEL synpred5_FuzzySelector;
    SEL synpred3_FuzzySelector;
    SEL synpred1_FuzzySelector;
}
+ (Fuzzy *)newFuzzy:(id<ANTLRCharStream>)anInput;

- (void)mIMPORT; 
- (void)mRETURN; 
- (void)mCLASS; 
- (void)mMETHOD; 
- (void)mFIELD; 
- (void)mSTAT; 
- (void)mCALL; 
- (void)mCOMMENT; 
- (void)mSL_COMMENT; 
- (void)mSTRING; 
- (void)mCHAR; 
- (void)mWS; 
- (void)mQID; 
- (void)mQIDStar; 
- (void)mTYPE; 
- (void)mARG; 
- (void)mID; 
- (void)mESC; 
- (void)mTokens; 
- (void)synpred1_Fuzzy_fragment; 
- (void)synpred2_Fuzzy_fragment; 
- (void)synpred3_Fuzzy_fragment; 
- (void)synpred4_Fuzzy_fragment; 
- (void)synpred5_Fuzzy_fragment; 
- (void)synpred6_Fuzzy_fragment; 
- (void)synpred7_Fuzzy_fragment; 
- (void)synpred8_Fuzzy_fragment; 
- (void)synpred9_Fuzzy_fragment; 

@end // end of Fuzzy interface