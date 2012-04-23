//
//  TreeIterator.h
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

#import <Foundation/Foundation.h>
#import "CommonTreeAdaptor.h"
#import "FastQueue.h"
#import "TreeAdaptor.h"
#import "Tree.h"

@interface TreeIterator : NSObject 
{
	BOOL firstTime;
	__strong id<TreeAdaptor> adaptor;
	__strong id<BaseTree> root;
	__strong id<BaseTree> tree;
	
	__strong FastQueue *nodes;
	__strong id<BaseTree> up;
	__strong id<BaseTree> down;
	__strong id<BaseTree> eof;
}

@property BOOL firstTime;
@property(retain) id<TreeAdaptor> adaptor;
@property(retain) id<BaseTree> root;
@property(retain) id<BaseTree> tree;
@property(retain) FastQueue *nodes;
@property(retain, readwrite) id<BaseTree> up;
@property(retain, readwrite) id<BaseTree> down;
@property(retain, readwrite) id<BaseTree> eof;

+ newANTRLTreeIterator;
+ (TreeIterator *) newANTRLTreeIteratorWithAdaptor:(CommonTreeAdaptor *)adaptor
                                                andTree:(id<BaseTree>)tree;
- (id) init;
- (id) initWithTree:(id<BaseTree>) t;
- (id) initWithTreeAdaptor:(id<TreeAdaptor>) a andTree:(id<BaseTree>) t;

- (void) reset;
- (BOOL) hasNext;
- (id) nextObject;
- (NSArray *) allObjects;

@end
