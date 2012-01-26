//
//  ANTLRMapElement.h
//  ANTLR
//
//  Created by Alan Condit on 6/8/10.
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
#import "ANTLRBaseMapElement.h"

@interface ANTLRMapElement : ANTLRBaseMapElement {
    NSString *name;
    id        node;
}
@property (retain, getter=getName, setter=setName:) NSString *name;
@property (retain, getter=getNode, setter=setNode:) id node;

+ (id) newANTLRMapElement;
+ (id) newANTLRMapElementWithName:(NSString *)aName Type:(NSInteger)aTType;
+ (id) newANTLRMapElementWithNode:(NSInteger)aTType Node:(id)aNode;
+ (id) newANTLRMapElementWithName:(NSString *)aName Node:(id)aNode;
+ (id) newANTLRMapElementWithObj1:(id)anObj1 Obj2:(id)anObj2;
- (id) init;
- (id) initWithName:(NSString *)aName Type:(NSInteger)aTType;
- (id) initWithNode:(NSInteger)aTType Node:(id)aNode;
- (id) initWithName:(NSString *)aName Node:(id)aNode;
- (id) initWithObj1:(id)anObj1 Obj2:(id)anObj2;

- (id) copyWithZone:(NSZone *)aZone;

- (NSInteger) count;
- (NSInteger) size;
- (NSString *)getName;
- (void)setName:(NSString *)aName;
- (id)getNode;
- (void)setNode:(id)aNode;
- (void)putNode:(id)aNode;
- (void)putNode:(id)aNode With:(NSInteger)uniqueID;
//- (void)setObject:(id)aNode atIndex:anIndex;

@end
