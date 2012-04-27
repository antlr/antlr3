//
//  LinkBase.h
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

#import <Foundation/Foundation.h>

#ifndef DEBUG_DEALLOC
#define DEBUG_DEALLOC
#endif

@protocol LinkList <NSObject>

+ (id<LinkList>)newLinkBase;
+ (id<LinkList>)newLinkBase:(id<LinkList>)np Prev:(id<LinkList>)pp;

- (void) dealloc;

- (id<LinkList>) append:(id<LinkList>)node;
- (id<LinkList>) insert:(id<LinkList>)node;

- (id<LinkList>) getfNext;
- (void) setFNext:(id<LinkList>)np;
- (id<LinkList>)getfPrev;
- (void) setFPrev:(id<LinkList>)pp;

@property (retain) id<LinkList> fPrev;
@property (retain) id<LinkList> fNext;
@end

@interface LinkBase : NSObject <LinkList> {
	id<LinkList> fPrev;
	id<LinkList> fNext;
}

@property (retain) id<LinkList> fPrev;
@property (retain) id<LinkList> fNext;

+ (id<LinkList>)newLinkBase;
+ (id<LinkList>)newLinkBase:(id<LinkList>)np Prev:(id<LinkList>)pp;
- (id<LinkList>)init;
- (id<LinkList>)initWithPtr:(id)np Prev:(id)pp;
- (void)dealloc;

- (id) copyWithZone:(NSZone *)aZone;

- (id<LinkList>)append:(id<LinkList>)node;
- (id<LinkList>)insert:(id<LinkList>)node;

- (id<LinkList>)getfNext;
- (void)setfNext:(id<LinkList>) np;
- (id<LinkList>)getfPrev;
- (void)setfPrev:(id<LinkList>) pp;
@end
