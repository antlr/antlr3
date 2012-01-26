//
//  ANTLRTreePatternParser.m
//  ANTLR
//
//  Created by Alan Condit on 6/18/10.
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

#import "ANTLRTreePatternParser.h"
#import "ANTLRTreePatternLexer.h"

@implementation ANTLRTreePatternParser

+ (ANTLRTreePatternParser *)newANTLRTreePatternParser:(ANTLRTreePatternLexer *)aTokenizer
                                               Wizard:(ANTLRTreeWizard *)aWizard
                                              Adaptor:(id<ANTLRTreeAdaptor>)anAdaptor
{
    return [[ANTLRTreePatternParser alloc] initWithTokenizer:aTokenizer Wizard:aWizard Adaptor:anAdaptor];
}

- (id) init
{
    if ((self = [super init]) != nil) {
        //tokenizer = aTokenizer;
        //wizard = aWizard;
        //adaptor = anAdaptor;
        //ttype = [tokenizer nextToken]; // kickstart
    }
    return self;
}

- (id) initWithTokenizer:(ANTLRTreePatternLexer *)aTokenizer
                  Wizard:(ANTLRTreeWizard *)aWizard
                 Adaptor:(id<ANTLRTreeAdaptor>)anAdaptor
{
    if ((self = [super init]) != nil) {
        adaptor = anAdaptor;
        if ( adaptor ) [adaptor retain];
        tokenizer = aTokenizer;
        if ( tokenizer ) [tokenizer retain];
        wizard = aWizard;
        if ( wizard ) [wizard retain];
        ttype = [aTokenizer nextToken]; // kickstart
    }
    return self;
}

- (void) dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in ANTLRTreePatternParser" );
#endif
	if ( adaptor ) [adaptor release];
	if ( tokenizer ) [tokenizer release];
	if ( wizard ) [wizard release];
	[super dealloc];
}

- (id<ANTLRBaseTree>)pattern
{
    if ( ttype==ANTLRLexerTokenTypeBEGIN ) {
        return [self parseTree];
    }
    else if ( ttype==ANTLRLexerTokenTypeID ) {
        id<ANTLRBaseTree> node = [self parseNode];
        if ( ttype==ANTLRLexerTokenTypeEOF ) {
            return node;
        }
        return nil; // extra junk on end
    }
    return nil;
}

- (id<ANTLRBaseTree>) parseTree
{
    if ( ttype != ANTLRLexerTokenTypeBEGIN ) {
        @throw [ANTLRRuntimeException newException:@"no BEGIN"];
    }
    ttype = [tokenizer nextToken];
    id<ANTLRBaseTree> root = [self parseNode];
    if ( root==nil ) {
        return nil;
    }
    while ( ttype==ANTLRLexerTokenTypeBEGIN  ||
           ttype==ANTLRLexerTokenTypeID      ||
           ttype==ANTLRLexerTokenTypePERCENT ||
           ttype==ANTLRLexerTokenTypeDOT )
    {
        if ( ttype==ANTLRLexerTokenTypeBEGIN ) {
            id<ANTLRBaseTree> subtree = [self parseTree];
            [adaptor addChild:subtree toTree:root];
        }
        else {
            id<ANTLRBaseTree> child = [self parseNode];
            if ( child == nil ) {
                return nil;
            }
            [adaptor addChild:child toTree:root];
        }
    }
    if ( ttype != ANTLRLexerTokenTypeEND ) {
        @throw [ANTLRRuntimeException newException:@"no END"];
    }
    ttype = [tokenizer nextToken];
    return root;
}

- (id<ANTLRBaseTree>) parseNode
{
    // "%label:" prefix
    NSString *label = nil;
    ANTLRTreePattern *node;
    if ( ttype == ANTLRLexerTokenTypePERCENT ) {
        ttype = [tokenizer nextToken];
        if ( ttype != ANTLRLexerTokenTypeID ) {
            return nil;
        }
        label = [tokenizer toString];
        ttype = [tokenizer nextToken];
        if ( ttype != ANTLRLexerTokenTypeCOLON ) {
            return nil;
        }
        ttype = [tokenizer nextToken]; // move to ID following colon
    }
    
    // Wildcard?
    if ( ttype == ANTLRLexerTokenTypeDOT ) {
        ttype = [tokenizer nextToken];
        id<ANTLRToken> wildcardPayload = [ANTLRCommonToken newToken:0 Text:@"."];
        node = [ANTLRWildcardTreePattern newANTLRWildcardTreePattern:wildcardPayload];
        if ( label != nil ) {
            node.label = label;
        }
        return node;
    }
    
    // "ID" or "ID[arg]"
    if ( ttype != ANTLRLexerTokenTypeID ) {
        return nil;
    }
    NSString *tokenName = [tokenizer toString];
    ttype = [tokenizer nextToken];
    if ( [tokenName isEqualToString:@"nil"] ) {
        return [adaptor emptyNode];
    }
    NSString *text = tokenName;
    // check for arg
    NSString *arg = nil;
    if ( ttype == ANTLRLexerTokenTypeARG ) {
        arg = [tokenizer toString];
        text = arg;
        ttype = [tokenizer nextToken];
    }
    
    // create node
    int treeNodeType = [wizard getTokenType:tokenName];
    if ( treeNodeType==ANTLRTokenTypeInvalid ) {
        return nil;
    }
    node = [adaptor createTree:treeNodeType Text:text];
    if ( label!=nil && [node class] == [ANTLRTreePattern class] ) {
        ((ANTLRTreePattern *)node).label = label;
    }
    if ( arg!=nil && [node class] == [ANTLRTreePattern class] ) {
        ((ANTLRTreePattern *)node).hasTextArg = YES;
    }
    return node;
}

@synthesize tokenizer;
@synthesize ttype;
@synthesize wizard;
@synthesize adaptor;
@end
