//
//  AMutableArray.m
//  a_ST4
//
//  Created by Alan Condit on 3/12/11.
//  Copyright 2011 Alan's MachineWorks. All rights reserved.
//
#import "AMutableArray.h"
#import "ArrayIterator.h"

#define BUFFSIZE 25

@implementation AMutableArray

@synthesize BuffSize;
@synthesize buffer;
@synthesize ptrBuffer;
//@synthesize count;


+ (id) newArray
{
    return [[AMutableArray alloc] init];
}

+ (id) arrayWithCapacity:(NSInteger)size
{
    return [[AMutableArray alloc] initWithCapacity:size];
}

- (id) init
{
    self=[super init];
    if ( self != nil ) {
        BuffSize = BUFFSIZE;
        buffer = [[NSMutableData dataWithLength:(BuffSize * sizeof(id))] retain];
        ptrBuffer = (id *)[buffer mutableBytes];
        for( int idx = 0; idx < BuffSize; idx++ ) {
            ptrBuffer[idx] = nil;
        }
    }
    return self;
}

- (id) initWithCapacity:(NSInteger)len
{
    self=[super init];
    if ( self != nil ) {
        BuffSize = (len >= BUFFSIZE) ? len : BUFFSIZE;
        buffer = [[NSMutableData dataWithLength:(BuffSize * sizeof(id))] retain];
        ptrBuffer = (id *)[buffer mutableBytes];
        for( int idx = 0; idx < BuffSize; idx++ ) {
            ptrBuffer[idx] = nil;
        }
    }
    return self;
}

- (void) dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in AMutableArray" );
#endif
    if ( count ) [self removeAllObjects];
    if ( buffer ) [buffer release];
    [super dealloc];
}

- (id) copyWithZone:(NSZone *)aZone
{
    AMutableArray *copy;
    
    copy = [[[self class] allocWithZone:aZone] init];
    if ( buffer ) {
        copy.buffer = [buffer copyWithZone:aZone];
    }
    copy.ptrBuffer = [copy.buffer mutableBytes];
    copy.count = count;
    copy.BuffSize = BuffSize;
    return copy;
}

- (void) addObject:(id)anObject
{
    if ( anObject == nil ) anObject = [NSNull null];
    [anObject retain];
	[self ensureCapacity:count];
	ptrBuffer[count++] = anObject;
}

- (void) addObjectsFromArray:(NSArray *)otherArray
{
    NSInteger cnt, i;
    cnt = [otherArray count];
    [self ensureCapacity:count+cnt];
    for( i = 0; i < cnt; i++) {
        [self addObject:[otherArray objectAtIndex:i]];
    }
    return;
}

- (id) objectAtIndex:(NSInteger)anIdx
{
    id obj;
    if ( anIdx < 0 || anIdx >= count ) {
        @throw [NSException exceptionWithName:NSRangeException
                                       reason:[NSString stringWithFormat:@"Attempt to retrieve objectAtIndex %d past end", anIdx]
                                     userInfo:nil];
        return nil;
    }
    ptrBuffer = [buffer mutableBytes];
    obj = ptrBuffer[anIdx];
    if ( obj == [NSNull null] ) {
        obj = nil;
    }
    return obj;
}

- (void) insertObject:(id)anObject atIndex:(NSInteger)anIdx
{
    if ( anObject == nil ) anObject = [NSNull null];
    if ( anObject == nil ) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Attempt to insert nil objectAtIndex" userInfo:nil];
    }
    if ( anIdx < 0 || anIdx > count ) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Attempt to insertObjectAtIndex past end" userInfo:nil];
    }
    if ( count == BuffSize ) {
        [self ensureCapacity:count];
    }
    if ( anIdx < count ) {
        for (int i = count; i > anIdx; i--) {
            ptrBuffer[i] = ptrBuffer[i-1];
        }
    }
    ptrBuffer[anIdx] = [anObject retain];
    count++;
}

- (void) removeObjectAtIndex:(NSInteger)idx;
{
    id tmp;
    if (idx < 0 || idx >= count) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Attempt to insert removeObjectAtIndex past end" userInfo:nil];
    }
    else if (count) {
        tmp = ptrBuffer[idx];
        if ( tmp ) [tmp release];
        for (int i = idx; i < count; i++) {
            ptrBuffer[i] = ptrBuffer[i+1];
        }
        count--;
    }
}

- (void) removeLastObject
{
    id tmp;
    if (count == 0) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Attempt to removeLastObject from 0" userInfo:nil];
    }
    count--;
    tmp = ptrBuffer[count];
    if ( tmp ) [tmp release];
    ptrBuffer[count] = nil;
}

- (void)removeAllObjects
{
    id tmp;
    if (count == 0) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Attempt to removeAllObjects from 0" userInfo:nil];
    }
    int i;
    for ( i = 0; i < BuffSize; i++ ) {
        if (i < count) {
            tmp = ptrBuffer[i];
            if ( tmp ) [tmp release];
        }
        ptrBuffer[i] = nil;
    }
    count = 0;
}

- (void) replaceObjectAtIndex:(NSInteger)idx withObject:(id)obj
{
    id tmp;
    if ( obj == nil ) {
        obj = [NSNull null];
    }
    if ( idx < 0 || idx >= count ) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Attempt to replace object past end" userInfo:nil];
   }
    if ( count ) {
        [obj retain];
        tmp = ptrBuffer[idx];
        if ( tmp ) [tmp release];
        ptrBuffer[idx] = obj;
    }
}

- (NSInteger) count
{
    return count;
}

- (void) setCount:(NSInteger)cnt
{
    count = cnt;
}

- (NSArray *) allObjects
{
    return [NSArray arrayWithObjects:ptrBuffer count:count];
}

- (ArrayIterator *) objectEnumerator
{
    return [ArrayIterator newIterator:[self allObjects]];
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

- (NSString *) description
{
    NSMutableString *str;
    NSInteger idx, cnt;
    cnt = [self count];
    str = [NSMutableString stringWithCapacity:30];
    [str appendString:@"["];
    for (idx = 0; idx < cnt; idx++ ) {
        [str appendString:[[self objectAtIndex:idx] toString]];
    }
    [str appendString:@"]"];
    return str;
}

- (NSString *) toString
{
    return [self description];
}

- (void) ensureCapacity:(NSInteger) index
{
	if ((index * sizeof(id)) >= [buffer length])
	{
		NSInteger newSize = ([buffer length] / sizeof(id)) * 2;
		if (index > newSize) {
			newSize = index + 1;
		}
        BuffSize = newSize;
		[buffer setLength:(BuffSize * sizeof(id))];
        ptrBuffer = [buffer mutableBytes];
	}
}

@end
