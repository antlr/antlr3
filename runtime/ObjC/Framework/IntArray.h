//
//  ANTLRIntArray.h
//  ANTLR
//
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

#import <Cocoa/Cocoa.h>

#define ANTLR_INT_ARRAY_INITIAL_SIZE 10

@interface ANTLRIntArray : NSObject 
{
    NSUInteger BuffSize;
    NSUInteger count;
    NSInteger idx;
    NSMutableData *buffer;
    __strong NSInteger *intBuffer;
    BOOL SPARSE;
}

+ (ANTLRIntArray *)newArray;
+ (ANTLRIntArray *)newArrayWithLen:(NSUInteger)aLen;

- (id) init;
- (id) initWithLen:(NSUInteger)aLen;

- (void) dealloc;

- (id) copyWithZone:(NSZone *)aZone;

- (void) addInteger:(NSInteger) value;
- (NSInteger) pop;
- (void) push:(NSInteger) value;
- (NSInteger) integerAtIndex:(NSUInteger) index;
- (void) insertInteger:(NSInteger)anInteger AtIndex:(NSUInteger) anIndex;
- (NSInteger)removeIntegerAtIndex:(NSUInteger) anIndex;
- (void)replaceInteger:(NSInteger)aValue AtIndex:(NSUInteger)anIndex;
- (void) reset;

- (NSUInteger) count;
- (NSUInteger) size;
- (void) ensureCapacity:(NSUInteger) anIndex;

@property (assign) NSUInteger BuffSize;
@property (assign) NSUInteger count;
@property (assign) NSInteger idx;
@property (retain) NSMutableData *buffer;
@property (assign) NSInteger *intBuffer;
@property (assign) BOOL SPARSE;

@end
