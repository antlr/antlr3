//
//  ANTLRFastQueueTest.m
//  ANTLR
//
//  Created by Ian Michell on 13/05/2010.
//  Copyright 2010 Ian Michell and Alan Condit. All rights reserved.
//

#import "ANTLRFastQueueTest.h"
#import "ANTLRFastQueue.h"
#import "ANTLRError.h"
#import "ANTLRRuntimeException.h"

@implementation ANTLRFastQueueTest

-(void) testInit
{
	ANTLRFastQueue *queue = [[ANTLRFastQueue newANTLRFastQueue] retain];
	STAssertNotNil(queue, @"Queue was not created and was nil");
	[queue release];
}

-(void) testAddAndGet
{
	ANTLRFastQueue *queue = [[ANTLRFastQueue newANTLRFastQueue] retain];
	STAssertNotNil(queue, @"Queue was not created and was nil");
	[queue addObject:@"My String"];
	STAssertTrue([[queue objectAtIndex:0] isKindOfClass:[NSString class]], @"First object is not a NSString");
	STAssertEquals([queue objectAtIndex:0], @"My String", @"Object at index zero is invalid");
	STAssertTrue([queue size] == 1, @"Queue is the wrong size: %d", [queue size]);
	[queue release];
}

-(void) testInvalidElementIndex
{
    //ANTLRRuntimeException *ANTLRNoSuchElementException = [ANTLRNoSuchElementException newException:@"No such element exception"];
    id retVal;
	ANTLRFastQueue *queue = [[ANTLRFastQueue newANTLRFastQueue] retain];
	STAssertNotNil(queue, @"Queue was not created and was nil");
	@try 
	{
		retVal = [queue objectAtIndex:100];
	}
	@catch (ANTLRNoSuchElementException *e) 
	{
		STAssertTrue([[e name] isEqualTo:@"ANTLRNoSuchElementException"], @"Exception was not type: ANTLRNoSuchElementException -- %@", [e name]);
		return;
	}
	STFail(@"Exception ANTLRNoSuchElementException was not thrown -- %@", [retVal name]);
    [queue release];
}

-(void) testHead
{
	ANTLRFastQueue *queue = [[ANTLRFastQueue newANTLRFastQueue] retain];
	STAssertNotNil(queue, @"Queue was not created and was nil");
	[queue addObject:@"Item 1"];
	[queue addObject:@"Item 2"];
	[queue addObject:@"Item 3"];
	id head = [queue head];
	STAssertNotNil(head, @"Object returned from head is nil");
	STAssertEquals(head, @"Item 1", @"Object returned was not first item in");
	[queue release];
}

-(void) testClear
{
	ANTLRFastQueue *queue = [[ANTLRFastQueue newANTLRFastQueue] retain];
	STAssertNotNil(queue, @"Queue was not created and was nil");
	[queue addObject:@"Item 1"];
	[queue addObject:@"Item 2"];
	[queue addObject:@"Item 3"];
	STAssertTrue([queue size] == 3, @"Queue was too small, was: %d expected 3", [queue size]);
	[queue reset];
	STAssertTrue([queue size] == 0, @"Queue is not empty, it's still %d", [queue size]);
	[queue release];
}

-(void) testDescription
{
	ANTLRFastQueue *queue = [[ANTLRFastQueue newANTLRFastQueue] retain];
	STAssertNotNil(queue, @"Queue was not created and was nil");
	[queue addObject:@"My"];
	[queue addObject:@"String"];
	STAssertTrue([[queue description] isEqualToString:@"My String"], @"Queue description was not right, got: \"%@\" expected: \"My String\"", [queue description]);
	[queue release];
}

-(void) testRemove
{
	ANTLRFastQueue *queue = [[ANTLRFastQueue newANTLRFastQueue] retain];
	STAssertNotNil(queue, @"Queue was not created and was nil");
	[queue addObject:@"My"];
	[queue addObject:@"String"];
	STAssertTrue([queue size] == 2, @"Queue not the correct size, was: %d expected 2", [queue size]);
	[queue remove];
	STAssertTrue([queue size] == 1, @"Queue not the correct size, was %d expected 1", [queue size]);
	[queue remove]; // test that the queue is reset when we remove the last object...
	STAssertTrue([queue size] == 0, @"Queue was not reset, when we hit the buffer, was still %d", [queue size]);
	[queue release];
}

@end
