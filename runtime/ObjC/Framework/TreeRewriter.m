//
//  TreeRewriter.m
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

#import "TreeRewriter.h"
#import "CommonTreeNodeStream.h"
#import "TreeRuleReturnScope.h"
#import "CommonTreeAdaptor.h"
#import "TreeVisitor.h"

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
        @throw [RuntimeException newException:@"Unknown Rewrite exception"];
    return nil;
}

@synthesize actor;
@synthesize ruleSEL;
@end

@implementation TreeRewriter

+ (TreeRewriter *) newTreeRewriter:(id<TreeNodeStream>)anInput
{
    return [[TreeRewriter alloc] initWithStream:anInput State:[RecognizerSharedState newRecognizerSharedState]];
}

+ (TreeRewriter *) newTreeRewriter:(id<TreeNodeStream>)anInput State:(RecognizerSharedState *)aState
{
    return [[TreeRewriter alloc] initWithStream:anInput State:aState];
}

- (id)initWithStream:(id<TreeNodeStream>)anInput
{
    SEL aRuleSel;

    if ((self = [super initWithStream:anInput]) != nil) {
        showTransformations = NO;
        state = [[RecognizerSharedState newRecognizerSharedState] retain];
        originalAdaptor = [input getTreeAdaptor];
        if ( originalAdaptor ) [originalAdaptor retain];
        originalTokenStream = [input getTokenStream];        
        if ( originalTokenStream ) [originalTokenStream retain];
        aRuleSel = @selector(topdown);
        topdown_fptr = [ANTLRfptr newANTLRfptrWithRule:(SEL)aRuleSel withObject:self];
        aRuleSel = @selector(bottomup);
        bottomup_ftpr = [ANTLRfptr newANTLRfptrWithRule:(SEL)aRuleSel withObject:self];        
    }
    return self;
}

- (id)initWithStream:(id<TreeNodeStream>)anInput State:(RecognizerSharedState *)aState
{
    SEL aRuleSel;
    
    if ((self = [super initWithStream:anInput]) != nil) {
        showTransformations = NO;
        state = aState;
        if ( state ) [state retain];
        originalAdaptor = [input getTreeAdaptor];
        if ( originalAdaptor ) [originalAdaptor retain];
        originalTokenStream = [input getTokenStream];        
        if ( originalTokenStream ) [originalTokenStream retain];
        aRuleSel = @selector(topdown);
        topdown_fptr = [ANTLRfptr newANTLRfptrWithRule:(SEL)aRuleSel withObject:self];
        aRuleSel = @selector(bottomup);
        bottomup_ftpr = [ANTLRfptr newANTLRfptrWithRule:(SEL)aRuleSel withObject:self];        
    }
    return self;
}

- (void) dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in TreeRewriter" );
#endif
	if ( state ) [state release];
	if ( originalAdaptor ) [originalAdaptor release];
	if ( originalTokenStream ) [originalTokenStream release];
	[super dealloc];
}

- (id) applyOnce:(CommonTree *)t Rule:(ANTLRfptr *)whichRule
{
    if ( t == nil ) return nil;
    @try {
        // share TreeParser object but not parsing-related state
        state = [RecognizerSharedState newRecognizerSharedState];
        input = [CommonTreeNodeStream newCommonTreeNodeStream:(CommonTreeAdaptor *)originalAdaptor Tree:t];
        [(CommonTreeNodeStream *)input setTokenStream:originalTokenStream];
        [self setBacktrackingLevel:1];
        TreeRuleReturnScope *r = [(ANTLRfptr *)whichRule rule];
        [self setBacktrackingLevel:0];
        if ( [self getFailed] )
            return t;
        if ( showTransformations &&
            r != nil && !(t == r.start) && r.start != nil ) {
            [self reportTransformation:t Tree:r.start];
        }
        if ( r != nil && r.start != nil )
            return r.start;
        else
            return t;
    }
    @catch (RecognitionException *e) {
        return t;
    }
    return t;
}

- (id) applyRepeatedly:(CommonTree *)t Rule:(ANTLRfptr *)whichRule
{
    BOOL treeChanged = true;
    while ( treeChanged ) {
        TreeRewriter *u = [self applyOnce:t Rule:whichRule];
        treeChanged = !(t == u);
        t = u;
    }
    return t;
}

- (id) downup:(CommonTree *)t
{
    return [self downup:t XForm:NO];
}

- (id) pre:(CommonTree *)t
{
    return [self applyOnce:t Rule:topdown_fptr];
}

- (id)post:(CommonTree *)t
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

- (id) downup:(CommonTree *)t XForm:(BOOL)aShowTransformations
{
    showTransformations = aShowTransformations;
    TreeVisitor *v = [TreeVisitor newTreeVisitor:[[originalAdaptor class] newTreeAdaptor]];
    TreeVisitorAction *actions = [TreeVisitorAction newTreeVisitorAction];
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
- (void)reportTransformation:(CommonTree *)oldTree Tree:(CommonTree *)newTree
{
    //System.out.println(((Tree)oldTree).toStringTree()+" -> "+ ((Tree)newTree).toStringTree());
}

- (id)topdown_fptr
{
    return [self topdown];
}

- (id)bottomup_ftpr
{
    return [self bottomup];
}

// methods the downup strategy uses to do the up and down rules.
// to override, just define tree grammar rule topdown and turn on
// filter=true.
- (id) topdown
// @throws RecognitionException
{
    @throw [RecognitionException newException:@"TopDown exception"];
    return nil;
}

- (id) bottomup
//@throws RecognitionException
{
    @throw [RecognitionException newException:@"BottomUp exception"];
    return nil;
}

@synthesize showTransformations;
@synthesize originalTokenStream;
@synthesize originalAdaptor;
@synthesize rule;
@end
