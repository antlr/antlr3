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
#import "ANTLRTree.h"
#import "ANTLRCommonToken.h"
#import "ANTLRCommonTree.h"
#import "ANTLRBaseTreeAdaptor.h"

@interface ANTLRCommonTreeAdaptor : ANTLRBaseTreeAdaptor {
}

+ (ANTLRCommonTree *) newEmptyTree;
+ (ANTLRCommonTreeAdaptor *)newTreeAdaptor;
- (id) init;
- (ANTLRCommonTree *)dupNode:(ANTLRCommonTree *)t;   

- (ANTLRCommonTree *) create:(id<ANTLRToken>) payload;
//- (ANTLRCommonTree *) createTree:(NSInteger)tokenType fromToken:(ANTLRCommonToken *)aToken;
//- (ANTLRCommonTree *) createTree:(NSInteger)tokenType fromToken:(ANTLRCommonToken *)aToken Text:(NSString *)text;
- (id<ANTLRToken>)createToken:(NSInteger)tokenType Text:(NSString *)text;
- (id<ANTLRToken>)createToken:(id<ANTLRToken>)fromToken;
- (void) setTokenBoundaries:(ANTLRCommonTree *)t From:(id<ANTLRToken>)startToken To:(id<ANTLRToken>)stopToken;
- (NSInteger)getTokenStartIndex:(ANTLRCommonTree *)t;
- (NSInteger)getTokenStopIndex:(ANTLRCommonTree *)t;
- (NSString *)getText:(ANTLRCommonTree *)t;
- (void)setText:(ANTLRCommonTree *)t Text:(NSString *)text;
- (NSInteger)getType:(ANTLRCommonTree *)t;
- (void) setType:(ANTLRCommonTree *)t Type:(NSInteger)tokenType;
- (id<ANTLRToken>)getToken:(ANTLRCommonTree *)t;
- (ANTLRCommonTree *)getChild:(ANTLRCommonTree *)t At:(NSInteger)i;
- (void) setChild:(ANTLRCommonTree *)t At:(NSInteger)i Child:(ANTLRCommonTree *)child;
- (NSInteger)getChildCount:(ANTLRCommonTree *)t;
- (ANTLRCommonTree *)getParent:(ANTLRCommonTree *)t;
- (void)setParent:(ANTLRCommonTree *)t With:(ANTLRCommonTree *)parent;
- (NSInteger)getChildIndex:(ANTLRCommonTree *)t;
- (void)setChildIndex:(ANTLRCommonTree *)t With:(NSInteger)index;
- (void)replaceChildren:(ANTLRCommonTree *)parent From:(NSInteger)startChildIndex To:(NSInteger)stopChildIndex With:(ANTLRCommonTree *)t;
- (id)copyWithZone:(NSZone *)zone;

@end
