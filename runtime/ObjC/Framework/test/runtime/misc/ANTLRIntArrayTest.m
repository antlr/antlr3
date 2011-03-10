//
//  ANTLRIntArrayTest.m
//  ANTLR
//
//  Created by Ian Michell on 13/05/2010.
//  Copyright 2010 Ian Michell. All rights reserved.
//

#import "ANTLRIntArrayTest.h"
#import "ANTLRIntArray.h"

@implementation ANTLRIntArrayTest

-(void) testAdd
{
	ANTLRIntArray *intArray = [ANTLRIntArray newArrayWithLen:10];
	[intArray addInteger:1];
	STAssertTrue([intArray count] == 1, @"Int array should be of size 1");
	STAssertTrue([intArray integerAtIndex:0] == 1, @"First item in int array should be 1");
	[intArray release];
}

-(void) testPushPop
{
	ANTLRIntArray *intArray = [ANTLRIntArray newArrayWithLen:10];
	for (NSInteger i = 0; i < 10; i++)
	{
		[intArray push:i + 1];
	}
	NSInteger popped = [intArray pop];
	NSLog(@"Popped value: %d", popped);
	STAssertTrue(popped == 10, @"Pop should pull the last element out, which should be 10 was: %d", popped);
	[intArray release];
}

-(void) testClearAndAdd
{
	ANTLRIntArray *intArray = [ANTLRIntArray newArrayWithLen:10];
	[intArray addInteger:1];
	STAssertTrue([intArray count] == 1, @"Int array should be of size 1");
	STAssertTrue([intArray integerAtIndex:0] == 1, @"First item in int array should be 1");
	[intArray reset];
	STAssertTrue([intArray count] == 0, @"Array size should be 0");
	[intArray release];
}

@end
