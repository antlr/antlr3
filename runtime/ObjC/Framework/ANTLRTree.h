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

@protocol ANTLRTree < NSObject, NSCopying >

//+ (id<ANTLRTree>) invalidNode;

- (id<ANTLRTree>) getChild:(NSUInteger)index;
- (NSUInteger) getChildCount;

// Tree tracks parent and child index now > 3.0

- (id<ANTLRTree>)getParent;

- (void) setParent:(id<ANTLRTree>)t;

/** Is there is a node above with token type ttype? */
- (BOOL) hasAncestor:(NSInteger)ttype;

/** Walk upwards and get first ancestor with this token type. */
- (id<ANTLRTree>) getAncestor:(NSInteger) ttype;

/** Return a list of all ancestors of this node.  The first node of
 *  list is the root and the last is the parent of this node.
 */
- (NSMutableArray *) getAncestors;

/** This node is what child index? 0..n-1 */
- (NSInteger) getChildIndex;

- (void) setChildIndex:(NSInteger) index;

/** Set the parent and child index values for all children */
- (void) freshenParentAndChildIndexes;

/** Add t as a child to this node.  If t is null, do nothing.  If t
 *  is nil, add all children of t to this' children.
 */
- (void) addChild:(id<ANTLRTree>) t;

/** Set ith child (0..n-1) to t; t must be non-null and non-nil node */
- (void) setChild:(NSInteger)i With:(id<ANTLRTree>) t;

- (id) deleteChild:(NSInteger) i;

/** Delete children from start to stop and replace with t even if t is
 *  a list (nil-root tree).  num of children can increase or decrease.
 *  For huge child lists, inserting children can force walking rest of
 *  children to set their childindex; could be slow.
 */
- (void) replaceChildrenFrom:(NSInteger)startChildIndex To:(NSInteger)stopChildIndex With:(id)t;	

- (NSArray *) getChildren;
// Add t as a child to this node.  If t is null, do nothing.  If t
//  is nil, add all children of t to this' children.

- (void) addChildren:(NSArray *) theChildren;
//- (void) removeAllChildren;

// Indicates the node is a nil node but may still have children, meaning
// the tree is a flat list.

- (BOOL) isNil;

/**  What is the smallest token index (indexing from 0) for this node
 *   and its children?
 */
- (NSInteger) getTokenStartIndex;

- (void) setTokenStartIndex:(NSInteger) index;

/**  What is the largest token index (indexing from 0) for this node
 *   and its children?
 */
- (NSInteger) getTokenStopIndex;
- (void) setTokenStopIndex:(NSInteger) index;

- (id<ANTLRTree>) dupNode;

- (NSString *) toString;

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
- (void) setCharPositionInLine:(NSInteger)pos;

#pragma mark Informational
- (NSString *) treeDescription;
- (NSString *) description;

@end

