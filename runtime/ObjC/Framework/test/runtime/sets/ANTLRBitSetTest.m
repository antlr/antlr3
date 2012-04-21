//
//  ANTLRBitSetTest.m
//  ANTLR
//
//  Created by Ian Michell on 13/05/2010.
//  Copyright 2010 Ian Michell and Alan Condit. All rights reserved.
//

#import "ANTLRBitSetTest.h"
#import "ANTLRBitSet.h"
#import "ACNumber.h"
#import <CoreFoundation/CoreFoundation.h>
#import <CoreFoundation/CFBitVector.h>

@implementation ANTLRBitSetTest

-(void) testWithBitData
{
	static const unsigned long long bitData[] = {3LL, 1LL};
	ANTLRBitSet *bitSet = [ANTLRBitSet newBitSetWithBits:bitData Count:2];
    CFIndex actual = (CFIndex)[bitSet numBits];
    CFIndex expected = 3;
	
    STAssertEquals(actual, expected, @"There should be three bits set in bitvector. But I have %d", actual);
	[bitSet release];
}

-(void) testWithBitArray
{
	AMutableArray *bits = [AMutableArray arrayWithCapacity:10];
	[bits addObject:[ACNumber numberWithBool:YES]];
	[bits addObject:[ACNumber numberWithBool:YES]];
	[bits addObject:[ACNumber numberWithBool:NO]];
	[bits addObject:[ACNumber numberWithBool:YES]];
	[bits addObject:[ACNumber numberWithBool:NO]];
	[bits addObject:[ACNumber numberWithBool:YES]];
	STAssertTrue([[bits objectAtIndex:0] boolValue], @"Value at index 0 was not true");
	STAssertTrue([[bits objectAtIndex:1] boolValue], @"Value at index 1 was not true");
	STAssertFalse([[bits objectAtIndex:2] boolValue], @"Value at index 2 was not false");
	STAssertTrue([[bits objectAtIndex:3] boolValue], @"Value at index 3 was not true");
	STAssertFalse([[bits objectAtIndex:4] boolValue], @"Value at index 4 was not false");
	STAssertTrue([[bits objectAtIndex:5] boolValue], @"Value at index 5 was not true");
	ANTLRBitSet *bitSet = [ANTLRBitSet newBitSetWithArray:bits];
	CFIndex actual = (CFIndex)[bitSet numBits];
	CFIndex expected = 4;
	STAssertEquals(actual, expected, @"There should be four bits set in bitvector. But I have %d", actual);
	[bitSet release];
}

-(void) testAdd
{

	ANTLRBitSet *bitSet = [ANTLRBitSet newBitSet];
	[bitSet add:1];
	[bitSet add:2];
	[bitSet add:3];
	CFIndex actual = (CFIndex)[bitSet numBits];
	CFIndex expected = 3;
	STAssertEquals(actual, expected, @"There should be three bits set in bitvector. But I have %d", actual);
	[bitSet release];
}

-(void) testRemove
{
	ANTLRBitSet *bitSet = [ANTLRBitSet newBitSet];
	[bitSet add:1];
	CFIndex actual = (CFIndex)[bitSet numBits];
	CFIndex expected = 1;
	STAssertTrue(actual == expected, @"Bitset was not of size 1");
	STAssertTrue([bitSet member:1], @"Bit at index 1 is not a member...");
	[bitSet remove:1];
	actual = [bitSet numBits];
	STAssertTrue(actual == 0, @"Bitset was not empty");
	STAssertFalse([bitSet member:1], @"Bit at index 1 is a member...");
	STAssertTrue([bitSet isNil], @"There was at least one bit on...");
}

-(void) testCopyBitSet
{
	static const unsigned long long bitData[] = {3LL, 1LL};
	ANTLRBitSet *bitSet = [ANTLRBitSet newBitSetWithBits:bitData Count:2];
	ANTLRBitSet *copy = [bitSet mutableCopyWithZone:nil];
	CFIndex actual = (CFIndex)[copy numBits];
	STAssertEquals(actual, (CFIndex)[bitSet numBits], @"There should be three bits set in bitvector. But I have %d", [copy numBits]);
	[bitSet release];
}

-(void) testOr
{
	static const unsigned long long bitData[] = {3LL, 1LL};
	ANTLRBitSet *bitSet = [ANTLRBitSet newBitSetWithBits:bitData Count:2];
	
	static const unsigned long long otherData[] = {5LL, 3LL, 1LL};
	ANTLRBitSet *otherBitSet = [ANTLRBitSet newBitSetWithBits:otherData Count:3];
	
	ANTLRBitSet *c = [bitSet or:otherBitSet];
	STAssertTrue([c size] == [otherBitSet size], @"c should be the same as otherBitSet");
}

-(void) testOrInPlace
{
    
	ANTLRBitSet *bitSet = [ANTLRBitSet newBitSet];
	[bitSet add:1];
	[bitSet add:2];
	[bitSet add:16];
	CFIndex actual = (CFIndex)[bitSet numBits];
	CFIndex expected = 3;
	STAssertEquals(actual, expected, @"There should be three bits set in bitvector. But I have %d", actual);
	ANTLRBitSet *followSet = [ANTLRBitSet newBitSet];
    [followSet orInPlace:bitSet];
	actual = (CFIndex)[followSet numBits];
	expected = 3;
    NSLog( @"%@\n", [followSet description] );
	STAssertEquals(actual, expected, @"There should be three bits set in bitvector. But I have %d", actual);
	[bitSet release];
	[followSet release];
}

-(void) testDescription
{
	ANTLRBitSet *bitSet = [ANTLRBitSet newBitSet];
	[bitSet add:1];
	[bitSet add:2];
	NSMutableString *aDescription = (NSMutableString *)[bitSet description];
	STAssertTrue([aDescription isEqualToString:@"{1,2}"], @"Description was not right, expected '{1,2}' got: %@", aDescription);
}

@end
