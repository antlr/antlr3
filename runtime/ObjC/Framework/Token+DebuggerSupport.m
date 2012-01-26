//
//  ANTLRToken+DebuggerSupport.m
//  ANTLR
//
//  Created by Kay Röpke on 03.12.2006.
// [The "BSD licence"]
// Copyright (c) 2006-2007 Kay Roepke
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products
//    derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "ANTLRToken+DebuggerSupport.h"


@implementation ANTLRCommonToken(DebuggerSupport)

- (NSString *)debuggerDescription
{
	NSString *_text = self.text;
	NSMutableString *escapedText;
	if (_text) {
		escapedText = [_text copyWithZone:nil];
		NSRange wholeString = NSMakeRange(0,[escapedText length]);
		[escapedText replaceOccurrencesOfString:@"%" withString:@"%25" options:0 range:wholeString];
		[escapedText replaceOccurrencesOfString:@"\n" withString:@"%0A" options:0 range:wholeString];
		[escapedText replaceOccurrencesOfString:@"\r" withString:@"%0D" options:0 range:wholeString];
	} else {
		escapedText = [NSMutableString stringWithString:@""];
	}
	// format is tokenIndex, type, channel, line, col, (escaped)text
	return [NSString stringWithFormat:@"%u %d %u %u %u \"%@", 
		[self getTokenIndex],
		self.type,
		self.channel,
		self.line,
		self.charPositionInLine,
		escapedText
		];
}

@end
