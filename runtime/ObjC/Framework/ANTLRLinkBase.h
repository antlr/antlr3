//
//  ANTLRLinkBase.h
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

#import <Cocoa/Cocoa.h>

#ifndef DEBUG_DEALLOC
#define DEBUG_DEALLOC
#endif

@protocol ANTLRLinkList <NSObject>

+ (id<ANTLRLinkList>)newANTLRLinkBase;
+ (id<ANTLRLinkList>)newANTLRLinkBase:(id<ANTLRLinkList>)np Prev:(id<ANTLRLinkList>)pp;

- (void) dealloc;

- (id<ANTLRLinkList>) append:(id<ANTLRLinkList>)node;
- (id<ANTLRLinkList>) insert:(id<ANTLRLinkList>)node;

- (id<ANTLRLinkList>) getfNext;
- (void) setFNext:(id<ANTLRLinkList>)np;
- (id<ANTLRLinkList>)getfPrev;
- (void) setFPrev:(id<ANTLRLinkList>)pp;

@property (retain) id<ANTLRLinkList> fPrev;
@property (retain) id<ANTLRLinkList> fNext;
@end

@interface ANTLRLinkBase : NSObject <ANTLRLinkList> {
	id<ANTLRLinkList> fPrev;
	id<ANTLRLinkList> fNext;
}

@property (retain) id<ANTLRLinkList> fPrev;
@property (retain) id<ANTLRLinkList> fNext;

+ (id<ANTLRLinkList>)newANTLRLinkBase;
+ (id<ANTLRLinkList>)newANTLRLinkBase:(id<ANTLRLinkList>)np Prev:(id<ANTLRLinkList>)pp;
- (id<ANTLRLinkList>)init;
- (id<ANTLRLinkList>)initWithPtr:(id)np Prev:(id)pp;
- (void)dealloc;

- (id) copyWithZone:(NSZone *)aZone;

- (id<ANTLRLinkList>)append:(id<ANTLRLinkList>)node;
- (id<ANTLRLinkList>)insert:(id<ANTLRLinkList>)node;

- (id<ANTLRLinkList>)getfNext;
- (void)setfNext:(id<ANTLRLinkList>) np;
- (id<ANTLRLinkList>)getfPrev;
- (void)setfPrev:(id<ANTLRLinkList>) pp;
@end
