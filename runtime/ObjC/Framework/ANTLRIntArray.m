//
//  ANTLRIntArray.m
//  ANTLR
//
//  Created by Ian Michell on 27/04/2010.
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

#import "ANTLRIntArray.h"
#import "ANTLRRuntimeException.h"

@implementation ANTLRIntArray

@synthesize BuffSize;
@synthesize count;
@synthesize idx;
@synthesize buffer;
@synthesize intBuffer;
@synthesize SPARSE;

+ (ANTLRIntArray *)newArray
{
    return [[ANTLRIntArray alloc] init];
}

+ (ANTLRIntArray *)newArrayWithLen:(NSUInteger)aLen
{
    return [[ANTLRIntArray alloc] initWithLen:aLen];
}

- (id)init
{
    self = [super init];
    if ( self != nil ) {
        BuffSize  = (ANTLR_INT_ARRAY_INITIAL_SIZE * (sizeof(NSInteger)/sizeof(id)));
        count = 0;
        idx = -1;
        buffer = [[NSMutableData dataWithLength:(NSUInteger)BuffSize * sizeof(id)] retain];
        intBuffer = (NSInteger *)[buffer mutableBytes];
        SPARSE = NO;
    }
    return self;
}

- (id)initWithLen:(NSUInteger)aLen
{
    self = [super init];
    if ( self != nil ) {
        BuffSize  = (ANTLR_INT_ARRAY_INITIAL_SIZE * (sizeof(NSInteger)/sizeof(id)));
        count = 0;
        idx = -1;
        buffer = [[NSMutableData dataWithLength:(NSUInteger)BuffSize * sizeof(id)] retain];
        intBuffer = (NSInteger *)[buffer mutableBytes];
        SPARSE = NO;
    }
    return self;
}

- (void)dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in ANTLRIntArray" );
#endif
    if ( buffer ) [buffer release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)aZone
{
    ANTLRIntArray *copy;
    
    copy = [[[self class] alloc] initWithLen:BuffSize];
    copy.idx = self.idx;
    NSInteger anIndex;
    for ( anIndex = 0; anIndex < BuffSize; anIndex++ ) {
        [copy addInteger:intBuffer[anIndex]];
    }
    return copy;
}

- (NSUInteger)count
{
    return count;
}

// FIXME: Java runtime returns p, I'm not so sure it's right so have added p + 1 to show true size!
- (NSUInteger)size
{
    if ( count > 0 )
        return ( count * sizeof(NSInteger));
    return 0;
}

- (void)addInteger:(NSInteger) value
{
    [self ensureCapacity:idx+1];
    intBuffer[++idx] = (NSInteger) value;
    count++;
}

- (NSInteger)pop
{
    if ( idx < 0 ) {
        @throw [ANTLRIllegalArgumentException newException:[NSString stringWithFormat:@"Nothing to pop, count = %d", count]];
    }
    NSInteger value = (NSInteger) intBuffer[idx--];
    count--;
    return value;
}

- (void)push:(NSInteger)aValue
{
    [self addInteger:aValue];
}

- (NSInteger)integerAtIndex:(NSUInteger) anIndex
{
    if ( SPARSE==NO  && anIndex > idx ) {
        @throw [ANTLRIllegalArgumentException newException:[NSString stringWithFormat:@"Index %d must be less than count %d", anIndex, count]];
    }
    else if ( SPARSE == YES && anIndex >= BuffSize ) {
        @throw [ANTLRIllegalArgumentException newException:[NSString stringWithFormat:@"Index %d must be less than BuffSize %d", anIndex, BuffSize]];
    }
    return intBuffer[anIndex];
}

- (void)insertInteger:(NSInteger)aValue AtIndex:(NSUInteger)anIndex
{
    [self replaceInteger:aValue AtIndex:anIndex];
    count++;
}

- (NSInteger)removeIntegerAtIndex:(NSUInteger) anIndex
{
    if ( SPARSE==NO && anIndex > idx ) {
        @throw [ANTLRIllegalArgumentException newException:[NSString stringWithFormat:@"Index %d must be less than count %d", anIndex, count]];
        return (NSInteger)-1;
    } else if ( SPARSE==YES && anIndex >= BuffSize ) {
        @throw [ANTLRIllegalArgumentException newException:[NSString stringWithFormat:@"Index %d must be less than BuffSize %d", anIndex, BuffSize]];
    }
    count--;
    return intBuffer[anIndex];
}

- (void)replaceInteger:(NSInteger)aValue AtIndex:(NSUInteger)anIndex
{
    if ( SPARSE == NO && anIndex > idx ) {
        @throw [ANTLRIllegalArgumentException newException:[NSString stringWithFormat:@"Index %d must be less than count %d", anIndex, count]];
    }
    else if ( SPARSE == YES && anIndex >= BuffSize ) {
        @throw [ANTLRIllegalArgumentException newException:[NSString stringWithFormat:@"Index %d must be less than BuffSize %d", anIndex, BuffSize]];
    }
    intBuffer[anIndex] = aValue;
}

-(void) reset
{
    count = 0;
    idx = -1;
}

- (void) ensureCapacity:(NSUInteger) anIndex
{
    if ( (anIndex * sizeof(NSUInteger)) >= [buffer length] )
    {
        NSUInteger newSize = ([buffer length] / sizeof(NSInteger)) * 2;
        if (anIndex > newSize) {
            newSize = anIndex + 1;
        }
        BuffSize = newSize;
        [buffer setLength:(BuffSize * sizeof(NSUInteger))];
        intBuffer = (NSInteger *)[buffer mutableBytes];
    }
}

@end

