//
//  ANTLRRewriteRuleTokenStream.m
//  ANTLR
//
//  Created by Kay Röpke on 7/16/07.
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

#import "ANTLRRewriteRuleTokenStream.h"
#import "ANTLRRuntimeException.h"
#import "ANTLRHashMap.h"
#import "ANTLRMapElement.h"

@implementation ANTLRRewriteRuleTokenStream

+ (id) newANTLRRewriteRuleTokenStream:(id<ANTLRTreeAdaptor>)anAdaptor
                          description:(NSString *)elementDescription
{
    return [[ANTLRRewriteRuleTokenStream alloc] initWithTreeAdaptor:anAdaptor
                                                        description:elementDescription];
}

/** Create a stream with one element */
+ (id) newANTLRRewriteRuleTokenStream:(id<ANTLRTreeAdaptor>)adaptor
                          description:(NSString *)elementDescription
                              element:(id) oneElement
{
    return [[ANTLRRewriteRuleTokenStream alloc] initWithTreeAdaptor:adaptor
                                                        description:elementDescription
                                                            element:oneElement];
}

/** Create a stream, but feed off an existing list */
+ (id) newANTLRRewriteRuleTokenStream:(id<ANTLRTreeAdaptor>)adaptor
                          description:(NSString *)elementDescription
                             elements:(AMutableArray *)elements
{
    return [[ANTLRRewriteRuleTokenStream alloc] initWithTreeAdaptor:adaptor
                                                        description:elementDescription
                                                           elements:elements];
}

- (id) init
{
    if ((self = [super init]) != nil ) {
    }
    return self;
}

- (id) initWithTreeAdaptor:(id<ANTLRTreeAdaptor>)anAdaptor
               description:(NSString *)aDescription
{
    if ((self = [super initWithTreeAdaptor:anAdaptor
                               description:aDescription]) != nil ) {
    }
    return self;
}

- (id) initWithTreeAdaptor:(id<ANTLRTreeAdaptor>)anAdaptor
               description:(NSString *)aDescription
                   element:(id)anElement
{
    if ((self = [super initWithTreeAdaptor:anAdaptor
                               description:aDescription
                                   element:anElement]) != nil ) {
    }
    return self;
}

- (id) initWithTreeAdaptor:(id<ANTLRTreeAdaptor>)anAdaptor
               description:(NSString *)aDescription
                  elements:(AMutableArray *)elementList
{
    if ((self = [super initWithTreeAdaptor:anAdaptor
                               description:aDescription
                                  elements:elementList]) != nil ) {
    }
    return self;
}

- (id<ANTLRBaseTree>) nextNode
{
    id<ANTLRToken> t = [self _next];
    return [treeAdaptor create:t];
}

- (id) nextToken
{
    return [self _next];
}

/** Don't convert to a tree unless they explicitly call nextTree.
 *  This way we can do hetero tree nodes in rewrite.
 */
- (id<ANTLRBaseTree>) toTree:(id<ANTLRToken>)element
{
    return element;
}

- (id) copyElement:(id)element
{
    @throw [ANTLRRuntimeException newException:@"copy can't be called for a token stream."];
}

@end
