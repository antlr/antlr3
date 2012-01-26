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

static NSInteger itIndex;

/*
 * Start of HashMap
 */
@implementation HashMap

@synthesize Scope;
@synthesize LastHash;

+(id)newHashMap
{
    return [[HashMap alloc] init];
}

+(id)newHashMapWithLen:(NSInteger)aBuffSize
{
    return [[HashMap alloc] initWithLen:aBuffSize];
}

-(id)init
{
    NSInteger idx;
    
    if ((self = [super init]) != nil) {
        fNext = nil;
        Scope = 0;
        ptr = 0;
        BuffSize = HASHSIZE;
        buffer = [[NSMutableData dataWithLength:(NSUInteger)BuffSize * sizeof(id)] retain];
        ptrBuffer = (MapElement **) [buffer mutableBytes];
        if ( fNext != nil ) {
            Scope = ((HashMap *)fNext)->Scope+1;
            for( idx = 0; idx < BuffSize; idx++ ) {
                ptrBuffer[idx] = ((HashMap *)fNext)->ptrBuffer[idx];
            }
        }
        mode = 0;
    }
    return( self );
}

-(id)initWithLen:(NSInteger)aBuffSize
{
    NSInteger idx;
    
    if ((self = [super init]) != nil) {
        fNext = nil;
        BuffSize = aBuffSize;
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
    }
    return( self );
}

-(void)dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in HashMap" );
#endif
    MapElement *tmp, *rtmp;
    NSInteger idx;

    if ( self.fNext != nil ) {
        for( idx = 0; idx < BuffSize; idx++ ) {
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
    [super dealloc];
}

- (NSInteger)count
{
    NSInteger aCnt = 0;
    
    for (NSInteger i = 0; i < BuffSize; i++) {
        if ( ptrBuffer[i] != nil ) {
            aCnt++;
        }
    }
    return aCnt;
}
                          
- (NSInteger) size
{
    NSInteger aSize = 0;
    
    for (NSInteger i = 0; i < BuffSize; i++) {
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
        for( idx = 0; idx < BuffSize; idx++ ) {
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
        for( idx = 0; idx < BuffSize; idx++ ) {
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
        for( idx = 0; idx < BuffSize; idx++ ) {
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
 *  HASH        hash entry to get index to table
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
    self->LastHash = hashval % BuffSize;
    return( self->LastHash );
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
    if ( idx < BuffSize ) {
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

    aTType = ttype % BuffSize;
    for( np = self->ptrBuffer[aTType]; np != nil; np = [np getfNext] ) {
        if ( [(NSNumber *)np.node integerValue] == ttype ) {
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
    if ( idx >= BuffSize ) {
        idx %= BuffSize;
    }
    ptrBuffer[idx] = aRule;
}

/* this may have to handle linking into the chain
 */
- (void) insertObject:(id)aRule atIndex:(NSInteger)idx
{
    if ( idx >= BuffSize ) {
        idx %= BuffSize;
    }
    if ( aRule != ptrBuffer[idx] ) {
        if ( ptrBuffer[idx] ) [ptrBuffer[idx] release];
        [aRule retain];
    }
    ptrBuffer[idx] = aRule;
}

- (id)objectAtIndex:(NSInteger)idx
{
    if ( idx >= BuffSize ) {
        idx %= BuffSize;
    }
    return ptrBuffer[idx];
}

/* this will never link into the chain
 */
- (void) setObject:(id)aRule atIndex:(NSInteger)idx
{
    if ( idx >= BuffSize ) {
        idx %= BuffSize;
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
    if (self && [self count] < BuffSize-1) {
        return YES;
    }
    return NO;
}

- (MapElement *)nextObject
{
    if (self && itIndex < BuffSize-1) {
        return ptrBuffer[itIndex];
    }
    return nil;
}

@synthesize BuffSize;
@synthesize count;
@synthesize ptr;
@synthesize ptrBuffer;
@synthesize buffer;
@end
