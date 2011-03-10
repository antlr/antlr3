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

#import "ANTLRTree.h"

@protocol ANTLRBaseTree <ANTLRTree>

@property (retain, getter=getChildren, setter=setChildren) NSMutableArray *children;

+ (id<ANTLRBaseTree>) newANTLRBaseTree;
+ (id<ANTLRBaseTree>) newANTLRBaseTree:(id<ANTLRBaseTree>)node;

- (id<ANTLRBaseTree>) init;
- (id<ANTLRBaseTree>) initWith:(id<ANTLRTree>)node;

- (id<ANTLRBaseTree>) getChild:(NSUInteger)i;
- (NSMutableArray *)getChildren;
- (void) setChildren:(NSMutableArray *)anArray;
- (id<ANTLRBaseTree>)getFirstChildWithType:(NSInteger)type;
- (NSUInteger) getChildCount;

// Add t as a child to this node.  If t is null, do nothing.  If t
//  is nil, add all children of t to this' children.

- (void) addChild:(id<ANTLRTree>) tree;
- (void) addChildren:(NSArray *) theChildren;
//- (void) removeAllChildren;

- (void) setChild:(NSInteger) i With:(id<ANTLRTree>)t;
- (id) deleteChild:(NSInteger) i;
- (NSMutableArray *) createChildrenList;
- (void) replaceChildrenFrom:(NSInteger)startChildIndex To:(NSInteger)stopChildIndex With:(id) t;
// Indicates the node is a nil node but may still have children, meaning
// the tree is a flat list.

- (BOOL) isNil;
- (NSInteger) getTokenStartIndex;
- (void) setTokenStartIndex:(NSInteger) index;
- (NSInteger) getTokenStopIndex;
- (void) setTokenStopIndex:(NSInteger) index;

- (void) freshenParentAndChildIndexes;
- (void) freshenParentAndChildIndexes:(NSInteger) offset;
- (void) sanityCheckParentAndChildIndexes;
- (void) sanityCheckParentAndChildIndexes:(id<ANTLRTree>) parent At:(NSInteger) i;

- (NSInteger) getChildIndex;
- (void) setChildIndex:(NSInteger)i;

- (id<ANTLRTree>)getAncestor:(NSInteger)ttype;
- (NSMutableArray *)getAncestors;

#pragma mark Copying
- (id) copyWithZone:(NSZone *)aZone;	// the children themselves are not copied here!
- (id) deepCopy;					// performs a deepCopyWithZone: with the default zone
- (id) deepCopyWithZone:(NSZone *)aZone;

#pragma mark Tree Parser support
- (NSInteger) getType;
- (NSString *) getText;
// In case we don't have a token payload, what is the line for errors?
- (NSInteger) getLine;
- (NSInteger) getCharPositionInLine;


#pragma mark Informational
- (NSString *) treeDescription;
- (NSString *) description;

- (NSString *) toString;
- (NSString *) toStringTree;

@end

@interface ANTLRBaseTree : NSObject <ANTLRTree>
{
	NSMutableArray *children;
    NSException *anException;
}

@property (retain, getter=getChildren, setter=setChildren) NSMutableArray *children;

+ (id<ANTLRBaseTree>) newANTLRBaseTree;
+ (id<ANTLRBaseTree>) newANTLRBaseTree:(id<ANTLRBaseTree>)node;
         
- (id<ANTLRTree>) init;
- (id<ANTLRBaseTree>) initWith:(id<ANTLRTree>)node;

- (id<ANTLRBaseTree>) getChild:(NSUInteger)i;
- (NSMutableArray *)getChildren;
- (void) setChildren:(NSMutableArray *)anArray;
- (id<ANTLRBaseTree>)getFirstChildWithType:(NSInteger)type;
- (NSUInteger) getChildCount;

//- (void) removeAllChildren;

// Add t as a child to this node.  If t is null, do nothing.  If t
//  is nil, add all children of t to this' children.

- (void) addChild:(id<ANTLRTree>) tree;
- (void) addChildren:(NSArray *) theChildren;

- (void) setChild:(NSInteger) i With:(id<ANTLRTree>)t;
- (id) deleteChild:(NSInteger) i;
- (NSMutableArray *) createChildrenList;
- (void) replaceChildrenFrom:(NSInteger)startChildIndex To:(NSInteger)stopChildIndex With:(id) t;
// Indicates the node is a nil node but may still have children, meaning
	// the tree is a flat list.

- (BOOL) isNil;
- (NSInteger) getTokenStartIndex;
- (void) setTokenStartIndex:(NSInteger) index;
- (NSInteger) getTokenStopIndex;
- (void) setTokenStopIndex:(NSInteger) index;

- (void) freshenParentAndChildIndexes;
- (void) freshenParentAndChildIndexes:(NSInteger) offset;
- (void) sanityCheckParentAndChildIndexes;
- (void) sanityCheckParentAndChildIndexes:(id<ANTLRTree>) parent At:(NSInteger) i;

- (NSInteger) getChildIndex;
- (void) setChildIndex:(NSInteger)i;

- (BOOL) hasAncestor:(NSInteger) ttype;
- (id<ANTLRTree>)getAncestor:(NSInteger)ttype;
- (NSMutableArray *)getAncestors;

- (id) copyWithZone:(NSZone *)aZone;
- (id) deepCopy;					// performs a deepCopyWithZone: with the default zone
- (id) deepCopyWithZone:(NSZone *)aZone;

	// Return a token type; needed for tree parsing
- (NSInteger) getType;
- (NSString *) getText;

	// In case we don't have a token payload, what is the line for errors?
- (NSInteger) getLine;
- (NSInteger) getCharPositionInLine;
- (void) setCharPositionInLine:(NSInteger)pos;

- (NSString *) treeDescription;
- (NSString *) description;
- (NSString *) toString;
- (NSString *) toStringTree;

@end

@interface ANTLRTreeNavigationNode : ANTLRBaseTree {
}
- (id) copyWithZone:(NSZone *)aZone;
@end

@interface ANTLRTreeNavigationNodeDown : ANTLRTreeNavigationNode {
}
+ (ANTLRTreeNavigationNodeDown *) getNavigationNodeDown;
- (NSInteger) tokenType;
- (NSString *) description;
@end

@interface ANTLRTreeNavigationNodeUp : ANTLRTreeNavigationNode {
}
+ (ANTLRTreeNavigationNodeUp *) getNavigationNodeUp;
- (NSInteger) tokenType;
- (NSString *) description;
@end

@interface ANTLRTreeNavigationNodeEOF : ANTLRTreeNavigationNode {
}
+ (ANTLRTreeNavigationNodeEOF *) getNavigationNodeEOF;
- (NSInteger) tokenType;
- (NSString *) description;
@end

extern ANTLRTreeNavigationNodeDown *navigationNodeDown;
extern ANTLRTreeNavigationNodeUp *navigationNodeUp;
extern ANTLRTreeNavigationNodeEOF *navigationNodeEOF;
