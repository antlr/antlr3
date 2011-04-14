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

#import "ANTLRMismatchedTokenException.h"


@implementation ANTLRMismatchedTokenException

@synthesize expecting;
@synthesize expectingChar;
@synthesize isTokenType;


+ (id) newException:(NSInteger)expectedTokenType Stream:(id<ANTLRIntStream>)anInput
{
	return [[ANTLRMismatchedTokenException alloc] initWithTokenType:expectedTokenType Stream:anInput];
}

+ (id) newExceptionMissing:(NSInteger)expectedTokenType
                                        Stream:(id<ANTLRIntStream>)anInput
                                         Token:(id<ANTLRToken>)inserted
{
	return [[ANTLRMismatchedTokenException alloc] initWithTokenType:expectedTokenType Stream:anInput Token:inserted];
}

+ (id) newExceptionChar:(unichar) expectedCharacter Stream:(id<ANTLRIntStream>)anInput
{
	return [[ANTLRMismatchedTokenException alloc] initWithCharacter:expectedCharacter Stream:anInput];
}

+ (id) newExceptionStream:(id<ANTLRIntStream>)anInput Exception:(NSException *)e Follow:(ANTLRBitSet *) follow
{
	return [[ANTLRMismatchedTokenException alloc] initWithStream:anInput];
}

-(id) initWithTokenType:(NSInteger)expectedTokenType Stream:(id<ANTLRIntStream>)anInput
{
	if ((self = [super initWithStream:anInput]) != nil) {
		expecting = expectedTokenType;
		isTokenType = YES;
	}
	return self;
}

-(id) initWithTokenType:(NSInteger)expectedTokenType
                 Stream:(id<ANTLRIntStream>)anInput
                  Token:(id<ANTLRToken>)inserted
{
	if ((self = [super initWithStream:anInput]) != nil) {
		expecting = expectedTokenType;
		isTokenType = YES;
	}
	return self;
}

- (id) initWithCharacter:(unichar) expectedCharacter Stream:(id<ANTLRIntStream>)anInput
{
	if ((self = [super initWithStream:anInput]) != nil) {
		expectingChar = expectedCharacter;
		isTokenType = NO;
	}
	return self;
}

- (NSString *) description
{
	NSMutableString *desc = (NSMutableString *)[super description];
	if (isTokenType) {
		[desc appendFormat:@" expected:%d got:%d", expecting, [self unexpectedType]];
	} else {
		[desc appendFormat:@" expected:%c got:%c", expectingChar, (unichar)[self unexpectedType]];
	}
	return desc;
}

@end
