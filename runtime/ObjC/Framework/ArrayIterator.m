/*
 * [The "BSD license"]
 *  Copyright (c) 2011 Terence Parr and Alan Condit
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *  3. The name of the author may not be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 *  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 *  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 *  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 *  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 *  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#import "AMutableArray.h"
#import "ArrayIterator.h"
#import "ANTLRRuntimeException.h"

@class AMutableArray;

@implementation ArrayIterator

@synthesize peekObj;
//@synthesize count;
@synthesize index;
@synthesize anArray;


+ (ArrayIterator *) newIterator:(NSArray *)array
{
    return [[ArrayIterator alloc] initWithArray:array];
}

+ (ArrayIterator *) newIteratorForDictKey:(NSDictionary *)dict
{
    return [[ArrayIterator alloc] initWithDictKey:dict];
}

+ (ArrayIterator *) newIteratorForDictObj:(NSDictionary *)dict
{
    return [[ArrayIterator alloc] initWithDictObj:dict];
}

- (id) initWithArray:(NSArray *)array
{
    self=[super init];
    if ( self != nil ) {
        if (![array isKindOfClass:[NSArray class]]) {
                @throw [NSException exceptionWithName:NSInvalidArgumentException
                                               reason:[NSString stringWithFormat:@"ArrayIterator expecting NSArray class but got %@", [array className]]
                                             userInfo:nil];
        }
        anArray = [array retain];
#ifdef DONTUSENOMO
        for (int i = 0; i < [array count]; i++) {
            [anArray addObject:[array objectAtIndex:i]];
            count++;
        }
#endif
        peekObj = nil;
        count = [anArray count];
        index = 0;
    }
    return self;
}

- (id) initWithDictKey:(NSDictionary *)dict
{
    self=[super init];
    if ( self != nil ) {
        if (![dict isKindOfClass:[NSDictionary class]]) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:[NSString stringWithFormat:@"ArrayIterator expecting NSDictionary class but got %@", [dict className]]
                                         userInfo:nil];
        }
        anArray = [[[dict keyEnumerator] allObjects] retain];
        peekObj = nil;
        count = [anArray count];
        index = 0;
    }
    return self;
}

- (id) initWithDictObj:(NSDictionary *)dict
{
    self=[super init];
    if ( self != nil ) {
        if (![dict isKindOfClass:[NSDictionary class]]) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:[NSString stringWithFormat:@"ArrayIterator expecting NSDictionary class but got %@", [dict className]]
                                         userInfo:nil];
        }
        anArray = [[[dict objectEnumerator] allObjects] retain];
        peekObj = nil;
        count = [anArray count];
        index = 0;
    }
    return self;
}

- (void)dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in ArrayIterator" );
#endif
    if ( anArray ) [anArray release];
    [super dealloc];
}

- (BOOL) hasNext
{
    if ( peekObj == nil ) {
        peekObj = [self nextObject];
    }
    return ((peekObj) ? YES : NO);
}

- (NSObject *) nextObject
{
    id obj = nil;
    if ( peekObj ) {
        obj = peekObj;
        peekObj = nil;
        return obj;
    }
    if ( index >= count ) {
        return nil;
    }
    if ( anArray ) {
        obj = [anArray objectAtIndex:index++];
        if ( index >= count ) {
            [anArray release];
            anArray = nil;
            index = 0;
            count = 0;
        }
    }
    return obj;
}

- (NSArray *) allObjects
{
    if ( (count <= 0 || index >= count) && peekObj == nil ) return nil;
    AMutableArray *theArray = [AMutableArray arrayWithCapacity:count];
    if (peekObj) {
        [theArray addObject:peekObj];
        peekObj = nil;
    }
    for (int i = index; i < count; i++) {
        [theArray addObject:[anArray objectAtIndex:i]];
    }
    return [NSArray arrayWithArray:(NSArray *)theArray];
}

- (void) removeObjectAtIndex:(NSInteger)idx
{
    @throw [ANTLRUnsupportedOperationException newException:@"Cant remove object from ArrayIterator"];
}

- (NSInteger) count
{
    return (index - count);
}

- (void) setCount:(NSInteger)cnt
{
    count = cnt;
}

@end
