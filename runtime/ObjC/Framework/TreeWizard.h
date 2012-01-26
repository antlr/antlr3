//
//  ANTLRTreeWizard.h
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

#import <Cocoa/Cocoa.h>
#import "ANTLRCommonTreeAdaptor.h"
#import "ANTLRCommonTree.h"
#import "ANTLRMapElement.h"
#import "ANTLRMap.h"
#import "AMutableArray.h"

@class ANTLRVisitor;

@protocol ANTLRContextVisitor <NSObject>
// TODO: should this be called visit or something else?
- (void) visit:(ANTLRCommonTree *)t Parent:(ANTLRCommonTree *)parent ChildIndex:(NSInteger)childIndex Map:(ANTLRMap *)labels;

@end

@interface ANTLRVisitor : NSObject <ANTLRContextVisitor> {
    NSInteger action;
    id actor;
    id object1;
    id object2;
}
+ (ANTLRVisitor *)newANTLRVisitor:(NSInteger)anAction Actor:(id)anActor Object:(id)anObject1 Object:(id)anObject2;
- (id) initWithAction:(NSInteger)anAction Actor:(id)anActor Object:(id)anObject1 Object:(id)anObject2;

- (void) visit:(ANTLRCommonTree *)t;
- (void) visit:(ANTLRCommonTree *)t Parent:(ANTLRCommonTree *)parent ChildIndex:(NSInteger)childIndex Map:(ANTLRMap *)labels;

@property NSInteger action;
@property (retain) id actor;
@property (retain) id object1;
@property (retain) id object2;
@end

/** When using %label:TOKENNAME in a tree for parse(), we must
 *  track the label.
 */
@interface ANTLRTreePattern : ANTLRCommonTree {
    NSString *label;
    BOOL      hasTextArg;
}
@property (retain, getter=getLabel, setter=setLabel:) NSString *label;
@property (assign, getter=getHasTextArg, setter=setHasTextArg:) BOOL hasTextArg;

+ (ANTLRCommonTree *)newANTLRTreePattern:(id<ANTLRToken>)payload;

- (id) initWithToken:(id<ANTLRToken>)payload;
- (NSString *)toString;
@end

@interface ANTLRWildcardTreePattern : ANTLRTreePattern {
}

+ (ANTLRWildcardTreePattern *)newANTLRWildcardTreePattern:(id<ANTLRToken>)payload;
- (id) initWithToken:(id<ANTLRToken>)payload;
@end

/** This adaptor creates TreePattern objects for use during scan() */
@interface ANTLRTreePatternTreeAdaptor : ANTLRCommonTreeAdaptor {
}
+ (ANTLRTreePatternTreeAdaptor *)newTreeAdaptor;
- (id) init;
- (ANTLRCommonTree *)createTreePattern:(id<ANTLRToken>)payload;

@end

@interface ANTLRTreeWizard : NSObject {
	id<ANTLRTreeAdaptor> adaptor;
	ANTLRMap *tokenNameToTypeMap;
}
+ (ANTLRTreeWizard *) newANTLRTreeWizard:(id<ANTLRTreeAdaptor>)anAdaptor;
+ (ANTLRTreeWizard *)newANTLRTreeWizard:(id<ANTLRTreeAdaptor>)adaptor Map:(ANTLRMap *)aTokenNameToTypeMap;
+ (ANTLRTreeWizard *)newANTLRTreeWizard:(id<ANTLRTreeAdaptor>)adaptor TokenNames:(NSArray *)theTokNams;
+ (ANTLRTreeWizard *)newANTLRTreeWizardWithTokenNames:(NSArray *)theTokNams;
- (id) init;
- (id) initWithAdaptor:(id<ANTLRTreeAdaptor>)adaptor;
- (id) initWithAdaptor:(id<ANTLRTreeAdaptor>)adaptor Map:(ANTLRMap *)tokenNameToTypeMap;
- (id) initWithTokenNames:(NSArray *)theTokNams;
- (id) initWithTokenNames:(id<ANTLRTreeAdaptor>)anAdaptor TokenNames:(NSArray *)theTokNams;
- (void) dealloc;
- (ANTLRMap *)computeTokenTypes:(NSArray *)theTokNams;
- (NSInteger)getTokenType:(NSString *)tokenName;
- (ANTLRMap *)index:(ANTLRCommonTree *)t;
- (void) _index:(ANTLRCommonTree *)t Map:(ANTLRMap *)m;
- (AMutableArray *)find:(ANTLRCommonTree *) t Pattern:(NSString *)pattern;
- (ANTLRTreeWizard *)findFirst:(ANTLRCommonTree *) t Type:(NSInteger)ttype;
- (ANTLRTreeWizard *)findFirst:(ANTLRCommonTree *) t Pattern:(NSString *)pattern;
- (void) visit:(ANTLRCommonTree *)t Type:(NSInteger)ttype Visitor:(ANTLRVisitor *)visitor;
- (void) _visit:(ANTLRCommonTree *)t
         Parent:(ANTLRCommonTree *)parent
     ChildIndex:(NSInteger)childIndex
           Type:(NSInteger)ttype
        Visitor:(ANTLRVisitor *)visitor;
- (void)visit:(ANTLRCommonTree *)t Pattern:(NSString *)pattern Visitor:(ANTLRVisitor *)visitor;
- (BOOL)parse:(ANTLRCommonTree *)t Pattern:(NSString *)pattern Map:(ANTLRMap *)labels;
- (BOOL) parse:(ANTLRCommonTree *) t Pattern:(NSString *)pattern;
- (BOOL) _parse:(ANTLRCommonTree *)t1 Pattern:(ANTLRCommonTree *)tpattern Map:(ANTLRMap *)labels;
- (ANTLRCommonTree *) createTree:(NSString *)pattern;
- (BOOL)equals:(id)t1 O2:(id)t2 Adaptor:(id<ANTLRTreeAdaptor>)anAdaptor;
- (BOOL)equals:(id)t1 O2:(id)t2;
- (BOOL) _equals:(id)t1 O2:(id)t2 Adaptor:(id<ANTLRTreeAdaptor>)anAdaptor;

@property (retain) id<ANTLRTreeAdaptor> adaptor;
@property (retain) ANTLRMap *tokenNameToTypeMap;
@end

