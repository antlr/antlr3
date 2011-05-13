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

#import "ANTLRBitSet.h"

@implementation ANTLRBitSet
#pragma mark Class Methods

+ (ANTLRBitSet *) newANTLRBitSet
{
    return [[ANTLRBitSet alloc] init];
}

+ (ANTLRBitSet *) newANTLRBitSetWithType:(ANTLRTokenType)type
{
    return [[ANTLRBitSet alloc] initWithType:type];
}

/** Construct a ANTLRBitSet given the size
 * @param nbits The size of the ANTLRBitSet in bits
 */
+ (ANTLRBitSet *) newANTLRBitSetWithNBits:(NSUInteger)nbits
{
    return [[ANTLRBitSet alloc] initWithNBits:nbits];
}

+ (ANTLRBitSet *) newANTLRBitSetWithArray:(AMutableArray *)types
{
    return [[ANTLRBitSet alloc] initWithArrayOfBits:types];
}

+ (ANTLRBitSet *) newANTLRBitSetWithBits:(const unsigned long long *)theBits Count:(NSUInteger)longCount
{
    return [[ANTLRBitSet alloc] initWithBits:theBits Count:longCount];
}


+ (ANTLRBitSet *) of:(NSUInteger) el
{
    ANTLRBitSet *s = [ANTLRBitSet newANTLRBitSetWithNBits:(el + 1)];
    [s add:el];
    return s;
}

+ (ANTLRBitSet *) of:(NSUInteger) a And2:(NSUInteger) b
{
    NSInteger c = (((a>b)?a:b)+1);
    ANTLRBitSet *s = [ANTLRBitSet newANTLRBitSetWithNBits:c];
    [s add:a];
    [s add:b];
    return s;
}

+ (ANTLRBitSet *) of:(NSUInteger)a And2:(NSUInteger)b And3:(NSUInteger)c
{
    NSUInteger d = ((a>b)?a:b);
    d = ((c>d)?c:d)+1;
    ANTLRBitSet *s = [ANTLRBitSet newANTLRBitSetWithNBits:d];
    [s add:a];
    [s add:b];
    [s add:c];
    return s;
}

+ (ANTLRBitSet *) of:(NSUInteger)a And2:(NSUInteger)b And3:(NSUInteger)c And4:(NSUInteger)d
{
    NSUInteger e = ((a>b)?a:b);
    NSUInteger f = ((c>d)?c:d);
    e = ((e>f)?e:f)+1;
    ANTLRBitSet *s = [ANTLRBitSet newANTLRBitSetWithNBits:e];
    [s add:a];
    [s add:b];
    [s add:c];
    [s add:d];
    return s;
}

// initializer
#pragma mark Initializer

- (ANTLRBitSet *) init
{
	if ((self = [super init]) != nil) {
		bitVector = CFBitVectorCreateMutable(kCFAllocatorDefault,0);
	}
	return self;
}

- (ANTLRBitSet *) initWithType:(ANTLRTokenType)type
{
	if ((self = [super init]) != nil) {
		bitVector = CFBitVectorCreateMutable(kCFAllocatorDefault,0);
        if ((CFIndex)type >= CFBitVectorGetCount(bitVector))
            CFBitVectorSetCount(bitVector, type+1);
        CFBitVectorSetBitAtIndex(bitVector, type, 1);
	}
	return self;
}

- (ANTLRBitSet *) initWithNBits:(NSUInteger)nbits
{
	if ((self = [super init]) != nil) {
        bitVector = CFBitVectorCreateMutable(kCFAllocatorDefault,0);
        CFBitVectorSetCount( bitVector, nbits );
	}
	return self;
}

- (ANTLRBitSet *) initWithBitVector:(CFMutableBitVectorRef)theBitVector
{
	if ((self = [super init]) != nil) {
		bitVector = theBitVector;
	}
	return self;
}

// Initialize the bit vector with a constant array of ulonglongs like ANTLR generates.
// Converts to big endian, because the underlying CFBitVector works like that.
- (ANTLRBitSet *) initWithBits:(const unsigned long long *)theBits Count:(NSUInteger)longCount
{
	if ((self = [super init]) != nil) {
		unsigned int longNo;
		CFIndex bitIdx;
        bitVector = CFBitVectorCreateMutable ( kCFAllocatorDefault, 0 );
		CFBitVectorSetCount( bitVector, sizeof(unsigned long long)*8*longCount );

		for (longNo = 0; longNo < longCount; longNo++) {
			for (bitIdx = 0; bitIdx < (CFIndex)sizeof(unsigned long long)*8; bitIdx++) {
				unsigned long long swappedBits = CFSwapInt64HostToBig(theBits[longNo]);
				if (swappedBits & (1LL << bitIdx)) {
					CFBitVectorSetBitAtIndex(bitVector, bitIdx+(longNo*(sizeof(unsigned long long)*8)), 1);
				}
			}
		}
	}
	return self;
}

// Initialize bit vector with an array of anything. Just test the boolValue and set the corresponding bit.
// Note: This is big-endian!
- (ANTLRBitSet *) initWithArrayOfBits:(NSArray *)theArray
{
	if ((self = [super init]) != nil) {
        bitVector = CFBitVectorCreateMutable ( kCFAllocatorDefault, 0 );
		id value;
		int bit = 0;
		for (value in theArray) {
			if ([value boolValue] == YES) {
                [self add:bit];
				//CFBitVectorSetBitAtIndex(bitVector, bit, 1);
			}
			bit++;
		}
	}
	return self;
}

- (void)dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in ANTLRBitSet" );
#endif
	CFRelease(bitVector);
	[super dealloc];
}

	// operations
#pragma mark Operations
// return a copy of (self|aBitSet)
- (ANTLRBitSet *) or:(ANTLRBitSet *) aBitSet
{
	ANTLRBitSet *bitsetCopy = [self mutableCopyWithZone:nil];
	[bitsetCopy orInPlace:aBitSet];
	return bitsetCopy;
}

// perform a bitwise OR operation in place by changing underlying bit vector, growing it if necessary
- (void) orInPlace:(ANTLRBitSet *) aBitSet
{
	CFIndex selfCnt = CFBitVectorGetCount(bitVector);
	CFMutableBitVectorRef otherBitVector = [aBitSet _bitVector];
	CFIndex otherCnt = CFBitVectorGetCount(otherBitVector);
	CFIndex maxBitCnt = selfCnt > otherCnt ? selfCnt : otherCnt;
	CFBitVectorSetCount(bitVector,maxBitCnt);		// be sure to grow the CFBitVector manually!
	
	CFIndex currIdx;
	for (currIdx = 0; currIdx < maxBitCnt; currIdx++) {
		if (CFBitVectorGetBitAtIndex(bitVector, currIdx) | CFBitVectorGetBitAtIndex(otherBitVector, currIdx)) {
			CFBitVectorSetBitAtIndex(bitVector, currIdx, 1);
		}
	}
}

// set a bit, grow the bit vector if necessary
- (void) add:(NSUInteger) bit
{
	if ((CFIndex)bit >= CFBitVectorGetCount(bitVector))
		CFBitVectorSetCount(bitVector, bit+1);
	CFBitVectorSetBitAtIndex(bitVector, bit, 1);
}

// unset a bit
- (void) remove:(NSUInteger) bit
{
	CFBitVectorSetBitAtIndex(bitVector, bit, 0);
}

- (void) setAllBits:(BOOL) aState
{
    for( NSInteger bit=0; bit < CFBitVectorGetCount(bitVector); bit++ ) {
        CFBitVectorSetBitAtIndex(bitVector, bit, aState);
    }
}

// returns the number of bits in the bit vector.
- (NSInteger) numBits
{
    // return CFBitVectorGetCount(bitVector);
    return CFBitVectorGetCountOfBit(bitVector, CFRangeMake(0, CFBitVectorGetCount(bitVector)), 1);
}

// returns the number of bits in the bit vector.
- (NSUInteger) size
{
    return CFBitVectorGetCount(bitVector);
}

- (void) setSize:(NSUInteger) nBits
{
    CFBitVectorSetCount( bitVector, nBits );
}

#pragma mark Informational
// return a bitmask representation of this bitvector for easy operations
- (unsigned long long) bitMask:(NSUInteger) bitNumber
{
	return 1LL << bitNumber;
}

// test a bit (no pun intended)
- (BOOL) member:(NSUInteger) bitNumber
{
	return CFBitVectorGetBitAtIndex(bitVector,bitNumber) ? YES : NO;
}

// are all bits off?
- (BOOL) isNil
{
	return ((CFBitVectorGetCountOfBit(bitVector, CFRangeMake(0,CFBitVectorGetCount(bitVector)), 1) == 0) ? YES : NO);
}

// return a string representation of the bit vector, indicating by their bitnumber which bits are set
- (NSString *) toString
{
	CFIndex length = CFBitVectorGetCount(bitVector);
	CFIndex currBit;
	NSMutableString *descString = [NSMutableString  stringWithString:@"{"];
	BOOL haveInsertedBit = NO;
	for (currBit = 0; currBit < length; currBit++) {
		if ( CFBitVectorGetBitAtIndex(bitVector, currBit) ) {
			if (haveInsertedBit) {
				[descString appendString:@","];
			}
			[descString appendFormat:@"%d", currBit];
			haveInsertedBit = YES;
		}
	}
	[descString appendString:@"}"];
	return descString;
}

// debugging aid. GDB invokes this automagically
- (NSString *) description
{
	return [self toString];
}

	// NSCopying
#pragma mark NSCopying support

- (id) mutableCopyWithZone:(NSZone *) theZone
{
	ANTLRBitSet *newBitSet = [[ANTLRBitSet allocWithZone:theZone] initWithBitVector:CFBitVectorCreateMutableCopy(kCFAllocatorDefault,0,bitVector)];
	return newBitSet;
}

- (CFMutableBitVectorRef) _bitVector
{
	return bitVector;
}

@synthesize bitVector;
@end

NSInteger max(NSInteger a, NSInteger b)
{
    return (a>b)?a:b;
}

