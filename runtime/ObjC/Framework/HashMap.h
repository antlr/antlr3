//
//  HashMap.h
//  ANTLR
//
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
#import "LinkBase.h"
#import "MapElement.h"

#define GLOBAL_SCOPE       0
#define LOCAL_SCOPE        1
#define HASHSIZE         101
#define HBUFSIZE      0x2000

@interface HashMap : LinkBase {
    //    TStringPool *fPool;
    NSInteger Scope;
    NSInteger LastHash;
    NSInteger BuffSize;
    NSUInteger count;
    NSUInteger ptr;
    __strong NSMutableData *buffer;
    __strong MapElement **ptrBuffer;
    NSInteger mode;
}

// Contruction/Destruction
+ (id)newHashMap;
+ (id)newHashMapWithLen:(NSInteger)aBuffSize;
- (id)init;
- (id)initWithLen:(NSInteger)aBuffSize;
- (void)dealloc;
- (HashMap *)PushScope:( HashMap **)map;
- (HashMap *)PopScope:( HashMap **)map;

- (NSInteger)count;
- (NSInteger)size;

// Instance Methods
/*    form hash value for string s */
- (NSInteger)hash:(NSString *)s;
/*   look for s in ptrBuffer  */
- (HashMap *)findscope:(int)level;
/*   look for s in ptrBuffer  */
- (id)lookup:(NSString *)s Scope:(int)scope;
/*   look for s in ptrBuffer  */
- (id)install:(MapElement *)sym Scope:(int)scope;
/*   look for s in ptrBuffer  */
- (void)deleteHashMap:(MapElement *)np;
- (int)RemoveSym:(NSString *)s;
- (void)delete_chain:(MapElement *)np;
#ifdef DONTUSEYET
- (int)bld_symtab:(KW_TABLE *)toknams;
#endif
- (MapElement **)getptrBuffer;
- (MapElement *)getptrBufferEntry:(int)idx;
- (void)setptrBuffer:(MapElement *)np Index:(int)idx;
- (NSInteger)getScope;
- (void)setScope:(NSInteger)i;
- (MapElement *)getTType:(NSString *)name;
- (MapElement *)getNameInList:(NSInteger)ttype;
- (void)putNode:(NSString *)name TokenType:(NSInteger)ttype;
- (NSInteger)getMode;
- (void)setMode:(NSInteger)aMode;
- (void) insertObject:(id)aRule atIndex:(NSInteger)idx;
- (id) objectAtIndex:(NSInteger)idx;
- (void) setObject:(id)aRule atIndex:(NSInteger)idx;
- (void)addObject:(id)anObject;
- (MapElement *) getName:(NSString *)aName;
- (void) putName:(NSString *)name Node:(id)aNode;

- (NSEnumerator *)objectEnumerator;
- (BOOL) hasNext;
- (MapElement *)nextObject;

//@property (copy) TStringPool *fPool;
@property (getter=getScope, setter=setScope:) NSInteger Scope;
@property (getter=getLastHash, setter=setLastHash:) NSInteger LastHash;

@property (getter=getMode,setter=setMode:) NSInteger mode;
@property NSInteger BuffSize;
@property (getter=getCount, setter=setCount:) NSUInteger count;
@property (assign) NSUInteger ptr;
@property (retain, getter=getBuffer, setter=setBuffer:) NSMutableData *buffer;
@property (assign, getter=getPtrBuffer, setter=setPtrBuffer:) MapElement **ptrBuffer;
@end
