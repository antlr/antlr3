//
//  ANTLRPtrBuffer.m
//  ANTLR
//
//  Created by Alan Condit on 6/9/10.
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

#define SUCCESS (0)
#define FAILURE (-1)

#import "ANTLRPtrBuffer.h"
#import "ANTLRTree.h"

/*
 * Start of ANTLRPtrBuffer
 */
@implementation ANTLRPtrBuffer

@synthesize BuffSize;
@synthesize buffer;
@synthesize ptrBuffer;
@synthesize count;
@synthesize ptr;

+(ANTLRPtrBuffer *)newANTLRPtrBuffer
{
    return [[ANTLRPtrBuffer alloc] init];
}

+(ANTLRPtrBuffer *)newANTLRPtrBufferWithLen:(NSInteger)cnt
{
    return [[ANTLRPtrBuffer alloc] initWithLen:cnt];
}

-(id)init
{
    NSUInteger idx;
    
    self = [super init];
    if ( self != nil ) {
        BuffSize  = BUFFSIZE;
        ptr = 0;
        buffer = [[NSMutableData dataWithLength:(NSUInteger)BuffSize * sizeof(id)] retain];
        ptrBuffer = (id *) [buffer mutableBytes];
        for( idx = 0; idx < BuffSize; idx++ ) {
            ptrBuffer[idx] = nil;
        }
        count = 0;
    }
    return( self );
}

-(id)initWithLen:(NSUInteger)cnt
{
    NSUInteger idx;
    
    self = [super init];
    if ( self != nil ) {
        BuffSize  = cnt;
        ptr = 0;
        buffer = [[NSMutableData dataWithLength:(NSUInteger)BuffSize * sizeof(id)] retain];
        ptrBuffer = (id *)[buffer mutableBytes];
        for( idx = 0; idx < BuffSize; idx++ ) {
            ptrBuffer[idx] = nil;
        }
        count = 0;
    }
    return( self );
}

-(void)dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in ANTLRPtrBuffer" );
#endif
    ANTLRLinkBase *tmp, *rtmp;
    NSInteger idx;
    
    if ( self.fNext != nil ) {
        for( idx = 0; idx < BuffSize; idx++ ) {
            tmp = ptrBuffer[idx];
            while ( tmp ) {
                rtmp = tmp;
                if ([tmp isKindOfClass:[ANTLRLinkBase class]])
                    tmp = (id)tmp.fNext;
                else
                    tmp = nil;
                [rtmp release];
            }
        }
    }
    [buffer release];
    [super dealloc];
}

- (id) copyWithZone:(NSZone *)aZone
{
    ANTLRPtrBuffer *copy;
    
    copy = [[[self class] allocWithZone:aZone] init];
    if ( buffer )
        copy.buffer = [buffer copyWithZone:aZone];
    copy.ptrBuffer = ptrBuffer;
    copy.ptr = ptr;
    return copy;
}

- (void)clear
{
    ANTLRLinkBase *tmp, *rtmp;
    NSInteger idx;

    for( idx = 0; idx < BuffSize; idx++ ) {
        tmp = ptrBuffer[idx];
        while ( tmp ) {
            rtmp = tmp;
            if ([tmp isKindOfClass:[ANTLRLinkBase class]])
                tmp = (id)tmp.fNext;
            else
                tmp = nil;
            [rtmp dealloc];
        }
        ptrBuffer[idx] = nil;
    }
    count = 0;
}

- (NSMutableData *)getBuffer
{
    return( buffer );
}

- (void)setBuffer:(NSMutableData *)np
{
    buffer = np;
}

- (NSUInteger)getCount
{
    return( count );
}

- (void)setCount:(NSUInteger)aCount
{
    count = aCount;
}

- (id *)getPtrBuffer
{
    return( ptrBuffer );
}

- (void)setPtrBuffer:(id *)np
{
    ptrBuffer = np;
}

- (NSUInteger)getPtr
{
    return( ptr );
}

- (void)setPtr:(NSUInteger)aPtr
{
    ptr = aPtr;
}

- (void) addObject:(id) v
{
    [self ensureCapacity:ptr];
    if ( v ) [v retain];
    ptrBuffer[ptr++] = v;
    count++;
}

- (void) push:(id) v
{
    if ( ptr >= BuffSize - 1 ) {
        [self ensureCapacity:ptr];
    }
    if ( v ) [v retain];
    ptrBuffer[ptr++] = v;
    count++;
}

- (id) pop
{
    id v = nil;
    if ( ptr > 0 ) {
        v = ptrBuffer[--ptr];
        ptrBuffer[ptr] = nil;
    }
    count--;
    if ( v ) [v release];
    return v;
}

- (id) peek
{
    id v = nil;
    if ( ptr > 0 ) {
        v = ptrBuffer[ptr-1];
    }
    return v;
}

- (NSUInteger)count
{
#ifdef DONTUSENOMO
    int cnt = 0;
    
    for (NSInteger i = 0; i < BuffSize; i++ ) {
        if ( ptrBuffer[i] != nil ) {
            cnt++;
        }
    }
    if ( cnt != count ) count = cnt;
#endif
    return count;
}

- (NSUInteger)length
{
    return BuffSize;
}

- (NSUInteger)size
{
    NSUInteger aSize = 0;
    for (int i = 0; i < BuffSize; i++ ) {
        if (ptrBuffer[i] != nil) {
            aSize += sizeof(id);
        }
    }
    return aSize;
}

- (void) insertObject:(id)aRule atIndex:(NSUInteger)idx
{
    if ( idx >= BuffSize ) {
        [self ensureCapacity:idx];
    }
    if ( aRule != ptrBuffer[idx] ) {
        if ( ptrBuffer[idx] ) [ptrBuffer[idx] release];
        if ( aRule ) [aRule retain];
    }
    ptrBuffer[idx] = aRule;
    count++;
}

- (id)objectAtIndex:(NSUInteger)idx
{
    if ( idx < BuffSize ) {
        return ptrBuffer[idx];
    }
    return nil;
}

- (void)addObjectsFromArray:(ANTLRPtrBuffer *)anArray
{
    NSInteger cnt, i;
    cnt = [anArray count];
    for( i = 0; i < cnt; i++) {
        id tmp = [anArray objectAtIndex:i];
        if ( tmp ) [tmp retain];
        [self insertObject:tmp atIndex:i];
    }
    count += cnt;
    return;
}

- (void)removeAllObjects
{
    int i;
    for ( i = 0; i < BuffSize; i++ ) {
        if ( ptrBuffer[i] ) [ptrBuffer[i] release];
        ptrBuffer[i] = nil;
    }
    count = 0;
    ptr = 0;
}

- (void)removeObjectAtIndex:(NSInteger)idx
{
    int i;
    if ( idx >= 0 && idx < count ) {
        if ( ptrBuffer[idx] ) [ptrBuffer[idx] release];
        for ( i = idx; i < count-1; i++ ) {
            ptrBuffer[i] = ptrBuffer[i+1];
        }
        ptrBuffer[i] = nil;
        count--;
    }
}

- (void) ensureCapacity:(NSUInteger) anIndex
{
    if ((anIndex * sizeof(id)) >= [buffer length])
    {
        NSInteger newSize = ([buffer length] / sizeof(id)) * 2;
        if (anIndex > newSize) {
            newSize = anIndex + 1;
        }
        BuffSize = newSize;
        [buffer setLength:(BuffSize * sizeof(id))];
        ptrBuffer = [buffer mutableBytes];
    }
}

- (NSString *) description
{
    NSMutableString *str;
    NSInteger idx, cnt;
    cnt = [self count];
    str = [NSMutableString stringWithCapacity:30];
    [str appendString:@"["];
    for (idx = 0; idx < cnt; idx++ ) {
        [str appendString:[[self objectAtIndex:idx] description]];
    }
    [str appendString:@"]"];
    return str;
}

- (NSString *) toString
{
    return [self description];
}

@end
