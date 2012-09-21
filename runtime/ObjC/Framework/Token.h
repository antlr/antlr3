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


#import <Foundation/Foundation.h>

#ifndef DEBUG_DEALLOC
#define DEBUG_DEALLOC
#endif

typedef enum {
    TokenTypeEOF = -1,
    TokenTypeInvalid,
    TokenTypeEOR,
    TokenTypeDOWN,
    TokenTypeUP,
    TokenTypeMIN
} TokenType;

typedef enum {
    TokenChannelDefault = 0,
    TokenChannelHidden = 99
} TokenChannel;

#define HIDDEN 99

@protocol Token < NSObject, NSCopying >

@property (retain, getter = text, setter = setText:) NSString *text;
@property (assign) NSInteger type;
@property (assign) NSUInteger line;
@property (assign) NSUInteger charPositionInLine;

// The singleton eofToken instance.
+ (id<Token>) eofToken;
// The default channel for this class of Tokens
+ (TokenChannel) defaultChannel;

// provide hooks to explicitely set the text as opposed to use the indices into the CharStream
- (NSString *) text;
- (void) setText:(NSString *)theText;

- (NSInteger)type;
- (void) setType: (NSInteger) aType;

// ANTLR v3 provides automatic line and position tracking. Subclasses do not need to
// override these, if they do not want to store line/pos tracking information
- (NSUInteger)line;
- (void) setLine: (NSUInteger) aLine;

- (NSUInteger)charPositionInLine;
- (void) setCharPositionInLine:(NSUInteger)aCharPositionInLine;

// explicitely change the channel this Token is on. The default parser implementation
// just sees the defaultChannel
// Common idiom is to put whitespace tokens on channel 99.
- (NSUInteger)channel;
- (void) setChannel: (NSUInteger) aChannel;

// the index of this Token into the TokenStream
- (NSInteger) getTokenIndex;
- (void) setTokenIndex: (NSInteger) aTokenIndex;
- (NSString *)toString;

@end

