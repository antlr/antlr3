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


@implementation ANTLRIntArray

+ (ANTLRIntArray *)newArray
{
    return [[[ANTLRIntArray alloc] init] retain];
}

+ (ANTLRIntArray *)newArrayWithLen:(NSUInteger)aLen
{
    return [[[ANTLRIntArray alloc] initWithLen:aLen] retain];
}

-(id) init
{
	if ((self = [super initWithLen:ANTLR_INT_ARRAY_INITIAL_SIZE]) != nil) {
        ip = (NSUInteger *)ptrBuffer;
	}
	return self;
}

-(id) initWithLen:(NSUInteger)aLen
{
	if ((self = [super initWithLen:aLen]) != nil) {
        ip = (NSUInteger *)ptrBuffer;
	}
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

- (id) copyWithZone:(NSZone *)aZone
{
    ANTLRIntArray *copy;
    
    copy = [super copyWithZone:aZone];
    return copy;
}

- (NSUInteger)count
{
    return ptr;
}

// FIXME: Java runtime returns p, I'm not so sure it's right so have added p + 1 to show true size!
-(NSUInteger) size
{
	return (ptr * sizeof(NSUInteger));
}

-(void) addInteger:(NSInteger) v
{
	[self ensureCapacity:ptr];
	ip[ptr++] = (NSInteger) v;
}

-(void) push:(NSInteger) v
{
	[self addInteger:v];
}

-(NSInteger) pop
{
	NSInteger v = (NSInteger) ip[--ptr];
	return v;
}

-(NSInteger) integerAtIndex:(NSUInteger) i
{
    if (i >= BuffSize) {
        return (NSInteger)-1;
    }
	return (NSInteger) ip[i];
}

-(void) insertInteger:(NSInteger)anInteger AtIndex:(NSUInteger)idx
{
    if ( idx >= BuffSize ) {
        [self ensureCapacity:idx];
    }
    ip[idx] = (NSInteger) anInteger;
}
-(void) reset
{
	ptr = 0;
}

- (void) ensureCapacity:(NSUInteger) anIndex
{
	if ((anIndex * sizeof(NSUInteger)) >= [buffer length])
	{
		NSUInteger newSize = ([buffer length] / sizeof(NSUInteger)) * 2;
		if (anIndex > newSize) {
			newSize = anIndex + 1;
		}
        BuffSize = newSize;
		[buffer setLength:(BuffSize * sizeof(NSUInteger))];
        ptrBuffer = (id *)[buffer mutableBytes];
        ip = (NSUInteger *)ptrBuffer;
	}
}

@synthesize ip;
@end

