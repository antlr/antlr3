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

#import "ANTLRTree.h"
#import "ANTLRToken.h"
// TODO: this shouldn't be here...but needed for invalidNode
#import "ANTLRCommonTree.h"

@implementation ANTLRTree

@synthesize isEmpty;
@synthesize isEmptyNode;
@synthesize invalidNode;
@synthesize children;

#pragma mark ANTLRTree protocol conformance

+ (id<ANTLRTree>) invalidNode
{
	static id<ANTLRTree> invalidNode = nil;
	if (!invalidNode) {
		invalidNode = [[ANTLRCommonTree alloc] initWithTokenType:ANTLRTokenTypeInvalid];
	}
	return invalidNode;
}

- (id<ANTLRTree>) init
{
	self = [super init];
	if ( self != nil ) {
		isEmptyNode = NO;
	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (id<ANTLRTree>) getChild:(NSUInteger) index
{
	return nil;
}

- (NSUInteger) getChildCount
{
	return 0;
}

- (NSArray *) getChildren
{
	return nil;
}

	// Add tree as a child to this node.  If tree is nil, do nothing.  If tree
	// is an empty node, add all children of tree to our children.

- (void) addChild:(id<ANTLRTree>) tree
{
}

- (void) addChildren:(NSArray *) theChildren
{
}

- (void) removeAllChildren
{
}

	// Indicates the node is an empty node but may still have children, meaning
	// the tree is a flat list.

- (BOOL) isEmpty
{
	return isEmptyNode;
}

- (void) setIsEmpty:(BOOL)emptyFlag
{
	isEmptyNode = emptyFlag;
}

#pragma mark ANTLRTree abstract base class

	// Return a token type; needed for tree parsing
- (NSInteger) getType
{
	return 0;
}

- (NSString *) getText
{
	return [self description];
}

	// In case we don't have a token payload, what is the line for errors?
- (NSInteger) getLine
{
	return 0;
}

- (NSInteger) getCharPositionInLine
{
	return 0;
}

- (NSString *) treeDescription
{
	return @"";
}

- (NSString *) description
{
	return @"";
}

- (void) _createChildrenList
{
	if ( children == nil )
		children = [[NSMutableArray alloc] init];
}

@end

@end