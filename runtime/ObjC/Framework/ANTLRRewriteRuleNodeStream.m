//
//  ANTLRRewriteRuleNodeStream.m
//  ANTLR
//
//  Created by Kay Röpke on 7/16/07.
//  Copyright 2007 classDump. All rights reserved.
//

#import "ANTLRRewriteRuleNodeStream.h"
#import "ANTLRRuntimeException.h"

@implementation ANTLRRewriteRuleNodeStream

+ (ANTLRRewriteRuleNodeStream*) newANTLRRewriteRuleNodeStream:(id<ANTLRTreeAdaptor>)aTreeAdaptor description:(NSString *)anElementDescription;
{
    return [[ANTLRRewriteRuleNodeStream alloc] initWithTreeAdaptor:aTreeAdaptor description:anElementDescription];
}

+ (ANTLRRewriteRuleNodeStream*) newANTLRRewriteRuleNodeStream:(id<ANTLRTreeAdaptor>)aTreeAdaptor description:(NSString *)anElementDescription element:(id)anElement;
{
    return [[ANTLRRewriteRuleNodeStream alloc] initWithTreeAdaptor:aTreeAdaptor description:anElementDescription element:anElement];
}

+ (ANTLRRewriteRuleNodeStream*) newANTLRRewriteRuleNode:(id<ANTLRTreeAdaptor>)aTreeAdaptor description:(NSString *)anElementDescription elements:(NSArray *)theElements;
{
    return [[ANTLRRewriteRuleNodeStream alloc] initWithTreeAdaptor:aTreeAdaptor description:anElementDescription elements:theElements];
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
    if ((self = [super init]) != nil) {
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

- (id<ANTLRBaseTree>) toTree:(id<ANTLRBaseTree>)element
{
    return [treeAdaptor dupNode:element];
}

- (id) dup:(id)element
{
    return [treeAdaptor dupTree:element];
    @throw [ANTLRRuntimeException newException:@"ANTLRUnsupportedOperationException" reason:@"dup can't be called for a node stream."];
}

@end
