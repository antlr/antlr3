//
//  ANTLRPtrBuffer.h
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

#import <Cocoa/Cocoa.h>
#import "ANTLRLinkBase.h"

//#define GLOBAL_SCOPE       0
//#define LOCAL_SCOPE        1
#define BUFFSIZE         101

@interface ANTLRPtrBuffer : ANTLRLinkBase {
	//ANTLRPtrBuffer *fNext;
    NSInteger BuffSize;
    NSMutableData *buffer;
    id *ptrBuffer;
    NSInteger count;
    NSInteger ptr;
}

@property (getter=getBuffSize, setter=setBuffSize:) NSInteger BuffSize;
@property (retain, getter=getBuffer, setter=setBuffer:) NSMutableData *buffer;
@property (retain, getter=getPtrBuffer, setter=setPtrBuffer:) id *ptrBuffer;
@property (getter=getCount, setter=setCount:) NSInteger count;
@property (getter=getPtr, setter=setPtr:) NSInteger ptr;

// Contruction/Destruction
+(ANTLRPtrBuffer *)newANTLRPtrBuffer;
+(ANTLRPtrBuffer *)newANTLRPtrBufferWithLen:(NSInteger)cnt;
-(id)init;
-(id)initWithLen:(NSInteger)cnt;
-(void)dealloc;

// Instance Methods
- (id) copyWithZone:(NSZone *)aZone;
/* clear -- reinitialize the maplist array */
- (void) clear;

- (NSInteger)count;
- (NSInteger)length;
- (NSInteger)size;

- (NSMutableData *)getBuffer;
- (void)setBuffer:(NSMutableData *)np;
- (NSInteger)getCount;
- (void)setCount:(NSInteger)aCount;
- (id *)getPtrBuffer;
- (void)setPtrBuffer:(id *)np;
- (NSInteger)getPtr;
- (void)setPtr:(NSInteger)np;

- (void) push:(id) v;
- (id) pop;
- (id) peek;

- (void) addObject:(id) v;
- (void) addObjectsFromArray:(ANTLRPtrBuffer *)anArray;
- (void) insertObject:(id)aRule atIndex:(NSInteger)idx;
- (id)   objectAtIndex:(NSInteger)idx;
- (void) removeAllObjects;

- (void) ensureCapacity:(NSInteger) index;

@end
