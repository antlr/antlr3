//
//  UnbufferedTokenStream.h
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

#import <Foundation/Foundation.h>
#import "RuntimeException.h"
#import "TokenSource.h"
#import "LookaheadStream.h"
#import "Token.h"

@interface UnbufferedTokenStream : LookaheadStream {
	id<TokenSource> tokenSource;
    NSInteger tokenIndex; // simple counter to set token index in tokens
    NSInteger channel;
}

@property (retain, getter=getTokenSource, setter=setTokenSource:) id<TokenSource> tokenSource;
@property (getter=getTokenIndex, setter=setTokenIndex:) NSInteger tokenIndex;
@property (getter=channel, setter=setChannel:) NSInteger channel;

+ (UnbufferedTokenStream *)newUnbufferedTokenStream:(id<TokenSource>)aTokenSource;
- (id) init;
- (id) initWithTokenSource:(id<TokenSource>)aTokenSource;

- (id<Token>)nextElement;
- (BOOL)isEOF:(id<Token>) aToken;
- (id<TokenSource>)getTokenSource;
- (NSString *)toStringFromStart:(NSInteger)aStart ToEnd:(NSInteger)aStop;
- (NSString *)toStringFromToken:(id<Token>)aStart ToEnd:(id<Token>)aStop;
- (NSInteger)LA:(NSInteger)anIdx;
- (id<Token>)objectAtIndex:(NSInteger)anIdx;
- (NSString *)getSourceName;


@end
