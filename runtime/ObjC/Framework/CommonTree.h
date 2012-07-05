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
#import "CommonToken.h"
#import "BaseTree.h"

@interface CommonTree : BaseTree <Tree> {
	__strong CommonToken *token;
	NSInteger startIndex;
	NSInteger stopIndex;
    __strong CommonTree *parent;
    NSInteger childIndex;
}

+ (CommonTree *) invalidNode;
+ (CommonTree *) newTree;
+ (CommonTree *) newTreeWithTree:(CommonTree *)aTree;
+ (CommonTree *) newTreeWithToken:(CommonToken *)aToken;
+ (CommonTree *) newTreeWithTokenType:(NSInteger)tokenType;
+ (CommonTree *) newTreeWithTokenType:(NSInteger)aTType Text:(NSString *)theText;

- (id) init;
- (id) initWithTreeNode:(CommonTree *)aNode;
- (id) initWithToken:(CommonToken *)aToken;
- (id) initWithTokenType:(NSInteger)aTokenType;
- (id) initWithTokenType:(NSInteger)aTokenType Text:(NSString *)theText;

- (id<BaseTree>) copyWithZone:(NSZone *)aZone;

- (BOOL) isNil;

- (CommonToken *) getToken;
- (void) setToken:(CommonToken *)aToken;
- (CommonToken *) dupNode;
- (NSInteger)type;
- (NSString *)text;
- (NSUInteger)line;
- (void) setLine:(NSUInteger)aLine;
- (NSUInteger)charPositionInLine;
- (void) setCharPositionInLine:(NSUInteger)pos;
- (CommonTree *) getParent;
- (void) setParent:(CommonTree *) t;

#ifdef DONTUSENOMO
- (NSString *) treeDescription;
#endif
- (NSString *) description;
- (void) setUnknownTokenBoundaries;
- (NSInteger) getTokenStartIndex;
- (void) setTokenStartIndex: (NSInteger) aStartIndex;
- (NSInteger) getTokenStopIndex;
- (void) setTokenStopIndex: (NSInteger) aStopIndex;

/*
 @property (retain, getter=getCommonToken, setter=setCommonToken:) CommonToken *token;
 @property (assign, getter=getTokenStartIndex, setter=setTokenStartIndex:) NSInteger startIndex;
 @property (assign, getter=getTokenStopIndex, setter=setTokenStopIndex:) NSInteger stopIndex;
 @property (retain, getter=getParent, setter=setParent:) id<BaseTree> parentparent;
 @property (assign, getter=getChildIndex, setter=setChildIndex:) NSInteger childIndex;
 */

@property (retain) CommonToken *token;
@property (assign) NSInteger startIndex;
@property (assign) NSInteger stopIndex;
@property (retain) CommonTree *parent;
@property (assign) NSInteger childIndex;

@end
