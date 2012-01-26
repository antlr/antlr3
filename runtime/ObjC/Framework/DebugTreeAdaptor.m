// [The "BSD licence"]
// Copyright (c) 2006-2007 Kay Roepke
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

#import "ANTLRDebugTreeAdaptor.h"


@implementation ANTLRDebugTreeAdaptor


- (id) initWithTreeAdaptor:(ANTLRCommonTreeAdaptor *)aTreeAdaptor debugListener:(id<ANTLRDebugEventListener>)aDebugListener
{
	self = [super init];
	if (self) {
		[self setDebugListener:aDebugListener];
		[self setTreeAdaptor:aTreeAdaptor];
	}
	return self;
}

- (void) dealloc
{
    [self setDebugListener: nil];
    [self setTreeAdaptor: nil];
    [super dealloc];
}

- (id<ANTLRDebugEventListener>) debugListener
{
    return debugListener; 
}

- (void) setDebugListener: (id<ANTLRDebugEventListener>) aDebugListener
{
    if (debugListener != aDebugListener) {
        [(id<ANTLRTreeAdaptor,NSObject>)aDebugListener retain];
        [(id<ANTLRTreeAdaptor,NSObject>)debugListener release];
        debugListener = aDebugListener;
    }
}

- (ANTLRCommonTreeAdaptor *) getTreeAdaptor
{
    return treeAdaptor; 
}

- (void) setTreeAdaptor: (ANTLRCommonTreeAdaptor *) aTreeAdaptor
{
    if (treeAdaptor != aTreeAdaptor) {
        [aTreeAdaptor retain];
        [treeAdaptor release];
        treeAdaptor = aTreeAdaptor;
    }
}

#pragma mark -
#pragma mark Proxy implementation

// anything else that hasn't some debugger event assicioated with it, is simply
// forwarded to the actual token stream
- (void) forwardInvocation:(NSInvocation *)anInvocation
{
	[anInvocation invokeWithTarget:[self getTreeAdaptor]];
}

#pragma mark -

#pragma mark Construction

- (id<ANTLRBaseTree>) newANTLRTreeWithToken:(id<ANTLRToken>) payload
{
	id<ANTLRBaseTree> newTree = [ANTLRCommonTree newTreeWithToken:payload];
	[debugListener createNode:[treeAdaptor uniqueIdForTree:newTree] fromTokenAtIndex:[payload getTokenIndex]];
	return newTree;
}

- (id<ANTLRBaseTree>) emptyTree
{
	id<ANTLRBaseTree> newTree = [treeAdaptor newEmptyTree];
	[debugListener createNilNode:[treeAdaptor uniqueIdForTree:newTree]];
	return newTree;
}

/*	We don't have debug events for those:
 - (id) copyNode:(id<ANTLRBaseTree>)aNode
{
}
- (id) copyTree:(id<ANTLRBaseTree>)aTree
{
}
*/

- (void) addChild:(id<ANTLRBaseTree>)child toTree:(id<ANTLRBaseTree>)aTree
{
	[treeAdaptor addChild:child toTree:aTree];
	[debugListener addChild:[treeAdaptor uniqueIdForTree:child] toTree:[self uniqueIdForTree:aTree]];
}

- (id<ANTLRBaseTree>) becomeRoot:(id<ANTLRBaseTree>)newRoot old:(id<ANTLRBaseTree>)oldRoot
{
	id<ANTLRBaseTree> newTree = [treeAdaptor becomeRoot:newRoot old:oldRoot];
	[debugListener becomeRoot:[treeAdaptor uniqueIdForTree:newTree] old:[self uniqueIdForTree:oldRoot]];
	return newTree;
}

/* handle by forwardInvocation: 
- (NSUInteger) uniqueIdForTree:(id<ANTLRBaseTree>)aNode
{
}
*/

#pragma mark Rewrite Rules

 - (void) addTokenAsChild:(id<ANTLRToken>)child toTree:(id<ANTLRBaseTree>)aTree
{
	id<ANTLRBaseTree> newChild = [self newANTLRTreeWithToken:child];
	[self addChild:newChild toTree:aTree];
}

- (id<ANTLRBaseTree>) makeToken:(id<ANTLRToken>)newRoot parentOf:(id<ANTLRBaseTree>)oldRoot
{
	id<ANTLRBaseTree> newNode = [self newANTLRTreeWithToken:newRoot];
	return [self becomeRoot:newNode old:oldRoot];
}

- (id<ANTLRBaseTree>) newANTLRTreeWithTokenType:(NSInteger)tokenType
{
	id<ANTLRBaseTree> newTree = [treeAdaptor newANTLRTreeWithTokenType:tokenType];
	[debugListener createNode:[treeAdaptor uniqueIdForTree:newTree] text:nil type:tokenType];
	return newTree;
}

- (id<ANTLRBaseTree>) newANTLRTreeWithTokenType:(NSInteger)tokenType text:(NSString *)tokenText
{
	id<ANTLRBaseTree> newTree = [treeAdaptor newANTLRTreeWithTokenType:tokenType text:tokenText];
	[debugListener createNode:[treeAdaptor uniqueIdForTree:newTree] text:tokenText type:tokenType];
	return newTree;
}
- (id<ANTLRBaseTree>) newANTLRTreeWithToken:(id<ANTLRToken>)fromToken tokenType:(NSInteger)tokenType
{
	id<ANTLRBaseTree> newTree = [treeAdaptor newANTLRTreeWithToken:fromToken tokenType:tokenType];
	[debugListener createNode:[treeAdaptor uniqueIdForTree:newTree] text:fromToken.text type:tokenType];
	return newTree;
}

- (id<ANTLRBaseTree>) newANTLRTreeWithToken:(id<ANTLRToken>)fromToken tokenType:(NSInteger)tokenType text:(NSString *)tokenText
{
	id<ANTLRBaseTree> newTree = [treeAdaptor newANTLRTreeWithToken:fromToken tokenType:tokenType text:tokenText];
	[debugListener createNode:[treeAdaptor uniqueIdForTree:newTree] text:tokenText type:tokenType];
	return newTree;
}

- (id<ANTLRBaseTree>) newANTLRTreeWithToken:(id<ANTLRToken>)fromToken text:(NSString *)tokenText
{
	id<ANTLRBaseTree> newTree = [treeAdaptor newANTLRTreeWithToken:fromToken text:tokenText];
	[debugListener createNode:[treeAdaptor uniqueIdForTree:newTree] text:tokenText type:fromToken.type];
	return newTree;
}

#pragma mark Content

/* handled by forwardInvocation:
- (NSInteger) tokenTypeForNode:(id<ANTLRBaseTree>)aNode
{
}
 
- (void) setTokenType:(NSInteger)tokenType forNode:(id)aNode
{
}

- (NSString *) textForNode:(id<ANTLRBaseTree>)aNode
{
}
 
- (void) setText:(NSString *)tokenText forNode:(id<ANTLRBaseTree>)aNode
{
}
*/
- (void) setBoundariesForTree:(id<ANTLRBaseTree>)aTree fromToken:(id<ANTLRToken>)startToken toToken:(id<ANTLRToken>)stopToken
{
	[treeAdaptor setBoundariesForTree:aTree fromToken:startToken toToken:stopToken];
	if (aTree && startToken && stopToken) {
		[debugListener setTokenBoundariesForTree:[aTree hash] From:[startToken getTokenIndex] To:[stopToken getTokenIndex]];
	}
}
/* handled by forwardInvocation:
- (NSInteger) tokenStartIndexForTree:(id<ANTLRBaseTree>)aTree
{
}
 
- (NSInteger) tokenStopIndexForTree:(id<ANTLRBaseTree>)aTree
{
}
*/

#pragma mark Navigation / Tree Parsing
/* handled by forwardInvocation:
- (id<ANTLRBaseTree>) childForNode:(id<ANTLRBaseTree>) aNode atIndex:(NSInteger) i
{
}
 
- (NSInteger) childCountForTree:(id<ANTLRBaseTree>) aTree
{
}
*/

@end
