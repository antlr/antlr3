
#import "AMutableArray.h"
#import "AMutableDictionary.h"
#import "ANTLRLinkBase.h"
/**
 * Sometimes we need to map a key to a value but key is two pieces of data.
 * This nested hash table saves creating a single key each time we access
 * map; avoids mem creation.
 */

@class AMutableArray;

@interface ANTLRDoubleKeyMap : ANTLRLinkBase {
    AMutableDictionary *data;
}

- (id) init;
- (id) setObject:(id)v forKey1:(id)k1 forKey2:(NSString *)k2;
- (id) objectForKey1:(id)k1 forKey2:(id)k2;
- (AMutableDictionary *) objectForKey:(id)k1;
- (NSArray *) valuesForKey:(id)k1;
- (NSArray *) allKeys1;
- (AMutableArray *) allKeys2:(id)k1;
- (NSArray *) values;

@property (retain) AMutableDictionary *data;

@end
