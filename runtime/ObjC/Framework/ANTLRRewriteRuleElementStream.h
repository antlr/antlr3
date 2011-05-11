// [The "BSD licence"]
// Copyright (c) 2006-2007 Kay Roepke 2010 Alan Condit
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
#import "ANTLRTreeAdaptor.h"

// TODO: this should be separated into stream and enumerator classes
@interface ANTLRRewriteRuleElementStream : NSObject {
    NSInteger cursor;
    BOOL dirty;        ///< indicates whether the stream should return copies of its elements, set to true after a call to -reset
    BOOL isSingleElement;
    id singleElement;
    __strong AMutableArray *elements;
    
    __strong NSString *elementDescription;
    __strong id<ANTLRTreeAdaptor> treeAdaptor;
}

@property (assign) NSInteger cursor;
@property (assign) BOOL dirty;
@property (assign) BOOL isSingleElement;
@property (assign) id singleElement;
@property (assign) AMutableArray *elements;
@property (assign) NSString *elementDescription;
@property (retain) id<ANTLRTreeAdaptor> treeAdaptor;

+ (ANTLRRewriteRuleElementStream*) newANTLRRewriteRuleElementStream:(id<ANTLRTreeAdaptor>)aTreeAdaptor
                                                        description:(NSString *)anElementDescription;
+ (ANTLRRewriteRuleElementStream*) newANTLRRewriteRuleElementStream:(id<ANTLRTreeAdaptor>)aTreeAdaptor
                                                        description:(NSString *)anElementDescription
                                                            element:(id)anElement;
+ (ANTLRRewriteRuleElementStream*) newANTLRRewriteRuleElementStream:(id<ANTLRTreeAdaptor>)aTreeAdaptor
                                                        description:(NSString *)anElementDescription
                                                           elements:(NSArray *)theElements;

- (id) initWithTreeAdaptor:(id<ANTLRTreeAdaptor>)aTreeAdaptor description:(NSString *)anElementDescription;
- (id) initWithTreeAdaptor:(id<ANTLRTreeAdaptor>)aTreeAdaptor description:(NSString *)anElementDescription element:(id)anElement;
- (id) initWithTreeAdaptor:(id<ANTLRTreeAdaptor>)aTreeAdaptor description:(NSString *)anElementDescription elements:(NSArray *)theElements;

- (void)reset;

- (id<ANTLRTreeAdaptor>) getTreeAdaptor;
- (void) setTreeAdaptor:(id<ANTLRTreeAdaptor>)aTreeAdaptor;

- (void) addElement:(id)anElement;
- (NSInteger) size;
 
- (BOOL) hasNext;
- (id<ANTLRBaseTree>) nextTree;
- (id<ANTLRBaseTree>) _next;       // internal: TODO: redesign if necessary. maybe delegate

- (id) copyElement:(id)element;
- (id) toTree:(id)element;

- (NSString *) getDescription;
- (void) setDescription:(NSString *)description;

@end

