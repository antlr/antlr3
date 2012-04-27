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
#import "RuntimeException.h"
#import "Token.h"
#import "IntStream.h"
#import "BaseTree.h"

@interface RecognitionException : RuntimeException {
	id<IntStream> input;
	NSInteger index;
	id<Token> token;
	id<BaseTree> node;
	unichar c;
	NSUInteger line;
	NSUInteger charPositionInLine;
	BOOL approximateLineInfo;
}

@property (retain, getter=getStream, setter=setStream:) id<IntStream> input;
@property (assign) NSInteger index;
@property (retain, getter=getToken, setter=setToken:) id<Token>token;
@property (retain, getter=getNode, setter=setNode:) id<BaseTree>node;
@property (assign) unichar c;
@property (assign) NSUInteger line;
@property (assign) NSUInteger charPositionInLine;
@property (assign) BOOL approximateLineInfo;

+ (id) newException;
+ (id) newException:(id<IntStream>) anInputStream; 
- (id) init;
- (id) initWithStream:(id<IntStream>)anInputStream;
- (id) initWithStream:(id<IntStream>)anInputStream reason:(NSString *)aReason;
- (id) initWithName:(NSString *)aName reason:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;

- (void) extractInformationFromTreeNodeStream:(id<IntStream>)input;

- (NSInteger) unexpectedType;
- (id<Token>)getUnexpectedToken;

- (id<IntStream>) getStream;
- (void) setStream: (id<IntStream>) aStream;

- (id<Token>) getToken;
- (void) setToken: (id<Token>) aToken;

- (id<BaseTree>) getNode;
- (void) setNode: (id<BaseTree>) aNode;

- (NSString *)getMessage;


@end
