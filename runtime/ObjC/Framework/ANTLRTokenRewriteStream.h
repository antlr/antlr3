//
//  ANTLRTokenRewriteStream.h
//  ANTLR
//
//  Created by Alan Condit on 6/19/10.
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
#import "ANTLRCommonTokenStream.h"
#import "ANTLRLinkBase.h"
#import "ANTLRHashMap.h"
#import "ANTLRMapElement.h"
#import "ANTLRTokenSource.h"

// Define the rewrite operation hierarchy

@interface ANTLRRewriteOperation : ANTLRCommonTokenStream
{
/** What index into rewrites List are we? */
NSInteger instructionIndex;
/** Token buffer index. */
NSInteger index;
NSString *text;
}

@property (getter=getInstructionIndex, setter=setInstructionIndex:) NSInteger instructionIndex;
@property (getter=getIndex, setter=setIndex:) NSInteger index;
@property (retain, getter=getText, setter=setText:) NSString *text;

+ (ANTLRRewriteOperation *) newANTLRRewriteOperation:(NSInteger)index Text:(NSString *)text;

- (id) initWithIndex:(NSInteger)anIndex Text:(NSString *)theText;

/** Execute the rewrite operation by possibly adding to the buffer.
 *  Return the index of the next token to operate on.
 */
- (NSInteger) execute:(NSString *)buf;

- (NSString *)toString;
- (NSInteger) indexOf:(char)aChar inString:(NSString *)aString;
@end

@interface ANTLRInsertBeforeOp : ANTLRRewriteOperation {
}

+ (ANTLRInsertBeforeOp *) newANTLRInsertBeforeOp:(NSInteger)anIndex Text:(NSString *)theText;
- (id) initWithIndex:(NSInteger)anIndex Text:(NSString *)theText;

@end

/** I'm going to try replacing range from x..y with (y-x)+1 ReplaceOp
 *  instructions.
 */
@interface ANTLRReplaceOp : ANTLRRewriteOperation {
    NSInteger lastIndex;
}

@property (getter=getLastIndex, setter=setLastIndex:) NSInteger lastIndex;

+ (ANTLRReplaceOp *) newANTLRReplaceOp:(NSInteger)from ToIndex:(NSInteger)to Text:(NSString*)theText;
- (id) initWithIndex:(NSInteger)from ToIndex:(NSInteger)to Text:(NSString *)theText;

- (NSInteger) execute:(NSString *)buf;
- (NSString *)toString;

@end

@interface ANTLRDeleteOp : ANTLRReplaceOp {
}
+ (ANTLRDeleteOp *) newANTLRDeleteOp:(NSInteger)from ToIndex:(NSInteger)to;

- (id) initWithIndex:(NSInteger)from ToIndex:(NSInteger)to;

- (NSString *)toString;

@end


@interface ANTLRTokenRewriteStream : ANTLRCommonTokenStream {
/** You may have multiple, named streams of rewrite operations.
 *  I'm calling these things "programs."
 *  Maps String (name) -> rewrite (List)
 */
ANTLRHashMap *programs;

/** Map String (program name) -> Integer index */
ANTLRHashMap *lastRewriteTokenIndexes;
}

@property (retain, getter=getPrograms, setter=setPrograms:) ANTLRHashMap *programs;
@property (retain, getter=getLastRewriteTokenIndexes, setter=setLastRewriteTokenIndexes:) ANTLRHashMap *lastRewriteTokenIndexes;

+ (ANTLRTokenRewriteStream *)newANTLRTokenRewriteStream;
+ (ANTLRTokenRewriteStream *)newANTLRTokenRewriteStream:(id<ANTLRTokenSource>) aTokenSource;
+ (ANTLRTokenRewriteStream *)newANTLRTokenRewriteStream:(id<ANTLRTokenSource>) aTokenSource Channel:(NSInteger)aChannel;

- (id) init;
- (id)initWithTokenSource:(id<ANTLRTokenSource>)aTokenSource;
- (id)initWithTokenSource:(id<ANTLRTokenSource>)aTokenSource Channel:(NSInteger)aChannel;

- (ANTLRHashMap *)getPrograms;
- (void)setPrograms:(ANTLRHashMap *)aProgList;

- (void) rollback:(NSInteger)instructionIndex;
- (void) rollback:(NSString *)programName Index:(NSInteger)anInstructionIndex;
- (void) deleteProgram;
- (void) deleteProgram:(NSString *)programName;
- (void) insertAfterToken:(id<ANTLRToken>)t Text:(NSString *)theText;
- (void) insertAfterIndex:(NSInteger)anIndex Text:(NSString *)theText;
- (void) insertAfterProgNam:(NSString *)programName Index:(NSInteger)anIndex Text:(NSString *)theText;


- (void) insertBeforeToken:(id<ANTLRToken>)t Text:(NSString *)theText;
- (void) insertBeforeIndex:(NSInteger)anIndex Text:(NSString *)theText;
- (void) insertBeforeProgName:(NSString *)programName Index:(NSInteger)index Text:(NSString *)theText;
- (void) replaceFromIndex:(NSInteger)anIndex Text:(NSString *)theText;
- (void) replaceFromIndex:(NSInteger)from ToIndex:(NSInteger)to Text:(NSString *)theText;
- (void) replaceFromToken:(id<ANTLRToken>)indexT Text:(NSString *)theText;
- (void) replaceFromToken:(id<ANTLRToken>)from ToToken:(id<ANTLRToken>)to Text:(NSString *)theText;
- (void) replaceProgNam:(NSString *)programName Token:(id<ANTLRToken>)from Token:(id<ANTLRToken>)to Text:(NSString *)theText;
- (void) replaceProgNam:(NSString *)programName FromIndex:(NSInteger)from ToIndex:(NSInteger)to Text:(NSString *)theText;
- (void) delete:(NSInteger)anIndex;
- (void) delete:(NSInteger)from ToIndex:(NSInteger)to;
- (void) deleteToken:(id<ANTLRToken>)indexT;
- (void) deleteFromToken:(id<ANTLRToken>)from ToToken:(id<ANTLRToken>)to;
- (void) delete:(NSString *)programName FromToken:(id<ANTLRToken>)from ToToken:(id<ANTLRToken>)to;
- (void) delete:(NSString *)programName FromIndex:(NSInteger)from ToIndex:(NSInteger)to;
- (NSInteger)getLastRewriteTokenIndex;
- (NSInteger)getLastRewriteTokenIndex:(NSString *)programName;
- (void)setLastRewriteTokenIndex:(NSString *)programName Index:(NSInteger)anInt;
- (ANTLRHashMap *) getProgram:(NSString *)name;
- (ANTLRHashMap *) initializeProgram:(NSString *)name;
- (NSString *)toOriginalString;
- (NSString *)toOriginalString:(NSInteger)start End:(NSInteger)end;
- (NSString *)toString;
- (NSString *)toString:(NSString *)programName;
- (NSString *)toStringFromStart:(NSInteger)start ToEnd:(NSInteger)end;
- (NSString *)toString:(NSString *)programName FromStart:(NSInteger)start ToEnd:(NSInteger)end;
- (ANTLRHashMap *)reduceToSingleOperationPerIndex:(ANTLRHashMap *)rewrites;
- (ANTLRHashMap *)getKindOfOps:(ANTLRHashMap *)rewrites KindOfClass:(Class)kind;
- (ANTLRHashMap *)getKindOfOps:(ANTLRHashMap *)rewrites KindOfClass:(Class)kind Index:(NSInteger)before;
- (NSString *)catOpText:(id)a PrevText:(id)b;
- (NSMutableString *)toDebugString;
- (NSMutableString *)toDebugStringFromStart:(NSInteger)start ToEnd:(NSInteger)end;
                    
@end
