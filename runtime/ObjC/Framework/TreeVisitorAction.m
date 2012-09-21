//
//  TreeVisitorAction.m
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

#import "TreeVisitorAction.h"


@implementation TreeVisitorAction

+ (TreeVisitorAction *)newTreeVisitorAction
{
    return [[TreeVisitorAction alloc] init];
}

- (id) init
{
    if ((self = [super init]) != nil ) {
        preAction = nil;
        postAction = nil;
    }
    return self;
}

- (void)setPreAction:(SEL)anAction
{
    preAction = anAction;
}

- (void)setPostAction:(SEL)anAction
{
    postAction = anAction;
}

/** Execute an action before visiting children of t.  Return t or
 *  a rewritten t.  It is up to the visitor to decide what to do
 *  with the return value.  Children of returned value will be
 *  visited if using TreeVisitor.visit().
 */
- (id<BaseTree>)pre:(id<BaseTree>) t
{
    if ( (preAction != nil ) && ( [self respondsToSelector:preAction] )) {
        [self performSelector:preAction];
        return t;
    }
    return nil;
}

/** Execute an action after visiting children of t.  Return t or
 *  a rewritten t.  It is up to the visitor to decide what to do
 *  with the return value.
 */
- (id<BaseTree>)post:(id<BaseTree>) t
{
    if ( (postAction != nil ) && ( [self respondsToSelector:postAction] )) {
        [self performSelector:postAction];
        return t;
    }
    return nil;
}

@synthesize preAction;
@synthesize postAction;

@end

@implementation TreeVisitorActionFiltered

+ (TreeVisitorAction *)newTreeVisitorActionFiltered:(TreeFilter *)aFilter
                                              RuleD:(fptr *)aTDRule
                                              RuleU:(fptr *)aBURule
{
    return [[TreeVisitorActionFiltered alloc] initWithFilter:aFilter RuleD:aTDRule RuleU:aBURule];
}

- (id) initWithFilter:(TreeFilter *)aFilter
                RuleD:(fptr *)aTDRule
                RuleU:(fptr *)aBURule
{
    if (( self = [super init] ) != nil ) {
        aTFilter = aFilter;
        TDRule = aTDRule;
        BURule = aBURule;
    }
    return self;
}

/** Execute an action before visiting children of t.  Return t or
 *  a rewritten t.  It is up to the visitor to decide what to do
 *  with the return value.  Children of returned value will be
 *  visited if using TreeVisitor.visit().
 */
- (id<BaseTree>)pre:(id<BaseTree>) t
{
    [aTFilter applyOnce:t rule:(fptr *)TDRule];
    return t;
}

/** Execute an action after visiting children of t.  Return t or
 *  a rewritten t.  It is up to the visitor to decide what to do
 *  with the return value.
 */
- (id<BaseTree>)post:(id<BaseTree>) t
{
    [aTFilter applyOnce:t rule:(fptr *)BURule];
    return t;
}



@synthesize aTFilter;

@end

