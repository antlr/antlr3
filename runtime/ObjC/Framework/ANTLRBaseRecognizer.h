// [The "BSD licence"]
// Copyright (c) 2006-2007 Kay Roepke 2010 Alan Condit
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products
//    derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

#import "ANTLRIntStream.h"
#import "AMutableArray.h"

// This is an abstract superclass for lexers and parsers.

#define ANTLR_MEMO_RULE_FAILED -2
#define ANTLR_MEMO_RULE_UNKNOWN -1
#define ANTLR_INITIAL_FOLLOW_STACK_SIZE 100

#import "ANTLRMapElement.h"
#import "ANTLRBitSet.h"
#import "ANTLRToken.h"
#import "ANTLRRecognizerSharedState.h"
#import "ANTLRRecognitionException.h"
#import "ANTLRMissingTokenException.h"
#import "ANTLRMismatchedTokenException.h"
#import "ANTLRMismatchedTreeNodeException.h"
#import "ANTLRUnwantedTokenException.h"
#import "ANTLRNoViableAltException.h"
#import "ANTLREarlyExitException.h"
#import "ANTLRMismatchedSetException.h"
#import "ANTLRMismatchedNotSetException.h"
#import "ANTLRFailedPredicateException.h"

@interface ANTLRBaseRecognizer : NSObject {
    __strong ANTLRRecognizerSharedState *state;  // the state of this recognizer. Might be shared with other recognizers, e.g. in grammar import scenarios.
    __strong NSString *grammarFileName;          // where did the grammar come from. filled in by codegeneration
    __strong NSString *sourceName;
    __strong AMutableArray *tokenNames;
}

+ (void) initialize;

+ (ANTLRBaseRecognizer *) newANTLRBaseRecognizer;
+ (ANTLRBaseRecognizer *) newANTLRBaseRecognizerWithRuleLen:(NSInteger)aLen;
+ (ANTLRBaseRecognizer *) newANTLRBaseRecognizer:(ANTLRRecognizerSharedState *)aState;

+ (AMutableArray *)getTokenNames;
+ (void)setTokenNames:(NSArray *)aTokNamArray;
+ (void)setGrammarFileName:(NSString *)aFileName;

- (id) init;
- (id) initWithLen:(NSInteger)aLen;
- (id) initWithState:(ANTLRRecognizerSharedState *)aState;

- (void) dealloc;

// simple accessors
- (NSInteger) getBacktrackingLevel;
- (void) setBacktrackingLevel:(NSInteger) level;

- (BOOL) getFailed;
- (void) setFailed: (BOOL) flag;

- (ANTLRRecognizerSharedState *) getState;
- (void) setState:(ANTLRRecognizerSharedState *) theState;

// reset this recognizer - might be extended by codegeneration/grammar
- (void) reset;

/** Match needs to return the current input symbol, which gets put
 *  into the label for the associated token ref; e.g., x=ID.  Token
 *  and tree parsers need to return different objects. Rather than test
 *  for input stream type or change the IntStream interface, I use
 *  a simple method to ask the recognizer to tell me what the current
 *  input symbol is.
 * 
 *  This is ignored for lexers.
 */
- (id) input;

- (void)skip;

// do actual matching of tokens/characters
- (id) match:(id<ANTLRIntStream>)anInput TokenType:(NSInteger)ttype Follow:(ANTLRBitSet *)follow;
- (void) matchAny:(id<ANTLRIntStream>)anInput;
- (BOOL) mismatchIsUnwantedToken:(id<ANTLRIntStream>)anInput TokenType:(NSInteger) ttype;
- (BOOL) mismatchIsMissingToken:(id<ANTLRIntStream>)anInput Follow:(ANTLRBitSet *)follow;

// error reporting and recovery
- (void) reportError:(ANTLRRecognitionException *)e;
- (void) displayRecognitionError:(AMutableArray *)theTokNams Exception:(ANTLRRecognitionException *)e;
- (NSString *)getErrorMessage:(ANTLRRecognitionException *)e TokenNames:(AMutableArray *)theTokNams;
- (NSInteger) getNumberOfSyntaxErrors;
- (NSString *)getErrorHeader:(ANTLRRecognitionException *)e;
- (NSString *)getTokenErrorDisplay:(id<ANTLRToken>)t;
- (void) emitErrorMessage:(NSString *)msg;
- (void) recover:(id<ANTLRIntStream>)anInput Exception:(ANTLRRecognitionException *)e;

// begin hooks for debugger
- (void) beginResync;
- (void) endResync;
// end hooks for debugger

// compute the bitsets necessary to do matching and recovery
- (ANTLRBitSet *)computeErrorRecoverySet;
- (ANTLRBitSet *)computeContextSensitiveRuleFOLLOW;
- (ANTLRBitSet *)combineFollows:(BOOL) exact;

- (id<ANTLRToken>) recoverFromMismatchedToken:(id<ANTLRIntStream>)anInput 
                                    TokenType:(NSInteger)ttype 
                                       Follow:(ANTLRBitSet *)follow;
                                    
- (id<ANTLRToken>)recoverFromMismatchedSet:(id<ANTLRIntStream>)anInput
                                    Exception:(ANTLRRecognitionException *)e
                                    Follow:(ANTLRBitSet *)follow;

- (id) getCurrentInputSymbol:(id<ANTLRIntStream>)anInput;
- (id) getMissingSymbol:(id<ANTLRIntStream>)anInput
              Exception:(ANTLRRecognitionException *)e
              TokenType:(NSInteger) expectedTokenType
                Follow:(ANTLRBitSet *)follow;

// helper methods for recovery. try to resync somewhere
- (void) consumeUntilTType:(id<ANTLRIntStream>)anInput TokenType:(NSInteger)ttype;
- (void) consumeUntilFollow:(id<ANTLRIntStream>)anInput Follow:(ANTLRBitSet *)bitSet;
- (void) pushFollow:(ANTLRBitSet *)fset;
- (ANTLRBitSet *)popFollow;

// to be used by the debugger to do reporting. maybe hook in incremental stuff here, too.
- (AMutableArray *) getRuleInvocationStack;
- (AMutableArray *) getRuleInvocationStack:(ANTLRRecognitionException *)exception
                                 Recognizer:(NSString *)recognizerClassName;

- (AMutableArray *) getTokenNames;
- (NSString *)getGrammarFileName;
- (NSString *)getSourceName;
- (AMutableArray *) toStrings:(NSArray *)tokens;
// support for memoization
- (NSInteger) getRuleMemoization:(NSInteger)ruleIndex StartIndex:(NSInteger)ruleStartIndex;
- (BOOL) alreadyParsedRule:(id<ANTLRIntStream>)anInput RuleIndex:(NSInteger)ruleIndex;
- (void) memoize:(id<ANTLRIntStream>)anInput
         RuleIndex:(NSInteger)ruleIndex
        StartIndex:(NSInteger)ruleStartIndex;
- (NSInteger) getRuleMemoizationCacheSize;
- (void)traceIn:(NSString *)ruleName Index:(NSInteger)ruleIndex Object:(id)inputSymbol;
- (void)traceOut:(NSString *)ruleName Index:(NSInteger)ruleIndex Object:(id)inputSymbol;


// support for syntactic predicates. these are called indirectly to support funky stuff in grammars,
// like supplying selectors instead of writing code directly into the actions of the grammar.
- (BOOL) evaluateSyntacticPredicate:(SEL)synpredFragment;
// stream:(id<ANTLRIntStream>)anInput;

@property (retain) ANTLRRecognizerSharedState *state;
@property (retain) NSString *grammarFileName;
@property (retain) NSString *sourceName;
@property (retain) AMutableArray *tokenNames;

@end
