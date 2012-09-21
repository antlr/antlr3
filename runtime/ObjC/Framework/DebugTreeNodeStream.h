// [The "BSD licence"]
// Copyright (c) 2006-2007 Kay Roepke
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
#import "DebugEventListener.h"
#import "TreeAdaptor.h"
#import "TreeNodeStream.h"

@interface DebugTreeNodeStream : NSObject <TreeNodeStream> {
	id<DebugEventListener> debugListener;
	id<TreeAdaptor> treeAdaptor;
	id<TreeNodeStream> input;
	BOOL initialStreamState;
}

- (id) initWithTreeNodeStream:(id<TreeNodeStream>)theStream debugListener:(id<DebugEventListener>)debugger;

- (id<DebugEventListener>) debugListener;
- (void) setDebugListener: (id<DebugEventListener>) aDebugListener;

- (id<TreeNodeStream>) input;
- (void) setInput: (id<TreeNodeStream>) aTreeNodeStream;

- (id<TreeAdaptor>) getTreeAdaptor;
- (void) setTreeAdaptor: (id<TreeAdaptor>) aTreeAdaptor;

#pragma mark TreeNodeStream conformance

- (id) LT:(NSInteger)k;
- (id<TreeAdaptor>) getTreeAdaptor;
- (void) setUniqueNavigationNodes:(BOOL)flag;

#pragma mark IntStream conformance
- (void) consume;
- (NSInteger) LA:(NSUInteger) i;
- (NSUInteger) mark;
- (NSUInteger) getIndex;
- (void) rewind:(NSUInteger) marker;
- (void) rewind;
- (void) release:(NSUInteger) marker;
- (void) seek:(NSUInteger) index;
- (NSUInteger) size;

@end
