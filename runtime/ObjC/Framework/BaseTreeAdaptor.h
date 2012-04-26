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

#import <Foundation/Foundation.h>
#import "TreeAdaptor.h"
#import "CommonErrorNode.h"
#import "UniqueIDMap.h"

@interface BaseTreeAdaptor : NSObject <TreeAdaptor, NSCopying> {
    UniqueIDMap *treeToUniqueIDMap;
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
- (id) errorNode:(id<TokenStream>)anInput
            From:(id<Token>)startToken
              To:(id<Token>)stopToken
       Exception:(NSException *) e;

- (BOOL) isNil:(id<BaseTree>) aTree;

- (id<BaseTree>)dupTree:(id<BaseTree>)aTree;

/** This is generic in the sense that it will work with any kind of
 *  tree (not just Tree interface).  It invokes the adaptor routines
 *  not the tree node routines to do the construction.  
 */
- (id<BaseTree>)dupTree:(id<BaseTree>)aTree Parent:(id<BaseTree>)parent;
- (id<BaseTree>)dupNode:(id<BaseTree>)aNode;
/** Add a child to the tree t.  If child is a flat tree (a list), make all
 *  in list children of t.  Warning: if t has no children, but child does
 *  and child isNil then you can decide it is ok to move children to t via
 *  t.children = child.children; i.e., without copying the array.  Just
 *  make sure that this is consistent with have the user will build
 *  ASTs.
 */
- (void) addChild:(id<BaseTree>)aChild toTree:(id<BaseTree>)aTree;

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
- (id<BaseTree>)becomeRoot:(id<BaseTree>)aNewRoot old:(id<BaseTree>)oldRoot;

/** Transform ^(nil x) to x and nil to null */
- (id<BaseTree>)rulePostProcessing:(id<BaseTree>)aRoot;

- (id<BaseTree>)becomeRootfromToken:(id<Token>)aNewRoot old:(id<BaseTree>)oldRoot;

- (id<BaseTree>) create:(id<Token>)payload;
- (id<BaseTree>) createTree:(NSInteger)aTType FromToken:(id<Token>)aFromToken;
- (id<BaseTree>) createTree:(NSInteger)aTType FromToken:(id<Token>)aFromToken Text:(NSString *)theText;
- (id<BaseTree>) createTree:(NSInteger)aTType Text:(NSString *)theText;

- (NSInteger) getType:(id<BaseTree>)aTree;

- (void) setType:(id<BaseTree>)aTree Type:(NSInteger)type;

- (id<Token>)getToken:(CommonTree *)t;

- (NSString *)getText:(CommonTree *)aTree;

- (void) setText:(id<BaseTree>)aTree Text:(NSString *)theText;

- (id<BaseTree>) getChild:(id<BaseTree>)aTree At:(NSInteger)i;

- (void) setChild:(id<BaseTree>)aTree At:(NSInteger)index Child:(id<BaseTree>)aChild;

- (id<BaseTree>) deleteChild:(id<BaseTree>)aTree Index:(NSInteger)index;

- (NSInteger) getChildCount:(id<BaseTree>)aTree;

- (id<BaseTree>) getParent:(id<BaseTree>) t;

- (void) setParent:(id<BaseTree>)t With:(id<BaseTree>) parent;

/** What index is this node in the child list? Range: 0..n-1
 *  If your node type doesn't handle this, it's ok but the tree rewrites
 *  in tree parsers need this functionality.
 */
- (NSInteger) getChildIndex:(id)t;
- (void) setChildIndex:(id)t With:(NSInteger)index;

- (void) replaceChildren:(id)parent From:(NSInteger)startChildIndex To:(NSInteger)stopChildIndex With:(id)t;

- (NSInteger) getUniqueID:(id<BaseTree>)node;

#ifdef DONTUSENOMO
- (NSInteger) getUniqueID;

- (void) setUniqueNodeID:(NSInteger)aUniqueNodeID;

- (UniqueIDMap *)getTreeToUniqueIDMap;

- (void) setTreeToUniqueIDMap:(UniqueIDMap *)aMapNode;
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
- (id<Token>)createToken:(NSInteger)aTType Text:(NSString *)theText;

- (id<Token>)createToken:(id<Token>)aFromToken;

@property (retain) UniqueIDMap *treeToUniqueIDMap;
@property (assign) NSInteger uniqueNodeID;

@end
