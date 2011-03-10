//
//  ANTLRTreeRewriter.h
//  ANTLR
//
//  Created by Alan Condit on 6/17/10.
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

#import <Cocoa/Cocoa.h>
#import "ANTLRTreeParser.h"

@interface ANTLRfptr : NSObject {
    id  actor;
    SEL ruleSEL;
}

+ (ANTLRfptr *)newANTLRfptrWithRule:(SEL)aRuleAction withObject:(id)anObject;
-initWithRule:(SEL)ruleAction withObject:(id)anObject;

- (id)rule;

@end

@interface ANTLRTreeRewriter : ANTLRTreeParser {
    BOOL showTransformations;
    id<ANTLRTokenStream> originalTokenStream;
    id<ANTLRTreeAdaptor> originalAdaptor;
    ANTLRfptr *rule;
    ANTLRfptr *topdown_fptr;
    ANTLRfptr *bottomup_ftpr;
}

+ (ANTLRTreeRewriter *) newANTLRTreeRewriter:(id<ANTLRTreeNodeStream>)anInput;
+ (ANTLRTreeRewriter *) newANTLRTreeRewriter:(id<ANTLRTreeNodeStream>)anInput State:(ANTLRRecognizerSharedState *)aState;
- (id)initWithStream:(id<ANTLRTreeNodeStream>)anInput;
- (id)initWithStream:(id<ANTLRTreeNodeStream>)anInput State:(ANTLRRecognizerSharedState *)aState;
- (ANTLRTreeRewriter *) applyOnce:(id<ANTLRTree>)t Rule:(ANTLRfptr *)whichRule;
- (ANTLRTreeRewriter *) applyRepeatedly:(id<ANTLRTree>)t Rule:(ANTLRfptr *)whichRule;
- (ANTLRTreeRewriter *) downup:(id<ANTLRTree>)t;
- (ANTLRTreeRewriter *) pre:(id<ANTLRTree>)t;
- (ANTLRTreeRewriter *) post:(id<ANTLRTree>)t;
- (ANTLRTreeRewriter *) downup:(id<ANTLRTree>)t XForm:(BOOL)aShowTransformations;
- (void)reportTransformation:(id<ANTLRTree>)oldTree Tree:(id<ANTLRTree>)newTree;
- (ANTLRTreeRewriter *) topdown_fptr;
- (ANTLRTreeRewriter *) bottomup_ftpr;
- (ANTLRTreeRewriter *) topdown;
- (ANTLRTreeRewriter *) bottomup;

@end
