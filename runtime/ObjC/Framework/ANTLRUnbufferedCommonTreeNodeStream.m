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


#import "ANTLRUnbufferedCommonTreeNodeStream.h"
#import "ANTLRUnbufferedCommonTreeNodeStreamState.h"
#import "ANTLRBaseTree.h"
#import "ANTLRToken.h"

#define INITIAL_LOOKAHEAD_BUFFER_SIZE 5
@implementation ANTLRUnbufferedCommonTreeNodeStream

@synthesize root;
@synthesize currentNode;
@synthesize previousNode;
@synthesize treeAdaptor;
@synthesize tokenStream;
@synthesize nodeStack;
@synthesize indexStack;
@synthesize markers;
@synthesize lastMarker;
@synthesize currentChildIndex;
@synthesize absoluteNodeIndex;
@synthesize lookahead;
@synthesize head;
@synthesize tail;

- (id) initWithTree:(ANTLRCommonTree *)theTree
{
	return [self initWithTree:theTree treeAdaptor:nil];
}

- (id) initWithTree:(ANTLRCommonTree *)theTree treeAdaptor:(ANTLRCommonTreeAdaptor *)theAdaptor
{
	if ((self = [super init]) != nil) {
		[self setRoot:theTree];
		if ( theAdaptor == nil ) 
			[self setTreeAdaptor:[ANTLRCommonTreeAdaptor newTreeAdaptor]];
		else
			[self setTreeAdaptor:theAdaptor];
		nodeStack = [[NSMutableArray arrayWithCapacity:5] retain];
		indexStack = [[NSMutableArray arrayWithCapacity:5] retain];
		markers = [[ANTLRPtrBuffer newANTLRPtrBufferWithLen:100] retain];
        // [markers insertObject:[NSNull null] atIndex:0];	// markers is one based - maybe fix this later
		lookahead = [NSMutableArray arrayWithCapacity:INITIAL_LOOKAHEAD_BUFFER_SIZE];	// lookahead is filled with [NSNull null] in -reset
        [lookahead retain];
		[self reset];
	}
	return self;
}

- (void) dealloc
{
	[self setRoot:nil];
	[self setTreeAdaptor:nil];
	
	[nodeStack release];	nodeStack = nil;
	[indexStack release];	indexStack = nil;
	[markers release];		markers = nil;
	[lookahead release];	lookahead = nil;
	
	[super dealloc];
}

- (void) reset
{
	currentNode = root;
	previousNode = nil;
	currentChildIndex = -1;
	absoluteNodeIndex = -1;
	head = tail = 0;
	[nodeStack removeAllObjects];
	[indexStack removeAllObjects];
	[markers removeAllObjects];
    // [markers insertObject:[NSNull null] atIndex:0];	// markers is one based - maybe fix this later
	[lookahead removeAllObjects];
	// TODO: this is not ideal, but works for now. optimize later
	int i;
	for (i = 0; i < INITIAL_LOOKAHEAD_BUFFER_SIZE; i++)
		[lookahead addObject:[NSNull null]];
}


#pragma mark ANTLRTreeNodeStream conformance

- (id) LT:(NSInteger)k
{
	if (k == -1)
		return previousNode;
	if (k < 0)
		@throw [NSException exceptionWithName:@"ANTLRTreeException" reason:@"-LT: looking back more than one node unsupported for unbuffered streams" userInfo:nil];
	if (k == 0)
		return ANTLRBaseTree.INVALID_NODE;
	[self fillBufferWithLookahead:k];
	return [lookahead objectAtIndex:(head+k-1) % [lookahead count]];
}

- (id) treeSource
{
	return [self root];
}

- (id<ANTLRTreeAdaptor>) getTreeAdaptor;
{
	return treeAdaptor;
}

- (void)setTreeAdaptor:(id<ANTLRTreeAdaptor>)aTreeAdaptor
{
    if (treeAdaptor != aTreeAdaptor) {
        [aTreeAdaptor retain];
        [treeAdaptor release];
        treeAdaptor = aTreeAdaptor;
    }
}

- (id<ANTLRTokenStream>) getTokenStream
{
	return tokenStream;
}

- (void) setTokenStream:(id<ANTLRTokenStream>)aTokenStream
{
	if (tokenStream != aTokenStream) {
		[tokenStream release];
		[aTokenStream retain];
		tokenStream = aTokenStream;
	}
}

- (void) setUsesUniqueNavigationNodes:(BOOL)flag
{
	shouldUseUniqueNavigationNodes = flag;
}

- (id) nodeAtIndex:(NSUInteger) idx
{
	@throw [NSException exceptionWithName:@"ANTLRTreeException" reason:@"-nodeAtIndex: unsupported for unbuffered streams" userInfo:nil];
}

- (NSString *) toString
{
	@throw [NSException exceptionWithName:@"ANTLRTreeException" reason:@"-toString unsupported for unbuffered streams" userInfo:nil];
}

- (NSString *) toStringWithRange:(NSRange) aRange
{
	@throw [NSException exceptionWithName:@"ANTLRTreeException" reason:@"-toString: unsupported for unbuffered streams" userInfo:nil];
}

- (NSString *) toStringFromNode:(id)startNode ToNode:(id)stopNode
{
	@throw [NSException exceptionWithName:@"ANTLRTreeException" reason:@"-toStringFromNode:toNode: unsupported for unbuffered streams" userInfo:nil];
}

#pragma mark ANTLRIntStream conformance

- (void) consume
{
	[self fillBufferWithLookahead:1];
	absoluteNodeIndex++;
	previousNode = [lookahead objectAtIndex:head];
	head = (head+1) % [lookahead count];
}

- (NSInteger) LA:(NSUInteger) i
{
	ANTLRCommonTree *node = [self LT:i];
	if (!node) 
		return ANTLRTokenTypeInvalid;
	int ttype = [node getType];
	return ttype;
}

- (NSUInteger) mark
{
	ANTLRUnbufferedCommonTreeNodeStreamState *state = [[[ANTLRUnbufferedCommonTreeNodeStreamState alloc] init] retain];
	[state setCurrentNode:currentNode];
	[state setPreviousNode:previousNode];
	[state setIndexStackSize:[indexStack count]];
	[state setNodeStackSize:[nodeStack count]];
	[state setCurrentChildIndex:currentChildIndex];
	[state setAbsoluteNodeIndex:absoluteNodeIndex];
	unsigned int lookaheadSize = [self lookaheadSize];
	unsigned int k;
	for ( k = 0; k < lookaheadSize; k++) {
		[state addToLookahead:[self LT:k+1]];
	}
	[markers addObject:state];
	//[state release];
	return [markers count];
}

- (NSUInteger) getIndex
{
	return absoluteNodeIndex + 1;
}

- (void) rewind:(NSUInteger) marker
{
	if ( [markers count] < marker ) {
		return;
	}
	ANTLRUnbufferedCommonTreeNodeStreamState *state = [markers objectAtIndex:marker];
	[markers removeObjectAtIndex:marker];

	absoluteNodeIndex = [state absoluteNodeIndex];
	currentChildIndex = [state currentChildIndex];
	currentNode = [state currentNode];
	previousNode = [state previousNode];
	// drop node and index stacks back to old size
	[nodeStack removeObjectsInRange:NSMakeRange([state nodeStackSize], [nodeStack count]-[state nodeStackSize])];
	[indexStack removeObjectsInRange:NSMakeRange([state indexStackSize], [indexStack count]-[state indexStackSize])];
	
	head = tail = 0; // wack lookahead buffer and then refill
	[lookahead release];
	lookahead = [[NSMutableArray alloc] initWithArray:[state lookahead]];
	tail = [lookahead count];
	// make some room after the restored lookahead, so that the above line is not a bug ;)
	// this also ensures that a subsequent -addLookahead: will not immediately need to resize the buffer
	[lookahead addObjectsFromArray:[NSArray arrayWithObjects:[NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null], nil]];
}

- (void) rewind
{
	[self rewind:[markers count]];
}

- (void) release:(NSUInteger) marker
{
	@throw [NSException exceptionWithName:@"ANTLRTreeException" reason:@"-release: unsupported for unbuffered streams" userInfo:nil];
}

- (void) seek:(NSUInteger) anIndex
{
	if ( anIndex < (NSUInteger) index )
		@throw [NSException exceptionWithName:@"ANTLRTreeException" reason:@"-seek: backwards unsupported for unbuffered streams" userInfo:nil];
	while ( (NSUInteger) index < anIndex ) {
		[self consume];
	}
}

- (NSUInteger) size;
{
	return absoluteNodeIndex + 1;	// not entirely correct, but cheap.
}


#pragma mark Lookahead Handling
- (void) addLookahead:(id<ANTLRBaseTree>)aNode
{
	[lookahead replaceObjectAtIndex:tail withObject:aNode];
	tail = (tail+1) % [lookahead count];
	
	if ( tail == head ) {
		NSMutableArray *newLookahead = [[[NSMutableArray alloc] initWithCapacity:[lookahead count]*2] retain];
		
		NSRange headRange = NSMakeRange(head, [lookahead count]-head);
		NSRange tailRange = NSMakeRange(0, tail);
		
		[newLookahead addObjectsFromArray:[lookahead objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:headRange]]];
		[newLookahead addObjectsFromArray:[lookahead objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:tailRange]]];
		
		unsigned int i;
		unsigned int lookaheadCount = [newLookahead count];
		for (i = 0; i < lookaheadCount; i++)
			[newLookahead addObject:[NSNull null]];
		[lookahead release];
		lookahead = newLookahead;
		
		head = 0;
		tail = lookaheadCount;	// tail is the location the _next_ lookahead node will end up in, not the last element's idx itself!
	}
	
}

- (NSUInteger) lookaheadSize
{
	return tail < head
		? ([lookahead count] - head + tail) 
		: (tail - head);
}

- (void) fillBufferWithLookahead:(NSInteger)k
{
	unsigned int n = [self lookaheadSize];
	unsigned int i;
	id lookaheadObject = self; // any valid object would do.
	for (i=1; i <= k-n && lookaheadObject != nil; i++) {
		lookaheadObject = [self nextObject];
	}
}

- (id) nextObject
{
	// NOTE: this could/should go into an NSEnumerator subclass for treenode streams.
	if (currentNode == nil) {
        if ( navigationNodeEOF == nil ) {
            navigationNodeEOF = [[ANTLRTreeNavigationNodeEOF alloc] init];
        }
		[self addLookahead:navigationNodeEOF];
		return nil;
	}
	if (currentChildIndex == -1) {
		return [self handleRootNode];
	}
	if (currentChildIndex < (NSInteger)[currentNode getChildCount]) {
		return [self visitChild:currentChildIndex];
	}
	[self walkBackToMostRecentNodeWithUnvisitedChildren];
	if (currentNode != nil) {
		return [self visitChild:currentChildIndex];
	}
	
	return nil;
}	

#pragma mark Node visiting
- (ANTLRCommonTree *) handleRootNode
{
	ANTLRCommonTree *node = currentNode;
	currentChildIndex = 0;
	if ([node isNil]) {
		node = [self visitChild:currentChildIndex];
	} else {
		[self addLookahead:node];
		if ([currentNode getChildCount] == 0) {
			currentNode = nil;
		}
	}
	return node;
}

- (ANTLRCommonTree *) visitChild:(NSInteger)childNumber
{
	ANTLRCommonTree *node = nil;
	
	[nodeStack addObject:currentNode];
	[indexStack addObject:[NSNumber numberWithInt:childNumber]];
	if (childNumber == 0 && ![currentNode isNil])
		[self addNavigationNodeWithType:ANTLRTokenTypeDOWN];

	currentNode = [currentNode getChild:childNumber];
	currentChildIndex = 0;
	node = currentNode;  // record node to return
	[self addLookahead:node];
	[self walkBackToMostRecentNodeWithUnvisitedChildren];
	return node;
}

- (void) walkBackToMostRecentNodeWithUnvisitedChildren
{
	while (currentNode != nil && currentChildIndex >= (NSInteger)[currentNode getChildCount])
	{
		currentNode = (ANTLRCommonTree *)[nodeStack lastObject];
		[nodeStack removeLastObject];
		currentChildIndex = [(NSNumber *)[indexStack lastObject] intValue];
		[indexStack removeLastObject];
		currentChildIndex++; // move to next child
		if (currentChildIndex >= (NSInteger)[currentNode getChildCount]) {
			if (![currentNode isNil]) {
				[self addNavigationNodeWithType:ANTLRTokenTypeUP];
			}
			if (currentNode == root) { // we done yet?
				currentNode = nil;
			}
		}
	}
	
}

- (void) addNavigationNodeWithType:(NSInteger)tokenType
{
	// TODO: this currently ignores shouldUseUniqueNavigationNodes.
	switch (tokenType) {
		case ANTLRTokenTypeDOWN: {
            if (navigationNodeDown == nil) {
                navigationNodeDown = [[ANTLRTreeNavigationNodeDown alloc] init];
            }
			[self addLookahead:navigationNodeDown];
			break;
		}
		case ANTLRTokenTypeUP: {
            if (navigationNodeUp == nil) {
                navigationNodeUp = [[ANTLRTreeNavigationNodeUp alloc] init];
            }
			[self addLookahead:navigationNodeUp];
			break;
		}
	}
}

#pragma mark Accessors
- (ANTLRCommonTree *) root
{
    return root; 
}

- (void) setRoot: (ANTLRCommonTree *) aRoot
{
    if (root != aRoot) {
        [aRoot retain];
        [root release];
        root = aRoot;
    }
}

@end

