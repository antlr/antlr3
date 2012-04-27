#import "LinkedList.h"
#import <Foundation/Foundation.h>
#import "AMutableArray.h"
#import "RuntimeException.h"

@implementation LLNode

@synthesize next;
@synthesize prev;
@synthesize item;

+ (LLNode *) newNode:(LLNode *)aPrev element:(id)anElement next:(LLNode *)aNext
{
    return [[LLNode alloc] init:aPrev element:anElement next:aNext];
}

- (id) init:(LLNode *)aPrev element:(id)anElement next:(LLNode *)aNext
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

@implementation ListIterator

+ (ListIterator *) newIterator:(LinkedList *)anLL
{
    return [[ListIterator alloc] init:anLL withIndex:0];
}

+ (ListIterator *) newIterator:(LinkedList *)anLL withIndex:(NSInteger)anIndex
{
    return [[ListIterator alloc] init:anLL withIndex:anIndex];
}

- (id) init:(LinkedList *)anLL withIndex:(NSInteger)anIndex
{
    self = [super init];
    if ( self ) {
        ll = anLL;
        index = anIndex;
        lastReturned = nil;
        expectedModCount = ll.modCount;
        next = (index == count) ? nil : [ll node:anIndex];
        nextIndex = index;
    }
    return self;
}

- (BOOL) hasNext
{
    return nextIndex < count;
}

- (id) next
{
    [self checkForComodification];
    if (![self hasNext])
        @throw [[[NoSuchElementException alloc] init] autorelease];
    lastReturned = next;
    next = next.next;
    nextIndex++;
    return lastReturned.item;
}

- (BOOL) hasPrevious
{
    return nextIndex > 0;
}

- (id) previous
{
    [self checkForComodification];
    if (![self hasPrevious])
        @throw [[[NoSuchElementException alloc] init] autorelease];
    lastReturned = next = (next == nil) ? ll.last : next.prev;
    nextIndex--;
    return lastReturned.item;
}

- (NSInteger) nextIndex
{
    return nextIndex;
}

- (NSInteger) previousIndex
{
    return nextIndex - 1;
}

- (void) remove
{
    [self checkForComodification];
    if (lastReturned == nil)
        @throw [[[IllegalStateException alloc] init] autorelease];
    LLNode *lastNext = lastReturned.next;
    [ll unlink:lastReturned];
    if (next == lastReturned)
        next = lastNext;
    else
        nextIndex--;
    lastReturned = nil;
    expectedModCount++;
}

- (void) set:(id)e
{
    if (lastReturned == nil)
        @throw [[[IllegalStateException alloc] init] autorelease];
    [self checkForComodification];
    lastReturned.item = e;
}

- (void) add:(id)e
{
    [self checkForComodification];
    lastReturned = nil;
    if (next == nil)
        [ll linkLast:e];
    else
        [ll linkBefore:e succ:next];
    nextIndex++;
    expectedModCount++;
}

- (void) checkForComodification
{
    if (ll.modCount != expectedModCount)
        @throw [[[ConcurrentModificationException alloc] init] autorelease];
}

- (void) dealloc
{
    [lastReturned release];
    [next release];
    [super dealloc];
}

@end

@implementation DescendingIterator

+ (DescendingIterator *)newIterator:(LinkedList *)anLL
{
    return [[DescendingIterator alloc] init:anLL];
}

- (id) init:(LinkedList *)anLL
{
    self = [super init:anLL withIndex:[anLL count]];
    if ( self ) {
        
    }
    return self;
}

- (BOOL) hasNext
{
    return [self hasPrevious];
}

- (id) next
{
    return [self previous];
}

- (void) remove
{
    [self remove];
}

- (void) dealloc
{
    [super dealloc];
}

@end

//long const serialVersionUID = 876323262645176354L;

@implementation LinkedList

@synthesize first;
@synthesize last;
@synthesize count;
@synthesize modCount;

+ (LinkedList *)newLinkedList
{
    return [[LinkedList alloc] init];
}

+ (LinkedList *)newLinkedList:(NSArray *)c
{
    return [[LinkedList alloc] initWithC:c];
}

/**
 * Constructs an empty list.
 */
- (id) init
{
    self = [super init];
    if ( self ) {
        count = 0;
    }
    return self;
}


/**
 * Constructs a list containing the elements of the specified
 * collection, in the order they are returned by the collection's
 * iterator.
 * 
 * @param  c the collection whose elements are to be placed into this list
 * @throws NullPointerException if the specified collection is null
 */
- (id) initWithC:(NSArray *)c
{
    self = [super init];
    if ( self ) {
        count = 0;
        [self addAll:c];
    }
    return self;
}


- (void) dealloc
{
    [first release];
    [last release];
    [super dealloc];
}

/**
 * Links e as first element.
 */
- (void) linkFirst:(id)e
{
    LLNode *f = first;
    LLNode *newNode = [[LLNode newNode:nil element:e next:f] autorelease];
    first = newNode;
    if (f == nil)
        last = newNode;
    else
        f.prev = newNode;
    count++;
    modCount++;
}


/**
 * Links e as last element.
 */
- (void) linkLast:(id)e
{
    LLNode *l = last;
    LLNode *newNode = [[LLNode newNode:l element:e next:nil] autorelease];
    last = newNode;
    if (l == nil)
        first = newNode;
    else
        l.next = newNode;
    count++;
    modCount++;
}


/**
 * Inserts element e before non-null LLNode succ.
 */
- (void) linkBefore:(id)e succ:(LLNode *)succ
{
    LLNode *pred = succ.prev;
    LLNode *newNode = [[LLNode newNode:pred element:e next:succ] autorelease];
    succ.prev = newNode;
    if (pred == nil)
        first = newNode;
    else
        pred.next = newNode;
    count++;
    modCount++;
}


/**
 * Unlinks non-null first node f.
 */
- (id) unlinkFirst:(LLNode *)f
{
    id element = f.item;
    LLNode *next = f.next;
    f.item = nil;
    f.next = nil;
    first = next;
    if (next == nil)
        last = nil;
    else
        next.prev = nil;
    count--;
    modCount++;
    return element;
}


/**
 * Unlinks non-null last node l.
 */
- (id) unlinkLast:(LLNode *)l
{
    id element = l.item;
    LLNode *prev = l.prev;
    l.item = nil;
    l.prev = nil;
    last = prev;
    if (prev == nil)
        first = nil;
    else
        prev.next = nil;
    count--;
    modCount++;
    return element;
}


/**
 * Unlinks non-null node x.
 */
- (LLNode *) unlink:(LLNode *)x
{
    id element = x.item;
    LLNode *next = x.next;
    LLNode *prev = x.prev;
    if (prev == nil) {
        first = next;
    }
    else {
        prev.next = next;
        x.prev = nil;
    }
    if (next == nil) {
        last = prev;
    }
    else {
        next.prev = prev;
        x.next = nil;
    }
    x.item = nil;
    count--;
    modCount++;
    return element;
}


/**
 * Returns the first element in this list.
 * 
 * @return the first element in this list
 * @throws NoSuchElementException if this list is empty
 */
- (LLNode *) first
{
    LLNode *f = first;
    if (f == nil)
        @throw [[[NoSuchElementException alloc] init] autorelease];
    return f.item;
}


/**
 * Returns the last element in this list.
 * 
 * @return the last element in this list
 * @throws NoSuchElementException if this list is empty
 */
- (LLNode *) last
{
    LLNode *l = last;
    if (l == nil)
        @throw [[[NoSuchElementException alloc] init] autorelease];
    return l.item;
}


/**
 * Removes and returns the first element from this list.
 * 
 * @return the first element from this list
 * @throws NoSuchElementException if this list is empty
 */
- (LLNode *) removeFirst
{
    LLNode *f = first;
    if (f == nil)
        @throw [[[NoSuchElementException alloc] init] autorelease];
    return [self unlinkFirst:f];
}


/**
 * Removes and returns the last element from this list.
 * 
 * @return the last element from this list
 * @throws NoSuchElementException if this list is empty
 */
- (LLNode *) removeLast
{
    LLNode *l = last;
    if (l == nil)
        @throw [[[NoSuchElementException alloc] init] autorelease];
    return [self unlinkLast:l];
}


/**
 * Inserts the specified element at the beginning of this list.
 * 
 * @param e the element to add
 */
- (void) addFirst:(LLNode *)e
{
    [self linkFirst:e];
}


/**
 * Appends the specified element to the end of this list.
 * 
 * <p>This method is equivalent to {@link #add}.
 * 
 * @param e the element to add
 */
- (void) addLast:(LLNode *)e
{
    [self linkLast:e];
}


/**
 * Returns {@code true} if this list contains the specified element.
 * More formally, returns {@code true} if and only if this list contains
 * at least one element {@code e} such that
 * <tt>(o==null&nbsp;?&nbsp;e==null&nbsp;:&nbsp;o.equals(e))</tt>.
 * 
 * @param o element whose presence in this list is to be tested
 * @return {@code true} if this list contains the specified element
 */
- (BOOL) contains:(id)o
{
    return [self indexOf:o] != -1;
}


/**
 * Returns the number of elements in this list.
 * 
 * @return the number of elements in this list
 */
- (NSInteger) count
{
    return count;
}


/**
 * Appends the specified element to the end of this list.
 * 
 * <p>This method is equivalent to {@link #addLast}.
 * 
 * @param e element to be appended to this list
 * @return {@code true} (as specified by {@link Collection#add})
 */
- (BOOL) add:(LLNode *)e
{
    [self linkLast:e];
    return YES;
}


/**
 * Removes the first occurrence of the specified element from this list,
 * if it is present.  If this list does not contain the element, it is
 * unchanged.  More formally, removes the element with the lowest index
 * {@code i} such that
 * <tt>(o==null&nbsp;?&nbsp;get(i)==null&nbsp;:&nbsp;o.equals(get(i)))</tt>
 * (if such an element exists).  Returns {@code true} if this list
 * contained the specified element (or equivalently, if this list
 * changed as a result of the call).
 * 
 * @param o element to be removed from this list, if present
 * @return {@code true} if this list contained the specified element
 */
- (BOOL) remove:(id)o
{
    if (o == nil) {
        
        for (LLNode *x = first; x != nil; x = x.next) {
            if (x.item == nil) {
                [self unlink:x];
                return YES;
            }
        }
        
    }
    else {
        
        for (LLNode *x = first; x != nil; x = x.next) {
            if ([o isEqualTo:x.item]) {
                [self unlink:x];
                return YES;
            }
        }
        
    }
    return NO;
}


/**
 * Appends all of the elements in the specified collection to the end of
 * this list, in the order that they are returned by the specified
 * collection's iterator.  The behavior of this operation is undefined if
 * the specified collection is modified while the operation is in
 * progress.  (Note that this will occur if the specified collection is
 * this list, and it's nonempty.)
 * 
 * @param c collection containing elements to be added to this list
 * @return {@code true} if this list changed as a result of the call
 * @throws NullPointerException if the specified collection is null
 */
- (BOOL) addAll:(NSArray *)c
{
    return [self addAll:count c:c];
}


/**
 * Inserts all of the elements in the specified collection into this
 * list, starting at the specified position.  Shifts the element
 * currently at that position (if any) and any subsequent elements to
 * the right (increases their indices).  The new elements will appear
 * in the list in the order that they are returned by the
 * specified collection's iterator.
 * 
 * @param index index at which to insert the first element
 * from the specified collection
 * @param c collection containing elements to be added to this list
 * @return {@code true} if this list changed as a result of the call
 * @throws IndexOutOfBoundsException {@inheritDoc}
 * @throws NullPointerException if the specified collection is null
 */
- (BOOL) addAll:(NSInteger)index c:(NSArray *)c
{
    [self checkPositionIndex:index];
    AMutableArray *a = [AMutableArray arrayWithArray:c];
    NSInteger numNew = [a count];
    if (numNew == 0)
        return NO;
    LLNode *pred, *succ;
    if (index == count) {
        succ = nil;
        pred = last;
    }
    else {
        succ = [self node:index];
        pred = succ.prev;
    }
    
    for (id o in a) {
        id e = (id)o;
        LLNode *newNode = [[LLNode newNode:pred element:e next:nil] autorelease];
        if (pred == nil)
            first = newNode;
        else
            pred.next = newNode;
        pred = newNode;
    }
    
    if (succ == nil) {
        last = pred;
    }
    else {
        pred.next = succ;
        succ.prev = pred;
    }
    count += numNew;
    modCount++;
    return YES;
}


/**
 * Removes all of the elements from this list.
 * The list will be empty after this call returns.
 */
- (void) clear
{
    
    for (LLNode *x = first; x != nil; ) {
        LLNode *next = x.next;
        x.item = nil;
        x.next = nil;
        x.prev = nil;
        x = next;
    }
    
    first = last = nil;
    count = 0;
    modCount++;
}


/**
 * Returns the element at the specified position in this list.
 * 
 * @param index index of the element to return
 * @return the element at the specified position in this list
 * @throws IndexOutOfBoundsException {@inheritDoc}
 */
- (id) get:(NSInteger)index
{
    [self checkElementIndex:index];
    return [self node:index].item;
}


/**
 * Replaces the element at the specified position in this list with the
 * specified element.
 * 
 * @param index index of the element to replace
 * @param element element to be stored at the specified position
 * @return the element previously at the specified position
 * @throws IndexOutOfBoundsException {@inheritDoc}
 */
- (id) set:(NSInteger)index element:(id)element
{
    [self checkElementIndex:index];
    LLNode *x = [self node:index];
    id oldVal = x.item;
    x.item = element;
    return oldVal;
}


/**
 * Inserts the specified element at the specified position in this list.
 * Shifts the element currently at that position (if any) and any
 * subsequent elements to the right (adds one to their indices).
 * 
 * @param index index at which the specified element is to be inserted
 * @param element element to be inserted
 * @throws IndexOutOfBoundsException {@inheritDoc}
 */
- (void) add:(NSInteger)index element:(LLNode *)element
{
    [self checkPositionIndex:index];
    if (index == count)
        [self linkLast:element];
    else
        [self linkBefore:element succ:[self node:index]];
}


/**
 * Removes the element at the specified position in this list.  Shifts any
 * subsequent elements to the left (subtracts one from their indices).
 * Returns the element that was removed from the list.
 * 
 * @param index the index of the element to be removed
 * @return the element previously at the specified position
 * @throws IndexOutOfBoundsException {@inheritDoc}
 */
- (LLNode *) removeIdx:(NSInteger)index
{
    [self checkElementIndex:index];
    return [self unlink:[self node:index]];
}


/**
 * Tells if the argument is the index of an existing element.
 */
- (BOOL) isElementIndex:(NSInteger)index
{
    return index >= 0 && index < count;
}


/**
 * Tells if the argument is the index of a valid position for an
 * iterator or an add operation.
 */
- (BOOL) isPositionIndex:(NSInteger)index
{
    return index >= 0 && index <= count;
}


/**
 * Constructs an IndexOutOfBoundsException detail message.
 * Of the many possible refactorings of the error handling code,
 * this "outlining" performs best with both server and client VMs.
 */
- (NSString *) outOfBoundsMsg:(NSInteger)index
{
    return [NSString stringWithFormat:@"Index: %d, Size: %d", index, count];
}

- (void) checkElementIndex:(NSInteger)index
{
    if (![self isElementIndex:index])
        @throw [[IndexOutOfBoundsException newException:[self outOfBoundsMsg:index]] autorelease];
}

- (void) checkPositionIndex:(NSInteger)index
{
    if (![self isPositionIndex:index])
        @throw [[IndexOutOfBoundsException newException:[self outOfBoundsMsg:index]] autorelease];
}


/**
 * Returns the (non-null) LLNode at the specified element index.
 */
- (LLNode *) node:(NSInteger)index
{
    if (index < (count >> 1)) {
        LLNode *x = first;
        
        for (NSInteger i = 0; i < index; i++)
            x = x.next;
        
        return x;
    }
    else {
        LLNode *x = last;
        
        for (NSInteger i = count - 1; i > index; i--)
            x = x.prev;
        
        return x;
    }
}


/**
 * Returns the index of the first occurrence of the specified element
 * in this list, or -1 if this list does not contain the element.
 * More formally, returns the lowest index {@code i} such that
 * <tt>(o==null&nbsp;?&nbsp;get(i)==null&nbsp;:&nbsp;o.equals(get(i)))</tt>,
 * or -1 if there is no such index.
 * 
 * @param o element to search for
 * @return the index of the first occurrence of the specified element in
 * this list, or -1 if this list does not contain the element
 */
- (NSInteger) indexOf:(id)o
{
    NSInteger index = 0;
    if (o == nil) {
        
        for (LLNode *x = first; x != nil; x = x.next) {
            if (x.item == nil)
                return index;
            index++;
        }
        
    }
    else {
        
        for (LLNode *x = first; x != nil; x = x.next) {
            if ([o isEqualTo:x.item])
                return index;
            index++;
        }
        
    }
    return -1;
}


/**
 * Returns the index of the last occurrence of the specified element
 * in this list, or -1 if this list does not contain the element.
 * More formally, returns the highest index {@code i} such that
 * <tt>(o==null&nbsp;?&nbsp;get(i)==null&nbsp;:&nbsp;o.equals(get(i)))</tt>,
 * or -1 if there is no such index.
 * 
 * @param o element to search for
 * @return the index of the last occurrence of the specified element in
 * this list, or -1 if this list does not contain the element
 */
- (NSInteger) lastIndexOf:(id)o
{
    NSInteger index = count;
    if (o == nil) {
        
        for (LLNode *x = last; x != nil; x = x.prev) {
            index--;
            if (x.item == nil)
                return index;
        }
        
    }
    else {
        
        for (LLNode *x = last; x != nil; x = x.prev) {
            index--;
            if ([o isEqualTo:x.item])
                return index;
        }
        
    }
    return -1;
}


/**
 * Retrieves, but does not remove, the head (first element) of this list.
 * 
 * @return the head of this list, or {@code null} if this list is empty
 * @since 1.5
 */
- (LLNode *) peek
{
    LLNode *f = first;
    return (f == nil) ? nil : f.item;
}


/**
 * Retrieves, but does not remove, the head (first element) of this list.
 * 
 * @return the head of this list
 * @throws NoSuchElementException if this list is empty
 * @since 1.5
 */
- (LLNode *) element
{
    return [self first];
}


/**
 * Retrieves and removes the head (first element) of this list.
 * 
 * @return the head of this list, or {@code null} if this list is empty
 * @since 1.5
 */
- (LLNode *) poll
{
    LLNode *f = first;
    return (f == nil) ? nil : [self unlinkFirst:f];
}


/**
 * Retrieves and removes the head (first element) of this list.
 * 
 * @return the head of this list
 * @throws NoSuchElementException if this list is empty
 * @since 1.5
 */
- (LLNode *) remove
{
    return [self removeFirst];
}


/**
 * Adds the specified element as the tail (last element) of this list.
 * 
 * @param e the element to add
 * @return {@code true} (as specified by {@link Queue#offer})
 * @since 1.5
 */
- (BOOL) offer:(LLNode *)e
{
    return [self add:e];
}


/**
 * Inserts the specified element at the front of this list.
 * 
 * @param e the element to insert
 * @return {@code true} (as specified by {@link Deque#offerFirst})
 * @since 1.6
 */
- (BOOL) offerFirst:(LLNode *)e
{
    [self addFirst:e];
    return YES;
}


/**
 * Inserts the specified element at the end of this list.
 * 
 * @param e the element to insert
 * @return {@code true} (as specified by {@link Deque#offerLast})
 * @since 1.6
 */
- (BOOL) offerLast:(LLNode *)e
{
    [self addLast:e];
    return YES;
}


/**
 * Retrieves, but does not remove, the first element of this list,
 * or returns {@code null} if this list is empty.
 * 
 * @return the first element of this list, or {@code null}
 * if this list is empty
 * @since 1.6
 */
- (LLNode *) peekFirst
{
    LLNode *f = first;
    return (f == nil) ? nil : f.item;
}


/**
 * Retrieves, but does not remove, the last element of this list,
 * or returns {@code null} if this list is empty.
 * 
 * @return the last element of this list, or {@code null}
 * if this list is empty
 * @since 1.6
 */
- (LLNode *) peekLast
{
    LLNode *l = last;
    return (l == nil) ? nil : l.item;
}


/**
 * Retrieves and removes the first element of this list,
 * or returns {@code null} if this list is empty.
 * 
 * @return the first element of this list, or {@code null} if
 * this list is empty
 * @since 1.6
 */
- (LLNode *) pollFirst
{
    LLNode *f = first;
    return (f == nil) ? nil : [self unlinkFirst:f];
}


/**
 * Retrieves and removes the last element of this list,
 * or returns {@code null} if this list is empty.
 * 
 * @return the last element of this list, or {@code null} if
 * this list is empty
 * @since 1.6
 */
- (LLNode *) pollLast
{
    LLNode *l = last;
    return (l == nil) ? nil : [self unlinkLast:l];
}


/**
 * Pushes an element onto the stack represented by this list.  In other
 * words, inserts the element at the front of this list.
 * 
 * <p>This method is equivalent to {@link #addFirst}.
 * 
 * @param e the element to push
 * @since 1.6
 */
- (void) push:(LLNode *)e
{
    [self addFirst:e];
}


/**
 * Pops an element from the stack represented by this list.  In other
 * words, removes and returns the first element of this list.
 * 
 * <p>This method is equivalent to {@link #removeFirst()}.
 * 
 * @return the element at the front of this list (which is the top
 * of the stack represented by this list)
 * @throws NoSuchElementException if this list is empty
 * @since 1.6
 */
- (LLNode *) pop
{
    return [self removeFirst];
}


/**
 * Removes the first occurrence of the specified element in this
 * list (when traversing the list from head to tail).  If the list
 * does not contain the element, it is unchanged.
 * 
 * @param o element to be removed from this list, if present
 * @return {@code true} if the list contained the specified element
 * @since 1.6
 */
- (BOOL) removeFirstOccurrence:(id)o
{
    return [self remove:o];
}


/**
 * Removes the last occurrence of the specified element in this
 * list (when traversing the list from head to tail).  If the list
 * does not contain the element, it is unchanged.
 * 
 * @param o element to be removed from this list, if present
 * @return {@code true} if the list contained the specified element
 * @since 1.6
 */
- (BOOL) removeLastOccurrence:(id)o
{
    if (o == nil) {
        
        for (LLNode *x = last; x != nil; x = x.prev) {
            if (x.item == nil) {
                [self unlink:x];
                return YES;
            }
        }
        
    }
    else {
        
        for (LLNode *x = last; x != nil; x = x.prev) {
            if ([o isEqualTo:x.item]) {
                [self unlink:x];
                return YES;
            }
        }
        
    }
    return NO;
}


/**
 * Returns a list-iterator of the elements in this list (in proper
 * sequence), starting at the specified position in the list.
 * Obeys the general contract of {@code List.listIterator(NSInteger)}.<p>
 * 
 * The list-iterator is <i>fail-fast</i>: if the list is structurally
 * modified at any time after the Iterator is created, in any way except
 * through the list-iterator's own {@code remove} or {@code add}
 * methods, the list-iterator will throw a
 * {@code ConcurrentModificationException}.  Thus, in the face of
 * concurrent modification, the iterator fails quickly and cleanly, rather
 * than risking arbitrary, non-deterministic behavior at an undetermined
 * time in the future.
 * 
 * @param index index of the first element to be returned from the
 * list-iterator (by a call to {@code next})
 * @return a ListIterator of the elements in this list (in proper
 * sequence), starting at the specified position in the list
 * @throws IndexOutOfBoundsException {@inheritDoc}
 * @see List#listIterator(NSInteger)
 */
- (ListIterator *) listIterator:(NSInteger)index
{
    [self checkPositionIndex:index];
    return [[ListIterator newIterator:self withIndex:index] autorelease];
}


/**
 * @since 1.6
 */
- (NSEnumerator *) descendingIterator
{
    return [[[DescendingIterator alloc] init] autorelease];
}

/*
- (LinkedList *) superClone:(NSZone *)zone
{
    
    @try {
        return (LinkedList *)[super copyWithZone:zone];
    }
    @catch (CloneNotSupportedException * e) {
        @throw [[[NSException exceptionWithName:@"InternalException" reason:@"Attempted to Clone non-cloneable List" userInfo:nil] autorelease];
    }
}
*/

/**
 * Returns a shallow copy of this {@code LinkedList}. (The elements
 * themselves are not cloned.)
 * 
 * @return a shallow copy of this {@code LinkedList} instance
 */
- (id) copyWithZone:(NSZone *)zone
{
    LinkedList *clone = [LinkedList allocWithZone:zone];
    clone.first = nil;
    clone.last = nil;
    clone.count = 0;
    clone.modCount = 0;
    
    for (LLNode *x = first; x != nil; x = x.next)
        [clone add:x.item];
    
    clone.count = count;
    clone.first = first;
    clone.last = last;
    return clone;
}


/**
 * Returns an array containing all of the elements in this list
 * in proper sequence (from first to last element).
 * 
 * <p>The returned array will be "safe" in that no references to it are
 * maintained by this list.  (In other words, this method must allocate
 * a new array).  The caller is thus free to modify the returned array.
 * 
 * <p>This method acts as bridge between array-based and collection-based
 * APIs.
 * 
 * @return an array containing all of the elements in this list
 * in proper sequence
 */
- (NSArray *) toArray
{
    AMutableArray *result = [AMutableArray arrayWithCapacity:10];
    
    for (LLNode *x = first; x != nil; x = x.next)
        [result addObject:x.item];
    
    return result;
}


/**
 * Returns an array containing all of the elements in this list in
 * proper sequence (from first to last element); the runtime type of
 * the returned array is that of the specified array.  If the list fits
 * in the specified array, it is returned therein.  Otherwise, a new
 * array is allocated with the runtime type of the specified array and
 * the size of this list.
 * 
 * <p>If the list fits in the specified array with room to spare (i.e.,
 * the array has more elements than the list), the element in the array
 * immediately following the end of the list is set to {@code null}.
 * (This is useful in determining the length of the list <i>only</i> if
 * the caller knows that the list does not contain any null elements.)
 * 
 * <p>Like the {@link #toArray()} method, this method acts as bridge between
 * array-based and collection-based APIs.  Further, this method allows
 * precise control over the runtime type of the output array, and may,
 * under certain circumstances, be used to save allocation costs.
 * 
 * <p>Suppose {@code x} is a list known to contain only strings.
 * The following code can be used to dump the list into a newly
 * allocated array of {@code String}:
 * 
 * <pre>
 * String[] y = x.toArray(new String[0]);</pre>
 * 
 * Note that {@code toArray(new Object[0])} is identical in function to
 * {@code toArray()}.
 * 
 * @param a the array into which the elements of the list are to
 * be stored, if it is big enough; otherwise, a new array of the
 * same runtime type is allocated for this purpose.
 * @return an array containing the elements of the list
 * @throws ArrayStoreException if the runtime type of the specified array
 * is not a supertype of the runtime type of every element in
 * this list
 * @throws NullPointerException if the specified array is null
 */
- (NSArray *) toArray:(AMutableArray *)a
{
    if ( [a count] < count )
        a = (AMutableArray *)[AMutableArray arrayWithArray:a];
    AMutableArray *result = a;
    
    for (LLNode *x = first; x != nil; x = x.next)
        [result addObject:x.item];
    
    if ([a count] > count)
        [a replaceObjectAtIndex:count withObject:nil];
    return a;
}


/**
 * Saves the state of this {@code LinkedList} instance to a stream
 * (that is, serializes it).
 * 
 * @serialData The size of the list (the number of elements it
 * contains) is emitted (NSInteger), followed by all of its
 * elements (each an Object) in the proper order.
 */
- (void) writeObject:(NSOutputStream *)s
{
/*
    [s defaultWriteObject];
    [s writeInt:count];
    
    for (LLNode *x = first; x != nil; x = x.next)
        [s writeObject:x.item];
 */
}


/**
 * Reconstitutes this {@code LinkedList} instance from a stream
 * (that is, deserializes it).
 */
- (void) readObject:(NSInputStream *)s
{
/*
    [s defaultReadObject];
    NSInteger len = [s readInt];
    
    for (NSInteger i = 0; i < len; i++)
        [self linkLast:(id)[s readObject]];
 */
}

@end
