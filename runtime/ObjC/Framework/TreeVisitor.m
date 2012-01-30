//
//  TreeVisitor.m
//  ANTLR
//
//  Created by Alan Condit on 6/18/10.
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

#import "TreeVisitor.h"
#import "CommonTreeAdaptor.h"

@implementation TreeVisitor

+ (TreeVisitor *)newTreeVisitor:(id<TreeAdaptor>)anAdaptor
{
    return [[TreeVisitor alloc] initWithAdaptor:anAdaptor];
}

+ (TreeVisitor *)newTreeVisitor
{
    return [[TreeVisitor alloc] init];
}


- (id)init
{
    if ((self = [super init]) != nil) {
        adaptor = [[CommonTreeAdaptor newTreeAdaptor] retain];
    }
    return self;
}

- (id)initWithAdaptor:(id<TreeAdaptor>)anAdaptor
{
    if ((self = [super init]) != nil) {
        adaptor = [anAdaptor retain];
    }
    return self;
}

- (void) dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in TreeVisitor" );
#endif
    if ( adaptor ) [adaptor release];
    [super dealloc];
}

/** Visit every node in tree t and trigger an action for each node
 *  before/after having visited all of its children.
 *  Execute both actions even if t has no children.
 *  If a child visit yields a new child, it can update its
 *  parent's child list or just return the new child.  The
 *  child update code works even if the child visit alters its parent
 *  and returns the new tree.
 *
 *  Return result of applying post action to this node.
 */
- (id<BaseTree>)visit:(id<BaseTree>)t Action:(TreeVisitorAction *)action
{
    // System.out.println("visit "+((Tree)t).toStringTree());
    BOOL isNil = [adaptor isNil:t];
    if ( action != nil && !isNil ) {
        t = [action pre:(id<BaseTree>)t]; // if rewritten, walk children of new t
    }
    for (int i=0; i < [adaptor getChildCount:t]; i++) {
        id<BaseTree> child = [adaptor getChild:t At:i];
        id<BaseTree> visitResult = [self visit:child Action:action];
        id<BaseTree> childAfterVisit = [adaptor getChild:t At:i];
        if ( visitResult !=  childAfterVisit ) { // result & child differ?
            [adaptor setChild:t At:i Child:visitResult];
        }
    }
    if ( action != nil && !isNil ) t = [action post:(id<BaseTree>)t];
    return t;
}

@synthesize adaptor;
@end
