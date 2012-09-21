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
#import "TokenSource.h"
#import "BaseRecognizer.h"
#import "RecognizerSharedState.h"
#import "CharStream.h"
#import "Token.h"
#import "CommonToken.h"
#import "RecognitionException.h"
#import "MismatchedTokenException.h"
#import "MismatchedRangeException.h"

@interface Lexer : BaseRecognizer <TokenSource> {
	id<CharStream> input;      ///< The character stream we pull tokens out of.
	NSUInteger ruleNestingLevel;
}

@property (retain, getter=input, setter=setInput:) id<CharStream> input;
@property (getter=getRuleNestingLevel, setter=setRuleNestingLevel:) NSUInteger ruleNestingLevel;

#pragma mark Initializer
- (id) initWithCharStream:(id<CharStream>) anInput;
- (id) initWithCharStream:(id<CharStream>)anInput State:(RecognizerSharedState *)state;

- (id) copyWithZone:(NSZone *)zone;

- (void) reset;

// - (RecognizerSharedState *) state;

#pragma mark Tokens
- (id<Token>)getToken;
- (void) setToken: (id<Token>) aToken;
- (id<Token>) nextToken;
- (void) mTokens;		// abstract, defined in generated sources
- (void) skip;
- (id<CharStream>) input;
- (void) setInput:(id<CharStream>)aCharStream;

- (void) emit;
- (void) emit:(id<Token>)aToken;

#pragma mark Matching
- (void) matchString:(NSString *)aString;
- (void) matchAny;
- (void) matchChar:(unichar) aChar;
- (void) matchRangeFromChar:(unichar)fromChar to:(unichar)toChar;

#pragma mark Informational
- (NSUInteger) line;
- (NSUInteger) charPositionInLine;
- (NSInteger) index;
- (NSString *) text;
- (void) setText:(NSString *) theText;

// error handling
- (void) reportError:(RecognitionException *)e;
- (NSString *)getErrorMessage:(RecognitionException *)e TokenNames:(AMutableArray *)tokenNames;
- (NSString *)getCharErrorDisplay:(NSInteger)c;
- (void) recover:(RecognitionException *)e;
- (void)traceIn:(NSString *)ruleName Index:(NSInteger)ruleIndex;
- (void)traceOut:(NSString *)ruleName Index:(NSInteger)ruleIndex;

@end
