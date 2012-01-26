//
//  ANTLRParseTree.m
//  ANTLR
//
//  Created by Alan Condit on 7/12/10.
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

#import "ANTLRParseTree.h"

/** A record of the rules used to match a token sequence.  The tokens
 *  end up as the leaves of this tree and rule nodes are the interior nodes.
 *  This really adds no functionality, it is just an alias for CommonTree
 *  that is more meaningful (specific) and holds a String to display for a node.
 */
@implementation ANTLRParseTree
+ (ANTLRParseTree *)newANTLRParseTree:(id<ANTLRToken>)label
{
    return [[ANTLRParseTree alloc] initWithLabel:label];
}
    
- (id)initWithLabel:(id<ANTLRToken>)label
{
    self = [super init];
    if ( self != nil) {
        payload = [label retain];
    }
    return self;
}

- (id<ANTLRBaseTree>)dupNode
{
    return nil;
}
    
- (NSInteger)type
{
    return 0;
}
    
- (NSString *)text
{
    return [self toString];
}
    
- (NSInteger)getTokenStartIndex
{
    return 0;
}
    
- (void)setTokenStartIndex:(NSInteger)anIndex
{
}
    
- (NSInteger)getTokenStopIndex
{
    return 0;
}
    
- (void)setTokenStopIndex:(NSInteger)anIndex
{
}

- (NSString *)description
{
    if ( [payload isKindOfClass:[ANTLRCommonToken class]] ) {
        id<ANTLRToken> t = (id<ANTLRToken>)payload;
        if ( t.type == ANTLRTokenTypeEOF ) {
            return @"<EOF>";
        }
        return [t text];
    }
    return [payload description];
}
    
- (NSString *)toString
{
    return [self description];
}
    
/** Emit a token and all hidden nodes before.  EOF node holds all
 *  hidden tokens after last real token.
 */
- (NSString *)toStringWithHiddenTokens
{
    NSMutableString *buf = [NSMutableString stringWithCapacity:25];
    if ( hiddenTokens!=nil ) {
        for (NSUInteger i = 0; i < [hiddenTokens count]; i++) {
            id<ANTLRToken>  hidden = (id<ANTLRToken> ) [hiddenTokens objectAtIndex:i];
            [buf appendString:[hidden text]];
        }
    }
    NSString *nodeText = [self toString];
    if ( ![nodeText isEqualTo:@"<EOF>"] )
        [buf appendString:nodeText];
    return buf;
}
    
/** Print out the leaves of this tree, which means printing original
 *  input back out.
 */
- (NSString *)toInputString
{
    NSMutableString *buf = [NSMutableString stringWithCapacity:25];
    [self _toStringLeaves:buf];
    return buf;
}
    
- (void)_toStringLeaves:(NSMutableString *)buf
{
    if ( [payload isKindOfClass:[ANTLRCommonToken class]] ) { // leaf node token?
        [buf appendString:[self toStringWithHiddenTokens]];
        return;
    }
    for (int i = 0; children!=nil && i < [children count]; i++) {
        ANTLRParseTree *t = (ANTLRParseTree *) [children objectAtIndex:i];
        [t _toStringLeaves:buf];
    }
}
    
@synthesize payload;
@synthesize hiddenTokens;
@synthesize children;
@synthesize anException;

@end
