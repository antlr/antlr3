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
    NSInteger idx;
    
	if ((self = [super init]) != nil) {
		fNext = nil;
        BuffSize  = BUFFSIZE;
        ptr = 0;
        buffer = [NSMutableData dataWithLength:(NSUInteger)BuffSize * sizeof(id)];
        [buffer retain];
        ptrBuffer = (id *)[buffer mutableBytes];
        for( idx = 0; idx < BuffSize; idx++ ) {
            ptrBuffer[idx] = nil;
        }
	}
    return( self );
}

-(id)initWithLen:(NSInteger)cnt
{
    NSInteger idx;
    
	if ((self = [super init]) != nil) {
		fNext = nil;
        BuffSize  = cnt;
        ptr = 0;
        buffer = [NSMutableData dataWithLength:(NSUInteger)BuffSize * sizeof(id)];
        [buffer retain];
        ptrBuffer = (id *)[buffer mutableBytes];
        for( idx = 0; idx < BuffSize; idx++ ) {
            ptrBuffer[idx] = nil;
        }
	}
    return( self );
}

-(void)dealloc
{
    ANTLRLinkBase *tmp, *rtmp;
    NSInteger idx;
	
    if ( self.fNext != nil ) {
        for( idx = 0; idx < BuffSize; idx++ ) {
            tmp = ptrBuffer[idx];
            while ( tmp ) {
                rtmp = tmp;
                tmp = (id)tmp.fNext;
                [rtmp dealloc];
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
            tmp = [tmp getfNext];
            [rtmp dealloc];
        }
        ptrBuffer[idx] = nil;
    }
}

- (NSMutableData *)getBuffer
{
	return( buffer );
}

- (void)setBuffer:(NSMutableData *)np
{
    buffer = np;
}

- (NSInteger)getCount
{
	return( count );
}

- (void)setCount:(NSInteger)aCount
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

- (NSInteger)getPtr
{
	return( ptr );
}

- (void)setPtr:(NSInteger)aPtr
{
    ptr = aPtr;
}

- (void) addObject:(id) v
{
	[self ensureCapacity:ptr];
    [v retain];
	ptrBuffer[ptr++] = v;
    count++;
}

- (void) push:(id) v
{
    if ( ptr >= BuffSize - 1 ) {
        [self ensureCapacity:ptr];
    }
    [v retain];
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
    [v release];
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

- (NSInteger)count
{
    int cnt = 0;
    
    for (NSInteger i = 0; i < BuffSize; i++ ) {
        if ( ptrBuffer[i] != nil ) {
            cnt++;
        }
    }
    if (cnt != count) count = cnt;
    return cnt;
}

- (NSInteger)length
{
    return BuffSize;
}

- (NSInteger)size
{
    NSInteger aSize = 0;
    for (int i = 0; i < BuffSize; i++ ) {
        if (ptrBuffer[i] != nil) {
            aSize += sizeof(id);
        }
    }
    return aSize;
}

- (void) insertObject:(id)aRule atIndex:(NSInteger)idx
{
    if ( idx >= BuffSize ) {
        [self ensureCapacity:idx];
    }
    if ( aRule != ptrBuffer[idx] ) {
        if ( ptrBuffer[idx] != nil ) [ptrBuffer[idx] release];
        [aRule retain];
    }
    ptrBuffer[idx] = aRule;
}

- (id)objectAtIndex:(NSInteger)idx
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
        if (tmp != nil)
            [tmp retain];
        [self insertObject:tmp atIndex:i];
    }
    return;
}

- (void)removeAllObjects
{
    int i;
    for ( i = 0; i < BuffSize; i++ ) {
        if ( ptrBuffer[i] != nil ) [ptrBuffer[i] release];
        ptrBuffer[i] = nil;
    }
    count = 0;
    ptr = 0;
}

- (void) ensureCapacity:(NSInteger) index
{
	if ((index * sizeof(id)) >= [buffer length])
	{
		NSInteger newSize = ([buffer length] / sizeof(id)) * 2;
		if (index > newSize) {
			newSize = index + 1;
		}
        BuffSize = newSize;
		[buffer setLength:(BuffSize * sizeof(id))];
        ptrBuffer = [buffer mutableBytes];
	}
}

- (NSString *) toString
{
    NSMutableString *str;
    NSInteger idx, cnt;
    cnt = [self count];
    str = [NSMutableString stringWithCapacity:30];
    [str appendString:@"["];
    for (idx = 0; idx < cnt; idx++ ) {
        [str appendString:[[self objectAtIndex:idx] toString]];
    }
    [str appendString:@"]"];
    return str;
}

@end
