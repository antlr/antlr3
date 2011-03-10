//
//  ANTLRSymbolStack.m
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

#import "ANTLRSymbolStack.h"
#import "ANTLRTree.h"


@implementation ANTLRSymbolsScope

+ (ANTLRSymbolsScope *)newANTLRSymbolsScope
{
    return( [[ANTLRSymbolsScope alloc] init] );
}

- (id)init
{
    if ((self = [super init]) != nil) {
    }
    return (self);
}

@end

/*
 * Start of ANTLRSymbolStack
 */
@implementation ANTLRSymbolStack

+(ANTLRSymbolStack *)newANTLRSymbolStack
{
    return [[ANTLRSymbolStack alloc] init];
}

+(ANTLRSymbolStack *)newANTLRSymbolStackWithLen:(NSInteger)cnt
{
    return [[ANTLRSymbolStack alloc] initWithLen:cnt];
}

-(id)init
{
	if ((self = [super init]) != nil) {
	}
    return( self );
}

-(id)initWithLen:(NSInteger)cnt
{
	if ((self = [super initWithLen:cnt]) != nil) {
	}
    return( self );
}

-(void)dealloc
{
	[super dealloc];
}

- (id) copyWithZone:(NSZone *)aZone
{
    return [super copyWithZone:aZone];
}

-(ANTLRSymbolsScope *)getHashMapEntry:(NSInteger)idx
{
	return( (ANTLRSymbolsScope *)[super objectAtIndex:idx] );
}

-(ANTLRSymbolsScope **)getHashMap
{
	return( (ANTLRSymbolsScope **)ptrBuffer );
}

-(ANTLRSymbolsScope *) pop
{
    return (ANTLRSymbolsScope *)[super pop];
}

- (void) insertObject:(ANTLRSymbolsScope *)aRule atIndex:(NSInteger)idx
{
    if (aRule != ptrBuffer[idx]) {
        if (ptrBuffer[idx] != nil) [ptrBuffer[idx] release];
        [aRule retain];
    }
    ptrBuffer[idx] = aRule;
}

- (ANTLRSymbolsScope *)objectAtIndex:(NSInteger)idx
{
    return (ANTLRSymbolsScope *)[super objectAtIndex:idx];
}

@end
