//
//  ANTLRUniqueIDMap.m
//  ANTLR
//
//  Created by Alan Condit on 7/7/10.
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

#import "ANTLRUniqueIDMap.h"
#import "ANTLRTree.h"

@implementation ANTLRUniqueIDMap
@synthesize lastHash;

+(id)newANTLRUniqueIDMap
{
    ANTLRUniqueIDMap *aNewANTLRUniqueIDMap;
    
    aNewANTLRUniqueIDMap = [[ANTLRUniqueIDMap alloc] init];
	return( aNewANTLRUniqueIDMap );
}

+(id)newANTLRUniqueIDMapWithLen:(NSInteger)aBuffSize
{
    ANTLRUniqueIDMap *aNewANTLRUniqueIDMap;
    
    aNewANTLRUniqueIDMap = [[ANTLRUniqueIDMap alloc] initWithLen:aBuffSize];
	return( aNewANTLRUniqueIDMap );
}

-(id)init
{
    NSInteger idx;
    
	if ((self = [super initWithLen:HASHSIZE]) != nil) {
		fNext = nil;
        for( idx = 0; idx < HASHSIZE; idx++ ) {
            ptrBuffer[idx] = nil;
        }
	}
    return( self );
}

-(id)initWithLen:(NSInteger)aBuffSize
{
	if ((self = [super initWithLen:aBuffSize]) != nil) {
	}
    return( self );
}

-(void)dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in ANTLRUniqueIDMap" );
#endif
    ANTLRNodeMapElement *tmp, *rtmp;
    NSInteger idx;
	
    if ( self.fNext != nil ) {
        for( idx = 0; idx < HASHSIZE; idx++ ) {
            tmp = ptrBuffer[idx];
            while ( tmp ) {
                rtmp = tmp;
                tmp = (ANTLRNodeMapElement *)tmp.fNext;
                [rtmp release];
            }
        }
    }
	[super dealloc];
}

-(void)deleteANTLRUniqueIDMap:(ANTLRNodeMapElement *)np
{
    ANTLRNodeMapElement *tmp, *rtmp;
    NSInteger idx;
    
    if ( self.fNext != nil ) {
        for( idx = 0; idx < HASHSIZE; idx++ ) {
            tmp = ptrBuffer[idx];
            while ( tmp ) {
                rtmp = tmp;
                tmp = tmp.fNext;
                [rtmp release];
            }
        }
    }
}

- (void)clear
{
    ANTLRNodeMapElement *tmp, *rtmp;
    NSInteger idx;
    
    for( idx = 0; idx < HASHSIZE; idx++ ) {
        tmp = ptrBuffer[idx];
        while ( tmp ) {
            rtmp = tmp;
            tmp = [tmp getfNext];
            [rtmp release];
        }
        ptrBuffer[idx] = nil;
    }
}

- (NSInteger)count
{
    id anElement;
    NSInteger aCnt = 0;
    
    for (int i = 0; i < BuffSize; i++) {
        if ((anElement = ptrBuffer[i]) != nil) {
            aCnt += (NSInteger)[anElement count];
        }
    }
    return aCnt;
}

- (NSInteger)size
{
    return BuffSize;
}

-(void)delete_chain:(ANTLRNodeMapElement *)np
{
    if ( np.fNext != nil )
		[self delete_chain:np.fNext];
	[np release];
}

- (id)getNode:(id<ANTLRBaseTree>)aNode
{
    ANTLRNodeMapElement *np;
    NSInteger idx;
    
    idx = [(id<ANTLRBaseTree>)aNode type];
    np = ptrBuffer[idx];
    while ( np != nil ) {
        if (np.node == aNode) {
            return( np.index );
        }
        np = np.fNext;
    }
    return( nil );
}

- (void)putID:(id)anID Node:(id<ANTLRBaseTree>)aNode
{
    ANTLRNodeMapElement *np, *np1;
    NSInteger idx;
    
    idx = [(id<ANTLRBaseTree>)aNode type];
    idx %= HASHSIZE;
    np = [[ANTLRNodeMapElement newANTLRNodeMapElementWithIndex:anID Node:aNode] retain];
    np1 = ptrBuffer[idx];
    np.fNext = np1;
    ptrBuffer[idx] = np;
    return;
}


@end
