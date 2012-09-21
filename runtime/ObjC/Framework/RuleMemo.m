//
//  RuleMemo.m
//  ANTLR
//
//  Created by Alan Condit on 6/16/10.
// [The "BSD licence"]
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

#import "RuleMemo.h"


@implementation RuleMemo

@synthesize startIndex;
@synthesize stopIndex;

+ (RuleMemo *)newRuleMemo
{
    return [[RuleMemo alloc] init];
}

+ (RuleMemo *)newRuleMemoWithStartIndex:(ACNumber *)anIndex StopIndex:(ACNumber *)aStopIndex
{
    return [[RuleMemo alloc] initWithStartIndex:anIndex StopIndex:aStopIndex];
}

- (id) init
{
    if ((self = [super init]) != nil ) {
        startIndex = nil;
        stopIndex = nil;
    }
    return (self);
}

- (id) initWithStartIndex:(ACNumber *)aStartIndex StopIndex:(ACNumber *)aStopIndex
{
    if ((self = [super init]) != nil ) {
        [aStartIndex retain];
        startIndex = aStartIndex;
        [aStopIndex retain];
        stopIndex = aStopIndex;
    }
    return (self);
}

- (id) copyWithZone:(NSZone *)aZone
{
    RuleMemo *copy;
    
    copy = [super copyWithZone:aZone];
    copy.startIndex = startIndex;
    copy.stopIndex = stopIndex;
    return( copy );
}

- (NSInteger)count
{
    NSInteger aCnt = 0;
    
    if (startIndex != nil) aCnt++;
    if (stopIndex != nil) aCnt++;
    return aCnt;
}

- (NSInteger) size
{
    return (2 * sizeof(id));
}

- (RuleMemo *)getRuleWithStartIndex:(NSInteger)aStartIndex
{
    RuleMemo *aMatchMemo = self;
    do {
        if (aStartIndex == [aMatchMemo.startIndex integerValue] ) {
            return aMatchMemo;
        }
        aMatchMemo = aMatchMemo.fNext;
    } while ( aMatchMemo != nil );
    return nil;
}

- (ACNumber *)getStartIndex:(NSInteger)aStartIndex
{
    RuleMemo *aMatchMemo = self;
    do {
        if (aStartIndex == [aMatchMemo.startIndex integerValue] ) {
            return aMatchMemo.stopIndex;
        }
        aMatchMemo = aMatchMemo.fNext;
    } while ( aMatchMemo != nil );
    return nil;
}

- (ACNumber *)getStopIndex:(NSInteger)aStartIndex
{
    RuleMemo *aMatchMemo = self;
    do {
        if (aStartIndex == [aMatchMemo.startIndex integerValue] ) {
            return aMatchMemo.stopIndex;
        }
        aMatchMemo = aMatchMemo.fNext;
    } while ( aMatchMemo != nil );
    return nil;
}

- (ACNumber *)getStartIndex;
{
    return startIndex;
}

- (void)setStartIndex:(ACNumber *)aStartIndex
{
    if ( aStartIndex != startIndex ) {
        if ( startIndex ) [startIndex release];
        [aStartIndex retain];
    }
    startIndex = aStartIndex;
}

- (ACNumber *)getStopIndex;
{
    return stopIndex;
}

- (void)setStopIndex:(ACNumber *)aStopIndex
{
    if ( aStopIndex != stopIndex ) {
        if ( stopIndex ) [stopIndex release];
        [aStopIndex retain];
    }
    stopIndex = aStopIndex;
}

@end
