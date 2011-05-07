//
//  ANTLRStringStreamTest.m
//  ANTLR
//
//  Created by Ian Michell on 12/05/2010.
//  Copyright 2010 Ian Michell. All rights reserved.
//

#import "ANTLRStringStreamTest.h"
#import "ANTLRCharStream.h"
#import "ANTLRStringStream.h"
#import "ANTLRError.h"

@implementation ANTLRStringStreamTest

-(void) testInitWithInput
{
	NSString *input = @"This is a string used for ANTLRStringStream input ;)";
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:input];
	NSString *subString = [stream substring:0 To:10];
	NSLog(@"The first ten chars are '%@'", subString);
	STAssertTrue([@"This is a " isEqualToString:subString], @"The strings do not match");
	[stream release];
}

-(void) testConsumeAndReset
{
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"This is a string used for input"];
	[stream consume];
	STAssertTrue(stream.index > 0, @"Index should be greater than 0 after consume");
	[stream reset];
	STAssertTrue(stream.index == 0, @"Index should be 0 after reset");
	[stream release];
}

-(void) testConsumeWithNewLine
{
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"This is a string\nused for input"];
	while (stream.index < [stream size] && stream.line == 1)
	{
		[stream consume];
	}
	STAssertTrue(stream.line == 2, @"Line number is incorrect, should be 2, was %d!", stream.line);
	STAssertTrue(stream.charPositionInLine == 0, @"Char position in line should be 0, it was: %d!", stream.charPositionInLine);
	[stream release];
}

-(void) testLAEOF
{
    NSInteger i;
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"This is a string\nused for input"];
	BOOL eofFound = NO;
	for (i = 1; i <= [stream size]+1; i++) {
		NSInteger r = [stream LA:i];
		if (r == (NSInteger)ANTLRCharStreamEOF) {
			eofFound = YES;
            break;
		}
	}
	STAssertTrue(eofFound, @"EOF Was not found in stream, Length =%d, index = %d, i = %d", [stream size], stream.index, i);
	[stream release];
}

-(void) testLTEOF
{
    NSInteger i;
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"This is a string\nused for input"];
	BOOL eofFound = NO;
	for ( i = 1; i <= [stream size]+1; i++) {
		NSInteger r = [stream LT:i];
		if (r == (NSInteger)ANTLRCharStreamEOF) {
			eofFound = YES;
            break;
		}
	}
	STAssertTrue(eofFound, @"EOF Was not found in stream, Length =%d, index = %d, i = %d", [stream size], stream.index, i);
	[stream release];
}

-(void) testSeek
{
	ANTLRStringStream *stream =[ANTLRStringStream newANTLRStringStream:@"This is a string used for input"];
	[stream seek:10];
	STAssertTrue(stream.index == 10, @"Index should be 10");
	// Get char 10 which is s (with 0 being T)
	STAssertTrue([stream LA:1] > -1 && (char)[stream LA:1] == 's', @"Char returned should be s");
	[stream release];
}

-(void) testSeekMarkAndRewind
{
	ANTLRStringStream *stream =[ANTLRStringStream newANTLRStringStream:@"This is a string used for input"];
	[stream mark];
	[stream seek:10];
	STAssertTrue(stream.index == 10, @"Index should be 10");
	[stream rewind];
	STAssertTrue(stream.index == 0, @"Index should be 0");
	[stream seek:5];
	STAssertTrue(stream.index == 5, @"Index should be 5");
	[stream mark]; // make a new marker to test a branch.
	[stream seek:10];
	STAssertTrue(stream.index == 10, @"Index should be 10");
	[stream rewind]; // should be marked to 5.
	STAssertTrue(stream.index == 5, @"Index should be 5");
	[stream release];
}

@end
