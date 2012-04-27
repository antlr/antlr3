//
//  TreeWizard.h
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

#import <Foundation/Foundation.h>
#import "CommonTreeAdaptor.h"
#import "CommonTree.h"
#import "MapElement.h"
#import "Map.h"
#import "AMutableArray.h"

@class ANTLRVisitor;

@protocol ANTLRContextVisitor <NSObject>
// TODO: should this be called visit or something else?
- (void) visit:(CommonTree *)t Parent:(CommonTree *)parent ChildIndex:(NSInteger)childIndex Map:(Map *)labels;

@end

@interface ANTLRVisitor : NSObject <ANTLRContextVisitor> {
    NSInteger action;
    id actor;
    id object1;
    id object2;
}
+ (ANTLRVisitor *)newANTLRVisitor:(NSInteger)anAction Actor:(id)anActor Object:(id)anObject1 Object:(id)anObject2;
- (id) initWithAction:(NSInteger)anAction Actor:(id)anActor Object:(id)anObject1 Object:(id)anObject2;

- (void) visit:(CommonTree *)t;
- (void) visit:(CommonTree *)t Parent:(CommonTree *)parent ChildIndex:(NSInteger)childIndex Map:(Map *)labels;

@property NSInteger action;
@property (retain) id actor;
@property (retain) id object1;
@property (retain) id object2;
@end

/** When using %label:TOKENNAME in a tree for parse(), we must
 *  track the label.
 */
@interface TreePattern : CommonTree {
    NSString *label;
    BOOL      hasTextArg;
}
@property (retain, getter=getLabel, setter=setLabel:) NSString *label;
@property (assign, getter=getHasTextArg, setter=setHasTextArg:) BOOL hasTextArg;

+ (CommonTree *)newTreePattern:(id<Token>)payload;

- (id) initWithToken:(id<Token>)payload;
- (NSString *)toString;
@end

@interface ANTLRWildcardTreePattern : TreePattern {
}

+ (ANTLRWildcardTreePattern *)newANTLRWildcardTreePattern:(id<Token>)payload;
- (id) initWithToken:(id<Token>)payload;
@end

/** This adaptor creates TreePattern objects for use during scan() */
@interface TreePatternTreeAdaptor : CommonTreeAdaptor {
}
+ (TreePatternTreeAdaptor *)newTreeAdaptor;
- (id) init;
- (CommonTree *)createTreePattern:(id<Token>)payload;

@end

@interface TreeWizard : NSObject {
	id<TreeAdaptor> adaptor;
	Map *tokenNameToTypeMap;
}
+ (TreeWizard *) newTreeWizard:(id<TreeAdaptor>)anAdaptor;
+ (TreeWizard *)newTreeWizard:(id<TreeAdaptor>)adaptor Map:(Map *)aTokenNameToTypeMap;
+ (TreeWizard *)newTreeWizard:(id<TreeAdaptor>)adaptor TokenNames:(NSArray *)theTokNams;
+ (TreeWizard *)newTreeWizardWithTokenNames:(NSArray *)theTokNams;
- (id) init;
- (id) initWithAdaptor:(id<TreeAdaptor>)adaptor;
- (id) initWithAdaptor:(id<TreeAdaptor>)adaptor Map:(Map *)tokenNameToTypeMap;
- (id) initWithTokenNames:(NSArray *)theTokNams;
- (id) initWithTokenNames:(id<TreeAdaptor>)anAdaptor TokenNames:(NSArray *)theTokNams;
- (void) dealloc;
- (Map *)computeTokenTypes:(NSArray *)theTokNams;
- (NSInteger)getTokenType:(NSString *)tokenName;
- (Map *)index:(CommonTree *)t;
- (void) _index:(CommonTree *)t Map:(Map *)m;
- (AMutableArray *)find:(CommonTree *) t Pattern:(NSString *)pattern;
- (TreeWizard *)findFirst:(CommonTree *) t Type:(NSInteger)ttype;
- (TreeWizard *)findFirst:(CommonTree *) t Pattern:(NSString *)pattern;
- (void) visit:(CommonTree *)t Type:(NSInteger)ttype Visitor:(ANTLRVisitor *)visitor;
- (void) _visit:(CommonTree *)t
         Parent:(CommonTree *)parent
     ChildIndex:(NSInteger)childIndex
           Type:(NSInteger)ttype
        Visitor:(ANTLRVisitor *)visitor;
- (void)visit:(CommonTree *)t Pattern:(NSString *)pattern Visitor:(ANTLRVisitor *)visitor;
- (BOOL)parse:(CommonTree *)t Pattern:(NSString *)pattern Map:(Map *)labels;
- (BOOL) parse:(CommonTree *) t Pattern:(NSString *)pattern;
- (BOOL) _parse:(CommonTree *)t1 Pattern:(CommonTree *)tpattern Map:(Map *)labels;
- (CommonTree *) createTree:(NSString *)pattern;
- (BOOL)equals:(id)t1 O2:(id)t2 Adaptor:(id<TreeAdaptor>)anAdaptor;
- (BOOL)equals:(id)t1 O2:(id)t2;
- (BOOL) _equals:(id)t1 O2:(id)t2 Adaptor:(id<TreeAdaptor>)anAdaptor;

@property (retain) id<TreeAdaptor> adaptor;
@property (retain) Map *tokenNameToTypeMap;
@end

