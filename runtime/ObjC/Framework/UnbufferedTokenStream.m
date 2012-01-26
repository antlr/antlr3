//
//  UnbufferedTokenStream.m
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

#import "UnbufferedTokenStream.h"

@implementation UnbufferedTokenStream

@synthesize tokenSource;
@synthesize tokenIndex;
@synthesize channel;

+ (UnbufferedTokenStream *)newUnbufferedTokenStream:(id<TokenSource>)aTokenSource
{
    return [[UnbufferedTokenStream alloc] initWithTokenSource:aTokenSource];
}

- (id) init
{
    if ((self = [super init]) != nil) {
        tokenSource = nil;
        tokenIndex = 0;
        channel = TokenChannelDefault;
    }
    return self;
}

- (id) initWithTokenSource:(id<TokenSource>)aTokenSource
{
    if ((self = [super init]) != nil) {
        tokenSource = aTokenSource;
        if ( tokenSource ) [tokenSource retain];
        tokenIndex = 0;
        channel = TokenChannelDefault;
    }
    return self;
}

- (void) dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in UnbufferedTokenStream" );
#endif
    if ( tokenSource ) [tokenSource release];
    [super dealloc];
}

- (id<Token>)nextElement
{
    id<Token> t = [tokenSource nextToken];
    [t setTokenIndex:tokenIndex++];
    return t;
}

- (BOOL)isEOF:(id<Token>)aToken
{
    return (aToken.type == TokenTypeEOF);
}    

- (id<TokenSource>)getTokenSource
{
    return tokenSource;
}

- (NSString *)toStringFromStart:(NSInteger)aStart ToEnd:(NSInteger)aStop
{
    return @"n/a";
}

- (NSString *)toStringFromToken:(id<Token>)aStart ToEnd:(id<Token>)aStop
{
    return @"n/a";
}

- (NSInteger)LA:(NSInteger)anIdx
{
    return [[self LT:anIdx] type];
}

- (id<Token>)objectAtIndex:(NSInteger)anIdx
{
    @throw [RuntimeException newException:@"Absolute token indexes are meaningless in an unbuffered stream"];
}

- (NSString *)getSourceName
{
    return [tokenSource getSourceName];
}


@end
