//
//  ANTLRHashRule.m
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

#define SUCCESS (0)
#define FAILURE (-1)
#define ANTLR_MEMO_RULE_UNKNOWN -1

#import "ANTLRHashRule.h"

/*
 * Start of ANTLRHashRule
 */
@implementation ANTLRHashRule

@synthesize LastHash;

+(id)newANTLRHashRule
{
    return [[ANTLRHashRule alloc] init];
}

+(id)newANTLRHashRuleWithLen:(NSInteger)aBuffSize
{
    return [[ANTLRHashRule alloc] initWithLen:aBuffSize];
}

-(id)init
{
    self = [super initWithLen:HASHSIZE];
    if ( self != nil ) {
    }
    return( self );
}

-(id)initWithLen:(NSInteger)aBuffSize
{
    self = [super initWithLen:aBuffSize];
    if ( self != nil ) {
        mode = 0;
    }
    return( self );
}

-(void)dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in ANTLRHashRule" );
#endif
    ANTLRRuleMemo *tmp, *rtmp;
    int Index;
    
    if ( self.fNext != nil ) {
        for( Index = 0; Index < BuffSize; Index++ ) {
            tmp = ptrBuffer[Index];
            while ( tmp && tmp != ptrBuffer[Index] ) {
                rtmp = tmp;
                if ([tmp isKindOfClass:[ANTLRLinkBase class]])
                    tmp = (ANTLRRuleMemo *)tmp.fNext;
                else
                    tmp = nil;
                [rtmp dealloc];
            }
        }
    }
    [super dealloc];
}

- (NSInteger)count
{
    NSInteger aCnt = 0;
    
    for (int i = 0; i < BuffSize; i++) {
        if ( ptrBuffer[i] != nil ) {
            aCnt++;
        }
    }
    return aCnt;
}
                          
- (NSInteger) length
{
    return BuffSize;
}

- (NSInteger) size
{
    NSInteger aSize = 0;
    
    for (int i = 0; i < BuffSize; i++) {
        if ( ptrBuffer[i] != nil ) {
            aSize += sizeof(id);
        }
    }
    return aSize;
}
                                  
                                  
-(void)deleteANTLRHashRule:(ANTLRRuleMemo *)np
{
    ANTLRRuleMemo *tmp, *rtmp;
    int Index;
    
    if ( self.fNext != nil ) {
        for( Index = 0; Index < BuffSize; Index++ ) {
            tmp = ptrBuffer[Index];
            while ( tmp && tmp != ptrBuffer[Index ] ) {
                rtmp = tmp;
                if ([tmp isKindOfClass:[ANTLRLinkBase class]])
                    tmp = (ANTLRRuleMemo *)tmp.fNext;
                else
                    tmp = nil;
                [rtmp release];
            }
        }
    }
}

-(void)delete_chain:(ANTLRRuleMemo *)np
{
    if ( np.fNext != nil )
        [self delete_chain:np.fNext];
    [np dealloc];
}

-(ANTLRRuleMemo **)getPtrBuffer
{
    return( ptrBuffer );
}

-(void)setPtrBuffer:(ANTLRRuleMemo **)np
{
    ptrBuffer = np;
}

- (NSNumber *)getRuleMemoStopIndex:(NSInteger)aStartIndex
{
    ANTLRRuleMemo *aRule;
    NSNumber *stopIndex;
    NSInteger anIndex;
    
    anIndex = ( aStartIndex >= BuffSize ) ? aStartIndex % BuffSize : aStartIndex;
    if ((aRule = ptrBuffer[anIndex]) == nil) {
        return nil;
    }
    stopIndex = [aRule getStopIndex:aStartIndex];
    return stopIndex;
}

- (void)putRuleMemo:(ANTLRRuleMemo *)aRule AtStartIndex:(NSInteger)aStartIndex
{
    NSInteger anIndex;
    
    anIndex = (aStartIndex >= BuffSize) ? aStartIndex %= BuffSize : aStartIndex;
    if ( ptrBuffer[anIndex] == nil ) {
        ptrBuffer[anIndex] = aRule;
        [aRule retain];
    }
    else {
        do {
            if ( [aRule.startIndex integerValue] == aStartIndex ) {
                [aRule setStartIndex:aRule.stopIndex];
                return;
            }
            aRule = aRule.fNext;
        } while ( aRule != nil );
    }
}

- (void)putRuleMemoAtStartIndex:(NSInteger)aStartIndex StopIndex:(NSInteger)aStopIndex
{
    ANTLRRuleMemo *aRule, *newRule;
    NSInteger anIndex;
    NSInteger aMatchIndex;

    anIndex = (aStartIndex >= BuffSize) ? aStartIndex % BuffSize : aStartIndex;
    aRule = ptrBuffer[anIndex];
    if ( aRule == nil ) {
        aRule = [ANTLRRuleMemo newANTLRRuleMemoWithStartIndex:[NSNumber numberWithInteger:aStartIndex]
                                                    StopIndex:[NSNumber numberWithInteger:aStopIndex]];
        [aRule retain];
        ptrBuffer[anIndex] = aRule;
    }
    else {
        aMatchIndex = [aRule.startIndex integerValue];
        if ( aStartIndex > aMatchIndex ) {
            if ( aRule != ptrBuffer[anIndex] ) {
                [aRule retain];
            }
            aRule.fNext = ptrBuffer[anIndex];
            ptrBuffer[anIndex] = aRule;
            return;
        }
        while (aRule.fNext != nil) {
            aMatchIndex = [((ANTLRRuleMemo *)aRule.fNext).startIndex integerValue];
            if ( aStartIndex > aMatchIndex ) {
                newRule = [ANTLRRuleMemo newANTLRRuleMemoWithStartIndex:[NSNumber numberWithInteger:aStartIndex]
                                                              StopIndex:[NSNumber numberWithInteger:aStopIndex]];
                [newRule retain];
                newRule.fNext = aRule.fNext;
                aRule.fNext = newRule;
                return;
            }
            if ( aMatchIndex == aStartIndex ) {
                [aRule setStartIndex:aRule.stopIndex];
                return;
            }
            aRule = aRule.fNext;
        }
    }
}

- (NSInteger)getLastHash
{
    return LastHash;
}

- (void)setLastHash:(NSInteger)aHash
{
    LastHash = aHash;
}

- (NSInteger)getMode
{
    return mode;
}

- (void)setMode:(NSInteger)aMode
{
    mode = aMode;
}

- (void) insertObject:(ANTLRRuleMemo *)aRule atIndex:(NSInteger)anIndex
{
    NSInteger Index;
    
    Index = ( anIndex >= BuffSize ) ? anIndex % BuffSize : anIndex;
    if (aRule != ptrBuffer[Index]) {
        if ( ptrBuffer[Index] ) [ptrBuffer[Index] release];
        [aRule retain];
    }
    ptrBuffer[Index] = aRule;
}

- (ANTLRRuleMemo *)objectAtIndex:(NSInteger)anIndex
{
    NSInteger anIdx;

    anIdx = ( anIndex >= BuffSize ) ? anIndex % BuffSize : anIndex;
    return ptrBuffer[anIdx];
}


@end
