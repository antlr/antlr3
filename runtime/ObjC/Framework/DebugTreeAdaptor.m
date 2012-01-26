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

#import "DebugTreeAdaptor.h"


@implementation DebugTreeAdaptor


- (id) initWithTreeAdaptor:(CommonTreeAdaptor *)aTreeAdaptor debugListener:(id<DebugEventListener>)aDebugListener
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

- (id<DebugEventListener>) debugListener
{
    return debugListener; 
}

- (void) setDebugListener: (id<DebugEventListener>) aDebugListener
{
    if (debugListener != aDebugListener) {
        [(id<TreeAdaptor,NSObject>)aDebugListener retain];
        [(id<TreeAdaptor,NSObject>)debugListener release];
        debugListener = aDebugListener;
    }
}

- (CommonTreeAdaptor *) getTreeAdaptor
{
    return treeAdaptor; 
}

- (void) setTreeAdaptor: (CommonTreeAdaptor *) aTreeAdaptor
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

- (id<BaseTree>) newTreeWithToken:(id<Token>) payload
{
	id<BaseTree> newTree = [CommonTree newTreeWithToken:payload];
	[debugListener createNode:[treeAdaptor uniqueIdForTree:newTree] fromTokenAtIndex:[payload getTokenIndex]];
	return newTree;
}

- (id<BaseTree>) emptyTree
{
	id<BaseTree> newTree = [treeAdaptor newEmptyTree];
	[debugListener createNilNode:[treeAdaptor uniqueIdForTree:newTree]];
	return newTree;
}

/*	We don't have debug events for those:
 - (id) copyNode:(id<BaseTree>)aNode
{
}
- (id) copyTree:(id<BaseTree>)aTree
{
}
*/

- (void) addChild:(id<BaseTree>)child toTree:(id<BaseTree>)aTree
{
	[treeAdaptor addChild:child toTree:aTree];
	[debugListener addChild:[treeAdaptor uniqueIdForTree:child] toTree:[self uniqueIdForTree:aTree]];
}

- (id<BaseTree>) becomeRoot:(id<BaseTree>)newRoot old:(id<BaseTree>)oldRoot
{
	id<BaseTree> newTree = [treeAdaptor becomeRoot:newRoot old:oldRoot];
	[debugListener becomeRoot:[treeAdaptor uniqueIdForTree:newTree] old:[self uniqueIdForTree:oldRoot]];
	return newTree;
}

/* handle by forwardInvocation: 
- (NSUInteger) uniqueIdForTree:(id<BaseTree>)aNode
{
}
*/

#pragma mark Rewrite Rules

 - (void) addTokenAsChild:(id<Token>)child toTree:(id<BaseTree>)aTree
{
	id<BaseTree> newChild = [self newTreeWithToken:child];
	[self addChild:newChild toTree:aTree];
}

- (id<BaseTree>) makeToken:(id<Token>)newRoot parentOf:(id<BaseTree>)oldRoot
{
	id<BaseTree> newNode = [self newTreeWithToken:newRoot];
	return [self becomeRoot:newNode old:oldRoot];
}

- (id<BaseTree>) newTreeWithTokenType:(NSInteger)tokenType
{
	id<BaseTree> newTree = [treeAdaptor newTreeWithTokenType:tokenType];
	[debugListener createNode:[treeAdaptor uniqueIdForTree:newTree] text:nil type:tokenType];
	return newTree;
}

- (id<BaseTree>) newTreeWithTokenType:(NSInteger)tokenType text:(NSString *)tokenText
{
	id<BaseTree> newTree = [treeAdaptor newTreeWithTokenType:tokenType text:tokenText];
	[debugListener createNode:[treeAdaptor uniqueIdForTree:newTree] text:tokenText type:tokenType];
	return newTree;
}
- (id<BaseTree>) newTreeWithToken:(id<Token>)fromToken tokenType:(NSInteger)tokenType
{
	id<BaseTree> newTree = [treeAdaptor newTreeWithToken:fromToken tokenType:tokenType];
	[debugListener createNode:[treeAdaptor uniqueIdForTree:newTree] text:fromToken.text type:tokenType];
	return newTree;
}

- (id<BaseTree>) newTreeWithToken:(id<Token>)fromToken tokenType:(NSInteger)tokenType text:(NSString *)tokenText
{
	id<BaseTree> newTree = [treeAdaptor newTreeWithToken:fromToken tokenType:tokenType text:tokenText];
	[debugListener createNode:[treeAdaptor uniqueIdForTree:newTree] text:tokenText type:tokenType];
	return newTree;
}

- (id<BaseTree>) newTreeWithToken:(id<Token>)fromToken text:(NSString *)tokenText
{
	id<BaseTree> newTree = [treeAdaptor newTreeWithToken:fromToken text:tokenText];
	[debugListener createNode:[treeAdaptor uniqueIdForTree:newTree] text:tokenText type:fromToken.type];
	return newTree;
}

#pragma mark Content

/* handled by forwardInvocation:
- (NSInteger) tokenTypeForNode:(id<BaseTree>)aNode
{
}
 
- (void) setTokenType:(NSInteger)tokenType forNode:(id)aNode
{
}

- (NSString *) textForNode:(id<BaseTree>)aNode
{
}
 
- (void) setText:(NSString *)tokenText forNode:(id<BaseTree>)aNode
{
}
*/
- (void) setBoundariesForTree:(id<BaseTree>)aTree fromToken:(id<Token>)startToken toToken:(id<Token>)stopToken
{
	[treeAdaptor setBoundariesForTree:aTree fromToken:startToken toToken:stopToken];
	if (aTree && startToken && stopToken) {
		[debugListener setTokenBoundariesForTree:[aTree hash] From:[startToken getTokenIndex] To:[stopToken getTokenIndex]];
	}
}
/* handled by forwardInvocation:
- (NSInteger) tokenStartIndexForTree:(id<BaseTree>)aTree
{
}
 
- (NSInteger) tokenStopIndexForTree:(id<BaseTree>)aTree
{
}
*/

#pragma mark Navigation / Tree Parsing
/* handled by forwardInvocation:
- (id<BaseTree>) childForNode:(id<BaseTree>) aNode atIndex:(NSInteger) i
{
}
 
- (NSInteger) childCountForTree:(id<BaseTree>) aTree
{
}
*/

@end
