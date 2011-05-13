//
//  AMutableDictionary.h
//  ST4
//
//  Created by Alan Condit on 4/18/11.
//  Copyright 2011 Alan Condit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACBTree.h"
#import "ArrayIterator.h"

@class ACBTree;
@class ArrayIterator;

@interface AMutableDictionary : NSMutableDictionary {

    __strong ACBTree  *root;
    NSInteger nodes_av;
    NSInteger nodes_inuse;
    NSInteger nxt_nodeid;
    NSUInteger count;
    __strong NSMutableData *data;
    __strong id       *ptrBuffer;
}

@property (retain) ACBTree  *root;
@property (assign) NSInteger nodes_av;
@property (assign) NSInteger nodes_inuse;
@property (assign) NSInteger nxt_nodeid;
@property (assign, readonly, getter=count) NSUInteger count;
@property (assign) NSMutableData *data;
@property (assign) id       *ptrBuffer;

+ (AMutableDictionary *) newDictionary;
+ (AMutableDictionary *) dictionaryWithCapacity;

- (id) init;
- (id) initWithCapacity:(NSUInteger)numItems;
- (void) dealloc;

- (BOOL) isEqual:(id)object;
- (id) objectForKey:(id)aKey;
- (void) setObject:(id)obj forKey:(id)aKey;
- (void) removeObjectForKey:(id)aKey;

- (NSUInteger) count;

- (NSArray *) allKeys;
- (NSArray *) allValues;
- (ArrayIterator *) keyEnumerator;
- (ArrayIterator *) objectEnumerator;

- (void) clear;
- (void) removeAllObjects;
- (NSInteger) nextNodeId;
- (NSArray *) toKeyArray;
- (NSArray *) toValueArray;

@end
