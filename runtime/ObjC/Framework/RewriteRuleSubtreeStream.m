//
//  ANTLRRewriteRuleSubtreeStream.m
//  ANTLR
//
//  Created by Kay Röpke on 7/16/07.
// [The "BSD licence"]
// Copyright (c) 2007 Kay Röpke 2010 Alan Condit
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

#import "ANTLRRewriteRuleSubtreeStream.h"


@implementation ANTLRRewriteRuleSubtreeStream

+ (ANTLRRewriteRuleSubtreeStream*) newANTLRRewriteRuleSubtreeStream:(id<ANTLRTreeAdaptor>)aTreeAdaptor
                                                        description:(NSString *)anElementDescription;
{
    return [[ANTLRRewriteRuleSubtreeStream alloc] initWithTreeAdaptor:aTreeAdaptor
                                                          description:anElementDescription];
}

+ (ANTLRRewriteRuleSubtreeStream*) newANTLRRewriteRuleSubtreeStream:(id<ANTLRTreeAdaptor>)aTreeAdaptor
                                                        description:(NSString *)anElementDescription
                                                            element:(id)anElement;
{
    return [[ANTLRRewriteRuleSubtreeStream alloc] initWithTreeAdaptor:aTreeAdaptor
                                                          description:anElementDescription
                                                              element:anElement];
}

+ (ANTLRRewriteRuleSubtreeStream*) newANTLRRewriteRuleSubtreeStream:(id<ANTLRTreeAdaptor>)aTreeAdaptor
                                                        description:(NSString *)anElementDescription
                                                           elements:(NSArray *)theElements;
{
    return [[ANTLRRewriteRuleSubtreeStream alloc] initWithTreeAdaptor:aTreeAdaptor
                                                          description:anElementDescription
                                                             elements:theElements];
}

- (id) initWithTreeAdaptor:(id<ANTLRTreeAdaptor>)aTreeAdaptor description:(NSString *)anElementDescription
{
    if ((self = [super initWithTreeAdaptor:aTreeAdaptor description:anElementDescription]) != nil) {
        dirty = NO;
        isSingleElement = YES;
    }
    return self;
}

- (id) initWithTreeAdaptor:(id<ANTLRTreeAdaptor>)aTreeAdaptor description:(NSString *)anElementDescription element:(id)anElement
{
    if ((self = [super initWithTreeAdaptor:aTreeAdaptor description:anElementDescription element:anElement]) != nil) {
        dirty = NO;
    }
    return self;
}

- (id) initWithTreeAdaptor:(id<ANTLRTreeAdaptor>)aTreeAdaptor description:(NSString *)anElementDescription elements:(NSArray *)theElements
{
    if ((self = [super initWithTreeAdaptor:aTreeAdaptor description:anElementDescription elements:theElements]) != nil) {
        dirty = NO;
    }
    return self;
}


- (id) nextNode
{
    if (dirty || (cursor >= [self size] && [self size] == 1))
        return [treeAdaptor dupNode:[self _next]];
    else 
        return [self _next];
}

- (id) dup:(id)element
{
    return [treeAdaptor dupTree:element];
}

@end
