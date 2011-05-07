//
//  ANTLRTreeRewriter.m
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

#import "ANTLRTreeRewriter.h"
#import "ANTLRCommonTreeNodeStream.h"
#import "ANTLRTreeRuleReturnScope.h"
#import "ANTLRCommonTreeAdaptor.h"
#import "ANTLRTreeVisitor.h"

@implementation ANTLRfptr

+ (ANTLRfptr *)newANTLRfptrWithRule:(SEL)aRuleAction withObject:(id)anObject
{
    return [[ANTLRfptr alloc] initWithRule:aRuleAction withObject:(id)anObject];
}

-initWithRule:(SEL)aRuleAction withObject:(id)anObject
{
    if ((self = [super init]) != nil) {
        actor = anObject;
        ruleSEL = aRuleAction;
    }
    return self;
}

- (id)rule
{
	if ( [actor respondsToSelector:ruleSEL] )
		return [actor performSelector:ruleSEL];
    else
        @throw [ANTLRRuntimeException newException:@"Unknown Rewrite exception"];
    return nil;
}

@synthesize actor;
@synthesize ruleSEL;
@end

@implementation ANTLRTreeRewriter

+ (ANTLRTreeRewriter *) newANTLRTreeRewriter:(id<ANTLRTreeNodeStream>)anInput
{
    return [[ANTLRTreeRewriter alloc] initWithStream:anInput State:[ANTLRRecognizerSharedState newANTLRRecognizerSharedState]];
}

+ (ANTLRTreeRewriter *) newANTLRTreeRewriter:(id<ANTLRTreeNodeStream>)anInput State:(ANTLRRecognizerSharedState *)aState
{
    return [[ANTLRTreeRewriter alloc] initWithStream:anInput State:aState];
}

- (id)initWithStream:(id<ANTLRTreeNodeStream>)anInput
{
    SEL aRuleSel;

    if ((self = [super initWithStream:anInput]) != nil) {
        showTransformations = NO;
        state = [ANTLRRecognizerSharedState newANTLRRecognizerSharedState];
        originalAdaptor = [input getTreeAdaptor];
        originalTokenStream = [input getTokenStream];        
        aRuleSel = @selector(topdown);
        topdown_fptr = [ANTLRfptr newANTLRfptrWithRule:(SEL)aRuleSel withObject:self];
        aRuleSel = @selector(bottomup);
        bottomup_ftpr = [ANTLRfptr newANTLRfptrWithRule:(SEL)aRuleSel withObject:self];        
    }
    return self;
}

- (id)initWithStream:(id<ANTLRTreeNodeStream>)anInput State:(ANTLRRecognizerSharedState *)aState
{
    SEL aRuleSel;
    
    if ((self = [super initWithStream:anInput]) != nil) {
        showTransformations = NO;
        state = aState;
        originalAdaptor = [input getTreeAdaptor];
        originalTokenStream = [input getTokenStream];        
        aRuleSel = @selector(topdown);
        topdown_fptr = [ANTLRfptr newANTLRfptrWithRule:(SEL)aRuleSel withObject:self];
        aRuleSel = @selector(bottomup);
        bottomup_ftpr = [ANTLRfptr newANTLRfptrWithRule:(SEL)aRuleSel withObject:self];        
    }
    return self;
}

- (ANTLRTreeRewriter *) applyOnce:(id<ANTLRBaseTree>)t Rule:(ANTLRfptr *)whichRule
{
    if ( t == nil ) return nil;
    @try {
        // share TreeParser object but not parsing-related state
        state = [ANTLRRecognizerSharedState newANTLRRecognizerSharedState];
        input = [ANTLRCommonTreeNodeStream newANTLRCommonTreeNodeStream:(id<ANTLRTreeAdaptor>)originalAdaptor Tree:(id<ANTLRBaseTree>)t];
        [(ANTLRCommonTreeNodeStream *)input setTokenStream:originalTokenStream];
        [self setBacktrackingLevel:1];
        ANTLRTreeRuleReturnScope *r = [(ANTLRfptr *)whichRule rule];
        [self setBacktrackingLevel:0];
        if ( [self getFailed] )
            return t;
        if ( showTransformations &&
            r != nil && !(t == r.start) && r.start != nil ) {
            [self reportTransformation:(id<ANTLRBaseTree>)t Tree:r.start];
        }
        if ( r != nil && r.start != nil )
            return r.start;
        else
            return t;
    }
    @catch (ANTLRRecognitionException *e) {
        return t;
    }
    return t;
}

- (ANTLRTreeRewriter *) applyRepeatedly:(id<ANTLRBaseTree>)t Rule:(ANTLRfptr *)whichRule
{
    BOOL treeChanged = true;
    while ( treeChanged ) {
        ANTLRTreeRewriter *u = [self applyOnce:(id<ANTLRBaseTree>)t Rule:whichRule];
        treeChanged = !(t == u);
        t = u;
    }
    return t;
}

- (ANTLRTreeRewriter *) downup:(id<ANTLRBaseTree>)t
{
    return [self downup:t XForm:NO];
}

- (ANTLRTreeRewriter *) pre:(id<ANTLRBaseTree>)t
{
    return [self applyOnce:t Rule:topdown_fptr];
}

- (ANTLRTreeRewriter *)post:(id<ANTLRBaseTree>)t
{
    return [self applyRepeatedly:t Rule:bottomup_ftpr];
}

#ifdef DONTUSENOMO
public Object downup(Object t, boolean showTransformations) {
    this.showTransformations = showTransformations;
    TreeVisitor v = new TreeVisitor(new CommonTreeAdaptor());
    TreeVisitorAction actions = new TreeVisitorAction() {
        public Object pre(Object t)  { return applyOnce(t, topdown_fptr); }
        public Object post(Object t) { return applyRepeatedly(t, bottomup_ftpr); }
    };
    t = v.visit(t, actions);
    return t;
}
#endif

- (ANTLRTreeRewriter *) downup:(id<ANTLRBaseTree>)t XForm:(BOOL)aShowTransformations
{
    showTransformations = aShowTransformations;
    ANTLRTreeVisitor *v = [ANTLRTreeVisitor newANTLRTreeVisitor:[[originalAdaptor class] newTreeAdaptor]];
    ANTLRTreeVisitorAction *actions = [ANTLRTreeVisitorAction newANTLRTreeVisitorAction];
    {
        //public Object pre(Object t)  { return applyOnce(t, topdown_fptr); }
        [self pre:t];
        //public Object post(Object t) { return applyRepeatedly(t, bottomup_ftpr); }
        [self post:t];
    };
    t = [v visit:t Action:actions];
    return t;
}

/** Override this if you need transformation tracing to go somewhere
 *  other than stdout or if you're not using Tree-derived trees.
 */
- (void)reportTransformation:(id<ANTLRBaseTree>)oldTree Tree:(id<ANTLRBaseTree>)newTree
{
    //System.out.println(((Tree)oldTree).toStringTree()+" -> "+ ((Tree)newTree).toStringTree());
}

- (ANTLRTreeRewriter *)topdown_fptr
{
    return [self topdown];
}

- (ANTLRTreeRewriter *)bottomup_ftpr
{
    return [self bottomup];
}

// methods the downup strategy uses to do the up and down rules.
// to override, just define tree grammar rule topdown and turn on
// filter=true.
- (ANTLRTreeRewriter *) topdown
// @throws RecognitionException
{
    [ANTLRRecognitionException newException:@"TopDown exception"];
    return nil;
}

- (ANTLRTreeRewriter *) bottomup
//@throws RecognitionException
{
    @throw [ANTLRRecognitionException newException:@"BottomUp exception"];
    return nil;
}

@synthesize showTransformations;
@synthesize originalTokenStream;
@synthesize originalAdaptor;
@synthesize rule;
@end
