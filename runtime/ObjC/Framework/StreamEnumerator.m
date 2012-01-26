//
//  ANTLRStreamEnumertor.m
//  ANTLR
//
//  Created by Ian Michell on 29/04/2010.
// [The "BSD licence"]
// Copyright (c) 2010 Ian Michell 2010 Alan Condit
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

#import "ANTLRStreamEnumerator.h"


@implementation ANTLRStreamEnumerator

-(id) init
{
	self = [super init];
	if (self)
	{
		i = 0;
	}
	return self;
}

-(id) initWithNodes:(AMutableArray *) n andEOF:(id) obj
{
	self = [self init];
	if (self)
	{
		nodes = n;
		eof = obj;
	}
	return self;
}

-(BOOL) hasNext
{
	return i < [nodes count];
}

-(id) nextObject
{
	NSUInteger current = i;
	i++;
	if (current < [nodes count])
	{
		return [nodes objectAtIndex:current];
	}
	return eof;
}

@synthesize i;
@synthesize eof;
@synthesize nodes;
@end
