//
//  ANTLRUnbufferedTokenStream.m
//  ANTLR
//
//  Created by Alan Condit on 7/12/10.
// [The "BSD licence"]
// Copyright (c) 2010 Alan Condit
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

#import "ANTLRUnbufferedTokenStream.h"

@implementation ANTLRUnbufferedTokenStream

@synthesize tokenSource;
@synthesize tokenIndex;
@synthesize channel;

+ (ANTLRUnbufferedTokenStream *)newANTLRUnbufferedTokenStream:(id<ANTLRTokenSource>)aTokenSource
{
    return [[ANTLRUnbufferedTokenStream alloc] initWithTokenSource:aTokenSource];
}

- (id) init
{
    if ((self = [super init]) != nil) {
        tokenSource = nil;
        tokenIndex = 0;
        channel = ANTLRTokenChannelDefault;
    }
    return self;
}

- (id) initWithTokenSource:(id<ANTLRTokenSource>)aTokenSource
{
    if ((self = [super init]) != nil) {
        tokenSource = aTokenSource;
        if ( tokenSource ) [tokenSource retain];
        tokenIndex = 0;
        channel = ANTLRTokenChannelDefault;
    }
    return self;
}

- (void) dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in ANTLRUnbufferedTokenStream" );
#endif
    if ( tokenSource ) [tokenSource release];
    [super dealloc];
}

- (id<ANTLRToken>)nextElement
{
    id<ANTLRToken> t = [tokenSource nextToken];
    [t setTokenIndex:tokenIndex++];
    return t;
}

- (BOOL)isEOF:(id<ANTLRToken>)aToken
{
    return (aToken.type == ANTLRTokenTypeEOF);
}    

- (id<ANTLRTokenSource>)getTokenSource
{
    return tokenSource;
}

- (NSString *)toStringFromStart:(NSInteger)aStart ToEnd:(NSInteger)aStop
{
    return @"n/a";
}

- (NSString *)toStringFromToken:(id<ANTLRToken>)aStart ToEnd:(id<ANTLRToken>)aStop
{
    return @"n/a";
}

- (NSInteger)LA:(NSInteger)anIdx
{
    return [[self LT:anIdx] type];
}

- (id<ANTLRToken>)objectAtIndex:(NSInteger)anIdx
{
    @throw [ANTLRRuntimeException newException:@"Absolute token indexes are meaningless in an unbuffered stream"];
}

- (NSString *)getSourceName
{
    return [tokenSource getSourceName];
}


@end
