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

#import "DebugTokenStream.h"


@implementation DebugTokenStream


- (id) initWithTokenStream:(id<TokenStream>)theStream debugListener:(id<DebugEventListener>)debugger
{
	self = [super init];
	if (self) {
		[self setDebugListener:debugger];
		[self setInput:theStream];
		[self.input LT:1];	// force reading first on-channel token
		initialStreamState = YES;
	}
	return self;
}

- (void) dealloc
{
    [self setDebugListener:nil];
    self.input = nil;
    [super dealloc];
}


- (id<DebugEventListener>) debugListener
{
    return debugListener; 
}

- (void) setDebugListener: (id<DebugEventListener>) aDebugListener
{
    if (debugListener != aDebugListener) {
        [(id<DebugEventListener,NSObject>)aDebugListener retain];
        [(id<DebugEventListener,NSObject>)debugListener release];
        debugListener = aDebugListener;
    }
}

- (id<TokenStream>) input
{
    return input; 
}

- (void) setInput: (id<TokenStream>) aTokenStream
{
    if (input != aTokenStream) {
        if ( input ) [input release];
        input = aTokenStream;
        [input retain];
    }
}

- (void) consumeInitialHiddenTokens
{
	int firstIdx = input.index;
	for (int i = 0; i<firstIdx; i++)
		[debugListener consumeHiddenToken:[input getToken:i]];
	initialStreamState = NO;
}

#pragma mark -
#pragma mark Proxy implementation

// anything else that hasn't some debugger event assicioated with it, is simply
// forwarded to the actual token stream
- (void) forwardInvocation:(NSInvocation *)anInvocation
{
	[anInvocation invokeWithTarget:self.input];
}

- (void) consume
{
	if ( initialStreamState )
		[self consumeInitialHiddenTokens];
	int a = input.index;
	id<Token> token = [input LT:1];
	[input consume];
	int b = input.index;
	[debugListener consumeToken:token];
	if (b > a+1) // must have consumed hidden tokens
		for (int i = a+1; i < b; i++)
			[debugListener consumeHiddenToken:[input getToken:i]];
}

- (NSInteger) mark
{
	lastMarker = [input mark];
	[debugListener mark:lastMarker];
	return lastMarker;
}

- (void) rewind
{
	[debugListener rewind];
	[input rewind];
}

- (void) rewind:(NSInteger)marker
{
	[debugListener rewind:marker];
	[input rewind:marker];
}

- (id<Token>) LT:(NSInteger)k
{
	if ( initialStreamState )
		[self consumeInitialHiddenTokens];
	[debugListener LT:k foundToken:[input LT:k]];
	return [input LT:k];
}

- (NSInteger) LA:(NSInteger)k
{
	if ( initialStreamState )
		[self consumeInitialHiddenTokens];
	[debugListener LT:k foundToken:[input LT:k]];
	return [input LA:k];
}

- (id<Token>) getToken:(NSInteger)i
{
    return [input getToken:i];
}

- (NSInteger) getIndex
{
    return input.index;
}

- (void) release:(NSInteger) marker
{
}

- (void) seek:(NSInteger)index
{
    // TODO: implement seek in dbg interface
    // db.seek(index);
    [input seek:index];
}

- (NSInteger) size
{
    return [input size];
}

- (id<TokenSource>) getTokenSource
{
    return [input getTokenSource];
}

- (NSString *) getSourceName
{
    return [[input getTokenSource] getSourceName];
}

- (NSString *) description
{
    return [input toString];
}

- (NSString *) toString
{
    return [input toString];
}

- (NSString *) toStringFromStart:(NSInteger)startIndex ToEnd:(NSInteger)stopIndex
{
    return [input toStringFromStart:startIndex ToEnd:stopIndex];
}

- (NSString *) toStringFromToken:(CommonToken *)startToken ToToken:(CommonToken *)stopToken
{
    return [input toStringFromStart:startToken.startIndex ToEnd:stopToken.stopIndex];
}

@end
