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

#import "ANTLRRewriteRuleElementStream.h"

@implementation ANTLRRewriteRuleElementStream

@synthesize cursor;
@synthesize dirty;
@synthesize isSingleElement;
@synthesize elements;
@synthesize elementDescription;
@synthesize treeAdaptor;

+ (ANTLRRewriteRuleElementStream *) newANTLRRewriteRuleElementStream:(id<ANTLRTreeAdaptor>)aTreeAdaptor
                                                         description:(NSString *)anElementDescription
{
    return [[ANTLRRewriteRuleElementStream alloc] initWithTreeAdaptor:aTreeAdaptor
                                                          description:anElementDescription];
}

+ (ANTLRRewriteRuleElementStream *) newANTLRRewriteRuleElementStream:(id<ANTLRTreeAdaptor>)aTreeAdaptor
                                                         description:(NSString *)anElementDescription
                                                             element:(id)anElement
{
    return [[ANTLRRewriteRuleElementStream alloc] initWithTreeAdaptor:aTreeAdaptor
                                                          description:anElementDescription
                                                              element:anElement];
}

+ (ANTLRRewriteRuleElementStream *) newANTLRRewriteRuleElementStream:(id<ANTLRTreeAdaptor>)aTreeAdaptor
                                                         description:(NSString *)anElementDescription
                                                            elements:(NSArray *)theElements;
{
    return [[ANTLRRewriteRuleElementStream alloc] initWithTreeAdaptor:aTreeAdaptor
                                                          description:anElementDescription
                                                             elements:theElements];
}

- (id) initWithTreeAdaptor:(id<ANTLRTreeAdaptor>)aTreeAdaptor description:(NSString *)anElementDescription
{
    if ((self = [super init]) != nil) {
        cursor = 0;
        dirty = NO;
        [self setDescription:anElementDescription];
        [self setTreeAdaptor:aTreeAdaptor];
        dirty = NO;
        isSingleElement = YES;
    }
    return self;
}

- (id) initWithTreeAdaptor:(id<ANTLRTreeAdaptor>)aTreeAdaptor description:(NSString *)anElementDescription element:(id)anElement
{
    if ((self = [super init]) != nil) {
        cursor = 0;
        dirty = NO;
        [self setDescription:anElementDescription];
        [self setTreeAdaptor:aTreeAdaptor];
        dirty = NO;
        isSingleElement = YES;
        [self addElement:anElement];
    }
    return self;
}

- (id) initWithTreeAdaptor:(id<ANTLRTreeAdaptor>)aTreeAdaptor description:(NSString *)anElementDescription elements:(NSArray *)theElements
{
    self = [super init];
    if (self) {
        cursor = 0;
        dirty = NO;
        [self setDescription:anElementDescription];
        [self setTreeAdaptor:aTreeAdaptor];
        dirty = NO;
        isSingleElement = NO;
        elements.multiple = [[NSMutableArray alloc] initWithArray:theElements];
    }
    return self;
}

- (void) dealloc
{
    if (isSingleElement)
        [elements.single release];
    else
        [elements.multiple release];
    [self setDescription:nil];
    [self setTreeAdaptor:nil];
    [super dealloc];
}

- (void)reset
{
    cursor = 0;
    dirty = YES;
}

- (id<ANTLRTreeAdaptor>) getTreeAdaptor
{
    return treeAdaptor;
}

- (void) setTreeAdaptor:(id<ANTLRTreeAdaptor>)aTreeAdaptor
{
    if (treeAdaptor != aTreeAdaptor) {
        [treeAdaptor release];
        [treeAdaptor retain];
        treeAdaptor = aTreeAdaptor;
    }
}

- (void) addElement: (id)anElement
{
    if (anElement == nil)
        return;
    if (isSingleElement) {
        
        if (elements.single == nil) {
            elements.single = [anElement retain];
            elements.single = anElement;
            return;
        }
        isSingleElement = NO;
        NSMutableArray *newArray = [[NSMutableArray arrayWithCapacity:5] retain];
        [newArray addObject:elements.single];
        // [elements.single release];  // balance previous retain in initializer/addElement
        [newArray addObject:anElement];
        elements.multiple = newArray;
    } else {
        [elements.multiple addObject:anElement];
    }
}

- (void) setElement: (id)anElement
{
    if (anElement == nil)
        return;
    if (isSingleElement) {
        if (elements.single == nil) {
            elements.single = [anElement retain];
            elements.single = anElement;
            return;
        }
        isSingleElement = NO;
        NSMutableArray *newArray = [[NSMutableArray arrayWithCapacity:5] retain];
        [newArray addObject:elements.single];
        // [elements.single release];  // balance previous retain in initializer/addElement
        [newArray addObject:anElement];
        elements.multiple = newArray;
    } else {
        [elements.multiple addObject:anElement];
    }
}

- (NSInteger) size
{
    if (isSingleElement && elements.single != nil)
        return 1;
    if (isSingleElement == NO && elements.multiple != nil)
        return [elements.multiple count];
    return 0;
}

- (BOOL) hasNext
{
    return (isSingleElement && elements.single != nil && cursor < 1) ||
            (isSingleElement == NO && elements.multiple != nil && cursor < [elements.multiple count]);
}

- (id<ANTLRTree>) nextTree
{
    NSInteger n = [self size];
    if ( dirty && (cursor >= 0 && n == 1)) {
        // if out of elements and size is 1, dup
        id element = [self _next];
        return [self copyElement:element];
    }
    // test size above then fetch
    id element = [self _next];
    return element;
}

- (id) _next       // internal: TODO: redesign if necessary. maybe delegate
{
    NSInteger n = [self size];
    if (n == 0) {
        @throw [NSException exceptionWithName:@"RewriteEmptyStreamException" reason:nil userInfo:nil];// TODO: fill in real exception
    }
    if ( cursor >= n ) {
        if ( n == 1 ) {
            return [self toTree:elements.single]; // will be dup'ed in -next
        }
        @throw [NSException exceptionWithName:@"RewriteCardinalityException" reason:nil userInfo:nil];// TODO: fill in real exception
    }
    if (isSingleElement && elements.single != nil) {
        cursor++;
        return [self toTree:elements.single];
    }
    id el = [elements.multiple objectAtIndex:cursor];
    cursor++;
    return [self toTree:el];
}

- (id) copyElement:(id)element
{
    [self doesNotRecognizeSelector:_cmd];   // subclass responsibility
    return nil;
}

- (id<ANTLRTree>) toTree:(id)element
{
    return element;
}

- (NSString *) getDescription
{
    return elementDescription;
}

- (void) setDescription:(NSString *) description
{
    if ( description != nil && description != elementDescription ) {
        if (elementDescription != nil) [elementDescription release];
        elementDescription = [NSString stringWithString:description];
        [description release];
    }
}

@end
