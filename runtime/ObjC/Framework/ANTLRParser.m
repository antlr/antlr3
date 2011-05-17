// [The "BSD licence"]
// Copyright (c) 2006-2007 Kay Roepke 2010 Alan Condit
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

#import "ANTLRParser.h"


@implementation ANTLRParser

+ (ANTLRParser *)newANTLRParser:(id<ANTLRTokenStream>)anInput
{
    return [[ANTLRParser alloc] initWithTokenStream:anInput];
}

+ (ANTLRParser *)newANTLRParser:(id<ANTLRTokenStream>)anInput State:(ANTLRRecognizerSharedState *)aState
{
    return [[ANTLRParser alloc] initWithTokenStream:anInput State:aState];
}

- (id) initWithTokenStream:(id<ANTLRTokenStream>)theStream
{
	if ((self = [super init]) != nil) {
		input = theStream;
	}
	return self;
}

- (id) initWithTokenStream:(id<ANTLRTokenStream>)theStream State:(ANTLRRecognizerSharedState *)aState
{
	if ((self = [super initWithState:aState]) != nil) {
        input = theStream;
	}
	return self;
}

- (void) reset
{
    [super reset]; // reset all recognizer state variables
    if ( input!=nil ) {
        [input seek:0]; // rewind the input
    }
}

- (void) dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in ANTLRParser" );
#endif
	[self setInput:nil];
	[super dealloc];
}

//---------------------------------------------------------- 
//  input 
//---------------------------------------------------------- 
- (id<ANTLRTokenStream>) input
{
    return input; 
}

- (void) setInput: (id<ANTLRTokenStream>) anInput
{
    if (input != anInput) {
        if ( input ) [input release];
        [anInput retain];
    }
    input = anInput;
}

- (id) getCurrentInputSymbol:(id<ANTLRTokenStream>)anInput
{
    state.token = [input LT:1];
    return state.token;
}

- (ANTLRCommonToken *)getMissingSymbol:(id<ANTLRTokenStream>)anInput
                             Exception:(ANTLRRecognitionException *)e
                                 TType:(NSInteger)expectedTokenType
                                BitSet:(ANTLRBitSet *)follow
{
    NSString *tokenText = nil;
    if ( expectedTokenType == ANTLRTokenTypeEOF )
        tokenText = @"<missing EOF>";
    else
        tokenText = [NSString stringWithFormat:@"<missing %@>\n",[[ANTLRBaseRecognizer getTokenNames] objectAtIndex:expectedTokenType]];
    ANTLRCommonToken *t = [[ANTLRCommonToken newToken:expectedTokenType Text:tokenText] retain];
    ANTLRCommonToken *current = [anInput LT:1];
    if ( current.type == ANTLRTokenTypeEOF ) {
        current = [anInput LT:-1];
    }
    t.line = current.line;
    t.charPositionInLine = current.charPositionInLine;
    t.channel = ANTLRTokenChannelDefault;
    return t;
}

/** Set the token stream and reset the parser */
- (void) setTokenStream:(id<ANTLRTokenStream>)anInput
{
    input = nil;
    [self reset];
    input = anInput;
}

- (id<ANTLRTokenStream>)getTokenStream
{
    return input;
}

- (NSString *)getSourceName
{
    return [input getSourceName];
}

- (void) traceIn:(NSString *)ruleName Index:(int)ruleIndex
{
    [super traceIn:ruleName Index:ruleIndex Object:[input LT:1]];
}

- (void) traceOut:(NSString *)ruleName Index:(NSInteger) ruleIndex
{
    [super traceOut:ruleName Index:ruleIndex Object:[input LT:1]];
}

@end
