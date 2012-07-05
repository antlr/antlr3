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
#import "BaseRecognizer.h"
#import "CommonToken.h"
#import "TokenStream.h"

@interface Parser : BaseRecognizer {
	id<TokenStream> input;
}
+ (Parser *)newParser:(id<TokenStream>)anInput;
+ (Parser *)newParser:(id<TokenStream>)anInput State:(RecognizerSharedState *)aState;

- (id) initWithTokenStream:(id<TokenStream>)theStream;
- (id) initWithTokenStream:(id<TokenStream>)theStream State:(RecognizerSharedState *)aState;

- (id<TokenStream>) input;
- (void) setInput: (id<TokenStream>) anInput;

- (void) reset;

- (id) getCurrentInputSymbol:(id<TokenStream>)anInput;
- (CommonToken *)getMissingSymbol:(id<TokenStream>)input
                             Exception:(RecognitionException *)e
                                 TType:(NSInteger)expectedTokenType
                                BitSet:(ANTLRBitSet *)follow;
- (void) setTokenStream:(id<TokenStream>)anInput;
- (id<TokenStream>)getTokenStream;
- (NSString *)getSourceName;

- (void) traceIn:(NSString *)ruleName Index:(int)ruleIndex;
- (void) traceOut:(NSString *)ruleName Index:(NSInteger) ruleIndex;

@end
