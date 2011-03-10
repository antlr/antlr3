// [The "BSD licence"]
// Copyright (c) 2010 Alan Condit
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

#import "ANTLRBaseTreeAdaptor.h"
#import "ANTLRRuntimeException.h"
#import "ANTLRUniqueIDMap.h"
#import "ANTLRMapElement.h"

@implementation ANTLRBaseTreeAdaptor

+ (ANTLRBaseTreeAdaptor *) newEmptyTree
{
    return [[ANTLRCommonTree alloc] init];
//    return nil;
}

- (id) init
{
    if ((self = [super init]) != nil) {
        
    }
    return self;
}

- (id) copyWithZone:(NSZone *)aZone
{
    ANTLRBaseTreeAdaptor *copy;
    
    copy = [[[self class] alloc] init];
    if (treeToUniqueIDMap)
        copy.treeToUniqueIDMap = [treeToUniqueIDMap copyWithZone:aZone];
    copy.uniqueNodeID = uniqueNodeID;
    return copy;
}
    

- (id) emptyNode
{
    return [[ANTLRBaseTreeAdaptor alloc] init];
}

/** create tree node that holds the start and stop tokens associated
 *  with an error.
 *
 *  If you specify your own kind of tree nodes, you will likely have to
 *  override this method. CommonTree returns Token.INVALID_TOKEN_TYPE
 *  if no token payload but you might have to set token type for diff
 *  node type.
 *
 *  You don't have to subclass CommonErrorNode; you will likely need to
 *  subclass your own tree node class to avoid class cast exception.
 */
- (id) errorNode:(id<ANTLRTokenStream>)anInput
            From:(id<ANTLRToken>)startToken
              To:(id<ANTLRToken>)stopToken
       Exception:(ANTLRRecognitionException *) e;
{
    //System.out.println("returning error node '"+t+"' @index="+anInput.index());
    return [ANTLRCommonErrorNode newANTLRCommonErrorNode:anInput
                                                    From:startToken
                                                      To:stopToken
                                               Exception:e];
}

- (BOOL) isNil:(id<ANTLRTree>) tree
{
    return [(id<ANTLRTree>)tree isNil];
}

- (id<ANTLRTree>)dupTree:(id<ANTLRTree>)tree
{
    return [self dupTree:(id<ANTLRTree>)tree Parent:nil];
}

/** This is generic in the sense that it will work with any kind of
 *  tree (not just Tree interface).  It invokes the adaptor routines
 *  not the tree node routines to do the construction.  
 */
- (id<ANTLRTree>)dupTree:(id<ANTLRTree>)t Parent:(id<ANTLRTree>)parent
{
    if ( t==nil ) {
        return nil;
    }
    id<ANTLRTree>newTree = [self dupNode:t];
    // ensure new subtree root has parent/child index set
    [self setChildIndex:newTree With:[self getChildIndex:t]]; // same index in new tree
    [self setParent:newTree With:parent];
    NSInteger n = [self getChildCount:t];
    for (NSInteger i = 0; i < n; i++) {
        id<ANTLRTree> child = [self getChild:t At:i];
        id<ANTLRTree> newSubTree = [self dupTree:child Parent:t];
        [self addChild:newSubTree toTree:newTree];
    }
    return newTree;
}

- (id<ANTLRTree>)dupNode:(id<ANTLRTree>)aNode
{
    return aNode; // override for better results :>)
}
/** Add a child to the tree t.  If child is a flat tree (a list), make all
 *  in list children of t.  Warning: if t has no children, but child does
 *  and child isNil then you can decide it is ok to move children to t via
 *  t.children = child.children; i.e., without copying the array.  Just
 *  make sure that this is consistent with have the user will build
 *  ASTs.
 */
- (void) addChild:(id<ANTLRTree>)child toTree:(id<ANTLRTree>)t
{
    if ( t != nil && child != nil ) {
        [(id<ANTLRTree>)t addChild:[(id<ANTLRTree>)child retain]];
    }
}

/** If oldRoot is a nil root, just copy or move the children to newRoot.
 *  If not a nil root, make oldRoot a child of newRoot.
 *
 *    old=^(nil a b c), new=r yields ^(r a b c)
 *    old=^(a b c), new=r yields ^(r ^(a b c))
 *
 *  If newRoot is a nil-rooted single child tree, use the single
 *  child as the new root node.
 *
 *    old=^(nil a b c), new=^(nil r) yields ^(r a b c)
 *    old=^(a b c), new=^(nil r) yields ^(r ^(a b c))
 *
 *  If oldRoot was null, it's ok, just return newRoot (even if isNil).
 *
 *    old=null, new=r yields r
 *    old=null, new=^(nil r) yields ^(nil r)
 *
 *  Return newRoot.  Throw an exception if newRoot is not a
 *  simple node or nil root with a single child node--it must be a root
 *  node.  If newRoot is ^(nil x) return x as newRoot.
 *
 *  Be advised that it's ok for newRoot to point at oldRoot's
 *  children; i.e., you don't have to copy the list.  We are
 *  constructing these nodes so we should have this control for
 *  efficiency.
 */
- (id<ANTLRTree>)becomeRoot:(id<ANTLRTree>)newRoot old:(id<ANTLRTree>)oldRoot
{
    if ( oldRoot == nil ) {
        return newRoot;
    }
    //System.out.println("becomeroot new "+newRoot.toString()+" old "+oldRoot);
    id<ANTLRTree> newRootTree = (id<ANTLRTree>)newRoot;
    id<ANTLRTree> oldRootTree = (id<ANTLRTree>)oldRoot;
    // handle ^(nil real-node)
    if ( [newRootTree isNil] ) {
        NSInteger nc = [newRootTree getChildCount];
        if ( nc == 1 ) newRootTree = [(id<ANTLRTree>)newRootTree getChild:0];
        else if ( nc > 1 ) {
            // TODO: make tree run time exceptions hierarchy
            @throw [ANTLRRuntimeException newException:NSStringFromClass([self class]) reason:@"more than one node as root (TODO: make exception hierarchy)"];
        }
    }
    // add oldRoot to newRoot; addChild takes care of case where oldRoot
    // is a flat list (i.e., nil-rooted tree).  All children of oldRoot
    // are added to newRoot.
    [newRootTree addChild:oldRootTree];
    return newRootTree;
}

/** Transform ^(nil x) to x and nil to null */
- (id<ANTLRTree>)rulePostProcessing:(id<ANTLRTree>)root
{
    //System.out.println("rulePostProcessing: "+((Tree)root).toStringTree());
    id<ANTLRTree> r = (id<ANTLRTree>)root;
    if ( r != nil && [r isNil] ) {
        if ( [r getChildCount] == 0 ) {
            r = nil;
        }
        else if ( [r getChildCount] == 1 ) {
            r = (id<ANTLRTree>)[r getChild:0];
            // whoever invokes rule will set parent and child index
            [r setParent:nil];
            [r setChildIndex:-1];
        }
    }
    return r;
}

- (id<ANTLRTree>)becomeRootfromToken:(id<ANTLRToken>)newRoot old:(id<ANTLRTree>)oldRoot
{
    return [self becomeRoot:[self createTree:newRoot] old:oldRoot];
}

- (id<ANTLRTree>)createTree:(NSInteger)tokenType FromToken:(id<ANTLRToken>)fromToken
{
    fromToken = [self createToken:fromToken];
    //((ClassicToken)fromToken).setType(tokenType);
    [fromToken setType:tokenType];
    id<ANTLRTree> t = [[self class] createTree:fromToken];
    return t;
}

- (id<ANTLRTree>)createTree:(NSInteger)tokenType FromToken:(id<ANTLRToken>)fromToken Text:(NSString *)text;
{
    if (fromToken == nil)
        return [self createTree:tokenType Text:text];
    fromToken = [self createToken:fromToken];
    [fromToken setType:tokenType];
    [fromToken setText:text];
    id<ANTLRTree>t = [[self class] createTree:fromToken];
    return t;
}

- (id<ANTLRTree>)createTree:(NSInteger)tokenType Text:(NSString *)text
{
    id<ANTLRToken> fromToken = [self createToken:tokenType Text:text];
    id<ANTLRTree> t = (id<ANTLRTree>)[self createTree:fromToken];
    return t;
}

- (NSInteger) getType:(id<ANTLRTree>) t
{
    return [(id<ANTLRTree>)t getType];
}

- (void) setType:(id<ANTLRTree>)t Type:(NSInteger)type
{
    @throw [ANTLRRuntimeException newANTLRNoSuchElementException:@"don't know enough about Tree node"];
}

- (NSString *)getText:(id<ANTLRTree>)t
{
    return [(id<ANTLRTree>)t getText];
}

- (void) setText:(id<ANTLRTree>)t Text:(NSString *)text
{
    @throw [ANTLRRuntimeException newANTLRNoSuchElementException:@"don't know enough about Tree node"];
}

- (id<ANTLRTree>) getChild:(id<ANTLRTree>)t At:(NSInteger)index
{
    return [(id<ANTLRTree>)t getChild:index ];
}

- (void) setChild:(id<ANTLRTree>)t At:(NSInteger)index Child:(id<ANTLRTree>)child
{
    [(id<ANTLRTree>)t setChild:index With:(id<ANTLRTree>)child];
}

- (id<ANTLRTree>) deleteChild:(id<ANTLRTree>)t Index:(NSInteger)index
{
    return [(id<ANTLRTree>)t deleteChild:index];
}

- (NSInteger) getChildCount:(id<ANTLRTree>)t
{
    return [(id<ANTLRTree>)t getChildCount];
}

- (NSInteger) getUniqueID:(id<ANTLRTree>)node
{
    if ( treeToUniqueIDMap == nil ) {
        treeToUniqueIDMap = [ANTLRUniqueIDMap newANTLRUniqueIDMap];
    }
    NSNumber *prevID = [treeToUniqueIDMap getNode:node];
    if ( prevID != nil ) {
        return [prevID integerValue];
    }
    NSInteger anID = uniqueNodeID;
    // ANTLRMapElement *aMapNode = [ANTLRMapElement newANTLRMapElementWithObj1:[NSNumber numberWithInteger:anID] Obj2:node];
    [treeToUniqueIDMap putID:[NSNumber numberWithInteger:anID] Node:node];
    uniqueNodeID++;
    return anID;
    // GCC makes these nonunique:
    // return System.identityHashCode(node);
}

/** Tell me how to create a token for use with imaginary token nodes.
 *  For example, there is probably no input symbol associated with imaginary
 *  token DECL, but you need to create it as a payload or whatever for
 *  the DECL node as in ^(DECL type ID).
 *
 *  If you care what the token payload objects' type is, you should
 *  override this method and any other createToken variant.
 */
- (id<ANTLRToken>) createToken:(NSInteger)aTType Text:(NSString *)text
{
    return nil;
}

/** Tell me how to create a token for use with imaginary token nodes.
 *  For example, there is probably no input symbol associated with imaginary
 *  token DECL, but you need to create it as a payload or whatever for
 *  the DECL node as in ^(DECL type ID).
 *
 *  This is a variant of createToken where the new token is derived from
 *  an actual real input token.  Typically this is for converting '{'
 *  tokens to BLOCK etc...  You'll see
 *
 *    r : lc='{' ID+ '}' -> ^(BLOCK[$lc] ID+) ;
 *
 *  If you care what the token payload objects' type is, you should
 *  override this method and any other createToken variant.
 */
- (id<ANTLRToken>) createToken:(id<ANTLRToken>) fromToken
{
    return nil;
}

- (void) setUniqueNodeID:(NSInteger)aUniqueNodeID
{
    uniqueNodeID = aUniqueNodeID;
}

#ifdef DONTUSENOMO
- (ANTLRUniqueIDMap *)getTreeToUniqueIDMap
{
    return treeToUniqueIDMap;
}

- (void) setTreeToUniqueIDMap:(ANTLRUniqueIDMap *)aMapListNode
{
    treeToUniqueIDMap = aMapListNode;
}

- (NSInteger)getUniqueID
{
    return uniqueNodeID;
}

#endif

@end
