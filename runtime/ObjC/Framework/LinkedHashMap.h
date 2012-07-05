#import "HashMap.h"
/**
 * <p>Hash table and linked list implementation of the <tt>Map</tt> interface,
 * with predictable iteration order.  This implementation differs from
 * <tt>HashMap</tt> in that it maintains a doubly-linked list running through
 * all of its entries.  This linked list defines the iteration ordering,
 * which is normally the order in which keys were inserted into the map
 * (<i>insertion-order</i>).  Note that insertion order is not affected
 * if a key is <i>re-inserted</i> into the map.  (A key <tt>k</tt> is
 * reinserted into a map <tt>m</tt> if <tt>m.put(k, v)</tt> is invoked when
 * <tt>m.containsKey(k)</tt> would return <tt>true</tt> immediately prior to
 * the invocation.)
 * 
 * <p>This implementation spares its clients from the unspecified, generally
 * chaotic ordering provided by {@link HashMap} (and {@link Hashtable}),
 * without incurring the increased cost associated with {@link TreeMap}.  It
 * can be used to produce a copy of a map that has the same order as the
 * original, regardless of the original map's implementation:
 * <pre>
 * void foo(Map m) {
 * Map copy = new LinkedHashMap(m);
 * ...
 * }
 * </pre>
 * This technique is particularly useful if a module takes a map on input,
 * copies it, and later returns results whose order is determined by that of
 * the copy.  (Clients generally appreciate having things returned in the same
 * order they were presented.)
 * 
 * <p>A special {@link #LinkedHashMap(NSInteger,float,boolean) constructor} is
 * provided to create a linked hash map whose order of iteration is the order
 * in which its entries were last accessed, from least-recently accessed to
 * most-recently (<i>access-order</i>).  This kind of map is well-suited to
 * building LRU caches.  Invoking the <tt>put</tt> or <tt>get</tt> method
 * results in an access to the corresponding entry (assuming it exists after
 * the invocation completes).  The <tt>putAll</tt> method generates one entry
 * access for each mapping in the specified map, in the order that key-value
 * mappings are provided by the specified map's entry set iterator.  <i>No
 * other methods generate entry accesses.</i> In particular, operations on
 * collection-views do <i>not</i> affect the order of iteration of the backing
 * map.
 * 
 * <p>The {@link #removeEldestEntry(Map.Entry)} method may be overridden to
 * impose a policy for removing stale mappings automatically when new mappings
 * are added to the map.
 * 
 * <p>This class provides all of the optional <tt>Map</tt> operations, and
 * permits null elements.  Like <tt>HashMap</tt>, it provides constant-time
 * performance for the basic operations (<tt>add</tt>, <tt>contains</tt> and
 * <tt>remove</tt>), assuming the hash function disperses elements
 * properly among the buckets.  Performance is likely to be just slightly
 * below that of <tt>HashMap</tt>, due to the added expense of maintaining the
 * linked list, with one exception: Iteration over the collection-views
 * of a <tt>LinkedHashMap</tt> requires time proportional to the <i>size</i>
 * of the map, regardless of its capacity.  Iteration over a <tt>HashMap</tt>
 * is likely to be more expensive, requiring time proportional to its
 * <i>capacity</i>.
 * 
 * <p>A linked hash map has two parameters that affect its performance:
 * <i>initial capacity</i> and <i>load factor</i>.  They are defined precisely
 * as for <tt>HashMap</tt>.  Note, however, that the penalty for choosing an
 * excessively high value for initial capacity is less severe for this class
 * than for <tt>HashMap</tt>, as iteration times for this class are unaffected
 * by capacity.
 * 
 * <p><strong>Note that this implementation is not synchronized.</strong>
 * If multiple threads access a linked hash map concurrently, and at least
 * one of the threads modifies the map structurally, it <em>must</em> be
 * synchronized externally.  This is typically accomplished by
 * synchronizing on some object that naturally encapsulates the map.
 * 
 * If no such object exists, the map should be "wrapped" using the
 * {@link Collections#synchronizedMap Collections.synchronizedMap}
 * method.  This is best done at creation time, to prevent accidental
 * unsynchronized access to the map:<pre>
 * Map m = Collections.synchronizedMap(new LinkedHashMap(...));</pre>
 * 
 * A structural modification is any operation that adds or deletes one or more
 * mappings or, in the case of access-ordered linked hash maps, affects
 * iteration order.  In insertion-ordered linked hash maps, merely changing
 * the value associated with a key that is already contained in the map is not
 * a structural modification.  <strong>In access-ordered linked hash maps,
 * merely querying the map with <tt>get</tt> is a structural
 * modification.</strong>)
 * 
 * <p>The iterators returned by the <tt>iterator</tt> method of the collections
 * returned by all of this class's collection view methods are
 * <em>fail-fast</em>: if the map is structurally modified at any time after
 * the iterator is created, in any way except through the iterator's own
 * <tt>remove</tt> method, the iterator will throw a {@link
 * ConcurrentModificationException}.  Thus, in the face of concurrent
 * modification, the iterator fails quickly and cleanly, rather than risking
 * arbitrary, non-deterministic behavior at an undetermined time in the future.
 * 
 * <p>Note that the fail-fast behavior of an iterator cannot be guaranteed
 * as it is, generally speaking, impossible to make any hard guarantees in the
 * presence of unsynchronized concurrent modification.  Fail-fast iterators
 * throw <tt>ConcurrentModificationException</tt> on a best-effort basis.
 * Therefore, it would be wrong to write a program that depended on this
 * exception for its correctness:   <i>the fail-fast behavior of iterators
 * should be used only to detect bugs.</i>
 * 
 * <p>This class is a member of the
 * <a href="{@docRoot}/../technotes/guides/collections/index.html">
 * Java Collections Framework</a>.
 * 
 * @param <K> the type of keys maintained by this map
 * @param <V> the type of mapped values
 * 
 * @author  Josh Bloch
 * @see     Object#hashCode()
 * @see     Collection
 * @see     Map
 * @see     HashMap
 * @see     TreeMap
 * @see     Hashtable
 * @since   1.4
 */
@class LinkedHashMap;

/**
 * LinkedHashMap entry.
 */

@interface LHMEntry : HMEntry
{
    LHMEntry *before;
    LHMEntry *after;
    BOOL accessOrder;
}

@property (retain) LHMEntry *before;
@property (retain) LHMEntry *after;
@property (assign) BOOL accessOrder;

- (id) newEntry:(NSInteger)aHash key:(NSString *)aKey value:(id)aValue next:(LHMEntry *)aNext;

- (id) init:(NSInteger)hash key:(NSString *)key value:(id)value next:(LHMEntry *)next;
- (void) recordAccess:(LinkedHashMap *)m;
- (void) recordRemoval:(LinkedHashMap *)m;

@end

/**
 * LinkedHashMapIterator.
 */

@interface LinkedHashIterator : HashIterator
{
    LHMEntry *nextEntry;
    LHMEntry *lastReturned;
    LinkedHashMap *lhm;
}

@property (retain) LHMEntry *nextEntry;
@property (retain) LHMEntry *lastReturned;
@property (retain) LinkedHashMap *lhm;

+ (LinkedHashIterator *) newIterator:(LinkedHashMap *)aLHM;

- (id) init:(LinkedHashMap *)aLHM;
- (BOOL) hasNext;
- (void) remove;
- (LHMEntry *) nextEntry;
@end

@interface LHMEntryIterator : LinkedHashIterator
{
}

+ (LHMEntryIterator *)newIterator:(LinkedHashMap *)aHM;

- (id) init:(LinkedHashMap *)aHM;
- (LHMEntry *) next;
@end

@interface LHMKeyIterator : LinkedHashIterator
{
}

+ (LHMKeyIterator *)newIterator:(LinkedHashMap *)aHM;

- (id) init:(LinkedHashMap *)aHM;
- (NSString *) next;
@end

@interface LHMValueIterator : LinkedHashIterator
{
}

+ (LHMValueIterator *)newIterator:(LinkedHashMap *)aHM;

- (id) init:(LinkedHashMap *)aHM;
- (id) next;
@end


@interface LinkedHashMap : HashMap
{
    
    /**
     * The head of the doubly linked list.
     */
    LHMEntry *header;
    /**
     * The iteration ordering method for this linked hash map: <tt>true</tt>
     * for access-order, <tt>false</tt> for insertion-order.
     * 
     * @serial
     */
    BOOL accessOrder;
    
}

@property (retain) LHMEntry *header;
@property (assign) BOOL accessOrder;

+ (id) newLinkedHashMap:(NSInteger)anInitialCapacity;
+ (id) newLinkedHashMap:(NSInteger)anInitialCapacity
             loadFactor:(float)loadFactor;
+ (id) newLinkedHashMap:(NSInteger)anInitialCapacity
             loadFactor:(float)loadFactor
            accessOrder:(BOOL)anAccessOrder;

- (id) init:(NSInteger)initialCapacity loadFactor:(float)loadFactor accessOrder:(BOOL)accessOrder;
- (id) init:(NSInteger)initialCapacity loadFactor:(float)loadFactor;
- (id) init:(NSInteger)initialCapacity;
- (id) init;
- (id) initWithM:(AMutableDictionary *)m;
- (void) transfer:(NSArray *)newTable;
- (BOOL) containsValue:(NSObject *)value;
- (id) get:(NSString *)key;
- (void) clear;
- (LHMEntryIterator *) newEntryIterator;
- (LHMKeyIterator *) newKeyIterator;
- (LHMValueIterator *) newValueIterator;
- (void) addEntry:(NSInteger)hash key:(NSString *)key value:(id)value bucketIndex:(NSInteger)bucketIndex;
- (void) createEntry:(NSInteger)hash key:(NSString *)key value:(id)value bucketIndex:(NSInteger)bucketIndex;
- (BOOL) removeEldestEntry:(LHMEntry *)eldest;
@end
