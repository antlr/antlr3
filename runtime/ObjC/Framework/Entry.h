
@class HashTable;

/**
 * HashTable entry.
 */

@interface HTEntry : NSObject {
    HTEntry *next;
    NSInteger hash;
    NSString *key;
    id value;
}

@property(nonatomic, retain) HTEntry  *next;
@property(assign)           NSInteger  hash;
@property(nonatomic, retain) NSString *key;
@property(nonatomic, retain)        id value;

+ (HTEntry *)newEntry:(NSInteger)h key:(NSString *)k value:(id)v next:(HTEntry *) n;
- (id) init:(NSInteger)h key:(NSString *)k value:(id)v next:(HTEntry *)n;
- (id) copyWithZone:(NSZone *)zone;
- (void) setValue:(id)newValue;
- (BOOL) isEqualTo:(id)o;
- (NSInteger) hash;
- (NSString *) description;
@end

/**
 * LinkedMap entry.
 */

@interface LMNode : NSObject {
    LMNode *next;
    LMNode *prev;
    id item;
}

@property(nonatomic, retain) LMNode *next;
@property(nonatomic, retain) LMNode *prev;
@property(nonatomic, retain)      id item;

+ (LMNode *) newNode:(LMNode *)aPrev element:(id)anElement next:(LMNode *)aNext;
- (id) init:(LMNode *)aPrev element:(id)anElement next:(LMNode *)aNext;
@end

