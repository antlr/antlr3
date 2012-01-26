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

+ (ANTLRCommonTree *)INVALID_NODE
{
	return [[ANTLRCommonTree alloc] initWithToken:[ANTLRCommonToken invalidToken]];
}

+ (ANTLRCommonTree *)invalidNode
{
    // Had to cast to ANTLRCommonTree * here, because GCC is dumb.
	return [[ANTLRCommonTree alloc] initWithToken:ANTLRCommonToken.INVALID_TOKEN];
}

+ (ANTLRCommonTree *)newTree
{
    return [[ANTLRCommonTree alloc] init];
}

+ (ANTLRCommonTree *)newTreeWithTree:(ANTLRCommonTree *)aTree
{
    return [[ANTLRCommonTree alloc] initWithTreeNode:aTree];
}

+ (ANTLRCommonTree *)newTreeWithToken:(id<ANTLRToken>)aToken
{
	return [[ANTLRCommonTree alloc] initWithToken:aToken];
}

+ (ANTLRCommonTree *)newTreeWithTokenType:(NSInteger)aTType
{
	return [[ANTLRCommonTree alloc] initWithTokenType:(NSInteger)aTType];
}

+ (ANTLRCommonTree *)newTreeWithTokenType:(NSInteger)aTType Text:(NSString *)theText
{
	return [[ANTLRCommonTree alloc] initWithTokenType:(NSInteger)aTType Text:theText];
}

- (id)init
{
	self = (ANTLRCommonTree *)[super init];
	if ( self != nil ) {
        token = nil;
		startIndex = -1;
		stopIndex = -1;
        parent = nil;
        childIndex = -1;
	}
	return (ANTLRCommonTree *)self;
}

- (id)initWithTreeNode:(ANTLRCommonTree *)aNode
{
	self = (ANTLRCommonTree *)[super init];
	if ( self != nil ) {
		token = aNode.token;
        if ( token ) [token retain];
		startIndex = aNode.startIndex;
		stopIndex = aNode.stopIndex;
        parent = nil;
        childIndex = -1;
	}
	return self;
}

- (id)initWithToken:(id<ANTLRToken>)aToken
{
	self = (ANTLRCommonTree *)[super init];
	if ( self != nil ) {
		token = aToken;
        if ( token ) [token retain];
		startIndex = -1;
		stopIndex = -1;
        parent = nil;
        childIndex = -1;
	}
	return self;
}

- (id)initWithTokenType:(NSInteger)aTokenType
{
	self = (ANTLRCommonTree *)[super init];
	if ( self != nil ) {
		token = [[ANTLRCommonToken newToken:aTokenType] retain];
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
	self = (ANTLRCommonTree *)[super init];
	if ( self != nil ) {
		token = [[ANTLRCommonToken newToken:aTokenType Text:theText] retain];
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
    if ( token ) {
        [token release];
        token = nil;
    }
    if ( parent ) {
        [parent release];
        parent = nil;
    }
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
    copy.parent = (ANTLRCommonTree *)[self.parent copyWithZone:aZone];
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
	if ( token != aToken ) {
		if ( token ) [token release];
		[aToken retain];
		token = aToken;
	}
}

- (ANTLRCommonTree *) dupNode
{
    return [ANTLRCommonTree newTreeWithTree:self ];
}

- (NSInteger)type
{
	if (token)
		return token.type;
	return ANTLRTokenTypeInvalid;
}

- (NSString *)text
{
	if (token)
		return token.text;
	return nil;
}

- (NSUInteger)line
{
	if (token)
		return token.line;
	return 0;
}

- (void) setLine:(NSUInteger)aLine
{
    if (token)
        token.line = aLine;
}

- (NSUInteger)charPositionInLine
{
	if (token)
		return token.charPositionInLine;
	return 0;
}

- (void) setCharPositionInLine:(NSUInteger)pos
{
    if (token)
        token.charPositionInLine = pos;
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
    for (NSUInteger i=0; i < [children count]; i++) {
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

- (ANTLRCommonTree *) getParent
{
    return parent;
}

- (void) setParent:(ANTLRCommonTree *) t
{
    parent = t;
}

- (void) setChildIndex:(NSInteger) anIndex
{
    childIndex = anIndex;
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
    if ( [self type] == ANTLRTokenTypeInvalid ) {
        return @"<errornode>";
    }
    if ( token==nil ) {
        return nil;
    }
    return token.text;
}

@synthesize token;
@synthesize startIndex;
@synthesize stopIndex;
@synthesize parent;
@synthesize childIndex;

@end
