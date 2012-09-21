//
//  RuleStack.m
//  ANTLR
//
//  Created by Alan Condit on 6/9/10.
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

#define SUCCESS (0)
#define FAILURE (-1)

extern NSInteger debug;

#import "RuleStack.h"
#import "Tree.h"

/*
 * Start of RuleStack
 */
@implementation RuleStack

+ (RuleStack *)newRuleStack
{
    return [[RuleStack alloc] init];
}

+ (RuleStack *)newRuleStack:(NSInteger)cnt
{
    return [[RuleStack alloc] initWithLen:cnt];
}

- (id)init
{
	if ((self = [super init]) != nil) {
	}
    return( self );
}

- (id)initWithLen:(NSInteger)cnt
{
	if ((self = [super initWithLen:cnt]) != nil) {
	}
    return( self );
}

- (void)dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in RuleStack" );
#endif
	[super dealloc];
}

- (id) copyWithZone:(NSZone *)aZone
{
    return [super copyWithZone:aZone];
}

- (NSInteger)count
{
    RuleMemo *anElement;
    NSInteger aCnt = 0;
    for( int i = 0; i < BuffSize; i++ ) {
        if ((anElement = ptrBuffer[i]) != nil)
            aCnt++;
    }
    return aCnt;
}

- (NSInteger)size
{
    RuleMemo *anElement;
    NSInteger aSize = 0;
    for( int i = 0; i < BuffSize; i++ ) {
        if ((anElement = ptrBuffer[i]) != nil) {
            aSize++;
        }
    }
    return aSize;
}

- (HashRule *)pop
{
    return (HashRule *)[super pop];
}

- (void) insertObject:(HashRule *)aRule atIndex:(NSInteger)idx
{
    if ( idx >= BuffSize ) {
        if ( debug > 2 ) NSLog( @"In RuleStack attempting to insert aRule at Index %d, but Buffer is only %d long\n", idx, BuffSize );
        [self ensureCapacity:idx];
    }
    if ( aRule != ptrBuffer[idx] ) {
        if ( ptrBuffer[idx] ) [ptrBuffer[idx] release];
        [aRule retain];
    }
    ptrBuffer[idx] = aRule;
}

- (HashRule *)objectAtIndex:(NSInteger)idx
{
    if (idx < BuffSize) {
        return ptrBuffer[idx];
    }
    return nil;
}

- (void)putHashRuleAtRuleIndex:(NSInteger)aRuleIndex StartIndex:(NSInteger)aStartIndex StopIndex:(NSInteger)aStopIndex
{
    HashRule *aHashRule;
    RuleMemo *aRuleMemo;

    if (aRuleIndex >= BuffSize) {
        if ( debug) NSLog( @"putHashRuleAtRuleIndex attempting to insert aRule at Index %d, but Buffer is only %d long\n", aRuleIndex, BuffSize );
        [self ensureCapacity:aRuleIndex];
    }
    if ((aHashRule = ptrBuffer[aRuleIndex]) == nil) {
        aHashRule = [[HashRule newHashRuleWithLen:17] retain];
        ptrBuffer[aRuleIndex] = aHashRule;
    }
    if (( aRuleMemo = [aHashRule objectAtIndex:aStartIndex] ) == nil ) {
        aRuleMemo = [[RuleMemo newRuleMemo] retain];
        [aHashRule insertObject:aRuleMemo atIndex:aStartIndex];
    }
    [aRuleMemo setStartIndex:[ACNumber numberWithInteger:aStartIndex]];
    [aRuleMemo setStopIndex:[ACNumber numberWithInteger:aStopIndex]];
}

@end
