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

#import "ANTLRRecognizerSharedState.h"
#import "ANTLRCharStream.h"
#import "ANTLRCommonToken.h"
#import "ANTLRMismatchedTokenException.h"
#import "ANTLRMismatchedRangeException.h"

@implementation ANTLRRecognizerSharedState

@synthesize following;
@synthesize _fsp;
@synthesize errorRecovery;
@synthesize lastErrorIndex;
@synthesize failed;
@synthesize syntaxErrors;
@synthesize backtracking;
@synthesize ruleMemo;
@synthesize token;
@synthesize type;
@synthesize channel;
@synthesize tokenStartLine;
@synthesize tokenStartCharPositionInLine;
@synthesize tokenStartCharIndex;
@synthesize text;

+ (ANTLRRecognizerSharedState *) newANTLRRecognizerSharedState
{
    return [[[ANTLRRecognizerSharedState alloc] init] retain];
}

+ (ANTLRRecognizerSharedState *) newANTLRRecognizerSharedStateWithRuleLen:(NSInteger)aLen
{
    return [[[ANTLRRecognizerSharedState alloc] initWithRuleLen:aLen] retain];
}

+ (ANTLRRecognizerSharedState *) newANTLRRecognizerSharedState:(ANTLRRecognizerSharedState *)aState
{
    return [[[ANTLRRecognizerSharedState alloc] initWithState:aState] retain];
}

- (id) init
{
    ANTLRHashRule *aHashRule;
	if ((self = [super init]) != nil ) {
        following = [[AMutableArray arrayWithCapacity:10] retain];
        _fsp = -1;
        errorRecovery = NO;			// are we recovering?
        lastErrorIndex = -1;
        failed = NO;				// indicate that some match failed
        syntaxErrors = 0;
        backtracking = 0;			// the level of backtracking
        tokenStartCharIndex = -1;
        tokenStartLine = 0;
        int cnt = 200;
		ruleMemo = [[ANTLRRuleStack newANTLRRuleStack:cnt] retain];
        for (int i = 0; i < cnt; i++ ) {
            aHashRule = [[ANTLRHashRule newANTLRHashRuleWithLen:17] retain];
            [ruleMemo addObject:aHashRule];
        }
#ifdef DONTUSEYET
        token = state.token;
        tokenStartCharIndex = state.tokenStartCharIndex;
        tokenStartCharPositionInLine = state.tokenStartCharPositionInLine;
        channel = state.channel;
        type = state.type;
        text = state.text;
#endif
	}
	return self;
}

- (id) initWithRuleLen:(NSInteger)aLen
{
    ANTLRHashRule *aHashRule;
	if ((self = [super init]) != nil ) {
        following = [[AMutableArray arrayWithCapacity:10] retain];
        _fsp = -1;
        errorRecovery = NO;			// are we recovering?
        lastErrorIndex = -1;
        failed = NO;				// indicate that some match failed
        syntaxErrors = 0;
        backtracking = 0;			// the level of backtracking
        tokenStartCharIndex = -1;
        tokenStartLine = 0;
		ruleMemo = [[ANTLRRuleStack newANTLRRuleStack:aLen] retain];
        for (int i = 0; i < aLen; i++ ) {
            aHashRule = [[ANTLRHashRule newANTLRHashRuleWithLen:17] retain];
            [ruleMemo addObject:aHashRule];
        }
#ifdef DONTUSEYET
        token = state.token;
        tokenStartCharIndex = state.tokenStartCharIndex;
        tokenStartCharPositionInLine = state.tokenStartCharPositionInLine;
        channel = state.channel;
        type = state.type;
        text = state.text;
#endif
	}
	return self;
}

- (id) initWithState:(ANTLRRecognizerSharedState *)aState
{
    ANTLRHashRule *aHashRule;
    if ( [following count] < [aState.following count] ) {
        //        following = new BitSet[state.following.size];
    }
    [following setArray:aState.following];
    _fsp = aState._fsp;
    errorRecovery = aState.errorRecovery;
    lastErrorIndex = aState.lastErrorIndex;
    failed = aState.failed;
    syntaxErrors = aState.syntaxErrors;
    backtracking = aState.backtracking;
    if ( aState.ruleMemo == nil ) {
        int cnt = 200;
        ruleMemo = [[ANTLRRuleStack newANTLRRuleStack:cnt] retain];
        for (int i = 0; i < cnt; i++ ) {
            aHashRule = [[ANTLRHashRule newANTLRHashRuleWithLen:17] retain];
            [ruleMemo addObject:aHashRule];
        }
    }
    else {
        ruleMemo = aState.ruleMemo;
        if ( [ruleMemo count] == 0 ) {
            int cnt = [ruleMemo length];
            for (int i = 0; i < cnt; i++ ) {
                [ruleMemo addObject:[[ANTLRHashRule newANTLRHashRuleWithLen:17] retain]];
            }
        }
        else {
            [ruleMemo addObjectsFromArray:aState.ruleMemo];
        }
    }
    token = aState.token;
    tokenStartCharIndex = aState.tokenStartCharIndex;
    tokenStartCharPositionInLine = aState.tokenStartCharPositionInLine;
    tokenStartLine = aState.tokenStartLine;
    channel = aState.channel;
    type = aState.type;
    text = aState.text;
    return( self );
}

- (void) dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in ANTLRRecognizerSharedState" );
#endif
    if ( token ) [token release];
	if ( following ) [following release];
	if ( ruleMemo ) [ruleMemo release];
	[super dealloc];
}

// token stuff
#pragma mark Tokens

- (id<ANTLRToken>)getToken
{
    return token; 
}

- (void) setToken: (id<ANTLRToken>) aToken
{
    if (token != aToken) {
        [aToken retain];
        if ( token ) [token release];
        token = aToken;
    }
}

- (NSUInteger)channel
{
    return channel;
}

- (void) setChannel:(NSUInteger) theChannel
{
    channel = theChannel;
}

- (NSUInteger) getTokenStartLine
{
    return tokenStartLine;
}

- (void) setTokenStartLine:(NSUInteger) theTokenStartLine
{
    tokenStartLine = theTokenStartLine;
}

- (NSUInteger) charPositionInLine
{
    return tokenStartCharPositionInLine;
}

- (void) setCharPositionInLine:(NSUInteger) theCharPosition
{
    tokenStartCharPositionInLine = theCharPosition;
}

- (NSInteger) getTokenStartCharIndex;
{
    return tokenStartCharIndex;
}

- (void) setTokenStartCharIndex:(NSInteger) theTokenStartCharIndex
{
    tokenStartCharIndex = theTokenStartCharIndex;
}

// error handling
- (void) reportError:(ANTLRRecognitionException *)e
{
	NSLog(@"%@", e.name);
}

- (AMutableArray *) getFollowing
{
	return following;
}

- (void)setFollowing:(AMutableArray *)aFollow
{
    if ( following != aFollow ) {
        if ( following ) [following release];
        [aFollow retain];
    }
    following = aFollow;
}

- (ANTLRRuleStack *) getRuleMemo
{
	return ruleMemo;
}

- (void)setRuleMemo:(ANTLRRuleStack *)aRuleMemo
{
    if ( ruleMemo != aRuleMemo ) {
        if ( ruleMemo ) [ruleMemo release];
        [aRuleMemo retain];
    }
    ruleMemo = aRuleMemo;
}

- (BOOL) isErrorRecovery
{
	return errorRecovery;
}

- (void) setIsErrorRecovery: (BOOL) flag
{
	errorRecovery = flag;
}


- (BOOL) getFailed
{
	return failed;
}

- (void) setFailed:(BOOL)flag
{
	failed = flag;
}


- (NSInteger) backtracking
{
	return backtracking;
}

- (void) setBacktracking:(NSInteger) value
{
	backtracking = value;
}

- (void) increaseBacktracking
{
	backtracking++;
}

- (void) decreaseBacktracking
{
	backtracking--;
}

- (BOOL) isBacktracking
{
	return backtracking > 0;
}


- (NSInteger) lastErrorIndex
{
    return lastErrorIndex;
}

- (void) setLastErrorIndex:(NSInteger) value
{
	lastErrorIndex = value;
}


@end
