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

#import "ANTLRCommonTreeNodeStream.h"
#import "ANTLRTokenStream.h"
#import "ANTLRIntStream.h"
#import "ANTLRCharStream.h"

@implementation ANTLRCommonTreeNodeStream

@synthesize root;
@synthesize tokens;
@synthesize adaptor;
@synthesize level;

+ (ANTLRCommonTreeNodeStream *) newANTLRCommonTreeNodeStream:(ANTLRCommonTree *)theTree
{
    return [[ANTLRCommonTreeNodeStream alloc] initWithTree:theTree];
}

+ (ANTLRCommonTreeNodeStream *) newANTLRCommonTreeNodeStream:(id<ANTLRTreeAdaptor>)anAdaptor Tree:(ANTLRCommonTree *)theTree
{
    return [[ANTLRCommonTreeNodeStream alloc] initWithTreeAdaptor:anAdaptor Tree:theTree];
}

- (id) initWithTree:(ANTLRCommonTree *)theTree
{
    if ((self = [super init]) != nil ) {
        root = theTree;
        adaptor = [ANTLRCommonTreeAdaptor newTreeAdaptor];
        it = [ANTLRTreeIterator newANTRLTreeIteratorWithAdaptor:adaptor andTree:root];
        calls = [ANTLRIntArray newArrayWithLen:INITIAL_CALL_STACK_SIZE];
        /** Tree (nil A B C) trees like flat A B C streams */
        hasNilRoot = NO;
        level = 0;
    }
    return self;
}

- (id) initWithTreeAdaptor:(id<ANTLRTreeAdaptor>)anAdaptor Tree:(ANTLRCommonTree *)theTree
{
    if ((self = [super init]) != nil ) {
        [adaptor createTree:ANTLRTokenTypeEOF Text:@"EOF"]; // set EOF
        root = theTree;
        adaptor = anAdaptor;
        //    it = [root objectEnumerator];
        it = [ANTLRTreeIterator newANTRLTreeIteratorWithAdaptor:adaptor andTree:root];
        calls = [ANTLRIntArray newArrayWithLen:INITIAL_CALL_STACK_SIZE];
        /** Tree (nil A B C) trees like flat A B C streams */
        hasNilRoot = NO;
        level = 0;
    }
    //    eof = [self isEOF]; // make sure tree iterator returns the EOF we want
    return self;
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

- (BOOL) isEOF:(id<ANTLRTree>) aTree
{
    return [adaptor getType:aTree] == ANTLRTokenTypeEOF;
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

- (id<ANTLRTokenStream>) getTokenStream
{
    return tokens;
}

- (void) setTokenStream:(id<ANTLRTokenStream>)theTokens
{
    tokens = theTokens;
}

- (ANTLRCommonTreeAdaptor *) getTreeAdaptor
{
    return adaptor;
}

- (void) setTreeAdaptor:(ANTLRCommonTreeAdaptor *) anAdaptor
{
    adaptor = anAdaptor;
}

- (ANTLRCommonTree *)getNode:(NSInteger) i
{
    @throw [ANTLRRuntimeException newANTLRRuntimeException:@"Absolute node indexes are meaningless in an unbuffered stream"];
    return nil;
}

- (NSInteger) LA:(NSInteger) i
{
    return [adaptor getType:[self LT:i]];
}

/** Make stream jump to a new location, saving old location.
 *  Switch back with pop().
 */
- (void) push:(NSInteger) index
{
    if ( calls == nil ) {
        calls = [ANTLRIntArray newArrayWithLen:INITIAL_CALL_STACK_SIZE];
    }
    [calls push:p]; // save current index
    [self seek:index];
}

/** Seek back to previous index saved during last push() call.
 *  Return top of stack (return index).
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

- (NSString *) toStringFromNode:(id<ANTLRTree>)startNode ToNode:(id<ANTLRTree>)stopNode
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
    id o = [self LT:1];
    NSInteger type = [adaptor getType:o];
    while ( type != ANTLRTokenTypeEOF ) {
        [buf appendString:@" "];
        [buf appendString:[NSString stringWithFormat:@"%d", type]];
        [self consume];
        o = [self LT:1];
        type = [adaptor getType:o];
    }
    return buf;
}

@end

