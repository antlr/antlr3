#import "ANTLRDoubleKeyMap.h"

@implementation ANTLRDoubleKeyMap

- (id) init
{
    self = [super init];
    if ( self  != nil ) {
        data = [[AMutableDictionary dictionaryWithCapacity:30] retain];
    }
    return self;
}

- (id) setObject:(id)v forKey1:(id)k1 forKey2:(id)k2
{
    AMutableDictionary *data2 = [data objectForKey:k1];
    id prev = nil;
    if ( data2 == nil ) {
        data2 = [AMutableDictionary dictionaryWithCapacity:30];
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
    AMutableDictionary *data2 = [data objectForKey:k1];
    if ( data2 == nil )
        return nil;
    return [data2 objectForKey:k2];
}

- (AMutableDictionary *) objectForKey:(id)k1
{
    return [data objectForKey:k1];
}


/**
 * Get all values associated with primary key
 */
- (NSArray *) valuesForKey:(id)k1
{
    AMutableDictionary *data2 = [data objectForKey:k1];
    if ( data2 == nil )
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
    AMutableDictionary * data2 = [data objectForKey:k1];
    if ( data2 == nil )
        return nil;
    return [data2 allKeys];
}

- (AMutableArray *) values
{
//    ANTLRHashMap *s = [[ANTLRHashMap newANTLRHashMapWithLen:30];
    AMutableArray *s = [AMutableArray arrayWithCapacity:30];
    
    for (AMutableDictionary *k2 in [data allValues]) {
        
        for ( NSString *v in [k2 allValues]) {
            [s addObject:v];
        }
        
    }
    
    return s;
}

- (void) dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in ANTLRCommonToken" );
#endif
    [data release];
    [super dealloc];
}

@synthesize data;
@end
