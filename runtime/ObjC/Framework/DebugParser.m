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

#import "DebugParser.h"


@implementation DebugParser

- (id) initWithTokenStream:(id<TokenStream>)theStream
{
	return [self initWithTokenStream:theStream debugListener:nil debuggerPort:-1];
}

- (id) initWithTokenStream:(id<TokenStream>)theStream
			  debuggerPort:(NSInteger)portNumber
{
	return [self initWithTokenStream:theStream debugListener:nil debuggerPort:portNumber];
}

- (id) initWithTokenStream:(id<TokenStream>)theStream
			 debugListener:(id<DebugEventListener>)theDebugListener
			  debuggerPort:(NSInteger)portNumber
{
	id<DebugEventListener,NSObject> debugger = nil;
	id<TokenStream> tokenStream = nil;
	if (theDebugListener) {
		debugger = [(id<DebugEventListener,NSObject>)theDebugListener retain];
		debugger = theDebugListener;
	} else {
		debugger = [[DebugEventSocketProxy alloc] initWithGrammarName:[self grammarFileName] debuggerPort:portNumber];
	}
	if (theStream && ![theStream isKindOfClass:[DebugTokenStream class]]) {
		tokenStream = [[DebugTokenStream alloc] initWithTokenStream:theStream debugListener:debugger];
	} else {
		tokenStream = [theStream retain];
		tokenStream = theStream;
	}
	self = [super initWithTokenStream:tokenStream];
	if (self) {
		[self setDebugListener:debugger];
		[debugger release];
		[tokenStream release];
		[debugListener waitForDebuggerConnection];
	}
	return self;
}

- (void) dealloc
{
    [self setDebugListener: nil];
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

#pragma mark -
#pragma mark Overrides

- (void) beginResync
{
	[debugListener beginResync];
}

- (void) endResync
{
	[debugListener endResync];
}
- (void)beginBacktracking:(NSInteger)level
{
	[debugListener beginBacktrack:level];
}

- (void)endBacktracking:(NSInteger)level wasSuccessful:(BOOL)successful
{
	[debugListener endBacktrack:level wasSuccessful:successful];
}

@end
