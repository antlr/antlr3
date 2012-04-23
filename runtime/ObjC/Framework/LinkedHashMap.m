#import <Foundation/Foundation.h>
#import "AMutableArray.h"
#import "LinkedHashMap.h"
#import "RuntimeException.h"

extern NSInteger const DEFAULT_INITIAL_CAPACITY;
extern float const DEFAULT_LOAD_FACTOR;

@implementation LHMEntry

@synthesize before;
@synthesize after;
@synthesize accessOrder;

- (id) newEntry:(NSInteger)aHash key:(NSString *)aKey value:(id)aValue next:(LHMEntry *)aNext
{
    return [[LHMEntry alloc] init:aHash key:aKey value:aValue next:aNext];
}

- (id) init:(NSInteger)aHash key:(NSString *)aKey value:(id)aValue next:(LHMEntry *)aNext
{
    self = [super init:aHash key:aKey value:aValue next:aNext];
    if (self) {
    }
    return self;
}


- (void) dealloc
{
    [before release];
    [after release];
    [super dealloc];
}

/**
 * Removes this entry from the linked list.
 */
- (void) removeEntry
{
    before.after = after;
    after.before = before;
}


/**
 * Inserts this entry before the specified existing entry in the list.
 */
- (void) addBefore:(LHMEntry *)existingEntry
{
    after = [existingEntry retain];
    before = [existingEntry.before retain];
    before.after = [self retain];
    after.before = [self retain];
}


/**
 * This method is invoked by the superclass whenever the value
 * of a pre-existing entry is read by Map.get or modified by Map.set.
 * If the enclosing Map is access-ordered, it moves the entry
 * to the end of the list; otherwise, it does nothing.
 */
- (void) recordAccess:(LinkedHashMap *)m
{
    LinkedHashMap *lhm = (LinkedHashMap *)m;
    if (lhm.accessOrder) {
        lhm.modCount++;
        [self removeEntry];
        [self addBefore:lhm.header];
    }
}

- (void) recordRemoval:(LinkedHashMap *)m
{
    [self removeEntry];
}

@end

@implementation LinkedHashIterator

@synthesize nextEntry;
@synthesize lastReturned;
@synthesize lhm;

+ (LinkedHashIterator *) newIterator:(LinkedHashMap *)aLHM
{
    return [[LinkedHashIterator alloc] init:aLHM];
}

- (id) init:(LinkedHashMap *)aLHM
{
    self = [super init];
    if ( self ) {
        lhm = aLHM;
        nextEntry = lhm.header.after;
        lastReturned = nil;
        expectedModCount = lhm.modCount;
/*
        AMutableArray *a = [AMutableArray arrayWithCapacity:lhm.Capacity];
        LHMEntry *tmp = lhm.header.after;
        while ( tmp != lhm.header ) {
            [a addObject:tmp];
            tmp = tmp.after;
        }
        anArray = [NSArray arrayWithArray:a];
 */
    }
    return self;
}

- (BOOL) hasNext
{
    return nextEntry != lhm.header;
}

- (void) remove
{
    if (lastReturned == nil)
        @throw [[IllegalStateException newException] autorelease];
    if (lhm.modCount != expectedModCount)
        @throw [[ConcurrentModificationException newException:@"Unexpected modCount"] autorelease];
    [lhm remove:(NSString *)(lastReturned.key)];
    lastReturned = nil;
    expectedModCount = lhm.modCount;
}

- (LHMEntry *) nextEntry
{
    if (lhm.modCount != expectedModCount)
        @throw [[ConcurrentModificationException newException:@"Unexpected modCount"] autorelease];
    if (nextEntry == lhm.header)
        @throw [[[NoSuchElementException alloc] init] autorelease];
    LHMEntry * e = lastReturned = nextEntry;
    nextEntry = e.after;
    return e;
}

- (void) dealloc
{
    [nextEntry release];
    [lastReturned release];
    [super dealloc];
}

@end

@implementation LHMKeyIterator
+ (LHMKeyIterator *)newIterator:(LinkedHashMap *)aLHM
{
    return [[LHMKeyIterator alloc] init:aLHM];
}

- (id) init:(LinkedHashMap *)aLHM
{
    self = [super init:aLHM];
    if ( self ) {
    }
    return self;
}

- (NSString *) next
{
    return [self nextEntry].key;
}

@end

@implementation LHMValueIterator
+ (LHMValueIterator *)newIterator:(LinkedHashMap *)aLHM
{
    return [[LHMValueIterator alloc] init:aLHM];
}

- (id) init:(LinkedHashMap *)aLHM
{
    self = [super init:aLHM];
    if ( self ) {
    }
    return self;
}

- (id) next
{
    return [self nextEntry].value;
}

@end

@implementation LHMEntryIterator
+ (LHMEntryIterator *)newIterator:(LinkedHashMap *)aLHM
{
    return [[LHMEntryIterator alloc] init:aLHM];
}

- (id) init:(LinkedHashMap *)aLHM
{
    self = [super init:aLHM];
    if ( self ) {
    }
    return self;
}

- (LHMEntry *) next
{
    return [self nextEntry];
}

@end

//long const serialVersionUID = 3801124242820219131L;

@implementation LinkedHashMap

@synthesize header;
@synthesize accessOrder;

/**
 * Constructs an empty insertion-ordered <tt>LinkedHashMap</tt> instance
 * with the specified initial capacity and load factor.
 * 
 * @param  initialCapacity the initial capacity
 * @param  loadFactor      the load factor
 * @throws IllegalArgumentException if the initial capacity is negative
 * or the load factor is nonpositive
 */
+ (id) newLinkedHashMap:(NSInteger)anInitialCapacity
             loadFactor:(float)loadFactor
            accessOrder:(BOOL)anAccessOrder
{
    return [[LinkedHashMap alloc] init:anInitialCapacity
                            loadFactor:loadFactor
                           accessOrder:(BOOL)anAccessOrder];
}

+ (id) newLinkedHashMap:(NSInteger)anInitialCapacity loadFactor:(float)loadFactor
{
    return [[LinkedHashMap alloc] init:anInitialCapacity loadFactor:loadFactor];
}

+ (id) newLinkedHashMap:(NSInteger)anInitialCapacity
{
    return [[LinkedHashMap alloc] init:anInitialCapacity loadFactor:DEFAULT_LOAD_FACTOR];
}

/**
 * Constructs an empty <tt>LinkedHashMap</tt> instance with the
 * specified initial capacity, load factor and ordering mode.
 * 
 * @param  initialCapacity the initial capacity
 * @param  loadFactor      the load factor
 * @param  accessOrder     the ordering mode - <tt>true</tt> for
 * access-order, <tt>false</tt> for insertion-order
 * @throws IllegalArgumentException if the initial capacity is negative
 * or the load factor is nonpositive
 */
- (id) init:(NSInteger)anInitialCapacity loadFactor:(float)aLoadFactor accessOrder:(BOOL)anAccessOrder
{
    self = [super init:anInitialCapacity loadFactor:aLoadFactor];
    if ( self ) {
        accessOrder = anAccessOrder;
        header = [[[LHMEntry alloc] init:-1 key:nil value:nil next:nil] retain];
        header.before = header.after = header;
    }
    return self;
}

- (id) init:(NSInteger)anInitialCapacity loadFactor:(float)aLoadFactor
{
    self = [super init:anInitialCapacity loadFactor:aLoadFactor];
    if ( self ) {
        accessOrder = NO;
        header = [[[LHMEntry alloc] init:-1 key:nil value:nil next:nil] retain];
        header.before = header.after = header;
    }
    return self;
}

/**
 * Constructs an empty insertion-ordered <tt>LinkedHashMap</tt> instance
 * with the specified initial capacity and a default load factor (0.75).
 * 
 * @param  initialCapacity the initial capacity
 * @throws IllegalArgumentException if the initial capacity is negative
 */
- (id) init:(NSInteger)initialCapacity
{
    self = [super init:initialCapacity loadFactor:DEFAULT_LOAD_FACTOR];
    if ( self ) {
        accessOrder = NO;
        header = [[[LHMEntry alloc] init:-1 key:nil value:nil next:nil] retain];
        header.before = header.after = header;
    }
    return self;
}

/**
 * Constructs an insertion-ordered <tt>LinkedHashMap</tt> instance with
 * the same mappings as the specified map.  The <tt>LinkedHashMap</tt>
 * instance is created with a default load factor (0.75) and an initial
 * capacity sufficient to hold the mappings in the specified map.
 * 
 * @param  m the map whose mappings are to be placed in this map
 * @throws NullPointerException if the specified map is null
 */
- (id) initWithM:(LinkedHashMap *)m
{
    self = [super initWithM:m];
    if ( self ) {
        accessOrder = NO;
        header = [[[LHMEntry alloc] init:-1 key:nil value:nil next:nil] retain];
        header.before = header.after = header;
    }
    return self;
}

/**
 * Constructs an empty insertion-ordered <tt>LinkedHashMap</tt> instance
 * with the default initial capacity (16) and load factor (0.75).
 */
- (id) init
{
    self = [super init];
    if ( self ) {
        accessOrder = NO;
        header = [[[LHMEntry alloc] init:-1 key:nil value:nil next:nil] retain];
        header.before = header.after = header;
    }
    return self;
}


/**
 * Transfers all entries to new table array.  This method is called
 * by superclass resize.  It is overridden for performance, as it is
 * faster to iterate using our linked list.
 */
- (void) transfer:(AMutableArray *)newTable
{
    NSInteger newCapacity = [newTable count];
    
    for (LHMEntry * e = header.after; e != header; e = e.after) {
        NSInteger index = [self indexFor:e.hash length:newCapacity];
        e.next = [newTable objectAtIndex:index];
        [newTable replaceObjectAtIndex:index withObject:e];
    }
    
}

/**
 * Returns <tt>true</tt> if this map maps one or more keys to the
 * specified value.
 * 
 * @param value value whose presence in this map is to be tested
 * @return <tt>true</tt> if this map maps one or more keys to the
 * specified value
 */
- (BOOL) containsValue:(id)value
{
    if (value == nil) {
        
        for (LHMEntry * e = header.after; e != header; e = e.after)
            if (e.value == nil)
                return YES;
        
    }
    else {
        
        for (LHMEntry * e = header.after; e != header; e = e.after)
            if ([value isEqualTo:e.value])
                return YES;
        
    }
    return NO;
}

/**
 * Returns the value to which the specified key is mapped,
 * or {@code null} if this map contains no mapping for the key.
 * 
 * <p>More formally, if this map contains a mapping from a key
 * {@code k} to a value {@code v} such that {@code (key==null ? k==null :
 * key.equals(k))}, then this method returns {@code v}; otherwise
 * it returns {@code null}.  (There can be at most one such mapping.)
 * 
 * <p>A return value of {@code null} does not <i>necessarily</i>
 * indicate that the map contains no mapping for the key; it's also
 * possible that the map explicitly maps the key to {@code null}.
 * The {@link #containsKey containsKey} operation may be used to
 * distinguish these two cases.
 */
- (id) get:(NSString *)aKey
{
    LHMEntry * e = (LHMEntry *)[self getEntry:aKey];
    if (e == nil)
        return nil;
    [e recordAccess:self];
    return e.value;
}


/**
 * Removes all of the mappings from this map.
 * The map will be empty after this call returns.
 */
- (void) clear
{
    [super clear];
    header.before = header.after = header;
}

- (void) dealloc {
    [header release];
    [super dealloc];
}

- (LHMEntryIterator *) newEntryIterator
{
    return [LHMEntryIterator newIterator:self];
}

- (LHMKeyIterator *) newKeyIterator
{
    return [LHMKeyIterator newIterator:self];
}

- (LHMValueIterator *) newValueIterator
{
    return [LHMValueIterator newIterator:self];
}


/**
 * This override alters behavior of superclass put method. It causes newly
 * allocated entry to get inserted at the end of the linked list and
 * removes the eldest entry if appropriate.
 */
- (void) addEntry:(NSInteger)aHash key:(NSString *)aKey value:(id)aValue bucketIndex:(NSInteger)aBucketIndex
{
    [self createEntry:aHash key:aKey value:aValue bucketIndex:aBucketIndex];
    LHMEntry * eldest = header.after;
    if ([self removeEldestEntry:eldest]) {
        [self removeEntryForKey:eldest.key];
    }
    else {
        if (count >= threshold)
            [self resize:2 * [buffer length]];
    }
}


/**
 * This override differs from addEntry in that it doesn't resize the
 * table or remove the eldest entry.
 */
- (void) createEntry:(NSInteger)aHash key:(NSString *)aKey value:(id)aValue bucketIndex:(NSInteger)bucketIndex
{
    LHMEntry *old = (LHMEntry *)ptrBuffer[bucketIndex];
    LHMEntry *e = [[[LHMEntry alloc] init:aHash key:aKey value:aValue next:old] retain];
    ptrBuffer[bucketIndex] = (id)e;
    [e addBefore:header];
    count++;
}


/**
 * Returns <tt>true</tt> if this map should remove its eldest entry.
 * This method is invoked by <tt>put</tt> and <tt>putAll</tt> after
 * inserting a new entry into the map.  It provides the implementor
 * with the opportunity to remove the eldest entry each time a new one
 * is added.  This is useful if the map represents a cache: it allows
 * the map to reduce memory consumption by deleting stale entries.
 * 
 * <p>Sample use: this override will allow the map to grow up to 100
 * entries and then delete the eldest entry each time a new entry is
 * added, maintaining a steady state of 100 entries.
 * <pre>
 * private static final NSInteger MAX_ENTRIES = 100;
 * 
 * protected boolean removeEldestEntry(Map.LHMEntry eldest) {
 * return count() > MAX_ENTRIES;
 * }
 * </pre>
 * 
 * <p>This method typically does not modify the map in any way,
 * instead allowing the map to modify itself as directed by its
 * return value.  It <i>is</i> permitted for this method to modify
 * the map directly, but if it does so, it <i>must</i> return
 * <tt>false</tt> (indicating that the map should not attempt any
 * further modification).  The effects of returning <tt>true</tt>
 * after modifying the map from within this method are unspecified.
 * 
 * <p>This implementation merely returns <tt>false</tt> (so that this
 * map acts like a normal map - the eldest element is never removed).
 * 
 * @param    eldest The least recently inserted entry in the map, or if
 * this is an access-ordered map, the least recently accessed
 * entry.  This is the entry that will be removed it this
 * method returns <tt>true</tt>.  If the map was empty prior
 * to the <tt>put</tt> or <tt>putAll</tt> invocation resulting
 * in this invocation, this will be the entry that was just
 * inserted; in other words, if the map contains a single
 * entry, the eldest entry is also the newest.
 * @return   <tt>true</tt> if the eldest entry should be removed
 * from the map; <tt>false</tt> if it should be retained.
 */
- (BOOL) removeEldestEntry:(LHMEntry *)eldest
{
    return NO;
}

@end
