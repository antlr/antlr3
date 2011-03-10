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

+ (id<ANTLRTree>) newEmptyTree;
+ (ANTLRCommonTreeAdaptor *)newANTLRCommonTreeAdaptor;
- (id) init;
- (id<ANTLRTree>)dupNode:(id<ANTLRTree>)t;    
- (ANTLRCommonTree *)createTree:(ANTLRCommonToken *)aToken;
- (ANTLRCommonTree *)createTree:(NSInteger)tokenType Text:(NSString *)text;
- (id<ANTLRToken>)createToken:(NSInteger)tokenType Text:(NSString *)text;
- (void) setTokenBoundaries:(id<ANTLRTree>)t From:(id<ANTLRToken>)startToken To:(id<ANTLRToken>)stopToken;
- (NSInteger)getTokenStartIndex:(id<ANTLRTree>)t;
- (NSInteger)getTokenStopIndex:(id<ANTLRTree>)t;
- (NSString *)getText:(id<ANTLRTree>)t;
- (void)setText:(id<ANTLRTree>)t Text:(NSString *)text;
- (NSInteger)getType:(id<ANTLRTree>)t;
- (void) setType:(id<ANTLRTree>)t Type:(NSInteger)tokenType;
- (id<ANTLRToken>)getToken:(id<ANTLRTree>)t;
- (id<ANTLRTree>)getChild:(id<ANTLRTree>)t At:(NSInteger)i;
- (void) setChild:(id<ANTLRTree>)t At:(NSInteger)i Child:(id<ANTLRTree>)child;
- (NSInteger)getChildCount:(id<ANTLRTree>)t;
- (id<ANTLRTree>)getParent:(id<ANTLRTree>)t;
- (void)setParent:(id<ANTLRTree>)t With:(id<ANTLRTree>)parent;
- (NSInteger)getChildIndex:(id<ANTLRTree>)t;
- (void)setChildIndex:(id<ANTLRTree>)t With:(NSInteger)index;
- (void)replaceChildren:(id<ANTLRTree>)parent From:(NSInteger)startChildIndex To:(NSInteger)stopChildIndex With:(id<ANTLRTree>)t;
- (id)copyWithZone:(NSZone *)zone;

@end
