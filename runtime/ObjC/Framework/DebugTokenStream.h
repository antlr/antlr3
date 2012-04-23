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

#import <Foundation/Foundation.h>
#import "Parser.h"
#import "TokenStream.h"
#import "TokenSource.h"
#import "DebugTokenStream.h"
#import "DebugEventListener.h"

@interface DebugTokenStream : NSObject <TokenStream>
{
	id<DebugEventListener> debugListener;
	id<TokenStream> input;
	BOOL initialStreamState;
    NSInteger lastMarker;
}

- (id) initWithTokenStream:(id<TokenStream>)theStream debugListener:(id<DebugEventListener>)debugger;

- (id<DebugEventListener>) debugListener;
- (void) setDebugListener: (id<DebugEventListener>) aDebugListener;

- (id<TokenStream>) input;
- (void) setInput:(id<TokenStream>)aTokenStream;

- (void) consume;
- (id<Token>) getToken:(NSInteger)index;
- (NSInteger) getIndex;
- (void) release:(NSInteger)marker;
- (void) seek:(NSInteger)index;
- (NSInteger) size;
- (id<TokenSource>) getTokenSource;
- (NSString *) getSourceName;
- (NSString *) toString;
- (NSString *) toStringFromStart:(NSInteger)aStart ToEnd:(NSInteger)aStop;
- (NSString *) toStringFromToken:(CommonToken *)startToken ToToken:(CommonToken *)stopToken;

@end
