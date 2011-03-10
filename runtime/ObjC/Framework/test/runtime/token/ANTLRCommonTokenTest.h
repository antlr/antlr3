//
//  ANTLRCommonTokenTest.h
//  ANTLR
//
//  Created by Ian Michell on 25/05/2010.
//  Copyright 2010 Ian Michell. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


@interface ANTLRCommonTokenTest : SenTestCase 
{

}

-(void) testGetEOFToken;
-(void) testInitAndRelease;
-(void) testInitWithTokenType;
-(void) testInitWithTokenTypeAndText;
-(void) testInitWithCharStream;
-(void) testInitWithToken;
-(void) testTokenDescription;

@end
