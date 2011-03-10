//
//  ANTLRCommonTokenTest.m
//  ANTLR
//
//  Created by Ian Michell on 25/05/2010.
//  Copyright 2010 Ian Michell and Alan Condit. All rights reserved.
//

#import "ANTLRCommonTokenTest.h"
#import "ANTLRCommonToken.h"
#import "ANTLRStringStream.h"

@implementation ANTLRCommonTokenTest

-(void) testInitAndRelease
{
	ANTLRCommonToken *token = [ANTLRCommonToken newANTLRCommonToken];
	STAssertNotNil(token, @"Token was nil");
	[token release];
}

-(void) testGetEOFToken
{
	ANTLRCommonToken *token = [ANTLRCommonToken eofToken];
	STAssertNotNil(token, @"Token was nil");
	STAssertEquals(token.type, (NSInteger)ANTLRTokenTypeEOF, @"Token was not of type ANTLRTokenTypeEOF");
	[token release];
}

-(void) testInitWithTokenType
{
	ANTLRCommonToken *token = [ANTLRCommonToken newANTLRCommonToken:ANTLRTokenTypeUP];
	token.text = @"<UP>";
	STAssertNotNil(token, @"Token was nil");
	STAssertEquals(token.type, (NSInteger)ANTLRTokenTypeUP, @"Token was not of type ANTLRTokenTypeUP");
	STAssertNotNil(token.text, @"Token text was nil, was expecting <UP>");
	STAssertTrue([token.text isEqualToString:@"<UP>"], @"Token text was not <UP> was instead: %@", token.text);
	[token release];
}

-(void) testInitWithTokenTypeAndText
{
	ANTLRCommonToken *token = [ANTLRCommonToken newANTLRCommonToken:ANTLRTokenTypeUP Text:@"<UP>"];
	STAssertNotNil(token, @"Token was nil");
	STAssertEquals(token.type, (NSInteger)ANTLRTokenTypeUP, @"Token was not of type ANTLRTokenTypeUP");
	STAssertNotNil(token.text, @"Token text was nil, was expecting <UP>");
	STAssertTrue([token.text isEqualToString:@"<UP>"], @"Token text was not <UP> was instead: %@", token.text);
	[token release];
}

-(void) testInitWithCharStream
{
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	ANTLRCommonToken *token = [ANTLRCommonToken newANTLRCommonToken:stream Type:555 Channel:ANTLRTokenChannelDefault Start:4 Stop:5];
	STAssertNotNil(token, @"Token was nil");
	STAssertEquals(token.type, (NSInteger)555, @"Token was not of type 555"); // Nice random type number
	STAssertNotNil(token.text, @"Token text was nil, was expecting ||");
	STAssertTrue([token.text isEqualToString:@"||"], @"Token text was not || was instead: %@", token.text);
	[token release];
}

-(void) testInitWithToken
{
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	ANTLRCommonToken *token = [ANTLRCommonToken newANTLRCommonToken:stream Type:555 Channel:ANTLRTokenChannelDefault Start:4 Stop:5];
	STAssertNotNil(token, @"Token was nil");
	STAssertEquals(token.type, (NSInteger)555, @"Token was not of type 555"); // Nice random type number
	STAssertNotNil(token.text, @"Token text was nil, was expecting ||");
	STAssertTrue([token.text isEqualToString:@"||"], @"Token text was not || was instead: %@", token.text);
	
	ANTLRCommonToken *newToken = [ANTLRCommonToken newANTLRCommonTokenWithToken:token];
	STAssertNotNil(newToken, @"New token is nil!");
	STAssertEquals(newToken.type, token.type, @"Tokens types do not match %d:%d!", newToken.type, token.type);
	STAssertEquals(newToken.line, token.line, @"Token lines do not match!");
	STAssertEquals(newToken.index, token.index, @"Token indexes do not match");
	STAssertEquals(newToken.channel, token.channel, @"Token channels are not the same");
	STAssertEquals(newToken.charPositionInLine, token.charPositionInLine, @"Token char positions in lines do not match");
	STAssertEquals(newToken.startIndex, token.startIndex, @"Token start positions do not match");
	STAssertEquals(newToken.stopIndex, token.stopIndex, @"Token stop positions do not match");
	STAssertTrue([newToken.text isEqualToString:token.text], @"Token text does not match!");
	[token release];
	//[newToken release];
}

-(void) testTokenDescription
{
    NSString *aDescription;
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	ANTLRCommonToken *token = [ANTLRCommonToken newANTLRCommonToken:stream Type:555 Channel:ANTLRTokenChannelDefault Start:4 Stop:5];
    aDescription = [token description];
	STAssertTrue([aDescription isEqualToString:@"[@0, 4:5='||',<555>,0:0]"], @"String description for token is not correct! got %@", aDescription);
}

@end
