//
//  ANTLRLinkBase.m
//  ANTLR
//
//  Created by Alan Condit on 6/14/10.
//  [The "BSD licence"]
//  Copyright (c) 2010 Alan Condit
//  All rights reserved.
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

#import "ANTLRLinkBase.h"

@implementation ANTLRLinkBase

@synthesize fPrev;
@synthesize fNext;

+(id<ANTLRLinkList>)newANTLRLinkBase
{
	return [[ANTLRLinkBase alloc] init];
}

+(id<ANTLRLinkList>)newANTLRLinkBase:(id<ANTLRLinkList>)np Prev:(id<ANTLRLinkList>)pp
{
	return [[ANTLRLinkBase alloc] initWithPtr:np Prev:pp];
}

-(id<ANTLRLinkList>)init
{
	if ((self = [super init]) != nil) {
		fNext = nil;
		fPrev = nil;
	}
	return(self);
}

-(id<ANTLRLinkList>)initWithPtr:(id<ANTLRLinkList>)np Prev:(id<ANTLRLinkList>)pp
{
	if ((self = [super init]) != nil) {
		fNext = np;
		fPrev = pp;
	}
	return(self);
}

-(void)dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in ANTLRLinkBase" );
#endif
	if (fNext) [fNext dealloc];
	if (fPrev) [fPrev dealloc];
	[super dealloc];
}

- (id) copyWithZone:(NSZone *)aZone
{
    ANTLRLinkBase *copy;
    
    copy = [[self class] allocWithZone:aZone];
    copy.fPrev = fPrev;
    copy.fNext = fNext;
    return( copy );
}

-(id<ANTLRLinkList>)append:(id<ANTLRLinkList>)node
{
	node.fPrev = (id<ANTLRLinkList>)self;
	node.fNext = (id<ANTLRLinkList>)self.fNext;
	if (node.fNext != nil)
        node.fNext.fPrev = node;
    self.fNext = node;
    return( node );
}

-(id<ANTLRLinkList>)insert:(id<ANTLRLinkList>)node
{
	node.fNext = self;
	node.fPrev = self.fPrev;
    if (node.fPrev != nil) 
        node.fPrev.fNext = node;
	self.fPrev = node;
	return( node );
}

-(id<ANTLRLinkList>)getfNext
{
	return(fNext);
}

-(void)setfNext:(id<ANTLRLinkList>)np
{
	fNext = np;
}

-(id<ANTLRLinkList>)getfPrev
{
	return(fPrev);
}

-(void)setfPrev:(id<ANTLRLinkList>)pp
{
	fPrev = pp;
}

@end
