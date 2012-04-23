#import "Entry.h"
#import <Foundation/Foundation.h>
#import "RuntimeException.h"

@implementation HTEntry

@synthesize next;
@synthesize hash;
@synthesize key;
@synthesize value;

+ (id) newEntry:(int)aHash key:(NSString *)aKey value:(id)aValue next:(HTEntry *)aNext
{
    return [[HTEntry alloc] init:aHash key:aKey value:aValue next:aNext];
}

- (id) init:(int)aHash key:(NSString *)aKey value:(id)aValue next:(HTEntry *)aNext
{
    if ( (self = [super init]) != nil) {
        next  = aNext;
        hash  = aHash;
        key   = aKey;
        value = aValue;
    }
    return self;
}

- (void) dealloc
{
    [next release];
    [key release];
    [value release];
    [super dealloc];
}


- (id) copyWithZone:(NSZone *)zone
{
    HTEntry *copy = [[HTEntry allocWithZone:zone] init:hash key:key value:value next:next];
    copy.next  = next;
    copy.hash  = hash;
    copy.key   = key;
    copy.value = value;
    //    return [[[HTEntry allocWithZone:zone] init:hash key:key value:value next:(next == nil ? nil : (HTEntry *)[next copyWithZone])] autorelease];
    return copy;
}

- (void) setValue:(id)aValue
{
    if (aValue == nil)
        @throw [[[NullPointerException alloc] init] autorelease];
    //    id oldValue = value;
    value = aValue;
    //    return oldValue;
}

- (BOOL) isEqualTo:(id)o
{
/*
    if (!([o conformsToProtocol:@protocol(HTEntry)]))
        return NO;
 */
    HTEntry *e = (HTEntry *)o;
    return (key == nil ? e.key == nil : [key isEqualTo:e.key]) && (value == nil ? e.value == nil : [value isEqualTo:e.value]);
}

- (int) hash
{
    return hash ^ (value == nil ? 0 : [value hash]);
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@ = %@",[key description], [value description]];
}

@end

@implementation LMNode

@synthesize next;
@synthesize prev;
@synthesize item;

+ (LMNode *) newNode:(LMNode *)aPrev element:(id)anElement next:(LMNode *)aNext
{
    return [[LMNode alloc] init:aPrev element:anElement next:aNext];
}

- (id) init:(LMNode *)aPrev element:(id)anElement next:(LMNode *)aNext
{
    self = [super init];
    if (self) {
        item = anElement;
        next = aNext;
        prev = aPrev;
    }
    return self;
}

- (void) dealloc
{
    [item release];
    [next release];
    [prev release];
    [super dealloc];
}

@end

