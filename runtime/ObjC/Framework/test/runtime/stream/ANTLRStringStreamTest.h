//
//  ANTLRStringStreamTest.h
//  ANTLR
//
//  Created by Ian Michell on 12/05/2010.
//  Copyright 2010 Ian Michell. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


@interface ANTLRStringStreamTest : SenTestCase {

}

-(void) testInitWithInput;
-(void) testConsumeAndReset;
-(void) testConsumeWithNewLine;
-(void) testSeek;
-(void) testSeekMarkAndRewind;
-(void) testLAEOF;
-(void) testLTEOF; // same as LA

@end
