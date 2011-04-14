#import "ANTLRDoubleKeyMap.h"

@implementation ANTLRDoubleKeyMap

- (id) init
{
    self = [super init];
    if ( self  != nil ) {
        data = [NSMutableDictionary dictionaryWithCapacity:30];
    }
    return self;
}

- (id) setObject:(id)v forKey1:(id)k1 forKey2:(id)k2
{
    NSMutableDictionary *data2 = [data objectForKey:k1];
    id prev = nil;
    if (data2 == nil) {
        data2 = [[NSMutableDictionary dictionaryWithCapacity:30] retain];
        [data setObject:data2 forKey:k1];
    }
    else {
        prev = [data2 objectForKey:k2];
    }
    [data2 setObject:v forKey:k2];
    return prev;
}

- (id) objectForKey1:(id)k1 forKey2:(id)k2
{
    NSMutableDictionary *data2 = [data objectForKey:k1];
    if (data2 == nil)
        return nil;
    return [data2 objectForKey:k2];
}

- (NSMutableDictionary *) objectForKey:(id)k1
{
    return [data objectForKey:k1];
}


/**
 * Get all values associated with primary key
 */
- (NSArray *) valuesForKey:(id)k1
{
    NSMutableDictionary * data2 = [data objectForKey:k1];
    if (data2 == nil)
        return nil;
    return [data2 allValues];
}


/**
 * get all primary keys
 */
- (NSArray *) allKeys1
{
    return [data allKeys];
}


/**
 * get all secondary keys associated with a primary key
 */
- (NSArray *) allKeys2:(id)k1
{
    NSMutableDictionary * data2 = [data objectForKey:k1];
    if (data2 == nil)
        return nil;
    return [data2 allKeys];
}

- (NSMutableArray *) values
{
//    ANTLRHashMap *s = [[ANTLRHashMap newANTLRHashMapWithLen:30];
    NSMutableArray *s = [NSMutableArray arrayWithCapacity:30];
    
    for (NSMutableDictionary *k2 in [data allValues]) {
        
        for ( NSString *v in [k2 allValues]) {
            [s addObject:v];
        }
        
    }
    
    return s;
}

- (void) dealloc {
    [data release];
    [super dealloc];
}

@synthesize data;
@end
