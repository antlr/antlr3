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

#import "ANTLRCommonTree.h"


@implementation ANTLRCommonTree

@synthesize token;
@synthesize startIndex;
@synthesize stopIndex;
@synthesize parent;
@synthesize childIndex;

+ (ANTLRCommonTree *)invalidNode
{
    // Had to cast to id<ANTLRTree> here, because GCC is dumb.
	return [((ANTLRCommonTree *)[ANTLRCommonTree alloc]) initWithToken:[ANTLRCommonToken invalidToken]];
}

+ (ANTLRCommonTree *)newTree
{
    return [[ANTLRCommonTree alloc] init];
}

+ (ANTLRCommonTree *)newTreeWithTree:(ANTLRCommonTree *)aTree
{
    return [[ANTLRCommonTree alloc] initWithTreeNode:aTree];
}

+ (ANTLRCommonTree *)newTreeWithToken:(ANTLRCommonToken *)aToken
{
    // Had to cast to id<ANTLRTree> here, because GCC is dumb.
	return [((ANTLRCommonTree *)[ANTLRCommonTree alloc]) initWithToken:aToken];
}

+ (ANTLRCommonTree *)newTreeWithTokenType:(NSInteger)aTType
{
    // Had to cast to id<ANTLRTree> here, because GCC is dumb.
	return [[ANTLRCommonTree alloc] initWithTokenType:(NSInteger)aTType];
}

+ (ANTLRCommonTree *)newTreeWithTokenType:(NSInteger)aTType Text:(NSString *)theText
{
    // Had to cast to id<ANTLRTree> here, because GCC is dumb.
	return [[ANTLRCommonTree alloc] initWithTokenType:(NSInteger)aTType Text:theText];
}

- (id)init
{
	if ((self = [super init]) != nil) {
        token = nil;
		startIndex = -1;
		stopIndex = -1;
        parent = nil;
        childIndex = -1;
	}
	return self;
}

- (id)initWithTreeNode:(ANTLRCommonTree *)aNode
{
	if ((self = [super init]) != nil) {
		token = aNode.token;
		startIndex = aNode.startIndex;
		stopIndex = aNode.stopIndex;
        parent = nil;
        childIndex = -1;
	}
	return self;
}

- (id)initWithToken:(ANTLRCommonToken *)aToken
{
	if ((self = [super init]) != nil ) {
		token = aToken;
		startIndex = -1;
		stopIndex = -1;
        parent = nil;
        childIndex = -1;
	}
	return self;
}

- (id)initWithTokenType:(NSInteger)aTokenType
{
	if ((self = [super init]) != nil ) {
		token = [ANTLRCommonToken newANTLRCommonToken:aTokenType];
//		startIndex = token.startIndex;
		startIndex = -1;
//		stopIndex = token.stopIndex;
		stopIndex = -1;
        parent = nil;
        childIndex = -1;
	}
	return self;
}

- (id) initWithTokenType:(NSInteger)aTokenType Text:(NSString *)theText
{
	if ((self = [super init]) != nil ) {
		token = [ANTLRCommonToken newANTLRCommonToken:aTokenType Text:theText];
//		startIndex = token.startIndex;
		startIndex = -1;
//		stopIndex = token.stopIndex;
		stopIndex = -1;
        parent = nil;
        childIndex = -1;
	}
	return self;
}

- (void) dealloc
{
	[self setToken:nil];
	[super dealloc];
}

- (id) copyWithZone:(NSZone *)aZone
{
    ANTLRCommonTree *copy;
	
    //    copy = [[[self class] allocWithZone:aZone] init];
    copy = [super copyWithZone:aZone]; // allocation occurs in ANTLRBaseTree
    if ( self.token )
        copy.token = [self.token copyWithZone:aZone];
    copy.startIndex = startIndex;
    copy.stopIndex = stopIndex;
    copy.parent = [self.parent copyWithZone:aZone];
    copy.childIndex = childIndex;
    return copy;
}

- (BOOL) isNil
{
	return token == nil;
}

- (ANTLRCommonToken *) getToken
{
	return token;
}

- (void) setToken:(ANTLRCommonToken *) aToken
{
	if (token != aToken) {
		[aToken retain];
		[token release];
		token = aToken;
	}
}

- (id<ANTLRTree>) dupNode
{
    return [ANTLRCommonTree newTreeWithTree:self ];
}

- (NSInteger) getType
{
	if (token)
		return [token getType];
	return ANTLRTokenTypeInvalid;
}

- (NSString *) getText
{
	if (token)
		return [token getText];
	return nil;
}

- (NSUInteger) getLine
{
	if (token)
		return [token getLine];
	return 0;
}

- (NSUInteger) getCharPositionInLine
{
	if (token)
		return [token getCharPositionInLine];
	return 0;
}

- (void) setCharPositionInLine:(int)pos
{
    if (token)
        [token setCharPositionInLine:pos];
}

- (NSInteger) getTokenStartIndex
{
	if ( startIndex == -1 && token != nil ) {
		return [token getTokenIndex];
	}
    return startIndex;
}

- (void) setTokenStartIndex: (NSInteger) aStartIndex
{
    startIndex = aStartIndex;
}

- (NSInteger) getTokenStopIndex
{
	if ( stopIndex == -1 && token != nil ) {
		return [token getTokenIndex];
	}
    return stopIndex;
}

- (void) setTokenStopIndex: (NSInteger) aStopIndex
{
    stopIndex = aStopIndex;
}

#ifdef DONTUSENOMO
- (NSString *) treeDescription
{
	if (children) {
		NSMutableString *desc = [NSMutableString stringWithString:@"(^"];
		[desc appendString:[self description]];
		unsigned int childIdx;
		for (childIdx = 0; childIdx < [children count]; childIdx++) {
			[desc appendFormat:@"%@", [[children objectAtIndex:childIdx] treeDescription]];
		}
		[desc appendString:@")"];
		return desc;
	} else {
		return [self description];
	}
}
#endif

/** For every node in this subtree, make sure it's start/stop token's
 *  are set.  Walk depth first, visit bottom up.  Only updates nodes
 *  with at least one token index < 0.
 */
- (void) setUnknownTokenBoundaries
{
    if ( children == nil ) {
        if ( startIndex<0 || stopIndex<0 ) {
            startIndex = stopIndex = [token getTokenIndex];
        }
        return;
    }
    for (int i=0; i < [children count]; i++) {
        [[children objectAtIndex:i] setUnknownTokenBoundaries];
    }
    if ( startIndex >= 0 && stopIndex >= 0 )
         return; // already set
    if ( [children count] > 0 ) {
        ANTLRCommonTree *firstChild = (ANTLRCommonTree *)[children objectAtIndex:0];
        ANTLRCommonTree *lastChild = (ANTLRCommonTree *)[children objectAtIndex:[children count]-1];
        startIndex = [firstChild getTokenStartIndex];
        stopIndex = [lastChild getTokenStopIndex];
    }
}

- (NSInteger) getChildIndex
{
    return childIndex;
}

- (id<ANTLRTree>) getParent
{
    return parent;
}

- (void) setParent:(id<ANTLRTree>) t
{
    parent = (ANTLRCommonTree *)t;
}

- (void) setChildIndex:(NSInteger) index
{
    childIndex = index;
}

- (NSString *) description
{
    return [self toString];
}

- (NSString *) toString
{
    if ( [self isNil] ) {
        return @"nil";
    }
    if ( [self getType] == ANTLRTokenTypeInvalid ) {
        return @"<errornode>";
    }
    if ( token==nil ) {
        return nil;
    }
    return [token getText];
}

@end
