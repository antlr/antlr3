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

#import <Cocoa/Cocoa.h>
#import "ANTLRTreeAdaptor.h"
#import "ANTLRCommonErrorNode.h"
#import "ANTLRUniqueIDMap.h"

@interface ANTLRBaseTreeAdaptor : NSObject <ANTLRTreeAdaptor, NSCopying> {
    ANTLRUniqueIDMap *treeToUniqueIDMap;
	NSInteger uniqueNodeID;
}

- (id) init;

- (id) copyWithZone:(NSZone *)aZone;

- (id) emptyNode;

- (id) createNil;

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
       Exception:(NSException *) e;

- (BOOL) isNil:(id<ANTLRBaseTree>) aTree;

- (id<ANTLRBaseTree>)dupTree:(id<ANTLRBaseTree>)aTree;

/** This is generic in the sense that it will work with any kind of
 *  tree (not just Tree interface).  It invokes the adaptor routines
 *  not the tree node routines to do the construction.  
 */
- (id<ANTLRBaseTree>)dupTree:(id<ANTLRBaseTree>)aTree Parent:(id<ANTLRBaseTree>)parent;
- (id<ANTLRBaseTree>)dupNode:(id<ANTLRBaseTree>)aNode;
/** Add a child to the tree t.  If child is a flat tree (a list), make all
 *  in list children of t.  Warning: if t has no children, but child does
 *  and child isNil then you can decide it is ok to move children to t via
 *  t.children = child.children; i.e., without copying the array.  Just
 *  make sure that this is consistent with have the user will build
 *  ASTs.
 */
- (void) addChild:(id<ANTLRBaseTree>)aChild toTree:(id<ANTLRBaseTree>)aTree;

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
- (id<ANTLRBaseTree>)becomeRoot:(id<ANTLRBaseTree>)aNewRoot old:(id<ANTLRBaseTree>)oldRoot;

/** Transform ^(nil x) to x and nil to null */
- (id<ANTLRBaseTree>)rulePostProcessing:(id<ANTLRBaseTree>)aRoot;

- (id<ANTLRBaseTree>)becomeRootfromToken:(id<ANTLRToken>)aNewRoot old:(id<ANTLRBaseTree>)oldRoot;

- (id<ANTLRBaseTree>) create:(id<ANTLRToken>)payload;
- (id<ANTLRBaseTree>) createTree:(NSInteger)aTType FromToken:(id<ANTLRToken>)aFromToken;
- (id<ANTLRBaseTree>) createTree:(NSInteger)aTType FromToken:(id<ANTLRToken>)aFromToken Text:(NSString *)theText;
- (id<ANTLRBaseTree>) createTree:(NSInteger)aTType Text:(NSString *)theText;

- (NSInteger) getType:(id<ANTLRBaseTree>)aTree;

- (void) setType:(id<ANTLRBaseTree>)aTree Type:(NSInteger)type;

- (id<ANTLRToken>)getToken:(ANTLRCommonTree *)t;

- (NSString *)getText:(ANTLRCommonTree *)aTree;

- (void) setText:(id<ANTLRBaseTree>)aTree Text:(NSString *)theText;

- (id<ANTLRBaseTree>) getChild:(id<ANTLRBaseTree>)aTree At:(NSInteger)i;

- (void) setChild:(id<ANTLRBaseTree>)aTree At:(NSInteger)index Child:(id<ANTLRBaseTree>)aChild;

- (id<ANTLRBaseTree>) deleteChild:(id<ANTLRBaseTree>)aTree Index:(NSInteger)index;

- (NSInteger) getChildCount:(id<ANTLRBaseTree>)aTree;

- (id<ANTLRBaseTree>) getParent:(id<ANTLRBaseTree>) t;

- (void) setParent:(id<ANTLRBaseTree>)t With:(id<ANTLRBaseTree>) parent;

/** What index is this node in the child list? Range: 0..n-1
 *  If your node type doesn't handle this, it's ok but the tree rewrites
 *  in tree parsers need this functionality.
 */
- (NSInteger) getChildIndex:(id)t;
- (void) setChildIndex:(id)t With:(NSInteger)index;

- (void) replaceChildren:(id)parent From:(NSInteger)startChildIndex To:(NSInteger)stopChildIndex With:(id)t;

- (NSInteger) getUniqueID:(id<ANTLRBaseTree>)node;

#ifdef DONTUSENOMO
- (NSInteger) getUniqueID;

- (void) setUniqueNodeID:(NSInteger)aUniqueNodeID;

- (ANTLRUniqueIDMap *)getTreeToUniqueIDMap;

- (void) setTreeToUniqueIDMap:(ANTLRUniqueIDMap *)aMapNode;
#endif

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
- (id<ANTLRToken>)createToken:(NSInteger)aTType Text:(NSString *)theText;

- (id<ANTLRToken>)createToken:(id<ANTLRToken>)aFromToken;

@property (retain) ANTLRUniqueIDMap *treeToUniqueIDMap;
@property (assign) NSInteger uniqueNodeID;

@end
