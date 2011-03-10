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
#import "ANTLRToken.h"
#import "ANTLRCharStream.h"

@interface ANTLRCommonToken : NSObject < ANTLRToken > {
	NSString *text;
	NSInteger type;
	// information about the Token's position in the input stream
	NSUInteger line;
	NSUInteger charPositionInLine;
	NSUInteger channel;
	// this token's position in the TokenStream
	NSUInteger index;
	
	// indices into the CharStream to avoid copying the text
	// can manually override the text by using -setText:
	NSUInteger startIndex;
	NSUInteger stopIndex;
	// the actual input stream this token was found in
	id<ANTLRCharStream> input;
}

@property (retain, getter=getText, setter=setText:) NSString *text;
@property (assign, getter=getType, setter=setType:) NSInteger type;
@property (assign, getter=getLine, setter=setLine:) NSUInteger line;
@property (assign, getter=getCharPositionInLine, setter=setCharPositionInLine:) NSUInteger charPositionInLine;
@property (assign, getter=getChannel, setter=setChannel:) NSUInteger channel;
@property (assign, getter=getTokenIndex, setter=setTokenIndex:) NSUInteger index;
@property (assign, getter=getStart, setter=setStart:) NSUInteger startIndex;
@property (assign, getter=getStop, setter=setStop:) NSUInteger stopIndex;
@property (retain, getter=getInput, setter=setInput:) id<ANTLRCharStream> input;

+ (void) initialize;
+ (ANTLRCommonToken *) newANTLRCommonToken;
+ (ANTLRCommonToken *) newANTLRCommonToken:(id<ANTLRCharStream>)anInput
                                      Type:(NSInteger)aTType
                                   Channel:(NSInteger)aChannel
                                     Start:(NSInteger)aStart
                                      Stop:(NSInteger)aStop;
+ (ANTLRCommonToken *) newANTLRCommonToken:(ANTLRTokenType)aType;
+ (id<ANTLRToken>) newANTLRCommonToken:(NSInteger)tokenType Text:(NSString *)tokenText;
+ (id<ANTLRToken>) newANTLRCommonTokenWithToken:(id<ANTLRToken>)fromToken;
+ (id<ANTLRToken>) eofToken;
+ (id<ANTLRToken>) skipToken;
+ (id<ANTLRToken>) invalidToken;
+ (ANTLRTokenChannel) defaultChannel;

// designated initializer. This is used as the default way to initialize a Token in the generated code.
- (ANTLRCommonToken *) init;
- (ANTLRCommonToken *) initWithInput:(id<ANTLRCharStream>)anInput
                                Type:(NSInteger)aTType
                             Channel:(NSInteger)aChannel
                               Start:(NSInteger)theStart
                                Stop:(NSInteger)theStop;
- (ANTLRCommonToken *) initWithToken:(ANTLRCommonToken *)aToken;
- (ANTLRCommonToken *) initWithType:(ANTLRTokenType)aType;
- (ANTLRCommonToken *) initWithType:(ANTLRTokenType)aTType Text:(NSString *)tokenText;

- (id<ANTLRCharStream>) getInput;
- (void) setInput: (id<ANTLRCharStream>) anInput;

- (NSUInteger) getStart;
- (void) setStart: (NSUInteger) aStart;

- (NSUInteger) getStop;
- (void) setStop: (NSUInteger) aStop;

// the index of this Token into the TokenStream
- (NSUInteger) getTokenIndex;
- (void) setTokenIndex: (NSUInteger) aTokenIndex;

// conform to NSCopying
- (id) copyWithZone:(NSZone *)theZone;

- (NSString *) description;
- (NSString *) toString;

@end
