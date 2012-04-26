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


#import <Foundation/Foundation.h>

#import "IntStream.h"
#import "AMutableArray.h"

// This is an abstract superclass for lexers and parsers.

#define ANTLR_MEMO_RULE_FAILED -2
#define ANTLR_MEMO_RULE_UNKNOWN -1
#define ANTLR_INITIAL_FOLLOW_STACK_SIZE 100

#import "MapElement.h"
#import "ANTLRBitSet.h"
#import "Token.h"
#import "RecognizerSharedState.h"
#import "RecognitionException.h"
#import "MissingTokenException.h"
#import "MismatchedTokenException.h"
#import "MismatchedTreeNodeException.h"
#import "UnwantedTokenException.h"
#import "NoViableAltException.h"
#import "EarlyExitException.h"
#import "MismatchedSetException.h"
#import "MismatchedNotSetException.h"
#import "FailedPredicateException.h"

@interface BaseRecognizer : NSObject {
    __strong RecognizerSharedState *state;  // the state of this recognizer. Might be shared with other recognizers, e.g. in grammar import scenarios.
    __strong NSString *grammarFileName;          // where did the grammar come from. filled in by codegeneration
    __strong NSString *sourceName;
    __strong AMutableArray *tokenNames;
}

+ (void) initialize;

+ (BaseRecognizer *) newBaseRecognizer;
+ (BaseRecognizer *) newBaseRecognizerWithRuleLen:(NSInteger)aLen;
+ (BaseRecognizer *) newBaseRecognizer:(RecognizerSharedState *)aState;

+ (AMutableArray *)getTokenNames;
+ (void)setTokenNames:(NSArray *)aTokNamArray;
+ (void)setGrammarFileName:(NSString *)aFileName;

- (id) init;
- (id) initWithLen:(NSInteger)aLen;
- (id) initWithState:(RecognizerSharedState *)aState;

- (void) dealloc;

// simple accessors
- (NSInteger) getBacktrackingLevel;
- (void) setBacktrackingLevel:(NSInteger) level;

- (BOOL) getFailed;
- (void) setFailed: (BOOL) flag;

- (RecognizerSharedState *) getState;
- (void) setState:(RecognizerSharedState *) theState;

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
- (id) match:(id<IntStream>)anInput TokenType:(NSInteger)ttype Follow:(ANTLRBitSet *)follow;
- (void) matchAny:(id<IntStream>)anInput;
- (BOOL) mismatchIsUnwantedToken:(id<IntStream>)anInput TokenType:(NSInteger) ttype;
- (BOOL) mismatchIsMissingToken:(id<IntStream>)anInput Follow:(ANTLRBitSet *)follow;

// error reporting and recovery
- (void) reportError:(RecognitionException *)e;
- (void) displayRecognitionError:(AMutableArray *)theTokNams Exception:(RecognitionException *)e;
- (NSString *)getErrorMessage:(RecognitionException *)e TokenNames:(AMutableArray *)theTokNams;
- (NSInteger) getNumberOfSyntaxErrors;
- (NSString *)getErrorHeader:(RecognitionException *)e;
- (NSString *)getTokenErrorDisplay:(id<Token>)t;
- (void) emitErrorMessage:(NSString *)msg;
- (void) recover:(id<IntStream>)anInput Exception:(RecognitionException *)e;

// begin hooks for debugger
- (void) beginResync;
- (void) endResync;
// end hooks for debugger

// compute the bitsets necessary to do matching and recovery
- (ANTLRBitSet *)computeErrorRecoverySet;
- (ANTLRBitSet *)computeContextSensitiveRuleFOLLOW;
- (ANTLRBitSet *)combineFollows:(BOOL) exact;

- (id<Token>) recoverFromMismatchedToken:(id<IntStream>)anInput 
                                    TokenType:(NSInteger)ttype 
                                       Follow:(ANTLRBitSet *)follow;
                                    
- (id<Token>)recoverFromMismatchedSet:(id<IntStream>)anInput
                                    Exception:(RecognitionException *)e
                                    Follow:(ANTLRBitSet *)follow;

- (id) getCurrentInputSymbol:(id<IntStream>)anInput;
- (id) getMissingSymbol:(id<IntStream>)anInput
              Exception:(RecognitionException *)e
              TokenType:(NSInteger) expectedTokenType
                Follow:(ANTLRBitSet *)follow;

// helper methods for recovery. try to resync somewhere
- (void) consumeUntilTType:(id<IntStream>)anInput TokenType:(NSInteger)ttype;
- (void) consumeUntilFollow:(id<IntStream>)anInput Follow:(ANTLRBitSet *)bitSet;
- (void) pushFollow:(ANTLRBitSet *)fset;
- (ANTLRBitSet *)popFollow;

// to be used by the debugger to do reporting. maybe hook in incremental stuff here, too.
- (AMutableArray *) getRuleInvocationStack;
- (AMutableArray *) getRuleInvocationStack:(RecognitionException *)exception
                                 Recognizer:(NSString *)recognizerClassName;

- (AMutableArray *) getTokenNames;
- (NSString *)getGrammarFileName;
- (NSString *)getSourceName;
- (AMutableArray *) toStrings:(NSArray *)tokens;
// support for memoization
- (NSInteger) getRuleMemoization:(NSInteger)ruleIndex StartIndex:(NSInteger)ruleStartIndex;
- (BOOL) alreadyParsedRule:(id<IntStream>)anInput RuleIndex:(NSInteger)ruleIndex;
- (void) memoize:(id<IntStream>)anInput
         RuleIndex:(NSInteger)ruleIndex
        StartIndex:(NSInteger)ruleStartIndex;
- (NSInteger) getRuleMemoizationCacheSize;
- (void)traceIn:(NSString *)ruleName Index:(NSInteger)ruleIndex Object:(id)inputSymbol;
- (void)traceOut:(NSString *)ruleName Index:(NSInteger)ruleIndex Object:(id)inputSymbol;


// support for syntactic predicates. these are called indirectly to support funky stuff in grammars,
// like supplying selectors instead of writing code directly into the actions of the grammar.
- (BOOL) evaluateSyntacticPredicate:(SEL)synpredFragment;
// stream:(id<IntStream>)anInput;

@property (retain) RecognizerSharedState *state;
@property (retain) NSString *grammarFileName;
@property (retain) NSString *sourceName;
@property (retain) AMutableArray *tokenNames;

@end
