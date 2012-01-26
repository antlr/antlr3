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
    NSUInteger BuffSize;
    NSUInteger count;
    NSUInteger ptr;
    __strong NSMutableData *buffer;
    __strong id *ptrBuffer;
}

@property (getter=getBuffSize, setter=setBuffSize:) NSUInteger BuffSize;
@property (getter=getCount, setter=setCount:) NSUInteger count;
@property (getter=getPtr, setter=setPtr:) NSUInteger ptr;
@property (retain, getter=getBuffer, setter=setBuffer:) NSMutableData *buffer;
@property (assign, getter=getPtrBuffer, setter=setPtrBuffer:) id *ptrBuffer;

// Contruction/Destruction
+(ANTLRPtrBuffer *)newANTLRPtrBuffer;
+(ANTLRPtrBuffer *)newANTLRPtrBufferWithLen:(NSInteger)cnt;
-(id)init;
-(id)initWithLen:(NSUInteger)cnt;
-(void)dealloc;

// Instance Methods
- (id) copyWithZone:(NSZone *)aZone;
/* clear -- reinitialize the maplist array */
- (void) clear;

- (NSUInteger)count;
- (NSUInteger)length;
- (NSUInteger)size;

- (NSMutableData *)getBuffer;
- (void)setBuffer:(NSMutableData *)np;
- (NSUInteger)getCount;
- (void)setCount:(NSUInteger)aCount;
- (id *)getPtrBuffer;
- (void)setPtrBuffer:(id *)np;
- (NSUInteger)getPtr;
- (void)setPtr:(NSUInteger)np;

- (void) push:(id) v;
- (id) pop;
- (id) peek;

- (void) addObject:(id) v;
- (void) addObjectsFromArray:(ANTLRPtrBuffer *)anArray;
- (void) insertObject:(id)aRule atIndex:(NSUInteger)idx;
- (id)   objectAtIndex:(NSUInteger)idx;
- (void) removeAllObjects;
- (void)removeObjectAtIndex:(NSInteger)idx;

- (void) ensureCapacity:(NSUInteger) index;
- (NSString *) description;
- (NSString *) toString;

@end
