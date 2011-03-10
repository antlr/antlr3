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

#import "ANTLRRecognitionException.h"
#import "ANTLRTokenStream.h"
#import "ANTLRTreeNodeStream.h"

@implementation ANTLRRecognitionException

@synthesize input;
@synthesize token;
@synthesize node;
@synthesize line;
@synthesize charPositionInLine;

+ (ANTLRRecognitionException *) newANTLRRecognitionException
{
	return [[ANTLRRecognitionException alloc] init];
}

+ (ANTLRRecognitionException *) exceptionWithStream:(id<ANTLRIntStream>) anInputStream
{
	return [[ANTLRRecognitionException alloc] initWithStream:anInputStream];
}

+ (ANTLRRecognitionException *) exceptionWithStream:(id<ANTLRIntStream>) anInputStream reason:(NSString *)aReason
{
	return [[ANTLRRecognitionException alloc] initWithStream:anInputStream reason:aReason];
}

- (id) init
{
	if ((self = [super initWithName:@"Recognition Exception" reason:@"Recognition Exception" userInfo:nil]) != nil) {
	}
	return self;
}

- (id) initWithStream:(id<ANTLRIntStream>)anInputStream reason:(NSString *)aReason
{
	if ((self = [super initWithName:NSStringFromClass([self class]) reason:aReason userInfo:nil]) != nil) {
		[self setStream:anInputStream];
		index = [anInputStream getIndex];
		
		Class inputClass = [input class];
		if ([inputClass conformsToProtocol:@protocol(ANTLRTokenStream)]) {
			[self setToken:[(id<ANTLRTokenStream>)input LT:1]];
			line = [token getLine];
			charPositionInLine = [token getCharPositionInLine];
		} else if ([inputClass conformsToProtocol:@protocol(ANTLRCharStream)]) {
			c = (unichar)[input LA:1];
			line = [(id<ANTLRCharStream>)input getLine];
			charPositionInLine = [(id<ANTLRCharStream>)input getCharPositionInLine];
		} else if ([inputClass conformsToProtocol:@protocol(ANTLRTreeNodeStream)]) {
			[self setNode:[(id<ANTLRTreeNodeStream>)input LT:1]];
			line = [node getLine];
			charPositionInLine = [node getCharPositionInLine];
		} else {
			c = (unichar)[input LA:1];
		}
	}
	return self;
}

- (id) initWithStream:(id<ANTLRIntStream>)anInputStream
{
	if ((self = [super initWithName:NSStringFromClass([self class]) reason:@"Runtime Exception" userInfo:nil]) != nil) {
	}
	return self;
}

- (void) dealloc
{
	[self setStream:nil];
	[self setToken:nil];
	[self setNode:nil];
	[super dealloc];
}

- (NSInteger) unexpectedType
{
	if (token) {
		return [token getType];
    } else if (node) {
        return [node getType];
	} else {
		return c;
	}
}

- (id<ANTLRToken>)getUnexpectedToken
{
    return token;
}

- (NSString *) description
{
	NSMutableString *desc = [[NSMutableString alloc] initWithString:NSStringFromClass([self class])];
	if (token) {
		[desc appendFormat:@" token:%@", token];
	} else if (node) {
		[desc appendFormat:@" node:%@", node];
	} else {
		[desc appendFormat:@" char:%c", c];
	}
	[desc appendFormat:@" line:%d position:%d", line, charPositionInLine];
	return desc;
}

//---------------------------------------------------------- 
//  input 
//---------------------------------------------------------- 
- (id<ANTLRIntStream>) getStream
{
    return input; 
}

- (void) setStream: (id<ANTLRIntStream>) aStream
{
    if (input != aStream) {
        [aStream retain];
        [input release];
        input = aStream;
    }
}

//---------------------------------------------------------- 
//  token 
//---------------------------------------------------------- 
- (id<ANTLRToken>) getToken
{
    return token; 
}

- (void) setToken: (id<ANTLRToken>) aToken
{
    if (token != aToken) {
        [aToken retain];
        [token release];
        token = aToken;
    }
}

//---------------------------------------------------------- 
//  node 
//---------------------------------------------------------- 
- (id<ANTLRTree>) getNode
{
    return node; 
}

- (void) setNode: (id<ANTLRTree>) aNode
{
    if (node != aNode) {
        [aNode retain];
        [node release];
        node = aNode;
    }
}

- (NSString *)getMessage
{
    return @"Fix getMessage in ANTLRRecognitionException";
}

- (NSInteger)getCharPositionInLine
{
    return charPositionInLine;
}

- (void)setCharPositionInLine:(NSInteger)aPos
{
    charPositionInLine = aPos;
}

@end
