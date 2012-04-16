#import "ArrayIterator.h"

@class LinkedList;

/**
 * LinkedList entry.
 */

@interface LLNode : NSObject
{
    LLNode *next;
    LLNode *prev;
    id item;
}

@property(retain) LLNode *next;
@property(retain) LLNode *prev;
@property(retain)      id item;

+ (LLNode *) newNode:(LLNode *)aPrev element:(id)anElement next:(LLNode *)aNext;

- (id) init:(LLNode *)aPrev element:(id)anElement next:(LLNode *)aNext;
- (void) dealloc;
@end

@interface ListIterator : ArrayIterator {
    LLNode * lastReturned;
    LLNode * next;
    NSInteger nextIndex;
    NSInteger expectedModCount;
    LinkedList *ll;
}

+ (ListIterator *) newIterator:(LinkedList *)anLL;
+ (ListIterator *) newIterator:(LinkedList *)anLL withIndex:(NSInteger)anIndex;

- (id) init:(LinkedList *)anLL withIndex:(NSInteger)anIndex;
- (BOOL) hasNext;
- (LLNode *) next;
- (BOOL) hasPrevious;
- (LLNode *) previous;
- (NSInteger) nextIndex;
- (NSInteger) previousIndex;
- (void) remove;
- (void) set:(LLNode *)e;
- (void) add:(LLNode *)e;
- (void) checkForComodification;
@end

/**
 * Adapter to provide descending iterators via ListItr.previous
 */

@interface DescendingIterator : ListIterator {
}

+ (DescendingIterator *) newIterator:(LinkedList *)anLL;
- (id) init:(LinkedList *)anLL;
- (BOOL) hasNext;
- (LLNode *) next;
- (void) remove;
- (void) dealloc;
@end

/**
 * Doubly-linked list implementation of the {@code List} and {@code Deque}
 * interfaces.  Implements all optional list operations, and permits all
 * elements (including {@code null}).
 * 
 * <p>All of the operations perform as could be expected for a doubly-linked
 * list.  Operations that index into the list will traverse the list from
 * the beginning or the end, whichever is closer to the specified index.
 * 
 * <p><strong>Note that this implementation is not synchronized.</strong>
 * If multiple threads access a linked list concurrently, and at least
 * one of the threads modifies the list structurally, it <i>must</i> be
 * synchronized externally.  (A structural modification is any operation
 * that adds or deletes one or more elements; merely setting the value of
 * an element is not a structural modification.)  This is typically
 * accomplished by synchronizing on some object that naturally
 * encapsulates the list.
 * 
 * If no such object exists, the list should be "wrapped" using the
 * {@link Collections#synchronizedList Collections.synchronizedList}
 * method.  This is best done at creation time, to prevent accidental
 * unsynchronized access to the list:<pre>
 * List list = Collections.synchronizedList(new LinkedList(...));</pre>
 * 
 * <p>The iterators returned by this class's {@code iterator} and
 * {@code listIterator} methods are <i>fail-fast</i>: if the list is
 * structurally modified at any time after the iterator is created, in
 * any way except through the Iterator's own {@code remove} or
 * {@code add} methods, the iterator will throw a {@link
 * ConcurrentModificationException}.  Thus, in the face of concurrent
 * modification, the iterator fails quickly and cleanly, rather than
 * risking arbitrary, non-deterministic behavior at an undetermined
 * time in the future.
 * 
 * <p>Note that the fail-fast behavior of an iterator cannot be guaranteed
 * as it is, generally speaking, impossible to make any hard guarantees in the
 * presence of unsynchronized concurrent modification.  Fail-fast iterators
 * throw {@code ConcurrentModificationException} on a best-effort basis.
 * Therefore, it would be wrong to write a program that depended on this
 * exception for its correctness:   <i>the fail-fast behavior of iterators
 * should be used only to detect bugs.</i>
 * 
 * <p>This class is a member of the
 * <a href="{@docRoot}/../technotes/guides/collections/index.html">
 * Java Collections Framework</a>.
 * 
 * @author  Josh Bloch
 * @see     List
 * @see     ArrayList
 * @since 1.2
 * @param <E> the type of elements held in this collection
 */

@interface LinkedList : NSObject {
    /**
     * Pointer to first node.
     * Invariant: (first == null && last == null) ||
     * (first.prev == null && first.item != null)
     */
    LLNode *first;
    
    /**
     * Pointer to last node.
     * Invariant: (first == null && last == null) ||
     * (last.next == null && last.item != null)
     */
    LLNode *last;
    NSInteger count;
    NSInteger modCount;
}

@property(nonatomic, retain) LLNode *first;
@property(nonatomic, retain) LLNode *last;
@property(assign) NSInteger count;
@property(assign) NSInteger modCount;

+ (LinkedList *)newLinkedList;
+ (LinkedList *)newLinkedList:(NSArray *)c;

- (id) init;
- (id) initWithC:(NSArray *)c;
- (void) linkLast:(LLNode *)e;
- (void) linkBefore:(LLNode *)e succ:(LLNode *)succ;
- (LLNode *) unlink:(LLNode *)x;
- (LLNode *) removeFirst;
- (LLNode *) removeLast;
- (void) addFirst:(LLNode *)e;
- (void) addLast:(LLNode *)e;
- (BOOL) contains:(id)o;
- (NSInteger) count;
- (BOOL) add:(LLNode *)e;
- (BOOL) remove:(id)o;
- (BOOL) addAll:(NSArray *)c;
- (BOOL) addAll:(NSInteger)index c:(NSArray *)c;
- (void) clear;
- (LLNode *) get:(NSInteger)index;
- (LLNode *) set:(NSInteger)index element:(LLNode *)element;
- (void) add:(NSInteger)index element:(LLNode *)element;
- (LLNode *) removeIdx:(NSInteger)index;
- (void) checkElementIndex:(NSInteger)index;
- (void) checkPositionIndex:(NSInteger)index;
- (LLNode *) node:(NSInteger)index;
- (NSInteger) indexOf:(id)o;
- (NSInteger) lastIndexOf:(id)o;
- (LLNode *) peek;
- (LLNode *) element;
- (LLNode *) poll;
- (LLNode *) remove;
- (BOOL) offer:(LLNode *)e;
- (BOOL) offerFirst:(LLNode *)e;
- (BOOL) offerLast:(LLNode *)e;
- (LLNode *) peekFirst;
- (LLNode *) peekLast;
- (LLNode *) pollFirst;
- (LLNode *) pollLast;
- (void) push:(LLNode *)e;
- (LLNode *) pop;
- (BOOL) removeFirstOccurrence:(id)o;
- (BOOL) removeLastOccurrence:(id)o;
- (ListIterator *) listIterator:(NSInteger)index;
- (NSEnumerator *) descendingIterator;
- (id) copyWithZone:(NSZone *)zone;
- (NSArray *) toArray;
- (NSArray *) toArray:(NSArray *)a;
@end
