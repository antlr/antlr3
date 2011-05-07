// [The "BSD licence"]
// Copyright (c) 2006-2007 Kay Roepke 2010 Alan Condit
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


#import <Cocoa/Cocoa.h>
#import "ANTLRCharStream.h"
#import "ANTLRCharStreamState.h"
#import "ANTLRPtrBuffer.h"

@interface ANTLRStringStream : NSObject < ANTLRCharStream > {
	NSString *data;
	NSInteger n;
	NSInteger index;
	NSUInteger line;
	NSUInteger charPositionInLine;
	NSInteger markDepth;
	ANTLRPtrBuffer *markers;
	NSInteger lastMarker;
	NSString *name;
    ANTLRCharStreamState *charState;
}

+ newANTLRStringStream;

+ newANTLRStringStream:(NSString *)aString;

+ newANTLRStringStream:(char *)myData Count:(NSInteger)numBytes;

- (id) init;

// this initializer copies the string
- (id) initWithString:(NSString *) theString;

// This is the preferred constructor as no data is copied
- (id) initWithStringNoCopy:(NSString *) theString;

- (id) initWithData:(char *)myData Count:(NSInteger)numBytes;

- (void) dealloc;

- (id) copyWithZone:(NSZone *)aZone;

// reset the stream's state, but keep the data to feed off
- (void) reset;
// consume one character from the stream
- (void) consume;

// look ahead i characters
- (NSInteger) LA:(NSInteger) i;
- (NSInteger) LT:(NSInteger) i;

// total length of the input data
- (NSInteger) size;

// seek and rewind in the stream
- (NSInteger) mark;
- (void) rewind:(NSInteger) marker;
- (void) rewind;
- (void) release:(NSInteger) marker;
- (void) seek:(NSInteger) index;

// provide the streams data (e.g. for tokens using indices)
- (NSString *) substring:(NSInteger)startIndex To:(NSInteger)stopIndex;
- (NSString *) substringWithRange:(NSRange) theRange;

- (ANTLRPtrBuffer *)getMarkers;
- (void) setMarkers:(ANTLRPtrBuffer *)aMarkerList;

- (NSString *)getSourceName;

- (NSString *)toString;

// accessors to the raw data of this stream

@property (retain) NSString *data;
@property (assign) NSInteger index;
@property (assign) NSInteger n;
@property (assign) NSUInteger line;
@property (assign) NSUInteger charPositionInLine;
@property (assign) NSInteger markDepth;
@property (retain) ANTLRPtrBuffer *markers;
@property (assign) NSInteger lastMarker;
@property (retain) NSString *name;
@property (retain) ANTLRCharStreamState *charState;

@end
