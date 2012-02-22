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


#import "CommonToken.h"

static CommonToken *SKIP_TOKEN;
static CommonToken *EOF_TOKEN;
static CommonToken *INVALID_TOKEN;

@implementation CommonToken

    static NSInteger DEFAULT_CHANNEL = TokenChannelDefault;
    static NSInteger INVALID_TOKEN_TYPE = TokenTypeInvalid;


@synthesize text;
@synthesize type;
@synthesize line;
@synthesize charPositionInLine;
@synthesize channel;
@synthesize index;
@synthesize startIndex;
@synthesize stopIndex;
@synthesize input;

+ (void) initialize
{
    EOF_TOKEN = [CommonToken newToken:TokenTypeEOF Text:@"EOF"];
    SKIP_TOKEN = [CommonToken newToken:TokenTypeInvalid Text:@"Skip"];
    INVALID_TOKEN = [CommonToken newToken:TokenTypeInvalid Text:@"Invalid"];
    [EOF_TOKEN retain];
    [SKIP_TOKEN retain];
    [INVALID_TOKEN retain];
}

+ (CommonToken *)INVALID_TOKEN
{
    return INVALID_TOKEN;
}

+ (NSInteger) DEFAULT_CHANNEL
{
    return DEFAULT_CHANNEL;
}

+ (NSInteger) INVALID_TOKEN_TYPE
{
    return INVALID_TOKEN_TYPE;
}

+ (CommonToken *) newToken
{
    return [[CommonToken alloc] init];
}

+ (CommonToken *) newToken:(id<CharStream>)anInput Type:(NSInteger)aTType Channel:(NSInteger)aChannel Start:(NSInteger)aStart Stop:(NSInteger)aStop
{
    return [[CommonToken alloc] initWithInput:(id<CharStream>)anInput Type:(NSInteger)aTType Channel:(NSInteger)aChannel Start:(NSInteger)aStart Stop:(NSInteger)aStop];
}

+ (CommonToken *) newToken:(TokenType)tokenType
{
    return( [[CommonToken alloc] initWithType:tokenType] );
}

+ (CommonToken *) newToken:(NSInteger)tokenType Text:(NSString *)tokenText
{
    return( [[CommonToken alloc] initWithType:tokenType Text:tokenText] );
}

+ (CommonToken *) newTokenWithToken:(CommonToken *)fromToken
{
    return( [[CommonToken alloc] initWithToken:fromToken] );
}

// return the singleton EOF Token 
+ (id<Token>) eofToken
{
    if (EOF_TOKEN == nil) {
        EOF_TOKEN = [[CommonToken newToken:TokenTypeEOF Text:@"EOF"] retain];
    }
    return EOF_TOKEN;
}

// return the singleton skip Token 
+ (id<Token>) skipToken
{
    if (SKIP_TOKEN == nil) {
        SKIP_TOKEN = [[CommonToken newToken:TokenTypeInvalid Text:@"Skip"] retain];
    }
    return SKIP_TOKEN;
}

// return the singleton skip Token 
+ (id<Token>) invalidToken
{
    if (INVALID_TOKEN == nil) {
        INVALID_TOKEN = [[CommonToken newToken:TokenTypeInvalid Text:@"Invalid"] retain];
    }
    return SKIP_TOKEN;
}

// the default channel for this class of Tokens
+ (TokenChannel) defaultChannel
{
    return TokenChannelDefault;
}

- (id) init
{
    if ((self = [super init]) != nil) {
        input = nil;
        type = TokenTypeInvalid;
        channel = TokenChannelDefault;
        startIndex = 0;
        stopIndex = 0;
    }
    return self;
}

// designated initializer
- (id) initWithInput:(id<CharStream>)anInput
                Type:(NSInteger)aTType
             Channel:(NSInteger)aChannel
               Start:(NSInteger)aStart
                Stop:(NSInteger)aStop
{
    if ((self = [super init]) != nil) {
        input = anInput;
        if ( input ) [input retain];
        type = aTType;
        channel = aChannel;
        startIndex = aStart;
        stopIndex = aStop;
        if (type == TokenTypeEOF)
            text = @"EOF";
        else
            text = [input substringWithRange:NSMakeRange(startIndex, (stopIndex-startIndex)+1)];
        if ( text ) [text retain];
    }
    return self;
}

- (id) initWithToken:(CommonToken *)oldToken
{
    if ((self = [super init]) != nil) {
        text = [NSString stringWithString:oldToken.text];
        if ( text ) [text retain];
        type = oldToken.type;
        line = oldToken.line;
        index = oldToken.index;
        charPositionInLine = oldToken.charPositionInLine;
        channel = oldToken.channel;
        input = oldToken.input;
        if ( input ) [input retain];
        if ( [oldToken isKindOfClass:[CommonToken class]] ) {
            startIndex = oldToken.startIndex;
            stopIndex = oldToken.stopIndex;
        }
    }
    return self;
}

- (id) initWithType:(TokenType)aTType
{
    if ((self = [super init]) != nil) {
        self.type = aTType;
    }
    return self;
}

- (id) initWithType:(TokenType)aTType Text:(NSString *)tokenText
{
    if ((self = [super init]) != nil) {
        self.type = aTType;
        self.text = [NSString stringWithString:tokenText];
        if ( text ) [text retain];
    }
    return self;
}

- (void)dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in CommonToken" );
#endif
    if ( input ) [input release];
    if ( text ) [text release];
    [super dealloc];
}

// create a copy, including the text if available
// the input stream is *not* copied!
- (id) copyWithZone:(NSZone *)theZone
{
    CommonToken *copy = [[[self class] allocWithZone:theZone] init];
    
    if (text)
        copy.text = [text copyWithZone:nil];
    copy.type = type;
    copy.line = line;
    copy.charPositionInLine = charPositionInLine;
    copy.channel = channel;
    copy.index = index;
    copy.startIndex = startIndex;
    copy.stopIndex = stopIndex;
    copy.input = input;
    return copy;
}


//---------------------------------------------------------- 
//  charPositionInLine 
//---------------------------------------------------------- 
- (NSUInteger) getCharPositionInLine
{
    return charPositionInLine;
}

- (void) setCharPositionInLine:(NSUInteger)aCharPositionInLine
{
    charPositionInLine = aCharPositionInLine;
}

//---------------------------------------------------------- 
//  line 
//---------------------------------------------------------- 
- (NSUInteger) getLine
{
    return line;
}

- (void) setLine:(NSUInteger)aLine
{
    line = aLine;
}

//---------------------------------------------------------- 
//  text 
//---------------------------------------------------------- 
- (NSString *) text
{
    if (text != nil) {
        return text;
    }
    if (input == nil) {
        return nil;
    }
    int n = [input size];
    if ( startIndex < n && stopIndex < n) {
        return [input substringWithRange:NSMakeRange(startIndex, (stopIndex-startIndex)+1)];
    }
    else {
        return @"<EOF>";
    }
}

- (void) setText:(NSString *)aText
{
    if (text != aText) {
        if ( text ) [text release];
        text = aText;
        [text retain];
    }
}


//---------------------------------------------------------- 
//  type 
//---------------------------------------------------------- 
- (NSInteger)type
{
    return type;
}

- (void) setType:(NSInteger)aType
{
    type = aType;
}

//---------------------------------------------------------- 
//  channel 
//---------------------------------------------------------- 
- (NSUInteger)channel
{
    return channel;
}

- (void) setChannel:(NSUInteger)aChannel
{
    channel = aChannel;
}


//---------------------------------------------------------- 
//  input 
//---------------------------------------------------------- 
- (id<CharStream>) input
{
    return input; 
}

- (void) setInput: (id<CharStream>) anInput
{
    if (input != anInput) {
        if ( input ) [input release];
        [anInput retain];
    }
    input = anInput;
}


//---------------------------------------------------------- 
//  start 
//---------------------------------------------------------- 
- (NSInteger) getStart
{
    return startIndex;
}

- (void) setStart: (NSInteger) aStart
{
    startIndex = aStart;
}

//---------------------------------------------------------- 
//  stop 
//---------------------------------------------------------- 
- (NSInteger) getStop
{
    return stopIndex;
}

- (void) setStop: (NSInteger) aStop
{
    stopIndex = aStop;
}

//---------------------------------------------------------- 
//  index 
//---------------------------------------------------------- 
- (NSInteger) getTokenIndex;
{
    return index;
}

- (void) setTokenIndex: (NSInteger) aTokenIndex;
{
    index = aTokenIndex;
}


// provide a textual representation for debugging
- (NSString *) description
{
    NSString *channelStr;
    NSMutableString *txtString;

    channelStr = @"";
    if ( channel > 0 ) {
        channelStr = [NSString stringWithFormat:@",channel=%d\n", channel];
    }
    if ([self text] != nil) {
        txtString = [NSMutableString stringWithString:[self text]];
        [txtString replaceOccurrencesOfString:@"\n" withString:@"\\\\n" options:NSAnchoredSearch range:NSMakeRange(0, [txtString length])];
        [txtString replaceOccurrencesOfString:@"\r" withString:@"\\\\r" options:NSAnchoredSearch range:NSMakeRange(0, [txtString length])];
        [txtString replaceOccurrencesOfString:@"\t" withString:@"\\\\t" options:NSAnchoredSearch range:NSMakeRange(0, [txtString length])];
    } else {
        txtString = [NSMutableString stringWithString:@"<no text>"];
    }
    return [NSString stringWithFormat:@"[@%d, %d:%d='%@',<%d>%@,%d:%d]", index, startIndex, stopIndex, txtString, type, channelStr, line, charPositionInLine];
}

- (NSString *)toString
{
   return [self description];
}

@end
