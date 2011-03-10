//
//  ANTLRBitSetTest.h
//  ANTLR
//
//  Created by Ian Michell on 13/05/2010.
//  Copyright 2010 Ian Michell. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface ANTLRBitSetTest : SenTestCase 
{
	
}

-(void) testWithBitData;
-(void) testWithBitArray;
-(void) testAdd;
-(void) testRemove;
-(void) testCopyBitSet;
-(void) testOr;
-(void) testDescription;

@end
