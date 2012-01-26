//
//  ANTLRLookaheadStream.m
//  ANTLR
//
//  Created by Ian Michell on 26/04/2010.
// [The "BSD licence"]
// Copyright (c) 2010 Ian Michell 2010 Alan Condit
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

#import "ANTLRLookaheadStream.h"
#import "ANTLRError.h"
#import "ANTLRRecognitionException.h"
#import "ANTLRCommonToken.h"
#import "ANTLRRuntimeException.h"

@implementation ANTLRLookaheadStream

@synthesize eof;
@synthesize index;
@synthesize eofElementIndex;
@synthesize lastMarker;
@synthesize markDepth;
@synthesize prevElement;

-(id) init
{
	self = [super init];
	if ( self != nil ) {
        eof = [[ANTLRCommonToken eofToken] retain];
		eofElementIndex = UNITIALIZED_EOF_ELEMENT_INDEX;
		markDepth = 0;
        index = 0;
	}
	return self;
}

-(id) initWithEOF:(id)obj
{
	if ((self = [super init]) != nil) {
		self.eof = obj;
        if ( self.eof ) [self.eof retain];
	}
	return self;
}

- (void) reset
{
	[super reset];
    index = 0;
    p = 0;
    prevElement = nil;
	eofElementIndex = UNITIALIZED_EOF_ELEMENT_INDEX;
}

-(id) nextElement
{
//	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id) remove
{
    id obj = [self objectAtIndex:0];
    p++;
    // have we hit end of buffer and not backtracking?
    if ( p == [data count] && markDepth==0 ) {
        // if so, it's an opportunity to start filling at index 0 again
        [self clear]; // size goes to 0, but retains memory
    }
    [obj release];
    return obj;
}

-(void) consume
{
	[self sync:1];
	prevElement = [self remove];
    index++;
}

-(void) sync:(NSInteger) need
{
	NSInteger n = (p + need - 1) - [data count] + 1;
	if ( n > 0 ) {
		[self fill:n];
	}
}

-(void) fill:(NSInteger) n
{
    id obj;
	for (NSInteger i = 1; i <= n; i++) {
		obj = [self nextElement];
		if ( obj == eof ) {
			[data addObject:self.eof];
			eofElementIndex = [data count] - 1;
		}
		else {
			[data addObject:obj];
		}
	}
}

-(NSUInteger) count
{
	@throw [NSException exceptionWithName:@"ANTLRUnsupportedOperationException" reason:@"Streams have no defined size" userInfo:nil];
}

-(id) LT:(NSInteger) k
{
	if (k == 0) {
		return nil;
	}
	if (k < 0) {
		return [self LB:-k];
	}
	if ((p + k - 1) >= eofElementIndex) {
		return self.eof;
	}
	[self sync:k];
	return [self objectAtIndex:(k - 1)];
}

-(id) LB:(NSInteger) k
{
	if (k == 1) {
		return prevElement;
	}
	@throw [ANTLRNoSuchElementException newException:@"can't look backwards more than one token in this stream"];
}

-(id) getCurrentSymbol
{
	return [self LT:1];
}

-(NSInteger) mark
{
	markDepth++;
	lastMarker = p;
	return lastMarker;
}

-(void) release:(NSInteger) marker
{
	// no resources to release
}

-(void) rewind:(NSInteger) marker
{
	markDepth--;
	[self seek:marker];
//    if (marker == 0) [self reset];
}

-(void) rewind
{
	[self seek:lastMarker];
//    if (lastMarker == 0) [self reset];
}

-(void) seek:(NSInteger) anIndex
{
	p = anIndex;
}

- (id) getEof
{
    return eof;
}

- (void) setEof:(id) anID
{
    eof = anID;
}

- (NSInteger) getEofElementIndex
{
    return eofElementIndex;
}

- (void) setEofElementIndex:(NSInteger) anInt
{
    eofElementIndex = anInt;
}

- (NSInteger) getLastMarker
{
    return lastMarker;
}

- (void) setLastMarker:(NSInteger) anInt
{
    lastMarker = anInt;
}

- (NSInteger) getMarkDepthlastMarker
{
    return markDepth;
}

- (void) setMarkDepth:(NSInteger) anInt
{
    markDepth = anInt;
}

@end
