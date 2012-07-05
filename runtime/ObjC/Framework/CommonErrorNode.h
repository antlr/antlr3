//
//  CommonErrorNode.h
//  ANTLR
//
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
#import "CommonTree.h"
#import "TokenStream.h"
//#import "IntStream.h"
//#import "Token.h"
#import "UnWantedTokenException.h"

@interface CommonErrorNode : CommonTree
{
id<IntStream> input;
id<Token> startToken;
id<Token> stopToken;
RecognitionException *trappedException;
}

+ (id) newCommonErrorNode:(id<TokenStream>)anInput
                  From:(id<Token>)startToken
                    To:(id<Token>)stopToken
                     Exception:(RecognitionException *) e;

- (id) initWithInput:(id<TokenStream>)anInput
                From:(id<Token>)startToken
                  To:(id<Token>)stopToken
           Exception:(RecognitionException *) e;

- (void)dealloc;
- (BOOL) isNil;

- (NSInteger)type;
- (NSString *)text;
- (NSString *)toString;

@property (retain) id<IntStream> input;
@property (retain) id<Token> startToken;
@property (retain) id<Token> stopToken;
@property (retain) RecognitionException *trappedException;
@end
