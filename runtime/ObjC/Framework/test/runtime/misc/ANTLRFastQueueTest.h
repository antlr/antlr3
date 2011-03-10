//
//  ANTLRFastQueueTest.h
//  ANTLR
//
//  Created by Ian Michell on 13/05/2010.
//  Copyright 2010 Ian Michell. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


@interface ANTLRFastQueueTest : SenTestCase {

}

-(void) testInit;
-(void) testAddAndGet;
-(void) testInvalidElementIndex;
-(void) testHead;
-(void) testClear;
-(void) testDescription;
-(void) testRemove;

@end
