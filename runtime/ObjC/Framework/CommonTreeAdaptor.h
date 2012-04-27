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
#import "Tree.h"
#import "CommonToken.h"
#import "CommonTree.h"
#import "BaseTreeAdaptor.h"

@interface CommonTreeAdaptor : BaseTreeAdaptor {
}

+ (CommonTree *) newEmptyTree;
+ (CommonTreeAdaptor *)newTreeAdaptor;
- (id) init;
- (CommonTree *)dupNode:(CommonTree *)t;   

- (CommonTree *) create:(id<Token>) payload;
//- (CommonTree *) createTree:(NSInteger)tokenType fromToken:(CommonToken *)aToken;
//- (CommonTree *) createTree:(NSInteger)tokenType fromToken:(CommonToken *)aToken Text:(NSString *)text;
- (id<Token>)createToken:(NSInteger)tokenType Text:(NSString *)text;
- (id<Token>)createToken:(id<Token>)fromToken;
- (void) setTokenBoundaries:(CommonTree *)t From:(id<Token>)startToken To:(id<Token>)stopToken;
- (NSInteger)getTokenStartIndex:(CommonTree *)t;
- (NSInteger)getTokenStopIndex:(CommonTree *)t;
- (NSString *)getText:(CommonTree *)t;
- (void)setText:(CommonTree *)t Text:(NSString *)text;
- (NSInteger)getType:(CommonTree *)t;
- (void) setType:(CommonTree *)t Type:(NSInteger)tokenType;
- (id<Token>)getToken:(CommonTree *)t;
- (CommonTree *)getChild:(CommonTree *)t At:(NSInteger)i;
- (void) setChild:(CommonTree *)t At:(NSInteger)i Child:(CommonTree *)child;
- (NSInteger)getChildCount:(CommonTree *)t;
- (CommonTree *)getParent:(CommonTree *)t;
- (void)setParent:(CommonTree *)t With:(CommonTree *)parent;
- (NSInteger)getChildIndex:(CommonTree *)t;
- (void)setChildIndex:(CommonTree *)t With:(NSInteger)index;
- (void)replaceChildren:(CommonTree *)parent From:(NSInteger)startChildIndex To:(NSInteger)stopChildIndex With:(CommonTree *)t;
- (id)copyWithZone:(NSZone *)zone;

@end
