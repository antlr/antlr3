//
//  ANTLRPtrStack.m
//  ANTLR
//
//  Created by Alan Condit on 6/9/10.
//  Copyright 2010 Alan's MachineWorks. All rights reserved.
//
#define SUCCESS (0)
#define FAILURE (-1)

#import "ANTLRPtrStack.h"
#import "ANTLRTree.h"

/*
 * Start of ANTLRPtrStack
 */
@implementation ANTLRPtrStack

+(ANTLRPtrStack *)newANTLRPtrStack
{
    return [[ANTLRPtrStack alloc] init];
}

+(ANTLRPtrStack *)newANTLRPtrStack:(NSInteger)cnt
{
    return [[ANTLRPtrStack alloc] initWithLen:cnt];
}

-(id)init
{
	self = [super initWithLen:HASHSIZE];
	if ( self != nil ) {
	}
    return( self );
}

-(id)initWithLen:(NSInteger)cnt
{
	self = [super initWithLen:cnt];
	if ( self != nil ) {
	}
    return( self );
}

-(void)dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in ANTLRPtrStack" );
#endif
	[super dealloc];
}

-(void)deleteANTLRPtrStack:(ANTLRPtrStack *)np
{
    ANTLRLinkBase *tmp, *rtmp;
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

#ifdef DONTUSENOMO
#ifdef USERDOC
/*
 *  HASH        hash entry to get index to table
 *  NSInteger hash( ANTLRPtrStack *self, char *s );
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
	LastHash = hashval % HashSize;
	return( LastHash );
}

#ifdef USERDOC
/*
 *  LOOKUP  search hashed list for entry
 *  id lookup:(NSString *)s;
 *
 *     Inputs:  NSString  *s       string to find
 *
 *     Returns: ANTLRRuleMemo  *        pointer to entry
 *
 *  Last Revision 9/03/90
 */
#endif
-(id)lookup:(NSString *)s
{
    ANTLRLinkBase *np;
    
    for( np = ptrBuffer[[self hash:s]]; np != nil; np = [np getfNext] ) {
        if ( [s isEqualToString:[np getName]] ) {
            return( np );        /*   found it       */
        }
    }
    return( nil );              /*   not found      */
}

#ifdef USERDOC
/*
 *  INSTALL search hashed list for entry
 *  NSInteger install( ANTLRPtrStack *self, id sym );
 *
 *     Inputs:  ANTLRRuleMemo    *sym   -- symbol ptr to install
 *              NSInteger         scope -- level to find
 *
 *     Returns: Boolean     TRUE   if installed
 *                          FALSE  if already in table
 *
 *  Last Revision 9/03/90
 */
#endif
-(id)install:(id)sym
{
    ANTLRLinkBase *np;
    
    np = [self lookup:[sym getName]];
    if ( np == nil ) {
        [sym setFNext:ptrBuffer[ LastHash ]];
        ptrBuffer[ LastHash ] = [sym retain];
        return( ptrBuffer[ LastHash ] );
    }
    return( nil );            /*   not found      */
}
#endif

-(id)getptrBufferEntry:(NSInteger)idx
{
	return( ptrBuffer[idx] );
}

-(id *)getptrBuffer
{
	return( ptrBuffer );
}

-(void)setptrBuffer:(id *)np
{
    ptrBuffer = np;
}

#ifdef DONTUSENOMO
/*
 * works only for maplist indexed not by name but by TokenNumber
 */
- (id)getName:(NSInteger)ttype
{
    id np;
    NSInteger aTType;

    aTType = ttype % HashSize;
    for( np = ptrBuffer[ttype]; np != nil; np = [np getfNext] ) {
        if ( np.index == ttype ) {
            return( np );        /*   found it       */
        }
    }
    return( nil );              /*   not found      */
}

- (id)getTType:(NSString *)name
{
    return [self lookup:name];
}
#endif

- (id) copyWithZone:(NSZone *)aZone
{
    return [super copyWithZone:aZone];
}

@end
