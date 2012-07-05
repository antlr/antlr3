//
//  MapElement.m
//  ANTLR
//
//  Created by Alan Condit on 6/8/10.
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

#import <Foundation/Foundation.h>
#import "MapElement.h"


@implementation MapElement

@synthesize name;
@synthesize node;

+ (id) newMapElement
{
    return [[MapElement alloc] init];
}

+ (id) newMapElementWithName:(NSString *)aName Type:(NSInteger)aTType
{
    return [[MapElement alloc] initWithName:aName Type:aTType];
}

+ (id) newMapElementWithNode:(NSInteger)aTType Node:(id)aNode
{
    return [[MapElement alloc] initWithNode:aTType Node:aNode];
}

+ (id) newMapElementWithName:(NSString *)aName Node:(id)aNode
{
    return [[MapElement alloc] initWithName:aName Node:aNode];
}

+ (id) newMapElementWithObj1:(id)anObj1 Obj2:(id)anObj2
{
    return [[MapElement alloc] initWithObj1:anObj1 Obj2:anObj2];
}

- (id) init
{
    self = [super init];
    if ( self != nil ) {
        index = nil;
        name  = nil;
    }
    return self;
}

- (id) initWithName:(NSString *)aName Type:(NSInteger)aTType
{
    self = [super init];
    if ( self != nil ) {
        index = [[ACNumber numberWithInteger: aTType] retain];
        name  = [[NSString stringWithString:aName] retain];
    }
    return self;
}

- (id) initWithNode:(NSInteger)aTType Node:(id)aNode
{
    self = [super initWithAnIndex:[ACNumber numberWithInteger:aTType]];
    if ( self != nil ) {
        node  = aNode;
        if ( node ) [node retain];
    }
    return self;
}

- (id) initWithName:(NSString *)aName Node:(id)aNode
{
    self = [super init];
    if ( self != nil ) {
        name  = [[NSString stringWithString:aName] retain];
        node = aNode;
        if ( node ) [node retain];
    }
    return self;
}

- (id) initWithObj1:(id)anIndex Obj2:(id)aNode
{
    self = [super initWithAnIndex:anIndex];
    if ( self != nil ) {
        node = aNode;
        if ( node ) [node retain];
    }
    return self;
}

- (void) dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in MapElement" );
#endif
    if ( name ) [name release];
    if ( node ) [node release];
    [super dealloc];
}

- (id) copyWithZone:(NSZone *)aZone
{
    MapElement *copy;

    copy = [super copyWithZone:aZone];
    if (name) copy.name = name;
    if (node) copy.node = node;
    return( copy );
}

- (NSInteger) count
{
    NSInteger aCnt = 0;
    if (name != nil) aCnt++;;
    if (node != nil) aCnt++;;
    return aCnt;
}

- (NSInteger)size
{
    NSInteger aSize = 0;
    if ( name ) aSize += sizeof(id);
    if ( node ) aSize += sizeof(id);
    return aSize;
}


- (NSString *)getName
{
    return name;
}

- (void)setName:(NSString *)aName
{
    if ( aName != name ) {
        if ( name ) [name release];
        [aName retain];
    }
    name = aName;
}

- (id)getNode
{
    return node;
}

- (void)setNode:(id)aNode
{   if ( aNode != node ) {
        if ( node ) [node release];
        [aNode retain];
    }
    node = aNode;
}

- (void)putNode:(id)aNode
{
    index = ((MapElement *)aNode).index;
    if (((MapElement *)aNode).name) {
        name = [((MapElement *)aNode).name retain];
        node = nil;
    }
    if (((MapElement *)aNode).node) {
        name = nil;
        node = [((MapElement *)aNode).node retain];
    }
}

- (void)putNode:(id)aNode With:(NSInteger)uniqueID
{
    index = ((MapElement *)aNode).index;
    if (((MapElement *)aNode).name) {
        name = [((MapElement *)aNode).name retain];
        node = nil;
    }
    if (((MapElement *)aNode).node) {
        name = nil;
        node = [((MapElement *)aNode).node retain];
    }
}

@end
