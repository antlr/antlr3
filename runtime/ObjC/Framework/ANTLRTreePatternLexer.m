//
//  ANTLRTreePatternLexer.m
//  ANTLR
//
//  Created by Alan Condit on 6/18/10.
// [The "BSD licence"]
// Copyright (c) 2010 Alan Condit
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

#import "ANTLRTreePatternLexer.h"

@implementation ANTLRTreePatternLexer

@synthesize pattern;
@synthesize p;
@synthesize c;
@synthesize n;
@synthesize sval;
@synthesize data;
@synthesize error;

+ (ANTLRTreePatternLexer *)newANTLRTreePatternLexer:(NSString *)aPattern
{
    return [[ANTLRTreePatternLexer alloc] initWithPattern:aPattern];
}

- (id) init
{
    if ((self = [super init]) != nil ) {
        p = -1;
        n = 0;
        error = NO;
        sval = [[NSMutableData dataWithLength:1000] retain];
        data = [sval mutableBytes];
        pattern = @"";
        n = [pattern length];
        if ( pattern ) [pattern retain];
        [self consume];
    }
    return self;
}

- (id) initWithPattern:(NSString *)aPattern
{
    if ((self = [super init]) != nil ) {
        p = -1;
        n = 0;
        error = NO;
        sval = [[NSMutableData dataWithLength:1000] retain];
        data = [sval mutableBytes];
        pattern = [aPattern retain];
        n = [pattern length];
        [self consume];
    }
    return self;
}

- (void) dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in ANTLRTreePatternLexer" );
#endif
	if ( pattern ) [pattern release];
	if ( sval ) [sval release];
	[super dealloc];
}

- (NSInteger) nextToken
{
    n = 0; // reset, but reuse buffer
    while ( c != ANTLRLexerTokenTypeEOF ) {
        if ( c==' ' || c=='\n' || c=='\r' || c=='\t' ) {
            [self consume];
            continue;
        }
        if ( (c>='a' && c<='z') || (c>='A' && c<='Z') || c=='_' ) {
            data[n++] = (char)c;
            [self consume];
            while ( (c>='a' && c<='z') || (c>='A' && c<='Z') ||
                   (c>='0' && c<='9') || c=='_' )
            {
                data[n++] = (char)c;
                [self consume];
            }
            return ANTLRLexerTokenTypeID;
        }
        if ( c == '(' ) {
            [self consume];
            return ANTLRLexerTokenTypeBEGIN;
        }
        if ( c==')' ) {
            [self consume];
            return ANTLRLexerTokenTypeEND;
        }
        if ( c=='%' ) {
            [self consume];
            return ANTLRLexerTokenTypePERCENT;
        }
        if ( c==':' ) {
            [self consume];
            return ANTLRLexerTokenTypeCOLON;
        }
        if ( c=='.' ) {
            [self consume];
            return ANTLRLexerTokenTypeDOT;
        }
        if ( c=='[' ) { // grab [x] as a string, returning x
            [self consume];
            while ( c!=']' ) {
                if ( c=='\\' ) {
                    [self consume];
                    if ( c!=']' ) {
                        data[n++] = (char)'\\';
                    }
                    data[n++] = (char)c;
                }
                else {
                    data[n++] = (char)c;
                }
                [self consume];
            }
            [self consume];
            return ANTLRLexerTokenTypeARG;
        }
        [self consume];
        error = true;
        return ANTLRLexerTokenTypeEOF;
    }
    return ANTLRLexerTokenTypeEOF;
}

- (void) consume
{
    p++;
    if ( p >= n ) {
        c = ANTLRLexerTokenTypeEOF;
    }
    else {
        c = [pattern characterAtIndex:p];
    }
}

- (NSString *)toString
{
    char buf[100];

    NSInteger idx = 0;
    for( NSInteger i = p; i < n; i++ ){
        buf[idx++] = data[i];
    }
    buf[idx] = '\0';
    return [NSString stringWithFormat:@"%s", buf];
}

- (NSMutableData *)getSval
{
    return sval;
}

- (void)setSval:(NSMutableData *)aSval
{
    if ( sval != aSval ) {
        if ( sval ) [sval release];
        [aSval retain];
    }
    sval = aSval;
}

@end
