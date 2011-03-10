//
//  ANTLRTreeIterator.h
//  ANTLR
//
//  Created by Ian Michell on 26/04/2010.
// [The "BSD licence"]
// Copyright (c) 2010 Ian Michell 2010 Alan Condit
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
#import "ANTLRCommonTreeAdaptor.h"
#import "ANTLRFastQueue.h"
#import "ANTLRTreeAdaptor.h"
#import "ANTLRTree.h"

@interface ANTLRTreeIterator : NSObject 
{
	id<ANTLRTreeAdaptor> adaptor;
	id<ANTLRTree> root;
	id<ANTLRTree> tree;
	BOOL firstTime;
	id<ANTLRTree> up;
	id<ANTLRTree> down;
	id<ANTLRTree> eof;
	
	ANTLRFastQueue *nodes;
}

@property(retain, readwrite) id<ANTLRTree> up;
@property(retain, readwrite) id<ANTLRTree> down;
@property(retain, readwrite) id<ANTLRTree> eof;

+ newANTRLTreeIterator;
+ (ANTLRTreeIterator *) newANTRLTreeIteratorWithAdaptor:(ANTLRCommonTreeAdaptor *)adaptor
                                                andTree:(id<ANTLRTree>)tree;
- (id) init;
- (id) initWithTree:(id<ANTLRTree>) t;
- (id) initWithTreeAdaptor:(id<ANTLRTreeAdaptor>) a andTree:(id<ANTLRTree>) t;

- (void) reset;
- (BOOL) hasNext;
- (id) nextObject;
- (NSArray *) allObjects;

@end
