//
//  AMutableDictionary.m
//  ST4
//
//  Created by Alan Condit on 4/18/11.
//  Copyright 2011 Alan Condit. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMutableDictionary.h"
#import "ACBTree.h"

@implementation AMutableDictionary

@synthesize root;
@synthesize nodes_av;
@synthesize nodes_inuse;
@synthesize nxt_nodeid;
//@synthesize count;
@synthesize data;
@synthesize ptrBuffer;

+ (AMutableDictionary *) newDictionary
{
    return [[AMutableDictionary alloc] init];
}

/** dictionaryWithCapacity
 *  capacity is meaningless to ACBTree because
 *  capacity is automatically increased
 */
+ (AMutableDictionary *) dictionaryWithCapacity
{
    return [[AMutableDictionary alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        nxt_nodeid = 0;
        count = 0;
        root = [ACBTree newNodeWithDictionary:self];
        root.nodeType = LEAF;
        root.numrecs = 0;
        root.updtd = NO;
        root.lnodeid = 1;
        root.lnode = nil;
        root.rnodeid = 0xffff;
        root.rnode = nil;
    }
    return self;
}

/** initWithCapacity
 *  capacity is meaningless to ACBTree because
 *  capacity is automatically increased
 */
- (id) initWithCapacity:(NSUInteger)numItems
{
    self = [super init];
    if (self) {
        // Initialization code here.
        nxt_nodeid = 0;
        count = 0;
        root = [ACBTree newNodeWithDictionary:self];
        root.nodeType = LEAF;
        root.numrecs = 0;
        root.updtd = NO;
        root.lnodeid = 1;
        root.lnode = nil;
        root.rnodeid = 0xffff;
        root.rnode = nil;
    }
    return self;
}

- (void) dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in AMutableDictionary" );
#endif
    if ( data ) [data release];
    if ( root ) [root release];
    [super dealloc];
}

- (id) objectForKey:(id)aKey
{
    id obj = nil;
    ACBTree *node;
    ACBKey *kp;
    NSInteger ret;
    BOOL mustRelease = NO;

    if ( [aKey isKindOfClass:[NSString class]] ) {
        kp = [ACBKey newKeyWithKStr:aKey];
        mustRelease = YES;
    }
    else if ( [aKey isKindOfClass:[ACBKey class]] ) {
        kp = aKey;
        //ACBKey *akey = [ACBKey newKey:aKey];
    }
    else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"What kind of key is this? %@", aKey]
                                     userInfo:nil];
        return nil; // not a key that I know how to deal with
    }
    node = [root search:kp.key];
    if ( node != nil ) {
        ret = [node searchnode:kp.key match:YES];
        if ( ret >= 0 && ret < node.numkeys ) {
            obj = node.btNodes[ret];
            if ( obj == [NSNull null] ) {
                obj = nil;
            }
        }
    }
    if ( mustRelease ) [kp release];
    return obj;
}

- (void) setObject:(id)obj forKey:(id)aKey
{
    ACBKey *kp;
    BOOL mustRelease = NO;
    if ( [aKey isKindOfClass:[NSString class]] ) {
        kp = [ACBKey newKeyWithKStr:aKey];
        mustRelease = YES;
    }
    else if ( [aKey isKindOfClass:[ACBKey class]] ) {
        kp = (ACBKey *)aKey;
    }
    else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"What kind of key is this? %@", aKey]
                                     userInfo:nil];
    }
    if ( [root search:kp.key] == nil ) {
        if ( obj == nil ) {
            obj = [NSNull null];
        }
        root = [root insertkey:kp value:obj];
        [kp retain];
        [obj retain];
        kp.recnum = count++;
    }
    else {
        if ( mustRelease ) [kp release];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"key alreadyExists" userInfo:nil];
    }
    return;
}

- (BOOL) isEqual:(id)object
{
    return [super isEqual:object];
}

- (void) removeObjectForKey:(id)aKey
{
    if ( [root deletekey:aKey] == SUCCESS )
        count--;
}

- (NSUInteger) count
{
    return count;
}

- (NSArray *) allKeys
{
    NSUInteger cnt = [root keyWalkLeaves];
    return [NSArray arrayWithObjects:ptrBuffer count:cnt];
}

- (NSArray *) allValues
{
    NSUInteger cnt = [root objectWalkLeaves];
    return [NSArray arrayWithObjects:ptrBuffer count:cnt];
}

- (ArrayIterator *) keyEnumerator
{
    return [ArrayIterator newIterator:[self allKeys]];
}

- (ArrayIterator *) objectEnumerator
{
    return [ArrayIterator newIterator:[self allValues]];
}

// This is where all the magic happens.
// You have two choices when implementing this method:
// 1) Use the stack based array provided by stackbuf. If you do this, then you must respect the value of 'len'.
// 2) Return your own array of objects. If you do this, return the full length of the array returned until you run out of objects, then return 0. For example, a linked-array implementation may return each array in order until you iterate through all arrays.
// In either case, state->itemsPtr MUST be a valid array (non-nil). This sample takes approach #1, using stackbuf to store results.
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
    NSUInteger cnt = 0;
    // This is the initialization condition, so we'll do one-time setup here.
    // Ensure that you never set state->state back to 0, or use another method to detect initialization
    // (such as using one of the values of state->extra).
    if (state->state == 0) {
        // We are not tracking mutations, so we'll set state->mutationsPtr to point into one of our extra values,
        // since these values are not otherwise used by the protocol.
        // If your class was mutable, you may choose to use an internal variable that is updated when the class is mutated.
        // state->mutationsPtr MUST NOT be NULL.
        state->mutationsPtr = &state->extra[0];
        [self.root objectWalkLeaves];
    }
    // Now we provide items, which we track with state->state, and determine if we have finished iterating.
    if (state->state < self.count) {
        // Set state->itemsPtr to the provided buffer.
        // Alternate implementations may set state->itemsPtr to an internal C array of objects.
        // state->itemsPtr MUST NOT be NULL.
        state->itemsPtr = stackbuf;
        // Fill in the stack array, either until we've provided all items from the list
        // or until we've provided as many items as the stack based buffer will hold.
        while((state->state < self.count) && (cnt < len)) {
            // For this sample, we generate the contents on the fly.
            // A real implementation would likely just be copying objects from internal storage.
            stackbuf[cnt++] = ptrBuffer[state->state++];
        }
        // state->state = ((cnt < len)? cnt : len);
    }
    else
    {
        // We've already provided all our items, so we signal we are done by returning 0.
        cnt = 0;
    }
    return cnt;
}

- (void) clear
{
    if ( count ) [self removeAllObjects];
}

- (void) removeAllObjects
{
    root = [ACBTree newNodeWithDictionary:self];
    root.nodeid = 0;
    nxt_nodeid = 1;
}

- (NSInteger) nextNodeId
{
    return nxt_nodeid++;
}

- (NSArray *) toKeyArray
{
    return nil;
}

- (NSArray *) toValueArray
{
    return nil;
}

@end
