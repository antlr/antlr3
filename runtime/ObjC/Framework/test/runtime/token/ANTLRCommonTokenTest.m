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

-(void) test01InitAndRelease
{
	ANTLRCommonToken *token = [[ANTLRCommonToken newToken] retain];
	STAssertNotNil(token, @"Token was nil");
	[token release];
}

-(void) test02GetEOFToken
{
	ANTLRCommonToken *token = [[ANTLRCommonToken eofToken] retain];
	STAssertNotNil(token, @"Token was nil");
	STAssertEquals(token.type, (NSInteger)ANTLRTokenTypeEOF, @"Token was not of type ANTLRTokenTypeEOF");
	[token release];
}

-(void) test03InitWithTokenType
{
	ANTLRCommonToken *token = [[ANTLRCommonToken newToken:ANTLRTokenTypeUP] retain];
	token.text = @"<UP>";
	STAssertNotNil(token, @"Token was nil");
	STAssertEquals(token.type, (NSInteger)ANTLRTokenTypeUP, @"Token was not of type ANTLRTokenTypeUP");
	STAssertNotNil(token.text, @"Token text was nil, was expecting <UP>");
	STAssertTrue([token.text isEqualToString:@"<UP>"], @"Token text was not <UP> was instead: %@", token.text);
	[token release];
}

-(void) test04InitWithTokenTypeAndText
{
	ANTLRCommonToken *token = [[ANTLRCommonToken newToken:ANTLRTokenTypeUP Text:@"<UP>"] retain];
	STAssertNotNil(token, @"Token was nil");
	STAssertEquals(token.type, (NSInteger)ANTLRTokenTypeUP, @"Token was not of type ANTLRTokenTypeUP");
	STAssertNotNil(token.text, @"Token text was nil, was expecting <UP>");
	STAssertTrue([token.text isEqualToString:@"<UP>"], @"Token text was not <UP> was instead: %@", token.text);
	[token release];
}

-(void) test05InitWithCharStream
{
	ANTLRStringStream *stream = [[ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"] retain];
	ANTLRCommonToken *token = [[ANTLRCommonToken newToken:stream Type:555 Channel:ANTLRTokenChannelDefault Start:4 Stop:5] retain];
	STAssertNotNil(token, @"Token was nil");
	STAssertEquals(token.type, (NSInteger)555, @"Token was not of type 555"); // Nice random type number
	STAssertNotNil(token.text, @"Token text was nil, was expecting ||");
	STAssertTrue([token.text isEqualToString:@"||"], @"Token text was not || was instead: %@", token.text);
	[token release];
    [stream release];
}

-(void) test06InitWithToken
{
	ANTLRStringStream *stream = [[ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"] retain];
	ANTLRCommonToken *token = [[ANTLRCommonToken newToken:stream Type:555 Channel:ANTLRTokenChannelDefault Start:4 Stop:5] retain];
	STAssertNotNil(token, @"Token was nil");
	STAssertEquals(token.type, (NSInteger)555, @"Token was not of type 555"); // Nice random type number
	STAssertNotNil(token.text, @"Token text was nil, was expecting ||");
	STAssertTrue([token.text isEqualToString:@"||"], @"Token text was not || was instead: %@", token.text);
	
	ANTLRCommonToken *newToken = [[ANTLRCommonToken newTokenWithToken:token] retain];
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
	[newToken release];
    [stream release];
}

-(void) test07TokenDescription
{
    NSString *aDescription;
	ANTLRStringStream *stream = [[ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"] retain];
	ANTLRCommonToken *token = [[ANTLRCommonToken newToken:stream Type:555 Channel:ANTLRTokenChannelDefault Start:4 Stop:5] retain];
    aDescription = [token description];
	STAssertTrue([aDescription isEqualToString:@"[@0, 4:5='||',<555>,0:0]"], @"String description for token is not correct! got %@", aDescription);
    [token release];
    [stream release];
}

@end
