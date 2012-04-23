//
//  HashMap.h
//  ANTLR
//
// Copyright (c) 2010 Alan Condit
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products
//    derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <Foundation/Foundation.h>
#import "AMutableArray.h"
#import "AMutableDictionary.h"
#import "ArrayIterator.h"
#import "LinkBase.h"
#import "MapElement.h"
#import "PtrBuffer.h"

#define GLOBAL_SCOPE       0
#define LOCAL_SCOPE        1
#define HASHSIZE         101
#define HBUFSIZE      0x2000

@class HashMap;

/**
 * HashMap entry.
 */

@interface HMEntry : NSObject {
    HMEntry  *next;
    NSInteger hash;
    NSString *key;
    id value;
}

@property(nonatomic, retain) HMEntry  *next;
@property(assign)            NSInteger  hash;
@property(nonatomic, retain) NSString *key;
@property(nonatomic, retain) id value;

+ (HMEntry *)newEntry:(NSInteger)h key:(NSString *)k value:(id)v next:(HMEntry *) n;
- (id) init:(NSInteger)h key:(NSString *)k value:(id)v next:(HMEntry *)n;
- (void) setValue:(id)newValue;
- (BOOL) isEqualTo:(id)o;
- (NSInteger) hashCode;
- (NSString *) description;
- (void) recordAccess:(HashMap *)m;
- (void) recordRemoval:(HashMap *)m;
@end

@interface HashIterator : ArrayIterator {
    HMEntry  *next;
    NSInteger expectedModCount;
    NSInteger idx;
    HMEntry  *current;
    HashMap  *hm;
}

+ (HashIterator *) newIterator:(HashMap *)aHM;

- (id) init:(HashMap *)aHM;
- (BOOL) hasNext;
- (HMEntry *) next;
- (void) remove;
@end

@interface HMEntryIterator : HashIterator
{
}

+ (HMEntryIterator *)newIterator:(HashMap *)aHM;

- (id) init:(HashMap *)aHM;
- (HMEntry *) next;
@end

@interface HMValueIterator : HashIterator
{
}

+ (HMValueIterator *)newIterator:(HashMap *)aHM;

- (id) init:(HashMap *)aHM;
- (id) next;
@end

@interface HMKeyIterator : HashIterator
{
}

+ (HMKeyIterator *)newIterator:(HashMap *)aHM;

- (id) init:(HashMap *)aHM;
- (NSString *) next;
@end

@interface HMKeySet : NSSet
{
    HashMap *hm;
    AMutableArray *anArray;
}

@property (retain) HashMap *hm;
@property (retain) AMutableArray *anArray;

+ (HMKeySet *)newKeySet:(HashMap *)aHM;

- (id) init:(HashMap *)aHM;
- (HashIterator *) iterator;
- (NSUInteger) count;
- (BOOL) contains:(id)o;
- (BOOL) remove:(id)o;
- (void) clear;
- (AMutableArray *)toArray;
@end

@interface Values : PtrBuffer
{
    HashMap *hm;
    AMutableArray *anArray;
}

@property (retain) HashMap *hm;
@property (retain) AMutableArray *anArray;

+ (Values *)newValueSet:(HashMap *)aHM;

- (id) init:(HashMap *)aHM;
- (HashIterator *) iterator;
- (NSUInteger) count;
- (BOOL) contains:(id)o;
- (void) clear;
- (AMutableArray *)toArray;
@end

@interface HMEntrySet : NSSet
{
    HashMap *hm;
    AMutableArray *anArray;
}

@property (retain) HashMap *hm;
@property (retain) AMutableArray *anArray;

+ (HMEntrySet *)newEntrySet:(HashMap *)aHM;

- (id) init:(HashMap *)aHM;
- (HashIterator *) iterator;
- (BOOL) contains:(id)o;
- (BOOL) remove:(id)o;
- (NSUInteger) count;
- (void) clear;
- (NSArray *)toArray;
@end

@interface HashMap : LinkBase {
    //    TStringPool *fPool;
    NSInteger Scope;
    NSInteger LastHash;
    NSInteger BuffSize;
    NSInteger Capacity;
    /**
     * The number of key-value mappings contained in this map.
     */
    NSUInteger count;
    NSUInteger ptr;
    __strong NSMutableData *buffer;
    __strong MapElement **ptrBuffer;
    NSInteger mode;
    /**
     * The table, resized as necessary. Length MUST Always be a power of two.
     */
//    AMutableArray *table;
    
    /**
     * The next size value at which to resize (capacity * load factor).
     * @serial
     */
    NSInteger threshold;
    
    /**
     * The load factor for the hash table.
     * 
     * @serial
     */
    float loadFactor;
    /**
     * The number of times this HashMap has been structurally modified
     * Structural modifications are those that change the number of mappings in
     * the HashMap or otherwise modify its internal structure (e.g.,
     * rehash).  This field is used to make iterators on Collection-views of
     * the HashMap fail-fast.  (See ConcurrentModificationException).
     */
    NSInteger modCount;
    HMEntrySet *entrySet;
    BOOL empty;
    HMKeySet *keySet;
    Values *values;
}

//@property (copy) TStringPool *fPool;
@property (getter=getScope, setter=setScope:) NSInteger Scope;
@property (getter=getLastHash, setter=setLastHash:) NSInteger LastHash;

@property (getter=getMode,setter=setMode:) NSInteger mode;
@property (assign) NSInteger BuffSize;
@property (assign) NSInteger Capacity;
@property (getter=getCount, setter=setCount:) NSUInteger count;
@property (assign) NSUInteger ptr;
@property (retain, getter=getBuffer, setter=setBuffer:) NSMutableData *buffer;
@property (assign, getter=getPtrBuffer, setter=setPtrBuffer:) MapElement **ptrBuffer;
@property (assign) NSInteger threshold;
@property (assign) float loadFactor;
@property (assign) NSInteger modCount;
@property (retain) HMEntrySet *entrySet;
@property (nonatomic, readonly) BOOL empty;
@property (retain) HMKeySet *keySet;
@property (retain) Values *values;

// Contruction/Destruction
+ (id) newHashMap;
+ (id) newHashMap:(NSInteger)anInitialCapacity loadFactor:(float)loadFactor;
+ (id) newHashMap:(NSInteger)anInitialCapacity;
+ (id) newHashMapWithLen:(NSInteger)aBuffSize;
- (id) init;
- (id) initWithLen:(NSInteger)aBuffSize;
- (id) init:(NSInteger)anInitialCapacity;
- (id) init:(NSInteger)anInitialCapacity loadFactor:(float)loadFactor;
- (id) initWithM:(HashMap *)m;
- (void)dealloc;
- (HashMap *)PushScope:( HashMap **)map;
- (HashMap *)PopScope:( HashMap **)map;

- (NSUInteger)count;
- (NSInteger)size;

// Instance Methods
/*    form hash value for string s */
- (NSInteger)hash:(NSString *)s;
- (NSInteger)hashInt:(NSInteger)anInt;
- (NSInteger) indexFor:(NSInteger)h length:(NSInteger)length;
/*   look for s in ptrBuffer  */
- (HashMap *)findscope:(NSInteger)level;
/*   look for s in ptrBuffer  */
- (id)lookup:(NSString *)s Scope:(NSInteger)scope;
/*   look for s in ptrBuffer  */
- (id)install:(MapElement *)sym Scope:(NSInteger)scope;
/*   look for s in ptrBuffer  */
- (void)deleteHashMap:(MapElement *)np;
- (NSInteger)RemoveSym:(NSString *)s;
- (void)delete_chain:(MapElement *)np;
#ifdef DONTUSEYET
- (int)bld_symtab:(KW_TABLE *)toknams;
#endif
- (MapElement **)getptrBuffer;
- (MapElement *)getptrBufferEntry:(NSInteger)idx;
- (void)setptrBuffer:(MapElement *)np Index:(NSInteger)idx;
- (NSInteger)getScope;
- (void)setScope:(NSInteger)i;
- (MapElement *)getTType:(NSString *)name;
- (MapElement *)getNameInList:(NSInteger)ttype;
- (void)putNode:(NSString *)name TokenType:(NSInteger)ttype;
- (NSInteger)getMode;
- (void)setMode:(NSInteger)aMode;
- (void) insertObject:(id)aRule atIndex:(NSInteger)idx;
- (id) objectAtIndex:(NSInteger)idx;
- (void) setObject:(id)aRule atIndex:(NSInteger)idx;
- (void)addObject:(id)anObject;
- (MapElement *) getName:(NSString *)aName;
- (void) putName:(NSString *)name Node:(id)aNode;

- (NSEnumerator *)objectEnumerator;
- (BOOL) hasNext;
- (MapElement *)nextObject;

- (NSUInteger) count;
- (id) get:(NSString *)key;
- (id) getForNullKey;
- (BOOL) containsKey:(NSString *)key;
- (HMEntry *) getEntry:(NSString *)key;
- (id) put:(NSString *)key value:(id)value;
- (id) putForNullKey:(id)value;
- (void) putForCreate:(NSString *)key value:(id)value;
- (void) putAllForCreate:(HashMap *)m;
- (void) resize:(NSInteger)newCapacity;
- (void) transfer:(NSArray *)newTable;
- (void) putAll:(HashMap *)m;
- (id) remove:(NSString *)key;
- (HMEntry *) removeEntryForKey:(NSString *)key;
- (HMEntry *) removeMapping:(id)o;
- (void) clear;
- (BOOL) containsValue:(id)value;
- (id) copyWithZone:(NSZone *)zone;
- (NSString *) description;
- (void) addEntry:(NSInteger)hash key:(NSString *)key value:(id)value bucketIndex:(NSInteger)bucketIndex;
- (void) createEntry:(NSInteger)hash key:(NSString *)key value:(id)value bucketIndex:(NSInteger)bucketIndex;
- (HMKeyIterator *) newKeyIterator;
- (HMValueIterator *) newValueIterator;
- (HMEntryIterator *) newEntryIterator;
- (HMKeySet *) keySet;
- (Values *) values;
- (HMEntrySet *) entrySet;
- (NSInteger) capacity;
- (float) loadFactor;

@end
