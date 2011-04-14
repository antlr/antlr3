//
//  ANTLRHashRule.h
//  ANTLR
//
// Copyright (c) 2010 Alan Condit
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

#import <Cocoa/Cocoa.h>
#import "ANTLRRuleMemo.h"
#import "ANTLRPtrBuffer.h"

#define GLOBAL_SCOPE       0
#define LOCAL_SCOPE        1
#define HASHSIZE         101
#define HBUFSIZE      0x2000

@interface ANTLRHashRule : ANTLRPtrBuffer {
    //    TStringPool *fPool;
    NSInteger LastHash;
    NSInteger mode;
}

// Contruction/Destruction
+ (id)newANTLRHashRule;
+ (id)newANTLRHashRuleWithLen:(NSInteger)aBuffSize;
- (id)init;
- (id)initWithLen:(NSInteger)aBuffSize;
- (void)dealloc;

- (NSInteger)count;
- (NSInteger)length;
- (NSInteger)size;

// Instance Methods
- (void)deleteANTLRHashRule:(ANTLRRuleMemo *)np;
- (void)delete_chain:(ANTLRRuleMemo *)np;
- (ANTLRRuleMemo **)getPtrBuffer;
- (void)setPtrBuffer:(ANTLRRuleMemo **)np;
- (NSNumber *)getRuleMemoStopIndex:(NSInteger)aStartIndex;
- (void)putRuleMemoAtStartIndex:(NSInteger)aStartIndex StopIndex:(NSInteger)aStopIndex;
- (NSInteger)getMode;
- (void)setMode:(NSInteger)aMode;
- (void) insertObject:(ANTLRRuleMemo *)aRule atIndex:(NSInteger)Index;
- (ANTLRRuleMemo *) objectAtIndex:(NSInteger)Index;

@property (getter=getLastHash, setter=setLastHash:) NSInteger LastHash;
@property (getter=getMode,setter=setMode:) NSInteger mode;
@end
