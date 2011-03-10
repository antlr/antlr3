//
//  ANTLRCommonErrorNode.m
//  ANTLR
//
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

#import "ANTLRCommonErrorNode.h"
#import "ANTLRMissingTokenException.h"
#import "ANTLRNoViableAltException.h"
#import "ANTLRTreeNodeStream.h"
#import "ANTLRUnwantedTokenException.h"

@implementation ANTLRCommonErrorNode

+ (id) newANTLRCommonErrorNode:(id<ANTLRTokenStream>)anInput
                          From:(id<ANTLRToken>)aStartToken
                            To:(id<ANTLRToken>)aStopToken
                     Exception:(ANTLRRecognitionException *) e
{
    return [[ANTLRCommonErrorNode alloc] initWithInput:anInput From:aStartToken To:aStopToken Exception:e];
}

- (id) init
{
    if ((self = [super init]) != nil ) {
    }
    return self;
}

- (id) initWithInput:(id<ANTLRTokenStream>)anInput
                From:(id<ANTLRToken>)aStartToken
                  To:(id<ANTLRToken>)aStopToken
           Exception:(ANTLRRecognitionException *) e
{
    if ((self = [super init]) != nil ) {
    //System.out.println("aStartToken: "+aStartToken+", aStopToken: "+aStopToken);
    if ( aStopToken == nil ||
        ([ aStopToken getTokenIndex] < [aStartToken getTokenIndex] &&
         [aStopToken getType] != ANTLRTokenTypeEOF) )
    {
            // sometimes resync does not consume a token (when LT(1) is
            // in follow set.  So, aStopToken will be 1 to left to aStartToken. adjust.
            // Also handle case where aStartToken is the first token and no token
            // is consumed during recovery; LT(-1) will return null.
            aStopToken = aStartToken;
        }
        input = anInput;
        startToken = aStartToken;
        stopToken = aStopToken;
        trappedException = e;
    }
    return self;
}

- (BOOL) isNil
{
    return NO;
}

- (NSInteger) getType
{
    return ANTLRTokenTypeInvalid;
}

- (NSString *)getText
{
    NSString *badText = nil;
    if ( [startToken isKindOfClass:[self class]] ) {
        int i = [(id<ANTLRToken>)startToken getTokenIndex];
        int j = [(id<ANTLRToken>)stopToken getTokenIndex];
        if ( [(id<ANTLRToken>)stopToken getType] == ANTLRTokenTypeEOF ) {
            j = [(id<ANTLRTokenStream>)input size];
        }
        badText = [(id<ANTLRTokenStream>)input toStringFromStart:i ToEnd:j];
    }
    else if ( [startToken isKindOfClass:[self class]] ) {
        badText = [(id<ANTLRTreeNodeStream>)input toStringFromNode:startToken ToNode:stopToken];
    }
    else {
        // people should subclass if they alter the tree type so this
        // next one is for sure correct.
        badText = @"<unknown>";
    }
    return badText;
}

- (NSString *)toString
{
    NSString *aString;
    if ( [trappedException isKindOfClass:[ANTLRMissingTokenException class]] ) {
        aString = [NSString stringWithFormat:@"<missing type: %@ >",
        [(ANTLRMissingTokenException *)trappedException getMissingType]];
        return aString;
    }
    else if ( [trappedException isKindOfClass:[ANTLRUnwantedTokenException class]] ) {
        aString = [NSString stringWithFormat:@"<extraneous: %@, resync=%@>",
        [trappedException getUnexpectedToken],
        [self getText]];
        return aString;
    }
    else if ( [trappedException isKindOfClass:[ANTLRMismatchedTokenException class]] ) {
        aString = [NSString stringWithFormat:@"<mismatched token: %@, resync=%@>", trappedException.token, [self getText]];
        return aString;
    }
    else if ( [trappedException isKindOfClass:[ANTLRNoViableAltException class]] ) {
        aString = [NSString stringWithFormat:@"<unexpected:  %@, resync=%@>", trappedException.token, [self getText]];
        return aString;
    }
    aString = [NSString stringWithFormat:@"<error: %@>",[self getText]];
    return aString;
}

@end
