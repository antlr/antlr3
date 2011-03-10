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
#import "ANTLRCommonToken.h"
#import "ANTLRBaseTree.h"

@interface ANTLRCommonTree : ANTLRBaseTree <ANTLRTree> {
	ANTLRCommonToken *token;
	NSInteger startIndex;
	NSInteger stopIndex;
    ANTLRCommonTree *parent;
    NSInteger childIndex;
}

@property (retain, getter=getANTLRCommonToken, setter=setANTLRCommonToken) ANTLRCommonToken *token;
@property (assign, getter=getTokenStartIndex, setter=setTokenStartIndex) NSInteger startIndex;
@property (assign, getter=getTokenStopIndex, setter=setTokenStopIndex) NSInteger stopIndex;
@property (retain, getter=getParent, setter=setParent:) ANTLRCommonTree *parent;
@property (assign, getter=getChildIndex, setter=setChildIndex) NSInteger childIndex;

+ (ANTLRCommonTree *) invalidNode;
+ (ANTLRCommonTree *) newANTLRCommonTree;
+ (ANTLRCommonTree *) newANTLRCommonTreeWithTree:(ANTLRCommonTree *)aTree;
+ (ANTLRCommonTree *) newANTLRCommonTreeWithToken:(ANTLRCommonToken *)aToken;
+ (ANTLRCommonTree *) newANTLRCommonTreeWithTokenType:(NSInteger)tokenType;
+ (ANTLRCommonTree *) newANTLRCommonTreeWithTokenType:(NSInteger)aTType Text:(NSString *)theText;
#ifdef DONTUSEYET
+ (id<ANTLRTree>) newANTLRCommonTreeWithTokenType:(NSInteger)tokenType;
+ (id<ANTLRTree>) newANTLRCommonTreeWithToken:(id<ANTLRToken>)fromToken TokenType:(NSInteger)tokenType;
+ (id<ANTLRTree>) newANTLRCommonTreeWithToken:(id<ANTLRToken>)fromToken TokenType:(NSInteger)tokenType Text:(NSString *)tokenText;
+ (id<ANTLRTree>) newANTLRCommonTreeWithToken:(id<ANTLRToken>)fromToken Text:(NSString *)tokenText;
#endif

- (id) init;
- (id) initWithTreeNode:(ANTLRCommonTree *)aNode;
- (id) initWithToken:(ANTLRCommonToken *)aToken;
- (id) initWithTokenType:(NSInteger)aTokenType;
- (id) initWithTokenType:(NSInteger)aTokenType Text:(NSString *)theText;

- (id<ANTLRTree>) copyWithZone:(NSZone *)aZone;

- (BOOL) isNil;

- (ANTLRCommonToken *) getToken;
- (void) setToken:(ANTLRCommonToken *)aToken;
- (id<ANTLRTree>) dupNode;
- (NSInteger) getType;
- (NSString *) getText;
- (NSUInteger) getLine;
- (NSUInteger) getCharPositionInLine;
- (ANTLRCommonTree *) getParent;
- (void) setParent:(ANTLRCommonTree *) t;

#ifdef DONTUSENOMO
- (NSString *) treeDescription;
#endif
- (NSString *) description;
- (void) setUnknownTokenBoundaries;
- (NSInteger) getTokenStartIndex;
- (void) setTokenStartIndex: (NSInteger) aStartIndex;
- (NSInteger) getTokenStopIndex;
- (void) setTokenStopIndex: (NSInteger) aStopIndex;

@end
