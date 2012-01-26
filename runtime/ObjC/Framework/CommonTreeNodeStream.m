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

#import "CommonTreeNodeStream.h"
#import "TokenStream.h"
#import "IntStream.h"
#import "CharStream.h"
#import "AMutableArray.h"
#import "CommonTreeAdaptor.h"

#ifndef DEBUG_DEALLOC
#define DEBUG_DEALLOC
#endif

@implementation CommonTreeNodeStream

@synthesize root;
@synthesize tokens;
@synthesize adaptor;
@synthesize level;

+ (CommonTreeNodeStream *) newCommonTreeNodeStream:(CommonTree *)theTree
{
    return [[CommonTreeNodeStream alloc] initWithTree:theTree];
}

+ (CommonTreeNodeStream *) newCommonTreeNodeStream:(id<TreeAdaptor>)anAdaptor Tree:(CommonTree *)theTree
{
    return [[CommonTreeNodeStream alloc] initWithTreeAdaptor:anAdaptor Tree:theTree];
}

- (id) initWithTree:(CommonTree *)theTree
{
    if ((self = [super init]) != nil ) {
        adaptor = [[CommonTreeAdaptor newTreeAdaptor] retain];
        root = [theTree retain];
        navigationNodeEOF = [[adaptor createTree:TokenTypeEOF Text:@"EOF"] retain]; // set EOF
        it = [[TreeIterator newANTRLTreeIteratorWithAdaptor:adaptor andTree:root] retain];
        calls = [[IntArray newArrayWithLen:INITIAL_CALL_STACK_SIZE] retain];
        /** Tree (nil A B C) trees like flat A B C streams */
        hasNilRoot = NO;
        level = 0;
    }
    return self;
}

- (id) initWithTreeAdaptor:(id<TreeAdaptor>)anAdaptor Tree:(CommonTree *)theTree
{
    if ((self = [super init]) != nil ) {
        adaptor = [anAdaptor retain];
        root = [theTree retain];
        navigationNodeEOF = [[adaptor createTree:TokenTypeEOF Text:@"EOF"] retain]; // set EOF
        //    it = [root objectEnumerator];
        it = [[TreeIterator newANTRLTreeIteratorWithAdaptor:adaptor andTree:root] retain];
        calls = [[IntArray newArrayWithLen:INITIAL_CALL_STACK_SIZE] retain];
        /** Tree (nil A B C) trees like flat A B C streams */
        hasNilRoot = NO;
        level = 0;
    }
    //    eof = [self isEOF]; // make sure tree iterator returns the EOF we want
    return self;
}

- (void)dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in CommonTreeNodeStream" );
#endif
    if ( root ) [root release];
    if ( tokens ) [tokens release];
    if ( adaptor ) [adaptor release];
    if ( it ) [it release];
    if ( calls ) [calls release];    
    [super dealloc];
}

- (void) reset
{
    [super reset];
    [it reset];
    hasNilRoot = false;
    level = 0;
    if ( calls != nil )
        [calls reset];  // [calls clear]; // in Java
}

/** Pull elements from tree iterator.  Track tree level 0..max_level.
 *  If nil rooted tree, don't give initial nil and DOWN nor final UP.
 */
- (id) nextElement
{
    id t = [it nextObject];
    //System.out.println("pulled "+adaptor.getType(t));
    if ( t == [it up] ) {
        level--;
        if ( level==0 && hasNilRoot ) return [it nextObject]; // don't give last UP; get EOF
    }
    else if ( t == [it down] )
        level++;
    if ( level == 0 && [adaptor isNil:t] ) { // if nil root, scarf nil, DOWN
        hasNilRoot = true;
        t = [it nextObject]; // t is now DOWN, so get first real node next
        level++;
        t = [it nextObject];
    }
    return t;
}

- (BOOL) isEOF:(id<BaseTree>) aTree
{
    return [adaptor getType:(CommonTree *)aTree] == TokenTypeEOF;
}

- (void) setUniqueNavigationNodes:(BOOL) uniqueNavigationNodes
{
}

- (id) getTreeSource
{
    return root;
}

- (NSString *) getSourceName
{
    return [[self getTokenStream] getSourceName];
}

- (id<TokenStream>) getTokenStream
{
    return tokens;
}

- (void) setTokenStream:(id<TokenStream>)theTokens
{
    if ( tokens != theTokens ) {
        if ( tokens ) [tokens release];
        [theTokens retain];
    }
    tokens = theTokens;
}

- (CommonTreeAdaptor *) getTreeAdaptor
{
    return adaptor;
}

- (void) setTreeAdaptor:(CommonTreeAdaptor *) anAdaptor
{
    if ( adaptor != anAdaptor ) {
        if ( adaptor ) [adaptor release];
        [anAdaptor retain];
    }
    adaptor = anAdaptor;
}

- (CommonTree *)getNode:(NSInteger) i
{
    @throw [RuntimeException newException:@"Absolute node indexes are meaningless in an unbuffered stream"];
    return nil;
}

- (NSInteger) LA:(NSInteger) i
{
    return [adaptor getType:[self LT:i]];
}

/** Make stream jump to a new location, saving old location.
 *  Switch back with pop().
 */
- (void) push:(NSInteger) anIndex
{
    if ( calls == nil ) {
        calls = [[IntArray newArrayWithLen:INITIAL_CALL_STACK_SIZE] retain];
    }
    [calls push:p]; // save current anIndex
    [self seek:anIndex];
}

/** Seek back to previous anIndex saved during last push() call.
 *  Return top of stack (return anIndex).
 */
- (NSInteger) pop
{
    int ret = [calls pop];
    [self seek:ret];
    return ret;
}    

// TREE REWRITE INTERFACE

- (void) replaceChildren:(id) parent From:(NSInteger)startChildIndex To:(NSInteger)stopChildIndex With:(id) aTree
{
    if ( parent != nil ) {
        [adaptor replaceChildren:parent From:startChildIndex To:stopChildIndex With:aTree];
    }
}

- (NSString *) toStringFromNode:(id<BaseTree>)startNode ToNode:(id<BaseTree>)stopNode
{
    // we'll have to walk from start to stop in tree; we're not keeping
    // a complete node stream buffer
    return @"n/a";
}

/** For debugging; destructive: moves tree iterator to end. */
- (NSString *) toTokenTypeString
{
    [self reset];
    NSMutableString *buf = [NSMutableString stringWithCapacity:5];
    id obj = [self LT:1];
    NSInteger type = [adaptor getType:obj];
    while ( type != TokenTypeEOF ) {
        [buf appendString:@" "];
        [buf appendString:[NSString stringWithFormat:@"%d", type]];
        [self consume];
        obj = [self LT:1];
        type = [adaptor getType:obj];
    }
    return buf;
}

@synthesize it;
@synthesize calls;
@synthesize hasNilRoot;
@end

