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
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

/**
 * Iterator for an array so I don't have to copy the array to a List
 * just to make it iteratable.
 */

/*
 * this is the state structure for FastEnumeration
 typedef struct {
 unsigned long state;
 id *itemsPtr;
 unsigned long *mutationsPtr;
 unsigned long extra[5];
 } NSFastEnumerationState;
 */

@interface ArrayIterator : NSObject {
    
    __strong id peekObj;
    /**
     * NSArrays are fixed size; precompute count.
     */
    NSInteger count;
    NSInteger index;
    __strong NSArray *anArray;
    
}

+ (ArrayIterator *) newIterator:(NSArray *)array;
+ (ArrayIterator *) newIteratorForDictKey:(NSDictionary *)dict;
+ (ArrayIterator *) newIteratorForDictObj:(NSDictionary *)dict;

- (id) initWithArray:(NSArray *)array;
- (id) initWithDictKey:(NSDictionary *)dict;
- (id) initWithDictObj:(NSDictionary *)dict;

- (BOOL) hasNext;
- (id) nextObject;
- (NSArray *)allObjects;
- (void) removeObjectAtIndex:(NSInteger)idx;
- (NSInteger) count;
- (void) setCount:(NSInteger)cnt;
- (void) dealloc;

@property (retain) id peekObj;
@property (assign, getter=count, setter=setCount:) NSInteger count;
@property (assign) NSInteger index;
@property (retain) NSArray *anArray;

@end
