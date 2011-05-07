//
//  AMutableArray.h
//  a_ST4
//
//  Created by Alan Condit on 3/12/11.
//  Copyright 2011 Alan's MachineWorks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ArrayIterator.h"

@class ArrayIterator;

@interface AMutableArray : NSMutableArray {
    NSInteger BuffSize;
    NSInteger count;
    __strong NSMutableData *buffer;
    __strong id *ptrBuffer;
}

+ (id) newArray;
+ (id) arrayWithCapacity:(NSInteger)size;

- (id) init;
- (id) initWithCapacity:(NSInteger)size;
- (id) copyWithZone:(NSZone *)aZone;

- (void) addObject:(id)anObject;
- (void) addObjectsFromArray:(NSArray *)anArray;
- (id) objectAtIndex:(NSInteger)anIdx;
- (void) insertObject:(id)anObject atIndex:(NSInteger)anIdx;
- (void) removeAllObjects;
- (void) removeLastObject;
- (void) removeObjectAtIndex:(NSInteger)idx;
- (void) replaceObjectAtIndex:(NSInteger)idx withObject:(id)obj;
- (NSInteger) count;
- (void)setCount:(NSInteger)cnt;
//- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;
- (NSArray *) allObjects;
- (ArrayIterator *) objectEnumerator;
- (void) ensureCapacity:(NSInteger) index;
- (NSString *) description;
- (NSString *) toString;

@property (assign) NSInteger BuffSize;
@property (assign, getter=count, setter=setCount:) NSInteger count;
@property (retain) NSMutableData *buffer;
@property (assign) id *ptrBuffer;

@end
