//
//  HashMap.m
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

#define SUCCESS (0)
#define FAILURE (-1)

#import "HashMap.h"
#import "AMutableArray.h"
#import "RuntimeException.h"

extern NSInteger max(NSInteger a, NSInteger b);

static NSInteger itIndex;

@implementation HMEntry

@synthesize next;
@synthesize hash;
@synthesize key;
@synthesize value;

/**
 * Creates new entry.
 */
+ (HMEntry *)newEntry:(NSInteger)h key:(NSString *)k value:(id)v next:(HMEntry *) n
{
    return [[HMEntry alloc] init:h key:k value:v next:n];
}

- (id) init:(NSInteger)h key:(NSString *)k value:(id)v next:(HMEntry *)n
{
    self = [super init];
    if ( self ) {
        value = v;
        next = n;
        key = k;
        hash = h;
    }
    return self;
}

- (void) setValue:(id)newValue
{
    value = newValue;
    //    return oldValue;
}

- (BOOL) isEqualTo:(id)o
{
    /*
     if (!([o conformsToProtocol:@protocol(HMEntry)]))
     return NO;
     */
    HMEntry *e = (HMEntry *)o;
    NSString *k1 = [self key];
    NSString *k2 = [e key];
    if (k1 == k2 || (k1 != nil && [k1 isEqualTo:k2])) {
        id v1 = [self value];
        id v2 = [e value];
        if (v1 == v2 || (v1 != nil && [v1 isEqualTo:v2]))
            return YES;
    }
    return NO;
}

- (NSInteger) hashCode
{
    return (key == nil ? 0 : [key hash]) ^ (value == nil ? 0 : [value hash]);
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@ = %@",[key description], [value description]];
}


/**
 * This method is invoked whenever the value in an entry is
 * overwritten by an invocation of put(k,v) for a key k that's already
 * in the HashMap.
 */
- (void) recordAccess:(HashMap *)m
{
}


/**
 * This method is invoked whenever the entry is
 * removed from the table.
 */
- (void) recordRemoval:(HashMap *)m
{
}

- (void) dealloc
{
    [key release];
    [value release];
    [next release];
    [super dealloc];
}

@end

@implementation HashIterator

+ (HashIterator *)newIterator:(HashMap *)aHM
{
    return [[HashIterator alloc] init:aHM];
}

- (id) init:(HashMap *)aHM
{
    self = [super init];
    if ( self ) {
        hm = aHM;
        expectedModCount = hm.modCount;
        if (count > 0) {
            while ( idx < [hm.buffer length] ) {
                next = (HMEntry *)hm.ptrBuffer[idx++];
                if ( next == nil )
                    break;
            }
        }
    }
    return self;
}

- (BOOL) hasNext
{
    return next != nil;
}

- (HMEntry *) next
{
//    if (hm.modCount != expectedModCount)
//        @throw [[ConcurrentModificationException alloc] init];
    HMEntry *e = next;
    if (e == nil)
        @throw [[NoSuchElementException alloc] init];
    if ((next = e.next) == nil) {
        while ( idx < [hm.buffer length] ) {
            next = [anArray objectAtIndex:idx++];
            if ( next == nil )
                break;
        }
    }
    current = e;
    return e;
}

- (void) remove
{
    if (current == nil)
        @throw [[IllegalStateException alloc] init];
//    if (modCount != expectedModCount)
//        @throw [[ConcurrentModificationException alloc] init];
    NSString *k = current.key;
    current = nil;
    [hm removeEntryForKey:k];
    expectedModCount = hm.modCount;
}

- (void) dealloc
{
    [next release];
    [current release];
    [super dealloc];
}

@end

@implementation HMValueIterator

+ (HMValueIterator *)newIterator:(HashMap *)aHM
{
    return [[HMValueIterator alloc] init:aHM];
}

- (id) init:(HashMap *)aHM
{
    self = [super init:aHM];
    if ( self ) {
    }
    return self;
}

- (id) next
{
    return [super next].value;
}

@end

@implementation HMKeyIterator

+ (HMKeyIterator *)newIterator:(HashMap *)aHM
{
    return [[HMKeyIterator alloc] init:aHM];
}

- (id) init:(HashMap *)aHM
{
    self = [super init:aHM];
    if ( self ) {
    }
    return self;
}

- (NSString *) next
{
    return [super next].key;
}

@end

@implementation HMEntryIterator

+ (HMEntryIterator *)newIterator:(HashMap *)aHM
{
    return [[HMEntryIterator alloc] init:aHM];
}

- (id) init:(HashMap *)aHM
{
    self = [super init:aHM];
    if ( self ) {
    }
    return self;
}

- (HMEntry *) next
{
    return [super next];
}

@end

@implementation HMKeySet

@synthesize hm;
@synthesize anArray;

+ (HMKeySet *)newKeySet:(HashMap *)aHM
{
    return [[HMKeySet alloc] init:(HashMap *)aHM];
}

- (id) init:(HashMap *)aHM
{
    self = [super init];
    if ( self ) {
        hm = aHM;
        anArray = [[AMutableArray arrayWithCapacity:16] retain];
        HMKeyIterator *it = [hm newKeyIterator];
        while ( [it hasNext] ) {
            NSString *aKey = [it next];
            [anArray addObject:aKey];
        }
    }
    return self;
}

- (HashIterator *) iterator
{
    return [HMKeyIterator newIterator:hm];
}

- (NSUInteger) count
{
    return hm.count;
}

- (BOOL) contains:(id)o
{
    return [hm containsKey:o];
}

- (BOOL) remove:(id)o
{
    return [hm removeEntryForKey:o] != nil;
}

- (void) clear {
    [hm clear];
}

- (AMutableArray *)toArray
{
    return anArray;
}

@end

@implementation Values

@synthesize hm;
@synthesize anArray;

+ (Values *)newValueSet:(HashMap *)aHM
{
    return [[Values alloc] init:aHM];
}

- (id) init:(HashMap *)aHM
{
    self = [super init];
    if ( self ) {
        hm = aHM;
        anArray = [[AMutableArray arrayWithCapacity:16] retain];
        HMValueIterator *it = [hm newValueIterator];
        while ( [it hasNext] ) {
            id aValue = [it next];
            [anArray addObject:aValue];
        }
    }
    return self;    
}

- (ArrayIterator *) iterator
{
    return [HMValueIterator newIterator:hm];
}

- (NSUInteger) count
{
    return hm.count;
}

- (BOOL) contains:(id)o
{
    return [hm containsValue:o];
}

- (void) clear {
    [hm clear];
}

- (AMutableArray *)toArray
{
    return anArray;
}

@end

@implementation HMEntrySet

@synthesize hm;
@synthesize anArray;

+ (HMEntrySet *)newEntrySet:(HashMap *)aHM
{
    return [[HMEntrySet alloc] init:aHM];
}

- (id) init:(HashMap *)aHM
{
    self = [super init];
    if ( self ) {
        hm = aHM;
        anArray = [[AMutableArray arrayWithCapacity:16] retain];
        HMEntryIterator *it = [hm newEntryIterator];
        while ( [it hasNext] ) {
            HMEntry *entry = [it next];
            [anArray addObject:entry];
        }
    }
    return self;
}

- (HashIterator *) iterator
{
    return [HMEntryIterator newIterator:hm];
}

- (BOOL) contains:(id)o
{
/*
    if (!([o conformsToProtocol:@protocol(HMEntry)]))
        return NO;
 */
    HMEntry *e = (HMEntry *)o;
    HMEntry *candidate = [hm getEntry:e.key];
    return candidate != nil && [candidate isEqualTo:e];
}

- (BOOL) remove:(id)o
{
    return [hm removeMapping:o] != nil;
}

- (NSUInteger) count
{
    return hm.count;
}

- (void) clear
{
    [hm clear];
}

- (NSArray *)toArray
{
    return anArray;
}

@end

/**
 * The default initial capacity - MUST be a power of two.
 */
NSInteger const DEFAULT_INITIAL_CAPACITY = 16;

/**
 * The maximum capacity, used if a higher value is implicitly specified
 * by either of the constructors with arguments.
 * MUST be a power of two <= 1<<30.
 */
NSInteger const MAXIMUM_CAPACITY = 1 << 30;

/**
 * The load factor used when none specified in constructor.
 */
float const DEFAULT_LOAD_FACTOR = 0.75f;
//long const serialVersionUID = 362498820763181265L;

/*
 * Start of HashMap
 */
@implementation HashMap

@synthesize Scope;
@synthesize LastHash;
@synthesize BuffSize;
@synthesize Capacity;
@synthesize count;
@synthesize ptr;
@synthesize ptrBuffer;
@synthesize buffer;
@synthesize threshold;
@synthesize loadFactor;
@synthesize modCount;
@synthesize entrySet;
@synthesize empty;
@synthesize keySet;
@synthesize values;

+(id)newHashMap
{
    return [[HashMap alloc] init];
}

+(id)newHashMapWithLen:(NSInteger)aBuffSize
{
    return [[HashMap alloc] initWithLen:aBuffSize];
}

+ (id) newHashMap:(NSInteger)initialCapacity
{
    return [[HashMap alloc] init:initialCapacity loadFactor:DEFAULT_LOAD_FACTOR];
}

+ (id) newHashMap:(NSInteger)initialCapacity loadFactor:(float)aLoadFactor
{
    return [[HashMap alloc] init:initialCapacity loadFactor:aLoadFactor];
}

/**
 * Constructs an empty <tt>HashMap</tt> with the default initial capacity
 * (16) and the default load factor (0.75).
 */
- (id) init
{
    NSInteger idx;

    self = [super init];
    if ( self ) {
        entrySet = nil;
        loadFactor = DEFAULT_LOAD_FACTOR;
        threshold = (NSInteger)(DEFAULT_INITIAL_CAPACITY * DEFAULT_LOAD_FACTOR);
        count = 0;
        BuffSize = HASHSIZE;
        NSInteger capacity = 1;
        
        while (capacity < BuffSize)
            capacity <<= 1;
        
        BuffSize = capacity;
        fNext = nil;
        Scope = 0;
        ptr = 0;
        buffer = [[NSMutableData dataWithLength:(NSUInteger)BuffSize * sizeof(id)] retain];
        ptrBuffer = (MapElement **) [buffer mutableBytes];
        if ( fNext != nil ) {
            Scope = ((HashMap *)fNext)->Scope+1;
            for( idx = 0; idx < BuffSize; idx++ ) {
                ptrBuffer[idx] = ((HashMap *)fNext)->ptrBuffer[idx];
            }
        }
        mode = 0;
        keySet = nil;
        values = nil;
   }
    return self;
}

-(id)initWithLen:(NSInteger)aBuffSize
{
    NSInteger idx;
    
    self = [super init];
    if ( self ) {
        fNext = nil;
        entrySet = nil;
        loadFactor = DEFAULT_LOAD_FACTOR;
        threshold = (NSInteger)(DEFAULT_INITIAL_CAPACITY * DEFAULT_LOAD_FACTOR);
        count = 0;
        BuffSize = aBuffSize;
        NSInteger capacity = 1;
        
        while (capacity < BuffSize)
            capacity <<= 1;
        
        BuffSize = capacity * sizeof(id);
        Capacity = capacity;
        Scope = 0;
        ptr = 0;
        buffer = [[NSMutableData dataWithLength:(NSUInteger)BuffSize] retain];
        ptrBuffer = (MapElement **) [buffer mutableBytes];
        if ( fNext != nil ) {
            Scope = ((HashMap *)fNext)->Scope+1;
            for( idx = 0; idx < Capacity; idx++ ) {
                ptrBuffer[idx] = ((HashMap *)fNext)->ptrBuffer[idx];
            }
        }
        mode = 0;
        keySet = nil;
        values = nil;
    }
    return( self );
}

/**
 * Constructs an empty <tt>HashMap</tt> with the specified initial
 * capacity and load factor.
 * 
 * @param  initialCapacity the initial capacity
 * @param  loadFactor      the load factor
 * @throws IllegalArgumentException if the initial capacity is negative
 * or the load factor is nonpositive
 */
- (id) init:(NSInteger)initialCapacity loadFactor:(float)aLoadFactor
{
    self = [super init];
    if ( self ) {
        entrySet = nil;
        if (initialCapacity < 0)
            @throw [[IllegalArgumentException alloc] init:[NSString stringWithFormat:@"Illegal initial capacity: %d", initialCapacity]];
        if (initialCapacity > MAXIMUM_CAPACITY)
            initialCapacity = MAXIMUM_CAPACITY;
        if (aLoadFactor <= 0 /* || [Float isNaN:loadFactor] */)
            @throw [[IllegalArgumentException alloc] init:[NSString stringWithFormat:@"Illegal load factor:%d ", aLoadFactor]];
        NSInteger capacity = 1;
        
        while (capacity < initialCapacity)
            capacity <<= 1;
        
        count = 0;
        BuffSize = capacity * sizeof(id);
        Capacity = capacity;
        loadFactor = aLoadFactor;
        threshold = (NSInteger)(capacity * loadFactor);
//        ptrBuffer = [AMutableArray arrayWithCapacity:initialCapacity];
//        [self init];
        keySet = nil;
        values = nil;
        Scope = 0;
        ptr = 0;
        buffer = [[NSMutableData dataWithLength:(NSUInteger)BuffSize] retain];
        ptrBuffer = (MapElement **) [buffer mutableBytes];
    }
    return self;
}


/**
 * Constructs an empty <tt>HashMap</tt> with the specified initial
 * capacity and the default load factor (0.75).
 * 
 * @param  initialCapacity the initial capacity.
 * @throws IllegalArgumentException if the initial capacity is negative.
 */
- (id) init:(NSInteger)anInitialCapacity
{
    self = [super init];
    if ( self ) {
        entrySet = nil;
        NSInteger initialCapacity = anInitialCapacity;
        if (initialCapacity > MAXIMUM_CAPACITY)
            initialCapacity = MAXIMUM_CAPACITY;
        NSInteger capacity = 1;
        while (capacity < initialCapacity)
            capacity <<= 1;
        count = 0;
        BuffSize = capacity;
        loadFactor = DEFAULT_LOAD_FACTOR;
        threshold = (NSInteger)(capacity * loadFactor);
        keySet = nil;
        values = nil;
        Scope = 0;
        ptr = 0;
        buffer = [[NSMutableData dataWithLength:(NSUInteger)BuffSize] retain];
        ptrBuffer = (MapElement **) [buffer mutableBytes];
    }
    return self;
}

/**
 * Constructs a new <tt>HashMap</tt> with the same mappings as the
 * specified <tt>Map</tt>.  The <tt>HashMap</tt> is created with
 * default load factor (0.75) and an initial capacity sufficient to
 * hold the mappings in the specified <tt>Map</tt>.
 * 
 * @param   m the map whose mappings are to be placed in this map
 * @throws  NullPointerException if the specified map is null
 */
- (id) initWithM:(HashMap *)m
{
    self = [super init];
    self = [self init:(NSInteger)max((([m count] / DEFAULT_LOAD_FACTOR) + 1), DEFAULT_INITIAL_CAPACITY) loadFactor:DEFAULT_LOAD_FACTOR];
    if ( self ) {
        entrySet = nil;
        NSInteger initialCapacity = max((([m count] / DEFAULT_LOAD_FACTOR) + 1), DEFAULT_INITIAL_CAPACITY);
        if (initialCapacity > MAXIMUM_CAPACITY)
            initialCapacity = MAXIMUM_CAPACITY;
        NSInteger capacity = 1;
        while (capacity < initialCapacity)
            capacity <<= 1;
        count = 0;
        BuffSize = capacity * sizeof(id);
        Capacity = capacity;
        loadFactor = DEFAULT_LOAD_FACTOR;
        threshold = (NSInteger)(capacity * loadFactor);
        keySet = nil;
        values = nil;
        Scope = 0;
        ptr = 0;
        buffer = [[NSMutableData dataWithLength:(NSUInteger)BuffSize] retain];
        ptrBuffer = (MapElement **) [buffer mutableBytes];
        [self putAllForCreate:m];
    }
    return self;
}

-(void)dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in HashMap" );
#endif
    MapElement *tmp, *rtmp;
    NSInteger idx;

    if ( self.fNext != nil ) {
        for( idx = 0; idx < Capacity; idx++ ) {
            tmp = ptrBuffer[idx];
            while ( tmp && tmp != [((HashMap *)fNext) getptrBufferEntry:idx] ) {
                rtmp = tmp;
                // tmp = [tmp getfNext];
                tmp = (MapElement *)tmp.fNext;
                [rtmp release];
            }
        }
    }
    if ( buffer ) [buffer release];
#ifdef DONTUSEYET
    [ptrBuffer release];
    [entrySet release];
#endif
    if ( keySet ) [keySet release];
    if ( values ) [values release];
    [super dealloc];
}

- (NSUInteger)count
{
/*
    NSUInteger aCnt = 0;
    
    for (NSUInteger i = 0; i < Capacity; i++) {
        if ( ptrBuffer[i] != nil ) {
            aCnt++;
        }
    }
    return aCnt;
 */
    return count;
}
                          
- (NSInteger) size
{
    NSInteger aSize = 0;
    
    for (NSInteger i = 0; i < Capacity; i++) {
        if ( ptrBuffer[i] != nil ) {
            aSize += sizeof(id);
        }
    }
    return aSize;
}
                                  
                                  
-(void)deleteHashMap:(MapElement *)np
{
    MapElement *tmp, *rtmp;
    NSInteger idx;
    
    if ( self.fNext != nil ) {
        for( idx = 0; idx < Capacity; idx++ ) {
            tmp = ptrBuffer[idx];
            while ( tmp && tmp != (LinkBase *)[((HashMap *)fNext) getptrBufferEntry:idx] ) {
                rtmp = tmp;
                tmp = [tmp getfNext];
                [rtmp release];
            }
        }
    }
}

-(HashMap *)PushScope:(HashMap **)map
{
    NSInteger idx;
    HashMap *htmp;
    
    htmp = [HashMap newHashMap];
    if ( *map != nil ) {
        ((HashMap *)htmp)->fNext = *map;
        [htmp setScope:[((HashMap *)htmp->fNext) getScope]+1];
        for( idx = 0; idx < Capacity; idx++ ) {
            htmp->ptrBuffer[idx] = ((HashMap *)htmp->fNext)->ptrBuffer[idx];
        }
    }
    //    gScopeLevel++;
    *map = htmp;
    return( htmp );
}

-(HashMap *)PopScope:(HashMap **)map
{
    NSInteger idx;
    MapElement *tmp;
    HashMap *htmp;
    
    htmp = *map;
    if ( (*map)->fNext != nil ) {
        *map = (HashMap *)htmp->fNext;
        for( idx = 0; idx < Capacity; idx++ ) {
            if ( htmp->ptrBuffer[idx] == nil ||
                htmp->ptrBuffer[idx] == (*map)->ptrBuffer[idx] ) {
                break;
            }
            tmp = htmp->ptrBuffer[idx];
            /*
             * must deal with parms, locals and labels at some point
             * can not forget the debuggers
             */
            htmp->ptrBuffer[idx] = [tmp getfNext];
            [tmp release];
        }
        *map = (HashMap *)htmp->fNext;
        //        gScopeLevel--;
    }
    return( htmp );
}

#ifdef USERDOC
/*
 *  HASH        hash entry to get idx to table
 *  NSInteger hash( HashMap *self, char *s );
 *
 *     Inputs:  char *s             string to find
 *
 *     Returns: NSInteger                 hashed value
 *
 *  Last Revision 9/03/90
 */
#endif
-(NSInteger)hash:(NSString *)s       /*    form hash value for string s */
{
    NSInteger hashval;
    const char *tmp;
    
    tmp = [s cStringUsingEncoding:NSASCIIStringEncoding];
    for( hashval = 0; *tmp != '\0'; )
        hashval += *tmp++;
    self->LastHash = hashval % Capacity;
    return( self->LastHash );
}

/**
 * Applies a supplemental hash function to a given hashCode, which
 * defends against poor quality hash functions.  This is critical
 * because HashMap uses power-of-two length hash tables, that
 * otherwise encounter collisions for hashCodes that do not differ
 * in lower bits. Note: Null keys always map to hash 0, thus idx 0.
 */
- (NSInteger) hashInt:(NSInteger) h
{
    // This function ensures that hashCodes that differ only by
    // constant multiples at each bit position have a bounded
    // number of collisions (approximately 8 at default load factor).
    h ^= (h >> 20) ^ (h >> 12);
    return h ^ (h >> 7) ^ (h >> 4);
}

/**
 * Returns idx for hash code h.
 */
- (NSInteger) indexFor:(NSInteger)h length:(NSInteger)length
{
    return h & (length - 1);
}

#ifdef USERDOC
/*
 *  FINDSCOPE  search hashed list for entry
 *  HashMap *findscope( HashMap *self, NSInteger scope );
 *
 *     Inputs:  NSInteger       scope -- scope level to find
 *
 *     Returns: HashMap   pointer to ptrBuffer of proper scope level
 *
 *  Last Revision 9/03/90
 */
#endif
-(HashMap *)findscope:(NSInteger)scope
{
    if ( self->Scope == scope ) {
        return( self );
    }
    else if ( fNext ) {
        return( [((HashMap *)fNext) findscope:scope] );
    }
    return( nil );              /*   not found      */
}

#ifdef USERDOC
/*
 *  LOOKUP  search hashed list for entry
 *  MapElement *lookup( HashMap *self, char *s, NSInteger scope );
 *
 *     Inputs:  char     *s          string to find
 *
 *     Returns: MapElement  *           pointer to entry
 *
 *  Last Revision 9/03/90
 */
#endif
-(id)lookup:(NSString *)s Scope:(NSInteger)scope
{
    MapElement *np;
    
    for( np = self->ptrBuffer[[self hash:s]]; np != nil; np = [np getfNext] ) {
        if ( [s isEqualToString:[np getName]] ) {
            return( np );        /*   found it       */
        }
    }
    return( nil );              /*   not found      */
}

#ifdef USERDOC
/*
 *  INSTALL search hashed list for entry
 *  NSInteger install( HashMap *self, MapElement *sym, NSInteger scope );
 *
 *     Inputs:  MapElement    *sym   -- symbol ptr to install
 *              NSInteger         scope -- level to find
 *
 *     Returns: Boolean     TRUE   if installed
 *                          FALSE  if already in table
 *
 *  Last Revision 9/03/90
 */
#endif
-(MapElement *)install:(MapElement *)sym Scope:(NSInteger)scope
{
    MapElement *np;
    
    np = [self lookup:[sym getName] Scope:scope ];
    if ( np == nil ) {
        [sym retain];
        [sym setFNext:self->ptrBuffer[ self->LastHash ]];
        self->ptrBuffer[ self->LastHash ] = sym;
        return( self->ptrBuffer[ self->LastHash ] );
    }
    return( nil );            /*   not found      */
}

#ifdef USERDOC
/*
 *  RemoveSym  search hashed list for entry
 *  NSInteger RemoveSym( HashMap *self, char *s );
 *
 *     Inputs:  char     *s          string to find
 *
 *     Returns: NSInteger      indicator of SUCCESS OR FAILURE
 *
 *  Last Revision 9/03/90
 */
#endif
-(NSInteger)RemoveSym:(NSString *)s
{
    MapElement *np, *tmp;
    NSInteger idx;
    
    idx = [self hash:s];
    for ( tmp = self->ptrBuffer[idx], np = self->ptrBuffer[idx]; np != nil; np = [np getfNext] ) {
        if ( [s isEqualToString:[np getName]] ) {
            tmp = [np getfNext];             /* get the next link  */
            [np release];
            return( SUCCESS );            /* report SUCCESS     */
        }
        tmp = [np getfNext];              //  BAD!!!!!!
    }
    return( FAILURE );                    /*   not found      */
}

-(void)delete_chain:(MapElement *)np
{
    if ( [np getfNext] != nil )
        [self delete_chain:[np getfNext]];
    [np dealloc];
}

#ifdef DONTUSEYET
-(NSInteger)bld_symtab:(KW_TABLE *)toknams
{
    NSInteger i;
    MapElement *np;
    
    for( i = 0; *(toknams[i].name) != '\0'; i++ ) {
        // install symbol in ptrBuffer
        np = [MapElement newMapElement:[NSString stringWithFormat:@"%s", toknams[i].name]];
        //        np->fType = toknams[i].toknum;
        [self install:np Scope:0];
    }
    return( SUCCESS );
}
#endif

-(MapElement *)getptrBufferEntry:(NSInteger)idx
{
    return( ptrBuffer[idx] );
}

-(MapElement **)getptrBuffer
{
    return( ptrBuffer );
}

-(void)setptrBuffer:(MapElement *)np Index:(NSInteger)idx
{
    if ( idx < Capacity ) {
        [np retain];
        ptrBuffer[idx] = np;
    }
}

-(NSInteger)getScope
{
    return( Scope );
}

-(void)setScopeScope:(NSInteger)i
{
    Scope = i;
}

- (MapElement *)getTType:(NSString *)name
{
    return [self lookup:name Scope:0];
}

/*
 * works only for maplist indexed not by name but by TokenNumber
 */
- (MapElement *)getNameInList:(NSInteger)ttype
{
    MapElement *np;
    NSInteger aTType;

    aTType = ttype % Capacity;
    for( np = self->ptrBuffer[aTType]; np != nil; np = [np getfNext] ) {
        if ( [(ACNumber *)np.node integerValue] == ttype ) {
            return( np );        /*   found it       */
        }
    }
    return( nil );              /*   not found      */
}

- (LinkBase *)getName:(NSString *)name
{
    return [self lookup:name Scope:0]; /*  nil if not found      */    
}

- (void)putNode:(NSString *)name TokenType:(NSInteger)ttype
{
    MapElement *np;
    
    // install symbol in ptrBuffer
    np = [MapElement newMapElementWithName:[NSString stringWithString:name] Type:ttype];
    //        np->fType = toknams[i].toknum;
    [self install:np Scope:0];
}

- (NSInteger)getMode
{
    return mode;
}

- (void)setMode:(NSInteger)aMode
{
    mode = aMode;
}

- (void) addObject:(id)aRule
{
    NSInteger idx;

    idx = [self count];
    if ( idx >= Capacity ) {
        idx %= Capacity;
    }
    ptrBuffer[idx] = aRule;
}

/* this may have to handle linking into the chain
 */
- (void) insertObject:(id)aRule atIndex:(NSInteger)idx
{
    if ( idx >= Capacity ) {
        idx %= Capacity;
    }
    if ( aRule != ptrBuffer[idx] ) {
        if ( ptrBuffer[idx] ) [ptrBuffer[idx] release];
        [aRule retain];
    }
    ptrBuffer[idx] = aRule;
}

- (id)objectAtIndex:(NSInteger)idx
{
    if ( idx >= Capacity ) {
        idx %= Capacity;
    }
    return ptrBuffer[idx];
}

/**
 * Returns <tt>true</tt> if this map contains no key-value mappings.
 * 
 * @return <tt>true</tt> if this map contains no key-value mappings
 */
- (BOOL) empty
{
    return count == 0;
}

/**
 * Offloaded version of get() to look up null keys.  Null keys map
 * to idx 0.  This null case is split out into separate methods
 * for the sake of performance in the two most commonly used
 * operations (get and put), but incorporated with conditionals in
 * others.
 */
- (id) getForNullKey
{
    
    for (HMEntry *e = (HMEntry *)ptrBuffer[0]; e != nil; e = e.next) {
        if (e.key == nil)
            return e.value;
    }
    
    return nil;
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
 * 
 * @see #put(Object, Object)
 */
- (id) get:(NSString *)key
{
    if (key == nil)
        return [self getForNullKey];
    //    NSInteger hash = [self hashInt:[self hash:key]];
    NSInteger hash = [self hashInt:[key hash]];
    
    for (HMEntry *e = (HMEntry *)ptrBuffer[[self indexFor:hash length:[self capacity]]]; e != nil; e = e.next) {
        NSString *k;
        if (e.hash == hash && ((k = e.key) == key || [key isEqualTo:k]))
            return e.value;
    }
    
    return nil;
}


/**
 * Returns <tt>true</tt> if this map contains a mapping for the
 * specified key.
 * 
 * @param   key   The key whose presence in this map is to be tested
 * @return <tt>true</tt> if this map contains a mapping for the specified
 * key.
 */
- (BOOL) containsKey:(NSString *)key
{
    return [self getEntry:key] != nil;
}

/**
 * Returns the entry associated with the specified key in the
 * HashMap.  Returns null if the HashMap contains no mapping
 * for the key.
 */
- (HMEntry *) getEntry:(NSString *)key
{
    //    NSInteger hash = (key == nil) ? 0 : [self hashInt:[self hash:key]];
    NSInteger hash = (key == nil) ? 0 : [self hashInt:[key hash]];
    
    for (HMEntry *e = (HMEntry *)ptrBuffer[[self indexFor:hash length:Capacity]]; e != nil; e = e.next) {
        NSString *k;
        if (e.hash == hash && ((k = e.key) == key || (key != nil && [key isEqualTo:k])))
            return e;
    }
    
    return nil;
}


/**
 * Associates the specified value with the specified key in this map.
 * If the map previously contained a mapping for the key, the old
 * value is replaced.
 * 
 * @param key key with which the specified value is to be associated
 * @param value value to be associated with the specified key
 * @return the previous value associated with <tt>key</tt>, or
 * <tt>null</tt> if there was no mapping for <tt>key</tt>.
 * (A <tt>null</tt> return can also indicate that the map
 * previously associated <tt>null</tt> with <tt>key</tt>.)
 */
- (id) put:(NSString *)key value:(id)value
{
    if (key == nil)
        return [self putForNullKey:value];
//    NSInteger hash = [self hashInt:[self hash:key]];
    NSInteger hash = [self hashInt:[key hash]];
    NSInteger i = [self indexFor:hash length:[self capacity]];
    
    for (HMEntry *e = (HMEntry *)ptrBuffer[i]; e != nil; e = e.next) {
        NSString *k;
        if (e.hash == hash && ((k = e.key) == key || [key isEqualTo:k])) {
            id oldValue = e.value;
            e.value = value;
            [e recordAccess:self];
            return oldValue;
        }
    }
    
    modCount++;
    [self addEntry:hash key:key value:value bucketIndex:i];
    return nil;
}


/**
 * Offloaded version of put for null keys
 */
- (id) putForNullKey:(id)value
{
    
    for (HMEntry *e = (HMEntry *)ptrBuffer[0]; e != nil; e = e.next) {
        if (e.key == nil) {
            id oldValue = e.value;
            e.value = value;
            [e recordAccess:self];
            return oldValue;
        }
    }
    
    modCount++;
    [self addEntry:0 key:nil value:value bucketIndex:0];
    return nil;
}

/**
 * This method is used instead of put by constructors and
 * pseudoconstructors (clone, readObject).  It does not resize the table,
 * check for comodification, etc.  It calls createEntry rather than
 * addEntry.
 */
- (void) putForCreate:(NSString *)key value:(id)value
{
    NSInteger hash = (key == nil) ? 0 : [self hashInt:[self hash:key]];
    NSInteger i = [self indexFor:hash length:[self capacity]];
    
    for (HMEntry *e = (HMEntry *)ptrBuffer[i]; e != nil; e = e.next) {
        NSString *k;
        if (e.hash == hash && ((k = e.key) == key || (key != nil && [key isEqualTo:k]))) {
            e.value = value;
            return;
        }
    }
    
    [self createEntry:hash key:key value:value bucketIndex:i];
}

- (void) putAllForCreate:(HashMap *)m
{
    
    for (HMEntry *e in [m entrySet])
        [self putForCreate:[e key] value:[e value]];
    
}

/**
 * Rehashes the contents of this map into a new array with a
 * larger capacity.  This method is called automatically when the
 * number of keys in this map reaches its threshold.
 * 
 * If current capacity is MAXIMUM_CAPACITY, this method does not
 * resize the map, but sets threshold to Integer.MAX_VALUE.
 * This has the effect of preventing future calls.
 * 
 * @param newCapacity the new capacity, MUST be a power of two;
 * must be greater than current capacity unless current
 * capacity is MAXIMUM_CAPACITY (in which case value
 * is irrelevant).
 */
- (void) resize:(NSInteger)newCapacity
{
//    NSArray * oldTable = ptrBuffer;
    NSInteger oldCapacity = Capacity;
    if (oldCapacity == MAXIMUM_CAPACITY) {
        threshold = NSIntegerMax;
        return;
    }
//    NSArray * newTable = [NSArray array];
//    [self transfer:newTable];
    BuffSize = newCapacity * sizeof(id);
    Capacity = newCapacity;
    [buffer setLength:BuffSize];
    ptrBuffer = [buffer mutableBytes];
    threshold = (NSInteger)(newCapacity * loadFactor);
}


/**
 * Transfers all entries from current table to newTable.
 */
- (void) transfer:(AMutableArray *)newTable
{
    NSInteger newCapacity = [newTable count];
    
    for (NSInteger j = 0; j < [self capacity]; j++) {
        HMEntry *e = (HMEntry *)ptrBuffer[j];
        if (e != nil) {
            ptrBuffer[j] = nil;
            
            do {
                HMEntry *next = e.next;
                NSInteger i = [self indexFor:e.hash length:newCapacity];
                e.next = [newTable objectAtIndex:i];
                [newTable replaceObjectAtIndex:i withObject:e];
                e = next;
            }
            while (e != nil);
        }
    }
    
}


/**
 * Copies all of the mappings from the specified map to this map.
 * These mappings will replace any mappings that this map had for
 * any of the keys currently in the specified map.
 * 
 * @param m mappings to be stored in this map
 * @throws NullPointerException if the specified map is null
 */
- (void) putAll:(HashMap *)m
{
    NSInteger numKeysToBeAdded = [m count];
    if (numKeysToBeAdded == 0)
        return;
    if (numKeysToBeAdded > threshold) {
        NSInteger targetCapacity = (NSInteger)(numKeysToBeAdded / loadFactor + 1);
        if (targetCapacity > MAXIMUM_CAPACITY)
            targetCapacity = MAXIMUM_CAPACITY;
        NSInteger newCapacity = Capacity;
        
        while (newCapacity < targetCapacity)
            newCapacity <<= 1;
        
        if (newCapacity > Capacity)
            [self resize:newCapacity];
    }
    
    for (HMEntry *e in [m entrySet])
        [self put:[e key] value:[e value]];
    
}

/**
 * Removes the mapping for the specified key from this map if present.
 * 
 * @param  key key whose mapping is to be removed from the map
 * @return the previous value associated with <tt>key</tt>, or
 * <tt>null</tt> if there was no mapping for <tt>key</tt>.
 * (A <tt>null</tt> return can also indicate that the map
 * previously associated <tt>null</tt> with <tt>key</tt>.)
 */
- (id) remove:(NSString *)key
{
    HMEntry *e = [self removeEntryForKey:key];
    return (e == nil ? nil : e.value);
}


/**
 * Removes and returns the entry associated with the specified key
 * in the HashMap.  Returns null if the HashMap contains no mapping
 * for this key.
 */
- (HMEntry *) removeEntryForKey:(NSString *)key
{
    NSInteger hash = (key == nil) ? 0 : [self hashInt:[self hash:key]];
    NSInteger i = [self indexFor:hash length:Capacity];
    HMEntry *prev = (HMEntry *)ptrBuffer[i];
    HMEntry *e = prev;
    
    while (e != nil) {
        HMEntry *next = e.next;
        NSString *k;
        if (e.hash == hash && ((k = e.key) == key || (key != nil && [key isEqualTo:k]))) {
            modCount++;
            count--;
            if (prev == e)
                ptrBuffer[i] = (id) next;
            else
                prev.next = next;
            [e recordRemoval:self];
            return e;
        }
        prev = e;
        e = next;
    }
    
    return e;
}

/**
 * Special version of remove for EntrySet.
 */
- (HMEntry *) removeMapping:(id)o
{
//    if (!([o conformsToProtocol:@protocol(HMEntry)]))
//        return nil;
    HMEntry *entry = (HMEntry *)o;
    NSString *key = entry.key;
    NSInteger hash = (key == nil) ? 0 : [self hashInt:[self hash:key]];
    NSInteger i = [self indexFor:hash length:Capacity];
    HMEntry *prev = (HMEntry *)ptrBuffer[i];
    HMEntry *e = prev;
    
    while (e != nil) {
        HMEntry *next = e.next;
        if (e.hash == hash && [e isEqualTo:entry]) {
            modCount++;
            count--;
            if (prev == e)
                ptrBuffer[i] = (id)next;
            else
                prev.next = next;
            [e recordRemoval:self];
            return e;
        }
        prev = e;
        e = next;
    }
    
    return e;
}

/**
 * Removes all of the mappings from this map.
 * The map will be empty after this call returns.
 */
- (void) clear
{
    modCount++;
    id tmp;
    
    for (NSInteger i = 0; i < Capacity; i++) {
        tmp = ptrBuffer[i];
        if ( tmp ) {
            [tmp release];
        }
        ptrBuffer[i] = nil;
    }
    count = 0;
}


/**
 * Special-case code for containsValue with null argument
 */
- (BOOL) containsNullValue
{
    for (NSInteger i = 0; i < Capacity; i++)
        
        for (HMEntry *e = (HMEntry *)ptrBuffer[i]; e != nil; e = e.next)
            if (e.value == nil)
                return YES;
    return NO;
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
    if (value == nil)
        return [self containsNullValue];
    
    for (NSInteger i = 0; i < Capacity; i++)
        
        for (HMEntry *e = (HMEntry *)ptrBuffer[i]; e != nil; e = e.next)
            if ([value isEqualTo:e.value])
                return YES;
    
    
    return NO;
}

/**
 * Returns a shallow copy of this <tt>HashMap</tt> instance: the keys and
 * values themselves are not cloned.
 * 
 * @return a shallow copy of this map
 */
- (id) copyWithZone:(NSZone *)zone
{
    HashMap *result = nil;
    
    //    @try {
    result = [HashMap allocWithZone:zone];
//        result = (HashMap *)[super copyWithZone:zone];
//    }
//    @catch (CloneNotSupportedException * e) {
//    }
    result.ptrBuffer = ptrBuffer;
    result.entrySet = nil;
    //    result.modCount = 0;
    //    result.count = 0;
    //    [result init];
    [result putAllForCreate:self];
    result.count = count;
    result.threshold = threshold;
    result.loadFactor = loadFactor;
    result.modCount = modCount;
    result.entrySet = entrySet;
    return result;
}


/**
 * Returns a string representation of this map.  The string representation
 * consists of a list of key-value mappings in the order returned by the
 * map's <tt>entrySet</tt> view's iterator, enclosed in braces
 * (<tt>"{}"</tt>).  Adjacent mappings are separated by the characters
 * <tt>", "</tt> (comma and space).  Each key-value mapping is rendered as
 * the key followed by an equals sign (<tt>"="</tt>) followed by the
 * associated value.  Keys and values are converted to strings as by
 * {@link String#valueOf(Object)}.
 *
 * @return a string representation of this map
 */
- (NSString *)description
{
    HashIterator *it = [[self entrySet] iterator];
    if (![it hasNext])
        return @"{}";
    
    NSMutableString *sb = [NSMutableString stringWithCapacity:40];
    [sb appendString:@"{"];
    while ( YES ) {
        HMEntry *e = [it next];
        NSString *key = e.key;
        id value = e.value;
        [sb appendFormat:@"%@=%@", (key == self ? @"[self Map]" : key), (value == self ? @"[self Map]" : value)];
        if ( ![it hasNext] ) {
            [sb appendString:@"}"];
            return sb;
        }
        [sb appendString:@", "];
    }
}

/**
 * Adds a new entry with the specified key, value and hash code to
 * the specified bucket.  It is the responsibility of this
 * method to resize the table if appropriate.
 * 
 * Subclass overrides this to alter the behavior of put method.
 */
- (void) addEntry:(NSInteger)hash key:(NSString *)key value:(id)value bucketIndex:(NSInteger)bucketIndex
{
    HMEntry *e = (HMEntry *)ptrBuffer[bucketIndex];
    ptrBuffer[bucketIndex] = [[HMEntry alloc] init:hash key:key value:value next:e];
    if (count++ >= threshold)
        [self resize:2 * BuffSize];
}

/**
 * Like addEntry except that this version is used when creating entries
 * as part of Map construction or "pseudo-construction" (cloning,
 * deserialization).  This version needn't worry about resizing the table.
 * 
 * Subclass overrides this to alter the behavior of HashMap(Map),
 * clone, and readObject.
 */
- (void) createEntry:(NSInteger)hash key:(NSString *)key value:(id)value bucketIndex:(NSInteger)bucketIndex
{
    HMEntry *e = (HMEntry *)ptrBuffer[bucketIndex];
    ptrBuffer[bucketIndex] = [[HMEntry alloc] init:hash key:key value:value next:e];
    count++;
}

- (HMKeyIterator *) newKeyIterator
{
    return [HMKeyIterator newIterator:self];
}

- (HMValueIterator *) newValueIterator
{
    return [HMValueIterator newIterator:self];
}

- (HMEntryIterator *) newEntryIterator
{
    return [HMEntryIterator newIterator:self];
}


/**
 * Returns a {@link Set} view of the keys contained in this map.
 * The set is backed by the map, so changes to the map are
 * reflected in the set, and vice-versa.  If the map is modified
 * while an iteration over the set is in progress (except through
 * the iterator's own <tt>remove</tt> operation), the results of
 * the iteration are undefined.  The set supports element removal,
 * which removes the corresponding mapping from the map, via the
 * <tt>Iterator.remove</tt>, <tt>Set.remove</tt>,
 * <tt>removeAll</tt>, <tt>retainAll</tt>, and <tt>clear</tt>
 * operations.  It does not support the <tt>add</tt> or <tt>addAll</tt>
 * operations.
 */
- (HMKeySet *) keySet
{
    HMKeySet *ks = keySet;
    return (ks != nil ? ks : (keySet = [HMKeySet newKeySet:self]));
}


/**
 * Returns a {@link Collection} view of the values contained in this map.
 * The collection is backed by the map, so changes to the map are
 * reflected in the collection, and vice-versa.  If the map is
 * modified while an iteration over the collection is in progress
 * (except through the iterator's own <tt>remove</tt> operation),
 * the results of the iteration are undefined.  The collection
 * supports element removal, which removes the corresponding
 * mapping from the map, via the <tt>Iterator.remove</tt>,
 * <tt>Collection.remove</tt>, <tt>removeAll</tt>,
 * <tt>retainAll</tt> and <tt>clear</tt> operations.  It does not
 * support the <tt>add</tt> or <tt>addAll</tt> operations.
 */
- (Values *) values
{
    Values *vs = values;
    return (vs != nil ? vs : (values = [Values newValueSet:self]));
}


/**
 * Returns a {@link Set} view of the mappings contained in this map.
 * The set is backed by the map, so changes to the map are
 * reflected in the set, and vice-versa.  If the map is modified
 * while an iteration over the set is in progress (except through
 * the iterator's own <tt>remove</tt> operation, or through the
 * <tt>setValue</tt> operation on a map entry returned by the
 * iterator) the results of the iteration are undefined.  The set
 * supports element removal, which removes the corresponding
 * mapping from the map, via the <tt>Iterator.remove</tt>,
 * <tt>Set.remove</tt>, <tt>removeAll</tt>, <tt>retainAll</tt> and
 * <tt>clear</tt> operations.  It does not support the
 * <tt>add</tt> or <tt>addAll</tt> operations.
 * 
 * @return a set view of the mappings contained in this map
 */
- (HMEntrySet *) entrySet0
{
    HMEntrySet *es = entrySet;
    return es != nil ? es : (entrySet = [HMEntrySet newEntrySet:self]);
}

- (HMEntrySet *) entrySet
{
    return [self entrySet0];
}


/**
 * Save the state of the <tt>HashMap</tt> instance to a stream (i.e.,
 * serialize it).
 * 
 * @serialData The <i>capacity</i> of the HashMap (the length of the
 * bucket array) is emitted (NSInteger), followed by the
 * <i>count</i> (an NSInteger, the number of key-value
 * mappings), followed by the key (Object) and value (Object)
 * for each key-value mapping.  The key-value mappings are
 * emitted in no particular order.
 */
- (void) writeObject:(NSOutputStream *)s
{
/*
    NSEnumerator * i = (count > 0) ? [[self entrySet0] iterator] : nil;
    [s defaultWriteObject];
    [s writeInt:[buffer length]];
    [s writeInt:count];
    if (i != nil) {
        while ([i hasNext]) {
            HMEntry *e = [i nextObject];
            [s writeObject:[e key]];
            [s writeObject:[e value]];
        }
        
    }
 */
}


/**
 * Reconstitute the <tt>HashMap</tt> instance from a stream (i.e.,
 * deserialize it).
 */
- (void) readObject:(NSInputStream *)s
{
/*
    [s defaultReadObject];
    NSInteger numBuckets = [s readInt];
    ptrBuffer = [NSArray array];
    [self init];
    NSInteger count = [s readInt];
    
    for (NSInteger i = 0; i < count; i++) {
        NSString * key = (NSString *)[s readObject];
        id value = (id)[s readObject];
        [self putForCreate:key value:value];
    }
 */
}

- (NSInteger) capacity
{
    return Capacity;
}

- (float) loadFactor
{
    return loadFactor;
}

/* this will never link into the chain
 */
- (void) setObject:(id)aRule atIndex:(NSInteger)idx
{
    if ( idx >= Capacity ) {
        idx %= Capacity;
    }
    if ( aRule != ptrBuffer[idx] ) {
        if ( ptrBuffer[idx] ) [ptrBuffer[idx] release];
        [aRule retain];
    }
    ptrBuffer[idx] = aRule;
}

- (void)putName:(NSString *)name Node:(id)aNode
{
    MapElement *np;
    
    np = [self lookup:name Scope:0 ];
    if ( np == nil ) {
        np = [MapElement newMapElementWithName:name Node:aNode];
        if ( ptrBuffer[LastHash] )
            [ptrBuffer[LastHash] release];
        [np retain];
        np.fNext = ptrBuffer[ LastHash ];
        ptrBuffer[ LastHash ] = np;
    }
    return;    
}

- (NSEnumerator *)objectEnumerator
{
#pragma mark fix this its broken
    NSEnumerator *anEnumerator;

    itIndex = 0;
    return anEnumerator;
}

- (BOOL)hasNext
{
    if (self && [self count] < Capacity-1) {
        return YES;
    }
    return NO;
}

- (MapElement *)nextObject
{
    if (self && itIndex < Capacity-1) {
        return ptrBuffer[itIndex];
    }
    return nil;
}

@end

