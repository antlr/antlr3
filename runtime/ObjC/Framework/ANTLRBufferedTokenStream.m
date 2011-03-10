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

#import "ANTLRBufferedTokenStream.h"
#import "ANTLRTokenSource.h"
#import "ANTLRCommonTreeAdaptor.h"

extern NSInteger debug;

@implementation ANTLRBufferedTokenStream

@synthesize tokenSource;
@synthesize tokens;
@synthesize lastMarker;
@synthesize p;
@synthesize range;

+ (ANTLRBufferedTokenStream *) newANTLRBufferedTokenStream
{
    return [[ANTLRBufferedTokenStream alloc] init];
}

+ (ANTLRBufferedTokenStream *) newANTLRBufferedTokenStreamWith:(id<ANTLRTokenSource>)aSource
{
    return [[ANTLRBufferedTokenStream alloc] initWithSource:aSource];
}

- (ANTLRBufferedTokenStream *) init
{
	if ((self = [super init]) != nil)
	{
        tokenSource = nil;
        tokens = [[NSMutableArray arrayWithCapacity:1000] retain];
        p = -1;
        range = -1;
	}
	return self;
}

-(id) initWithSource:(id<ANTLRTokenSource>)aSource
{
	if ((self = [super init]) != nil)
	{
        tokenSource = aSource;
        tokens = [[NSMutableArray arrayWithCapacity:1000] retain];
        p = -1;
        range = -1;
	}
	return self;
}

- (id) copyWithZone:(NSZone *)aZone
{
    ANTLRBufferedTokenStream *copy;
    
    copy = [[[self class] allocWithZone:aZone] init];
    copy.tokenSource = self.tokenSource;
    if ( self.tokens )
        copy.tokens = [tokens copyWithZone:aZone];
    copy.lastMarker = self.lastMarker;
    copy.p = self.p;
    copy.range = self.range;
    return copy;
}

- (id<ANTLRTokenSource>) getTokenSource
{
    return tokenSource;
}

- (NSInteger) getIndex
{
    return p;
}

- (void) setIndex:(NSInteger) index
{
    p = index;
}

- (NSInteger) getRange
{
    return range;
}

- (void) setRange:(NSInteger)anInt
{
    range = anInt;
}

- (NSInteger) mark
{
    if ( p == -1 ) {
        [self setup];
//        [self fill];
    }
    lastMarker = [self getIndex];
    return lastMarker;
}

- (void) release:(NSInteger) marker
{
    // no resources to release
}

- (void) rewind:(NSInteger) marker
{
    [self seek:marker];
}

- (void) rewind
{
    [self seek:lastMarker];
}

- (void) reset
{
    p = 0;
    lastMarker = 0;
}

- (void) seek:(NSInteger) index
{
    p = index;
}

- (NSInteger) size
{
    return [tokens count];
}

/** Move the input pointer to the next incoming token.  The stream
 *  must become active with LT(1) available.  consume() simply
 *  moves the input pointer so that LT(1) points at the next
 *  input symbol. Consume at least one token.
 *
 *  Walk past any token not on the channel the parser is listening to.
 */
- (void) consume
{
    if ( p == -1 ) {
        [self setup];
//        [self fill];
    }
    p++;
    [self sync:p];
}

/** Make sure index i in tokens has a token. */
- (void) sync:(NSInteger) i
{
    // how many more elements we need?
    NSInteger n = (i - [tokens count]) + 1;
    if (debug > 1) NSLog(@"[self sync:%d] needs %d\n", i, n);
    if ( n > 0 )
        [self fetch:n];
}

/** add n elements to buffer */
- (void) fetch:(NSInteger)n
{
    for (NSInteger i=1; i <= n; i++) {
        id<ANTLRToken> t = [tokenSource nextToken];
        [t setTokenIndex:[tokens count]];
        if (debug > 1) NSLog(@"adding %@ at index %d\n", [t getText], [tokens count]);
        [tokens addObject:t];
        [t retain];
        if ( [t getType] == ANTLRTokenTypeEOF )
            break;
    }
}

- (id<ANTLRToken>) getToken:(NSInteger) i
{
    if ( i < 0 || i >= [tokens count] ) {
        @throw [ANTLRRuntimeException newANTLRNoSuchElementException:[NSString stringWithFormat:@"token index %d out of range 0..%d", i, [tokens count]-1]];
    }
    return [tokens objectAtIndex:i];
}

/** Get all tokens from start..stop inclusively */
- (NSMutableArray *)getFrom:(NSInteger)startIndex To:(NSInteger)stopIndex
{
    if ( startIndex < 0 || stopIndex < 0 )
        return nil;
    if ( p == -1 ) {
        [self setup];
//        [self fill];
    }
    NSMutableArray *subset = [NSMutableArray arrayWithCapacity:5];
    if ( stopIndex >= [tokens count] )
        stopIndex = [tokens count]-1;
    for (NSInteger i = startIndex; i <= stopIndex; i++) {
        id<ANTLRToken>t = [tokens objectAtIndex:i];
        if ( [t getType] == ANTLRTokenTypeEOF )
            break;
        [subset addObject:t];
    }
    return subset;
}

- (NSInteger) LA:(NSInteger)i
{
    return [[self LT:i] getType];
}

- (id<ANTLRToken>) LB:(NSInteger)k
{
    if ( (p - k) < 0 )
        return nil;
    return [tokens objectAtIndex:(p-k)];
}

- (id<ANTLRToken>) LT:(NSInteger)k
{
    if ( p == -1 ) {
        [self setup];
//        [self fill];
    }
    if ( k == 0 )
        return nil;
    if ( k < 0 )
        return [self LB:-k];
    
    NSInteger i = p + k - 1;
    [self sync:i];
    if ( i >= [tokens count] ) { // return EOF token
                                // EOF must be last token
        return [tokens objectAtIndex:([tokens count]-1)];
    }
    if ( i > range )
        range = i; 		
    return [tokens objectAtIndex:i];
}

- (void) setup
{
    [self sync:0];
    p = 0;
}

/** Reset this token stream by setting its token source. */
- (void) setTokenSource:(id<ANTLRTokenSource>) aTokenSource
{
    tokenSource = aTokenSource;
    [tokens removeAllObjects];
    p = -1;
}

- (NSMutableArray *)getTokens
{
    return tokens;
}

- (NSMutableArray *)getTokensFrom:(NSInteger) startIndex To:(NSInteger) stopIndex
{
    return [self getTokensFrom:startIndex To:stopIndex With:(ANTLRBitSet *)nil];
}

/** Given a start and stop index, return a List of all tokens in
 *  the token type BitSet.  Return null if no tokens were found.  This
 *  method looks at both on and off channel tokens.
 */
- (NSMutableArray *)getTokensFrom:(NSInteger)startIndex To:(NSInteger)stopIndex With:(ANTLRBitSet *)types
{
    if ( p == -1 ) {
        [self setup];
//        [self fill];
    }
    if ( stopIndex >= [tokens count] )
        stopIndex = [tokens count]-1;
    if ( startIndex < 0 )
        startIndex = 0;
    if ( startIndex > stopIndex )
        return nil;
    
    // list = tokens[start:stop]:{Token t, t.getType() in types}
    NSMutableArray *filteredTokens = [NSMutableArray arrayWithCapacity:5];
    for (NSInteger i = startIndex; i <= stopIndex; i++) {
        id<ANTLRToken>t = [tokens objectAtIndex:i];
        if ( types == nil || [types member:[t getType]] ) {
            [filteredTokens addObject:t];
            [t retain];
        }
    }
    if ( [filteredTokens count] == 0 ) {
        filteredTokens = nil;
    }
    return filteredTokens;
}

- (NSMutableArray *)getTokensFrom:(NSInteger)startIndex To:(NSInteger)stopIndex WithType:(NSInteger)ttype
{
    return [self getTokensFrom:startIndex To:stopIndex With:[ANTLRBitSet of:ttype]];
}

- (NSMutableArray *)getTokensFrom:(NSInteger)startIndex To:(NSInteger)stopIndex WithList:(NSMutableArray *)types
{
    return [self getTokensFrom:startIndex To:stopIndex With:[ANTLRBitSet newANTLRBitSetWithArray:types]];
}
            
- (NSString *)getSourceName
{
    return [tokenSource getSourceName];
}

/** Grab *all* tokens from stream and return string */
- (NSString *) toString
{
    if ( p == -1 ) {
        [self setup];
    }
    [self fill];
    return [self toStringFromStart:0 ToEnd:[tokens count]-1];
}

- (NSString *) toStringFromStart:(NSInteger)startIdx ToEnd:(NSInteger)stopIdx
{
    if ( startIdx < 0 || stopIdx < 0 )
        return nil;
    if ( p == -1 ) {
        [self setup];
    }
    if ( stopIdx >= [tokens count] )
        stopIdx = [tokens count]-1;
    NSMutableString *buf = [NSMutableString stringWithCapacity:5];
    for (NSInteger i = startIdx; i <= stopIdx; i++) {
        id<ANTLRToken>t = [tokens objectAtIndex:i];
        if ( [t getType] == ANTLRTokenTypeEOF )
            break;
        [buf appendString:[t getText]];
    }
    return buf;
}

- (NSString *) toStringFromToken:(id<ANTLRToken>)startToken ToToken:(id<ANTLRToken>)stopToken
{
    if ( startToken != nil && stopToken != nil ) {
        return [self toStringFromStart:[startToken getTokenIndex] ToEnd:[stopToken getTokenIndex]];
    }
    return nil;
}

/** Get all tokens from lexer until EOF */
- (void) fill
{
    if ( p == -1 ) [self setup];
    if ( [[tokens objectAtIndex:p] getType] == ANTLRTokenTypeEOF )
        return;
    
    NSInteger i = p+1;
    [self sync:i];
    while ( [[tokens objectAtIndex:i] getType] != ANTLRTokenTypeEOF ) {
        i++;
        [self sync:i];
    }
}

#ifdef DONTUSENOMO
- (NSUInteger) getCharPositionInLine
{
    return -1;
}

- (void) setCharPositionInLine:(NSUInteger)thePos
{
}
#endif

@end
