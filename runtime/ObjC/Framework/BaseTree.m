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

#import "ANTLRBaseTree.h"
#import "ANTLRBaseTreeAdaptor.h"
#import "ANTLRToken.h"
// TODO: this shouldn't be here...but needed for invalidNode
#import "AMutableArray.h"
#import "ANTLRCommonTree.h"
#import "ANTLRRuntimeException.h"
#import "ANTLRError.h"

#pragma mark - Navigation Nodes
ANTLRTreeNavigationNodeDown *navigationNodeDown = nil;
ANTLRTreeNavigationNodeUp *navigationNodeUp = nil;
ANTLRTreeNavigationNodeEOF *navigationNodeEOF = nil;


@implementation ANTLRBaseTree

static id<ANTLRBaseTree> invalidNode = nil;

#pragma mark ANTLRTree protocol conformance

+ (id<ANTLRBaseTree>) INVALID_NODE
{
	if ( invalidNode == nil ) {
		invalidNode = [[ANTLRCommonTree alloc] initWithTokenType:ANTLRTokenTypeInvalid];
	}
	return invalidNode;
}

+ (id<ANTLRBaseTree>) invalidNode
{
	if ( invalidNode == nil ) {
		invalidNode = [[ANTLRCommonTree alloc] initWithTokenType:ANTLRTokenTypeInvalid];
	}
	return invalidNode;
}

+ newTree
{
    return [[ANTLRBaseTree alloc] init];
}

/** Create a new node from an existing node does nothing for ANTLRBaseTree
 *  as there are no fields other than the children list, which cannot
 *  be copied as the children are not considered part of this node. 
 */
+ newTree:(id<ANTLRBaseTree>) node
{
    return [[ANTLRBaseTree alloc] initWith:(id<ANTLRBaseTree>) node];
}

- (id) init
{
    self = [super init];
    if ( self != nil ) {
        children = nil;
        return self;
    }
    return nil;
}

- (id) initWith:(id<ANTLRBaseTree>)node
{
    self = [super init];
    if ( self != nil ) {
        // children = [[AMutableArray arrayWithCapacity:5] retain];
        // [children addObject:node];
        [self addChild:node];
        return self;
    }
    return nil;
}

- (void) dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in ANTLRBaseTree" );
#endif
	if ( children ) [children release];
	[super dealloc];
}

- (id<ANTLRBaseTree>) getChild:(NSUInteger)i
{
    if ( children == nil || i >= [children count] ) {
        return nil;
    }
    return (id<ANTLRBaseTree>)[children objectAtIndex:i];
}

/** Get the children internal List; note that if you directly mess with
 *  the list, do so at your own risk.
 */
- (AMutableArray *) children
{
    return children;
}

- (void) setChildren:(AMutableArray *)anArray
{
    if ( children != anArray ) {
        if ( children ) [children release];
        if ( anArray ) [anArray retain];
    }
    children = anArray;
}

- (id<ANTLRBaseTree>) getFirstChildWithType:(NSInteger) aType
{
    for (NSUInteger i = 0; children != nil && i < [children count]; i++) {
        id<ANTLRBaseTree> t = (id<ANTLRBaseTree>) [children objectAtIndex:i];
        if ( t.type == aType ) {
            return t;
        }
    }	
    return nil;
}

- (NSUInteger) getChildCount
{
    if ( children == nil ) {
        return 0;
    }
    return [children count];
}

/** Add t as child of this node.
 *
 *  Warning: if t has no children, but child does
 *  and child isNil then this routine moves children to t via
 *  t.children = child.children; i.e., without copying the array.
 */
- (void) addChild:(id<ANTLRBaseTree>) t
{
    //System.out.println("add child "+t.toStringTree()+" "+self.toStringTree());
    //System.out.println("existing children: "+children);
    if ( t == nil ) {
        return; // do nothing upon addChild(nil)
    }
    if ( self == (ANTLRBaseTree *)t )
        @throw [ANTLRIllegalArgumentException newException:@"ANTLRBaseTree Can't add self to self as child"];        
    id<ANTLRBaseTree> childTree = (id<ANTLRBaseTree>) t;
    if ( [childTree isNil] ) { // t is an empty node possibly with children
        if ( children != nil && children == childTree.children ) {
            @throw [ANTLRRuntimeException newException:@"ANTLRBaseTree add child list to itself"];
        }
        // just add all of childTree's children to this
        if ( childTree.children != nil ) {
            if ( children != nil ) { // must copy, this has children already
                int n = [childTree.children count];
                for ( int i = 0; i < n; i++) {
                    id<ANTLRBaseTree> c = (id<ANTLRBaseTree>)[childTree.children objectAtIndex:i];
                    [children addObject:c];
                    // handle double-link stuff for each child of nil root
                    [c setParent:(id<ANTLRBaseTree>)self];
                    [c setChildIndex:[children count]-1];
                }
            }
            else {
                // no children for this but t has children; just set pointer
                // call general freshener routine
                children = childTree.children;
                [self freshenParentAndChildIndexes];
            }
        }
    }
    else { // child is not nil (don't care about children)
        if ( children == nil ) {
            children = [[AMutableArray arrayWithCapacity:5] retain]; // create children list on demand
        }
        [children addObject:t];
        [childTree setParent:(id<ANTLRBaseTree>)self];
        [childTree setChildIndex:[children count]-1];
    }
    // System.out.println("now children are: "+children);
}

/** Add all elements of kids list as children of this node */
- (void) addChildren:(AMutableArray *) kids
{
    for (NSUInteger i = 0; i < [kids count]; i++) {
        id<ANTLRBaseTree> t = (id<ANTLRBaseTree>) [kids objectAtIndex:i];
        [self addChild:t];
    }
}

- (void) setChild:(NSUInteger) i With:(id<ANTLRBaseTree>)t
{
    if ( t == nil ) {
        return;
    }
    if ( [t isNil] ) {
        @throw [ANTLRIllegalArgumentException newException:@"ANTLRBaseTree Can't set single child to a list"];        
    }
    if ( children == nil ) {
        children = [[AMutableArray arrayWithCapacity:5] retain];
    }
    if ([children count] > i ) {
        [children replaceObjectAtIndex:i withObject:t];
    }
    else {
        [children insertObject:t atIndex:i];
    }
    [t setParent:(id<ANTLRBaseTree>)self];
    [t setChildIndex:i];
}

- (id) deleteChild:(NSUInteger) idx
{
    if ( children == nil ) {
        return nil;
    }
    id<ANTLRBaseTree> killed = (id<ANTLRBaseTree>)[children objectAtIndex:idx];
    [children removeObjectAtIndex:idx];
    // walk rest and decrement their child indexes
    [self freshenParentAndChildIndexes:idx];
    return killed;
}

/** Delete children from start to stop and replace with t even if t is
 *  a list (nil-root ANTLRTree).  num of children can increase or decrease.
 *  For huge child lists, inserting children can force walking rest of
 *  children to set their childindex; could be slow.
 */
- (void) replaceChildrenFrom:(NSInteger)startChildIndex To:(NSInteger)stopChildIndex With:(id) t
{
    /*
     System.out.println("replaceChildren "+startChildIndex+", "+stopChildIndex+
     " with "+((ANTLRBaseTree)t).toStringTree());
     System.out.println("in="+toStringTree());
     */
    if ( children == nil ) {
        @throw [ANTLRIllegalArgumentException newException:@"ANTLRBaseTree Invalid Indexes; no children in list"];        
    }
    int replacingHowMany = stopChildIndex - startChildIndex + 1;
    int replacingWithHowMany;
    id<ANTLRBaseTree> newTree = (id<ANTLRBaseTree>) t;
    AMutableArray *newChildren = nil;
    // normalize to a list of children to add: newChildren
    if ( [newTree isNil] ) {
        newChildren = newTree.children;
    }
    else {
        newChildren = [AMutableArray arrayWithCapacity:5];
        [newChildren addObject:newTree];
    }
    replacingWithHowMany = [newChildren count];
    int numNewChildren = [newChildren count];
    int delta = replacingHowMany - replacingWithHowMany;
    // if same number of nodes, do direct replace
    if ( delta == 0 ) {
        int j = 0; // index into new children
        for (int i=startChildIndex; i <= stopChildIndex; i++) {
            id<ANTLRBaseTree> child = (id<ANTLRBaseTree>)[newChildren objectAtIndex:j];
            [children replaceObjectAtIndex:i withObject:(id)child];
            [child setParent:(id<ANTLRBaseTree>)self];
            [child setChildIndex:i];
            j++;
        }
    }
    else if ( delta > 0 ) { // fewer new nodes than there were
                            // set children and then delete extra
        for (int j = 0; j < numNewChildren; j++) {
            [children replaceObjectAtIndex:startChildIndex+j withObject:[newChildren objectAtIndex:j]];
        }
        int indexToDelete = startChildIndex+numNewChildren;
        for (int c=indexToDelete; c<=stopChildIndex; c++) {
            // delete same index, shifting everybody down each time
            [children removeObjectAtIndex:indexToDelete];
        }
        [self freshenParentAndChildIndexes:startChildIndex];
    }
    else { // more new nodes than were there before
           // fill in as many children as we can (replacingHowMany) w/o moving data
        for (int j=0; j<replacingHowMany; j++) {
            [children replaceObjectAtIndex:startChildIndex+j withObject:[newChildren objectAtIndex:j]];
        }
        //        int numToInsert = replacingWithHowMany-replacingHowMany;
        for (int j=replacingHowMany; j<replacingWithHowMany; j++) {
            [children insertObject:[newChildren objectAtIndex:j] atIndex:startChildIndex+j];
        }
        [self freshenParentAndChildIndexes:startChildIndex];
    }
    //System.out.println("out="+toStringTree());
}

/** Override in a subclass to change the impl of children list */
- (AMutableArray *) createChildrenList
{
    return [AMutableArray arrayWithCapacity:5];
}

- (BOOL) isNil
{
    return NO;
}

/** Set the parent and child index values for all child of t */
- (void) freshenParentAndChildIndexes
{
    [self freshenParentAndChildIndexes:0];
}
               
- (void) freshenParentAndChildIndexes:(NSInteger) offset
{
    int n = [self getChildCount];
    for (int i = offset; i < n; i++) {
        id<ANTLRBaseTree> child = (id<ANTLRBaseTree>)[self getChild:i];
        [child setChildIndex:i];
        [child setParent:(id<ANTLRBaseTree>)self];
    }
}
               
- (void) sanityCheckParentAndChildIndexes
{
    [self sanityCheckParentAndChildIndexes:nil At:-1];
}
               
- (void) sanityCheckParentAndChildIndexes:(id<ANTLRBaseTree>)aParent At:(NSInteger) i
{
    if ( aParent != [self getParent] ) {
        @throw [ANTLRIllegalStateException newException:[NSString stringWithFormat:@"parents don't match; expected %s found %s", aParent, [self getParent]]];
    }
    if ( i != [self getChildIndex] ) {
        @throw [ANTLRIllegalStateException newException:[NSString stringWithFormat:@"child indexes don't match; expected %d found %d", i, [self getChildIndex]]];
    }
    int n = [self getChildCount];
    for (int c = 0; c < n; c++) {
        id<ANTLRBaseTree> child = (id<ANTLRBaseTree>)[self getChild:c];
        [child sanityCheckParentAndChildIndexes:(id<ANTLRBaseTree>)self At:c];
    }
}
               
/**  What is the smallest token index (indexing from 0) for this node
 *   and its children?
 */
- (NSInteger) getTokenStartIndex
{
    return 0;
}

- (void) setTokenStartIndex:(NSInteger) anIndex
{
}

/**  What is the largest token index (indexing from 0) for this node
 *   and its children?
 */
- (NSInteger) getTokenStopIndex
{
    return 0;
}

- (void) setTokenStopIndex:(NSInteger) anIndex
{
}

- (id<ANTLRBaseTree>) dupNode
{
    return nil;
}


/** ANTLRBaseTree doesn't track child indexes. */
- (NSInteger) getChildIndex
{
    return 0;
}

- (void) setChildIndex:(NSInteger) anIndex
{
}

/** ANTLRBaseTree doesn't track parent pointers. */
- (id<ANTLRBaseTree>) getParent
{
    return nil;
}

- (void) setParent:(id<ANTLRBaseTree>) t
{
}

/** Walk upwards looking for ancestor with this token type. */
- (BOOL) hasAncestor:(NSInteger) ttype
{
    return([self getAncestor:ttype] != nil);
}

/** Walk upwards and get first ancestor with this token type. */
- (id<ANTLRBaseTree>) getAncestor:(NSInteger) ttype
{
    id<ANTLRBaseTree> t = (id<ANTLRBaseTree>)self;
    t = (id<ANTLRBaseTree>)[t getParent];
    while ( t != nil ) {
        if ( t.type == ttype )
            return t;
        t = (id<ANTLRBaseTree>)[t getParent];
    }
    return nil;
}

/** Return a list of all ancestors of this node.  The first node of
 *  list is the root and the last is the parent of this node.
 */
- (AMutableArray *)getAncestors
{
    if ( [self getParent] == nil )
        return nil;
    AMutableArray *ancestors = [AMutableArray arrayWithCapacity:5];
    id<ANTLRBaseTree> t = (id<ANTLRBaseTree>)self;
    t = (id<ANTLRBaseTree>)[t getParent];
    while ( t != nil ) {
        [ancestors insertObject:t atIndex:0]; // insert at start
        t = (id<ANTLRBaseTree>)[t getParent];
    }
    return ancestors;
}

- (NSInteger)type
{
    return ANTLRTokenTypeInvalid;
}

- (NSString *)text
{
    return nil;
}

- (NSUInteger)line
{
    return 0;
}

- (NSUInteger)charPositionInLine
{
    return 0;
}

- (void) setCharPositionInLine:(NSUInteger) pos
{
}

#pragma mark Copying
     
     // the children themselves are not copied here!
- (id) copyWithZone:(NSZone *)aZone
{
    id<ANTLRBaseTree> theCopy = [[[self class] allocWithZone:aZone] init];
    [theCopy addChildren:self.children];
    return theCopy;
}
     
- (id) deepCopy 					// performs a deepCopyWithZone: with the default zone
{
    return [self deepCopyWithZone:NULL];
}
     
- (id) deepCopyWithZone:(NSZone *)aZone
{
    id<ANTLRBaseTree> theCopy = [self copyWithZone:aZone];
        
    if ( [theCopy.children count] )
        [theCopy.children removeAllObjects];
    AMutableArray *childrenCopy = theCopy.children;
    for (id loopItem in children) {
        id<ANTLRBaseTree> childCopy = [loopItem deepCopyWithZone:aZone];
        [theCopy addChild:childCopy];
    }
    if ( childrenCopy ) [childrenCopy release];
    return theCopy;
}
     
- (NSString *) treeDescription
{
    if ( children == nil || [children count] == 0 ) {
        return [self description];
    }
    NSMutableString *buf = [NSMutableString stringWithCapacity:[children count]];
    if ( ![self isNil] ) {
        [buf appendString:@"("];
        [buf appendString:[self toString]];
        [buf appendString:@" "];
    }
    for (int i = 0; children != nil && i < [children count]; i++) {
        id<ANTLRBaseTree> t = (id<ANTLRBaseTree>)[children objectAtIndex:i];
        if ( i > 0 ) {
            [buf appendString:@" "];
        }
        [buf appendString:[(id<ANTLRBaseTree>)t toStringTree]];
    }
    if ( ![self isNil] ) {
        [buf appendString:@")"];
    }
    return buf;
}

/** Print out a whole tree not just a node */
- (NSString *) toStringTree
{
    return [self treeDescription];
}

- (NSString *) description
{
    return nil;
}

/** Override to say how a node (not a tree) should look as text */
- (NSString *) toString
{
    return nil;
}

@synthesize children;
@synthesize anException;

@end

#pragma mark -

@implementation ANTLRTreeNavigationNode
- (id)init
{
    self = (ANTLRTreeNavigationNode *)[super init];
    return self;
}

- (id) copyWithZone:(NSZone *)aZone
{
	return nil;
}
@end

@implementation ANTLRTreeNavigationNodeDown
+ (ANTLRTreeNavigationNodeDown *) getNavigationNodeDown
{
    if ( navigationNodeDown == nil )
        navigationNodeDown = [[ANTLRTreeNavigationNodeDown alloc] init];
    return navigationNodeDown;
}

- (id)init
{
    self = [super init];
    return self;
}

- (NSInteger) tokenType { return ANTLRTokenTypeDOWN; }
- (NSString *) description { return @"DOWN"; }
@end

@implementation ANTLRTreeNavigationNodeUp
+ (ANTLRTreeNavigationNodeUp *) getNavigationNodeUp
{
    if ( navigationNodeUp == nil )
        navigationNodeUp = [[ANTLRTreeNavigationNodeUp alloc] init];
    return navigationNodeUp;
}


- (id)init
{
    self = [super init];
    return self;
}

- (NSInteger) tokenType { return ANTLRTokenTypeUP; }
- (NSString *) description { return @"UP"; }
@end

@implementation ANTLRTreeNavigationNodeEOF
+ (ANTLRTreeNavigationNodeEOF *) getNavigationNodeEOF
{
    if ( navigationNodeEOF == nil )
        navigationNodeEOF = [[ANTLRTreeNavigationNodeEOF alloc] init];
    return navigationNodeEOF;
}

- (id)init
{
    self = [super init];
    return self;
}

- (NSInteger) tokenType { return ANTLRTokenTypeEOF; }
- (NSString *) description { return @"EOF"; }

@end

