//
//  ANTLRTreeIterator.m
//  ANTLR
//
//  Created by Ian Michell on 26/04/2010.
// Copyright (c) 2010 Ian Michell 2010 Alan Condit
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


#import "ANTLRTreeIterator.h"
#import "ANTLRCommonTreeAdaptor.h"

@implementation ANTLRTreeIterator

+ (ANTLRTreeIterator *) newANTRLTreeIterator
{
    return [[ANTLRTreeIterator alloc] init];
}

+ (ANTLRTreeIterator *) newANTRLTreeIteratorWithAdaptor:(ANTLRCommonTreeAdaptor *)adaptor
                                                andTree:(id<ANTLRBaseTree>)tree
{
    return [[ANTLRTreeIterator alloc] initWithTreeAdaptor:adaptor andTree:tree];
}

- (id) init
{
	if ((self = [super init]) != nil) {
		firstTime = YES;
		nodes = [ANTLRFastQueue newANTLRFastQueue];
		down = [adaptor createTree:ANTLRTokenTypeDOWN Text:@"DOWN"];
		up = [adaptor createTree:ANTLRTokenTypeUP Text:@"UP"];
		eof = [adaptor createTree:ANTLRTokenTypeEOF Text:@"EOF"];
		tree = eof;
		root = eof;
	}
	return self;
}

-(id) initWithTree:(id<ANTLRBaseTree>) t
{
	return [self initWithTreeAdaptor:[ANTLRCommonTreeAdaptor newTreeAdaptor] andTree:t];
}

-(id) initWithTreeAdaptor:(id<ANTLRTreeAdaptor>)a andTree:(id<ANTLRBaseTree>)t
{
	if ((self = [super init]) != nil) {
		firstTime = YES;
		adaptor = a;
		tree = t;
		root = t;
		nodes = [ANTLRFastQueue newANTLRFastQueue];
		down = [adaptor createTree:ANTLRTokenTypeDOWN Text:@"DOWN"];
		up = [adaptor createTree:ANTLRTokenTypeUP Text:@"UP"];
		eof = [adaptor createTree:ANTLRTokenTypeEOF Text:@"EOF"];
	}
	return self;
}

-(void) reset
{
	firstTime = YES;
	tree = root;
	[nodes clear];
}

-(BOOL) hasNext
{
	if (firstTime) {
        return root != nil;
    }
	if ( nodes && [nodes size] > 0) {
        return YES;
    }
	if (tree == nil) {
        return NO;
    }
	if ([adaptor getChildCount:tree] > 0) {
        return YES;
    }
	return [adaptor getParent:tree] != nil;
}

-(id) nextObject
{
	// is this the first time we are using this method?
	if (firstTime) {
		firstTime = NO;
		if ([adaptor getChildCount:tree] == 0) {
			[nodes addObject:eof];
			return tree;
		}
		return tree;
	}
	// do we have any objects queued up?
	if ( nodes && [nodes size] > 0) {
		return [nodes remove];
	}
	// no nodes left?
	if (tree == nil) {
		return eof;
	}
	if ([adaptor getChildCount:tree] > 0) {
		tree = [adaptor getChild:tree At:0];
		[nodes addObject:tree]; // real node is next after down
		return self.down;
	}
	// if no children, look for next sibling of ancestor
	id<ANTLRBaseTree> parent = [adaptor getParent:tree];
	while (parent != nil && ([adaptor getChildIndex:tree] + 1) >= [adaptor getChildCount:parent]) {
		[nodes addObject:up];
		tree = parent;
		parent = [adaptor getParent:tree];
	}
	if (parent == nil) {
		tree = nil;
		[nodes addObject:self.eof];
		return [nodes remove];
	}
	// must have found a node with an unvisited sibling
	// move to it and return it
	NSInteger nextSiblingIndex = [adaptor getChildIndex:tree] + 1;
	tree = [adaptor getChild:parent At:nextSiblingIndex];
	[nodes addObject:tree];
	return [nodes remove];
}

-(NSArray *) allObjects
{
	AMutableArray *array = [AMutableArray arrayWithCapacity:10];
	while ([self hasNext]) {
		[array addObject:[self nextObject]];
	}
	return array;
}

- (void)remove
{
    @throw [ANTLRRuntimeException newException:@"ANTLRUnsupportedOperationException"];
}
@synthesize up;
@synthesize down;
@synthesize eof;

@synthesize adaptor;
@synthesize root;
@synthesize tree;
@synthesize firstTime;
@synthesize nodes;
@end
