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

-(void) test01InitAndRelease;
-(void) test02GetEOFToken;
-(void) test03InitWithTokenType;
-(void) test04InitWithTokenTypeAndText;
-(void) test05InitWithCharStream;
-(void) test06InitWithToken;
-(void) test07TokenDescription;

@end
