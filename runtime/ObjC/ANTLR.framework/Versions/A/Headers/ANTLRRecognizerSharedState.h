// [The "BSD licence"]
// Copyright (c) 2007 Kay Roepke 2010 Alan Condit
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
#import "ANTLRToken.h"
#import "ANTLRBitSet.h"
#import "ANTLRRuleStack.h"

@interface ANTLRRecognizerSharedState : NSObject {
	NSMutableArray *following;          // a stack of FOLLOW bitsets used for context sensitive prediction and recovery
    NSInteger _fsp;                     // Follow stack pointer
	BOOL errorRecovery;                 // are we recovering?
	NSInteger lastErrorIndex;
	BOOL failed;                        // indicate that some match failed
    NSInteger syntaxErrors;
	NSInteger backtracking;             // the level of backtracking
	ANTLRRuleStack *ruleMemo;			// store previous results of matching rules so we don't have to do it again. Hook in incremental stuff here, too.

	id<ANTLRToken> token;
	NSInteger  tokenStartCharIndex;
	NSUInteger tokenStartLine;
	NSUInteger tokenStartCharPositionInLine;
	NSUInteger channel;
	NSUInteger type;
	NSString   *text;
}

@property (retain, getter=getFollowing, setter=setFollowing:) NSMutableArray *following;
@property (assign) NSInteger _fsp;
@property (assign) BOOL errorRecovery;
@property (assign) NSInteger lastErrorIndex;
@property (assign, getter=getFailed, setter=setFailed:) BOOL failed;
@property (assign) NSInteger syntaxErrors;
@property (assign, getter=getBacktracking, setter=setBacktracking) NSInteger backtracking;
@property (retain, getter=getRuleMemo, setter=setRuleMemo:) ANTLRRuleStack *ruleMemo;
@property (copy, getter=getToken, setter=setToken) id<ANTLRToken> token;
@property (getter=getType,setter=setType:) NSUInteger type;
@property (getter=getChannel,setter=setChannel:) NSUInteger channel;
@property (getter=getTokenStartLine,setter=setTokenStartLine:) NSUInteger tokenStartLine;
@property (getter=getCharPositionInLine,setter=setCharPositionInLine:) NSUInteger tokenStartCharPositionInLine;
@property (getter=getTokenStartCharIndex,setter=setTokenStartCharIndex:) NSInteger tokenStartCharIndex;
@property (retain, getter=getText, setter=setText) NSString *text;

+ (ANTLRRecognizerSharedState *) newANTLRRecognizerSharedState;
+ (ANTLRRecognizerSharedState *) newANTLRRecognizerSharedStateWithRuleLen:(NSInteger)aLen;
+ (ANTLRRecognizerSharedState *) newANTLRRecognizerSharedState:(ANTLRRecognizerSharedState *)aState;

- (id) init;
- (id) initWithRuleLen:(NSInteger)aLen;
- (id) initWithState:(ANTLRRecognizerSharedState *)state;

- (id<ANTLRToken>) getToken;
- (void) setToken:(id<ANTLRToken>) theToken;

- (NSUInteger) getType;
- (void) setType:(NSUInteger) theTokenType;

- (NSUInteger) getChannel;
- (void) setChannel:(NSUInteger) theChannel;

- (NSUInteger) getTokenStartLine;
- (void) setTokenStartLine:(NSUInteger) theTokenStartLine;

- (NSUInteger) getCharPositionInLine;
- (void) setCharPositionInLine:(NSUInteger) theCharPosition;

- (NSInteger) getTokenStartCharIndex;
- (void) setTokenStartCharIndex:(NSInteger) theTokenStartCharIndex;

- (NSString *) getText;
- (void) setText:(NSString *) theText;


- (NSMutableArray *) getFollowing;
- (void)setFollowing:(NSMutableArray *)aFollow;
- (ANTLRRuleStack *) getRuleMemo;
- (void)setRuleMemo:(ANTLRRuleStack *)aRuleMemo;
- (BOOL) isErrorRecovery;
- (void) setIsErrorRecovery: (BOOL) flag;

- (BOOL) getFailed;
- (void) setFailed: (BOOL) flag;

- (NSInteger)  getBacktracking;
- (void) setBacktracking:(NSInteger) value;
- (void) increaseBacktracking;
- (void) decreaseBacktracking;
- (BOOL) isBacktracking;

- (NSInteger) lastErrorIndex;
- (void) setLastErrorIndex:(NSInteger) value;

@end
