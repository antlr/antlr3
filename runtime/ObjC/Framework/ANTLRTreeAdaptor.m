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

#import "ANTLRTreeAdaptor.h"
#import "ANTLRTreeException.h"
#import "ANTLRBaseTree.h"

@implementation ANTLRTreeAdaptor


+ (id<ANTLRBaseTree>) newEmptyTree
{
	return [ANTLRTreeAdaptor newTreeWithToken:nil];
}

+ (id) newAdaptor
{
    return [[ANTLRTreeAdaptor alloc] init];
}

- (id) init
{
    self = [super init];
    return self;
}

- (id) initWithPayload:(id<ANTLRToken>)payload
{
    self = [super init];
    return self;
}

#pragma mark Rewrite Rules

/** Create a tree node from Token object; for CommonTree type trees,
 *  then the token just becomes the payload.  This is the most
 *  common create call.
 *
 *  Override if you want another kind of node to be built.
 */
- (id<ANTLRBaseTree>) create:(id<ANTLRToken>) payload
{
    return nil;
}

/** Create a new node derived from a token, with a new token type.
 *  This is invoked from an imaginary node ref on right side of a
 *  rewrite rule as IMAG[$tokenLabel].
 *
 *  This should invoke createToken(Token).
 */
- (id<ANTLRBaseTree>) createTree:(NSInteger)tokenType fromToken:(id<ANTLRToken>)fromToken
{
	id<ANTLRToken> newToken = [self createToken:fromToken];
	[newToken setType:tokenType];
    
	id<ANTLRBaseTree> newTree = [self create:newToken];
	[newToken release];
	return newTree;
}

/** Create a new node derived from a token, with a new token type.
 *  This is invoked from an imaginary node ref on right side of a
 *  rewrite rule as IMAG[$tokenLabel].
 *
 *  This should invoke createToken(Token).
 */
- (id<ANTLRBaseTree>) createTree:(NSInteger)tokenType fromToken:(id<ANTLRToken>)fromToken text:(NSString *)tokenText
{
	id<ANTLRToken> newToken = [self createToken:fromToken];
	[newToken setText:tokenText];
	
	id<ANTLRBaseTree> newTree = [self create:newToken];
	[newToken release];
	return newTree;
}

/** Create a new node derived from a token, with a new token type.
 *  This is invoked from an imaginary node ref on right side of a
 *  rewrite rule as IMAG["IMAG"].
 *
 *  This should invoke createToken(int,String).
 */
- (id<ANTLRBaseTree>) createTree:(NSInteger)tokenType text:(NSString *)tokenText
{
	id<ANTLRToken> newToken = [self createToken:tokenType text:tokenText];
	
	id<ANTLRBaseTree> newTree = [self create:newToken];
	[newToken release];
	return newTree;
}

- (id) copyNode:(id<ANTLRBaseTree>)aNode
{
	return [aNode copyWithZone:nil];	// not -copy: to silence warnings
}

- (id) copyTree:(id<ANTLRBaseTree>)aTree
{
	return [aTree deepCopy];
}


- (void) addChild:(id<ANTLRBaseTree>)child toTree:(id<ANTLRBaseTree>)aTree
{
	[aTree addChild:child];
}

- (id) makeNode:(id<ANTLRBaseTree>)newRoot parentOf:(id<ANTLRBaseTree>)oldRoot
{
	id<ANTLRBaseTree> newRootNode = newRoot;

	if (oldRoot == nil)
		return newRootNode;
    // handles ^(nil real-node) case
	if ([newRootNode isNil]) {
		if ([newRootNode getChildCount] > 1) {
#warning TODO: Find a way to the current input stream here!
			@throw [ANTLRTreeException exceptionWithOldRoot:oldRoot newRoot:newRootNode stream:nil];
		}
#warning TODO: double check memory management with respect to code generation
		// remove the empty node, placing its sole child in its role.
		id<ANTLRBaseTree> tmpRootNode = [[newRootNode childAtIndex:0] retain];
		[newRootNode release];
		newRootNode = tmpRootNode;		
	}
	// the handling of an empty node at the root of oldRoot happens in addChild:
	[newRootNode addChild:oldRoot];
    // this release relies on the fact that the ANTLR code generator always assigns the return value of this method
    // to the variable originally holding oldRoot. If we don't release we leak the reference.
    // FIXME: this is totally non-obvious. maybe do it in calling code by comparing pointers and conditionally releasing
    // the old object
    [oldRoot release];
    
    // what happens to newRootNode's retain count? Should we be autoreleasing this one? Probably.
	return [newRootNode retain];
}


- (id<ANTLRBaseTree>) postProcessTree:(id<ANTLRBaseTree>)aTree
{
	id<ANTLRBaseTree> processedNode = aTree;
	if (aTree != nil && [aTree isNil] != NO && [aTree getChildCount] == 1) {
		processedNode = [aTree childAtIndex:0];
	}
	return processedNode;
}


- (NSUInteger) uniqueIdForTree:(id<ANTLRBaseTree>)aNode
{
	// TODO: is hash appropriate here?
	return [aNode hash];
}


#pragma mark Content

- (NSInteger) tokenTypeForNode:(id<ANTLRBaseTree>)aNode
{
	return [aNode getType];
}

- (void) setTokenType:(NSInteger)tokenType forNode:(id)aNode
{
	// currently unimplemented
}


- (NSString *) textForNode:(id<ANTLRBaseTree>)aNode
{
	return [aNode getText];
}

- (void) setText:(NSString *)tokenText forNode:(id<ANTLRBaseTree>)aNode
{
	// currently unimplemented
}


#pragma mark Navigation / Tree Parsing

- (id<ANTLRBaseTree>) childForNode:(id<ANTLRBaseTree>) aNode atIndex:(NSInteger) i
{
	// currently unimplemented
	return nil;
}

- (NSInteger) childCountForTree:(id<ANTLRBaseTree>) aTree
{
	// currently unimplemented
	return 0;
}

#pragma mark Subclass Responsibilties

- (void) setBoundariesForTree:(id<ANTLRBaseTree>)aTree fromToken:(id<ANTLRToken>)startToken toToken:(id<ANTLRToken>)stopToken
{
	// subclass responsibility
}

- (NSInteger) tokenStartIndexForTree:(id<ANTLRBaseTree>)aTree
{
	// subclass responsibility
	return 0;
}

- (NSInteger) tokenStopIndexForTree:(id<ANTLRBaseTree>)aTree
{
	// subclass responsibility
	return 0;
}


@end
