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
#import "ANTLRTreeNodeStream.h"
#import "ANTLRCommonTokenStream.h"
#import "ANTLRCommonTree.h"
#import "ANTLRCommonTreeAdaptor.h"

@interface ANTLRUnbufferedCommonTreeNodeStream : NSObject < ANTLRTreeNodeStream > {

	BOOL shouldUseUniqueNavigationNodes;

	ANTLRCommonTree *root;
	ANTLRCommonTree *currentNode;
	ANTLRCommonTree *previousNode;

	id<ANTLRTreeAdaptor> treeAdaptor;
	
	id<ANTLRTokenStream> tokenStream;
	
	NSMutableArray *nodeStack;
	NSMutableArray *indexStack;
	ANTLRPtrBuffer *markers;
	NSInteger lastMarker;
	
	NSInteger currentChildIndex;
	NSInteger absoluteNodeIndex;
	
	NSMutableArray *lookahead;
	NSUInteger head;
	NSUInteger tail;
}

@property (retain, getter=getRoot, setter=setRoot:) ANTLRCommonTree *root;
@property (retain, getter=getCurrentNode, setter=setCurrentNode:) ANTLRCommonTree *currentNode;
@property (retain, getter=getPreviousNode, setter=setPreviousNode:) ANTLRCommonTree *previousNode;
@property (retain, getter=getTreeAdaptor, setter=setTreeAdaptor:) id<ANTLRTreeAdaptor> treeAdaptor;
@property (retain, getter=getTokenStream, setter=setTokenStream:) id<ANTLRTokenStream> tokenStream;
@property (retain, getter=getNodeStack, setter=setNodeStack:) NSMutableArray *nodeStack;
@property (retain, getter=getIndexStack, setter=setIndexStackStack:) NSMutableArray *indexStack;
@property (retain, getter=getMarkers, setter=setMarkers:) ANTLRPtrBuffer *markers;
@property (assign, getter=getLastMarker, setter=setLastMarker:) NSInteger lastMarker;
@property (assign, getter=getCurrentChildIndex, setter=setCurrentChildIndex:) NSInteger currentChildIndex;
@property (assign, getter=getAbsoluteNodeIndex, setter=setAbsoluteNodeIndex:) NSInteger absoluteNodeIndex;
@property (retain, getter=getLookahead, setter=setLookahead:) NSMutableArray *lookahead;
@property (assign, getter=getHead, setter=setHead:) NSUInteger head;
@property (assign, getter=getTail, setter=setTail:) NSUInteger tail;

- (id) initWithTree:(ANTLRCommonTree *)theTree;
- (id) initWithTree:(ANTLRCommonTree *)theTree treeAdaptor:(ANTLRCommonTreeAdaptor *)theAdaptor;

- (void) reset;

#pragma mark ANTLRTreeNodeStream conformance

- (id) LT:(NSInteger)k;
- (id) treeSource;
- (id<ANTLRTreeAdaptor>) getTreeAdaptor;
- (void)setTreeAdaptor:(id<ANTLRTreeAdaptor>)aTreeAdaptor;
- (id<ANTLRTokenStream>) getTokenStream;
- (void) setTokenStream:(id<ANTLRTokenStream>)aTokenStream;	///< Added by subclass, not in protocol
- (void) setUsesUniqueNavigationNodes:(BOOL)flag;

- (id) nodeAtIndex:(NSUInteger) idx;

- (NSString *) toString;
- (NSString *) toStringWithRange:(NSRange) aRange;
- (NSString *) toStringFromNode:(id)startNode toNode:(id)stopNode;

#pragma mark ANTLRIntStream conformance
- (void) consume;
- (NSInteger) LA:(NSUInteger) i;
- (NSUInteger) mark;
- (NSUInteger) getIndex;
- (void) rewind:(NSUInteger) marker;
- (void) rewind;
- (void) release:(NSUInteger) marker;
- (void) seek:(NSUInteger) index;
- (NSUInteger) size;

#pragma mark Lookahead Handling
- (void) addLookahead:(id<ANTLRBaseTree>)aNode;
- (NSUInteger) lookaheadSize;
- (void) fillBufferWithLookahead:(NSInteger)k;
- (id) nextObject;

#pragma mark Node visiting
- (ANTLRCommonTree *) handleRootNode;
- (ANTLRCommonTree *) visitChild:(NSInteger)childNumber;
- (void) walkBackToMostRecentNodeWithUnvisitedChildren;
- (void) addNavigationNodeWithType:(NSInteger)tokenType;

#pragma mark Accessors
- (ANTLRCommonTree *) root;
- (void) setRoot: (ANTLRCommonTree *) aRoot;

@end
