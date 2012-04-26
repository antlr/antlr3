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

#import <Foundation/Foundation.h>
#import "CommonTree.h"
#import "CommonTreeNodeStream.h"
#import "LookaheadStream.h"
#import "TreeNodeStream.h"
#import "TreeIterator.h"
#import "IntArray.h"

@interface CommonTreeNodeStream : LookaheadStream <TreeNodeStream> {
#define DEFAULT_INITIAL_BUFFER_SIZE 100
#define INITIAL_CALL_STACK_SIZE 10
    
/** Pull nodes from which tree? */
__strong id root;
    
/** If this tree (root) was created from a token stream, track it. */
__strong id <TokenStream> tokens;
    
	/** What tree adaptor was used to build these trees */
__strong CommonTreeAdaptor *adaptor;
    
/** The tree iterator we using */
__strong TreeIterator *it;
    
/** Stack of indexes used for push/pop calls */
__strong IntArray *calls;    
    
/** Tree (nil A B C) trees like flat A B C streams */
BOOL hasNilRoot;
    
/** Tracks tree depth.  Level=0 means we're at root node level. */
NSInteger level;
}
@property (retain, getter=getRoot, setter=setRoot:) CommonTree *root;
@property (retain, getter=getTokens,setter=setTokens:) id<TokenStream> tokens;
@property (retain, getter=getTreeAdaptor, setter=setTreeAdaptor:) CommonTreeAdaptor *adaptor;
@property (assign, getter=getLevel, setter=setLevel:) NSInteger level;

+ (CommonTreeNodeStream *) newCommonTreeNodeStream:(CommonTree *)theTree;
+ (CommonTreeNodeStream *) newCommonTreeNodeStream:(id<TreeAdaptor>)anAdaptor Tree:(CommonTree *)theTree;

- (id) initWithTree:(CommonTree *)theTree;

- (id) initWithTreeAdaptor:(id<TreeAdaptor>)adaptor Tree:(CommonTree *)theTree;
    
- (void) reset;
    
    /** Pull elements from tree iterator.  Track tree level 0..max_level.
     *  If nil rooted tree, don't give initial nil and DOWN nor final UP.
     */
- (id) nextElement;
    
- (BOOL) isEOF:(id<BaseTree>) obj;
- (void) setUniqueNavigationNodes:(BOOL) uniqueNavigationNodes;
    
- (id) getTreeSource;
    
- (NSString *) getSourceName;
    
- (id<TokenStream>) getTokenStream;
    
- (void) setTokenStream:(id<TokenStream>) tokens;
    
- (CommonTreeAdaptor *) getTreeAdaptor;
    
- (void) setTreeAdaptor:(CommonTreeAdaptor *) adaptor;
    
- (CommonTree *)get:(NSInteger) i;

- (NSInteger) LA:(NSInteger) i;
    
    /** Make stream jump to a new location, saving old location.
     *  Switch back with pop().
     */
- (void) push:(NSInteger) index;
    
    /** Seek back to previous index saved during last push() call.
     *  Return top of stack (return index).
     */
- (NSInteger) pop;
    
// TREE REWRITE INTERFACE
    
- (void) replaceChildren:(id)parent From:(NSInteger)startChildIndex To:(NSInteger)stopChildIndex With:(id) t;
    
- (NSString *) toStringFromNode:(id<BaseTree>)startNode ToNode:(id<BaseTree>)stopNode;

/** For debugging; destructive: moves tree iterator to end. */
- (NSString *) toTokenTypeString;

@property (retain) TreeIterator *it;
@property (retain) IntArray *calls;
@property BOOL hasNilRoot;
@end
