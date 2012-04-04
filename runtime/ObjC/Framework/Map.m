//
//  Map.m
//  ANTLR
//
//  Created by Alan Condit on 6/9/10.
// [The "BSD licence"]
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

#import "Map.h"
#import "BaseTree.h"

/*
 * Start of Map
 */
@implementation Map

@synthesize lastHash;

+(id)newMap
{
    return [[Map alloc] init];
}

+(id)newMapWithLen:(NSInteger)aBuffSize
{
    return [[Map alloc] initWithLen:aBuffSize];
}

-(id)init
{
    NSInteger idx;
    
	self = [super initWithLen:HASHSIZE];
    if ( self != nil ) {
		fNext = nil;
        for( idx = 0; idx < HASHSIZE; idx++ ) {
            ptrBuffer[idx] = nil;
        }
	}
    return( self );
}

-(id)initWithLen:(NSInteger)aBuffSize
{
	self = [super initWithLen:aBuffSize];
    if ( self != nil ) {
	}
    return( self );
}

-(void)dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in MMap" );
#endif
    MapElement *tmp, *rtmp;
    NSInteger idx;
	
    if ( self.fNext != nil ) {
        for( idx = 0; idx < BuffSize; idx++ ) {
            tmp = ptrBuffer[idx];
            while ( tmp ) {
                rtmp = tmp;
                tmp = (MapElement *)tmp.fNext;
                [rtmp release];
            }
        }
    }
	[super dealloc];
}

-(void)deleteMap:(MapElement *)np
{
    MapElement *tmp, *rtmp;
    NSInteger idx;
    
    if ( self.fNext != nil ) {
        for( idx = 0; idx < BuffSize; idx++ ) {
            tmp = ptrBuffer[idx];
            while ( tmp ) {
                rtmp = tmp;
                tmp = [tmp getfNext];
                [rtmp release];
            }
        }
    }
}

- (void)clear
{
    MapElement *tmp, *rtmp;
    NSInteger idx;

    for( idx = 0; idx < BuffSize; idx++ ) {
        tmp = ptrBuffer[idx];
        while ( tmp ) {
            rtmp = tmp;
            tmp = [tmp getfNext];
            [rtmp dealloc];
        }
        ptrBuffer[idx] = nil;
    }
}

- (NSInteger)count
{
    NSInteger aCnt = 0;
    
    for (int i = 0; i < BuffSize; i++) {
        if (ptrBuffer[i] != nil) {
            aCnt++;
        }
    }
    return aCnt;
}

- (NSInteger)length
{
    return BuffSize;
}

- (NSInteger)size
{
    MapElement *anElement;
    NSInteger aSize = 0;
    
    for (int i = 0; i < BuffSize; i++) {
        if ((anElement = ptrBuffer[i]) != nil) {
            aSize += (NSInteger)[anElement size];
        }
    }
    return aSize;
}
                          
#ifdef USERDOC
/*
 *  HASH        hash entry to get index to table
 *  NSInteger hash( Map *self, char *s );
 *
 *     Inputs:  NSString *s         string to find
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
	self->lastHash = hashval % HASHSIZE;
	return( self->lastHash );
}

#ifdef USERDOC
/*
 *  LOOKUP  search hashed list for entry
 *  MapElement *lookup:(NSString *)s;
 *
 *     Inputs:  NSString  *s       string to find
 *
 *     Returns: MapElement  *        pointer to entry
 *
 *  Last Revision 9/03/90
 */
#endif
-(id)lookup:(NSString *)s
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
 *  NSInteger install( Map *self, MapElement *sym );
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
-(MapElement *)install:(MapElement *)sym
{
    MapElement *np;
    
    np = [self lookup:[sym getName]];
    if ( np == nil ) {
        [sym setFNext:ptrBuffer[ lastHash ]];
        ptrBuffer[ lastHash ] = sym;
        [sym retain];
        return( ptrBuffer[ lastHash ] );
    }
    return( nil );            /*   not found      */
}

#ifdef USERDOC
/*
 *  RemoveSym  search hashed list for entry
 *  NSInteger RemoveSym( Map *self, char *s );
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
	[np release];
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

/*
 * works only for maplist indexed not by name but by TokenNumber
 */
- (MapElement *)getName:(NSInteger)ttype
{
    MapElement *np;
    NSInteger aTType;

    aTType = ttype % HASHSIZE;
    for( np = self->ptrBuffer[ttype]; np != nil; np = [np getfNext] ) {
        if ( [(ACNumber *)np.node integerValue] == ttype ) {
            return( np );        /*   found it       */
        }
    }
    return( nil );              /*   not found      */
}

- (NSInteger)getNode:(id<BaseTree>)aNode
{
    MapElement *np;
    NSInteger idx;

    idx = [(id<BaseTree>)aNode type];
    idx %= HASHSIZE;
    np = ptrBuffer[idx];
    return( [(ACNumber *)np.node integerValue] );
}

- (MapElement *)getTType:(NSString *)name
{
    return [self lookup:name];
}

// create node and install node in ptrBuffer
- (void)putName:(NSString *)name TType:(NSInteger)ttype
{
    MapElement *np;
    
    np = [MapElement newMapElementWithName:[NSString stringWithString:name] Type:ttype];
    [self install:np];
}

// create node and install node in ptrBuffer
- (void)putName:(NSString *)name Node:(id)aNode
{
    MapElement *np, *np1;
    NSInteger idx;
    
    idx = [self hash:name];
    np1 = [MapElement newMapElementWithName:[NSString stringWithString:name] Type:idx];
    np = [self lookup:name];
    if ( np == nil ) {
        [np1 setFNext:self->ptrBuffer[ self->lastHash ]];
        self->ptrBuffer[ self->lastHash ] = np1;
        [np1 retain];
    }
    else {
        // ptrBuffer[idx] = np;
    }
    return;
}

// create node and install node in ptrBuffer
- (void)putNode:(NSInteger)aTType Node:(id)aNode
{
    MapElement *np;
    NSInteger ttype;
    
    ttype = aTType % HASHSIZE;
    np = [MapElement newMapElementWithNode:ttype Node:(id)aNode];
    ptrBuffer[ttype] = np;
}

@end
