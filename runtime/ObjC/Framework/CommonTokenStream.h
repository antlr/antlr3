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
#import "TokenStream.h"
#import "Token.h"
#import "CommonToken.h"
#import "TokenSource.h"
#import "ANTLRBitSet.h"
#import "BufferedTokenStream.h"
#import "AMutableDictionary.h"

@interface CommonTokenStream : BufferedTokenStream < TokenStream >
{
	__strong AMutableDictionary *channelOverride;
	NSUInteger channel;
}

@property (retain, getter=getChannelOverride,setter=setChannelOverride:) AMutableDictionary *channelOverride;
@property (assign, getter=channel,setter=setChannel:) NSUInteger channel;

+ (CommonTokenStream *)newCommonTokenStream;
+ (CommonTokenStream *)newCommonTokenStreamWithTokenSource:(id<TokenSource>)theTokenSource;
+ (CommonTokenStream *)newCommonTokenStreamWithTokenSource:(id<TokenSource>)theTokenSource
                                                               Channel:(NSUInteger)aChannel;

- (id) init;
- (id) initWithTokenSource:(id<TokenSource>)theTokenSource;
- (id) initWithTokenSource:(id<TokenSource>)theTokenSource Channel:(NSUInteger)aChannel;

- (void) consume;
- (id<Token>) LB:(NSInteger)k;
- (id<Token>) LT:(NSInteger)k;

- (NSInteger) skipOffTokenChannels:(NSInteger) i;
- (NSInteger) skipOffTokenChannelsReverse:(NSInteger) i;

- (void)setup;
- (void)reset;

- (NSInteger) getNumberOfOnChannelTokens;

// - (id<TokenSource>) getTokenSource;
- (void) setTokenSource: (id<TokenSource>) aTokenSource;

- (NSUInteger)channel;
- (void)setChannel:(NSUInteger)aChannel;

- (AMutableDictionary *)channelOverride;
- (void)setChannelOverride:(AMutableDictionary *)anOverride;

- (id) copyWithZone:(NSZone *)aZone;

#ifdef DONTUSENOMO
- (NSArray *) tokensInRange:(NSRange)aRange;
- (NSArray *) tokensInRange:(NSRange)aRange inBitSet:(ANTLRBitSet *)aBitSet;
- (NSArray *) tokensInRange:(NSRange)aRange withTypes:(NSArray *)tokenTypes;
- (NSArray *) tokensInRange:(NSRange)aRange withType:(NSInteger)tokenType;

- (id<Token>) getToken:(NSInteger)i;

- (NSInteger) size;
- (void) rewind;
- (void) rewind:(NSInteger)marker;
- (void) seek:(NSInteger)index;

- (NSString *) toString;
- (NSString *) toStringFromStart:(NSInteger)startIndex ToEnd:(NSInteger)stopIndex;
- (NSString *) toStringFromToken:(id<Token>)startToken ToToken:(id<Token>)stopToken;

#endif

@end
