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
#import "TokenStream.h"
#import "TokenSource.h"
#import "ANTLRBitSet.h"
#import "CommonToken.h"
#import "AMutableArray.h"

@interface BufferedTokenStream : NSObject <TokenStream> 
{
__strong id<TokenSource> tokenSource;
    
    /** Record every single token pulled from the source so we can reproduce
     *  chunks of it later.  The buffer in LookaheadStream overlaps sometimes
     *  as its moving window moves through the input.  This list captures
     *  everything so we can access complete input text.
     */
__strong AMutableArray *tokens;
    
    /** Track the last mark() call result value for use in rewind(). */
NSInteger lastMarker;
    
    /** The index into the tokens list of the current token (next token
     *  to consume).  tokens[index] should be LT(1).  index=-1 indicates need
     *  to initialize with first token.  The ctor doesn't get a token.
     *  First call to LT(1) or whatever gets the first token and sets index=0;
     */
NSInteger index;
    
NSInteger range; // how deep have we gone?
    
}
@property (retain, getter=getTokenSource,setter=setTokenSource:) id<TokenSource> tokenSource;
@property (retain, getter=getTokens,setter=setTokens:) AMutableArray *tokens;
@property (assign, getter=getLastMarker,setter=setLastMarker:) NSInteger lastMarker;
@property (assign) NSInteger index;
@property (assign, getter=getRange,setter=setRange:) NSInteger range;

+ (BufferedTokenStream *) newBufferedTokenStream;
+ (BufferedTokenStream *) newBufferedTokenStreamWith:(id<TokenSource>)aSource;
- (id) initWithTokenSource:(id<TokenSource>)aSource;
- (void)dealloc;
- (id) copyWithZone:(NSZone *)aZone;
- (NSUInteger)charPositionInLine;
- (NSUInteger)line;
- (NSInteger) getRange;
- (void) setRange:(NSInteger)anInt;
- (NSInteger) mark;
- (void) release:(NSInteger) marker;
- (void) rewind:(NSInteger) marker;
- (void) rewind;
- (void) reset;
- (void) seek:(NSInteger) anIndex;
- (NSInteger) size;
- (void) consume;
- (void) sync:(NSInteger) i;
- (void) fetch:(NSInteger) n;
- (id<Token>) getToken:(NSInteger) i;
- (AMutableArray *)getFrom:(NSInteger)startIndex To:(NSInteger) stopIndex;
- (NSInteger) LA:(NSInteger)i;
- (id<Token>) LB:(NSInteger) k;
- (id<Token>) LT:(NSInteger) k;
- (void) setup;
- (id<TokenSource>) getTokenSource;
- (void) setTokenSource:(id<TokenSource>) aTokenSource;
- (AMutableArray *)getTokens;
- (NSString *) getSourceName;
- (AMutableArray *)getTokensFrom:(NSInteger)startIndex To:(NSInteger)stopIndex;
- (AMutableArray *)getTokensFrom:(NSInteger)startIndex To:(NSInteger)stopIndex With:(ANTLRBitSet *)types;
- (AMutableArray *)getTokensFrom:(NSInteger)startIndex To:(NSInteger)stopIndex WithList:(AMutableArray *)types;
- (AMutableArray *)getTokensFrom:(NSInteger)startIndex To:(NSInteger)stopIndex WithType:(NSInteger)ttype;
- (NSString *) toString;
- (NSString *) toStringFromStart:(NSInteger)startIndex ToEnd:(NSInteger)stopIndex;
- (NSString *) toStringFromToken:(id<Token>)startIndex ToToken:(id<Token>)stopIndex;
- (void) fill;

@end
