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

#import "Parser.h"


@implementation Parser

+ (Parser *)newParser:(id<TokenStream>)anInput
{
    return [[Parser alloc] initWithTokenStream:anInput];
}

+ (Parser *)newParser:(id<TokenStream>)anInput State:(RecognizerSharedState *)aState
{
    return [[Parser alloc] initWithTokenStream:anInput State:aState];
}

- (id) initWithTokenStream:(id<TokenStream>)theStream
{
    if ((self = [super init]) != nil) {
        [self setInput:theStream];
    }
    return self;
}

- (id) initWithTokenStream:(id<TokenStream>)theStream State:(RecognizerSharedState *)aState
{
    if ((self = [super initWithState:aState]) != nil) {
        [self setInput:theStream];
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
    NSLog( @"called dealloc in Parser" );
#endif
    [input release];
	[super dealloc];
}

//---------------------------------------------------------- 
//  input 
//---------------------------------------------------------- 
- (id<TokenStream>) input
{
    return input; 
}

- (void) setInput: (id<TokenStream>) anInput
{
    if (input != anInput) {
        if ( input ) [input release];
        [anInput retain];
    }
    input = anInput;
}

- (id) getCurrentInputSymbol:(id<TokenStream>)anInput
{
    state.token = [input LT:1];
    return state.token;
}

- (CommonToken *)getMissingSymbol:(id<TokenStream>)anInput
                             Exception:(RecognitionException *)e
                                 TType:(NSInteger)expectedTokenType
                                BitSet:(ANTLRBitSet *)follow
{
    NSString *tokenText = nil;
    if ( expectedTokenType == TokenTypeEOF )
        tokenText = @"<missing EOF>";
    else
        tokenText = [NSString stringWithFormat:@"<missing %@>\n",[[BaseRecognizer getTokenNames] objectAtIndex:expectedTokenType]];
    CommonToken *t = [[CommonToken newToken:expectedTokenType Text:tokenText] retain];
    CommonToken *current = [anInput LT:1];
    if ( current.type == TokenTypeEOF ) {
        current = [anInput LT:-1];
    }
    t.line = current.line;
    t.charPositionInLine = current.charPositionInLine;
    t.channel = TokenChannelDefault;
    t.input = current.input;
    return t;
}

/** Set the token stream and reset the parser */
- (void) setTokenStream:(id<TokenStream>)anInput
{
    input = nil;
    [self reset];
    input = anInput;
}

- (id<TokenStream>)getTokenStream
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
