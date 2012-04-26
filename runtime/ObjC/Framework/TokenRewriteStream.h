//
//  TokenRewriteStream.h
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

#import <Foundation/Foundation.h>
#import "CommonTokenStream.h"
#import "LinkBase.h"
#import "HashMap.h"
#import "MapElement.h"
#import "TokenSource.h"

// Define the rewrite operation hierarchy

@interface RewriteOperation : CommonTokenStream
{
/** What rwIndex into rewrites List are we? */
NSInteger instructionIndex;
/** Token buffer rwIndex. */
NSInteger rwIndex;
NSString *text;
}

@property (getter=getInstructionIndex, setter=setInstructionIndex:) NSInteger instructionIndex;
@property (assign) NSInteger rwIndex;
@property (retain, getter=text, setter=setText:) NSString *text;

+ (RewriteOperation *) newRewriteOperation:(NSInteger)anIndex Text:(NSString *)text;

- (id) initWithIndex:(NSInteger)anIndex Text:(NSString *)theText;

/** Execute the rewrite operation by possibly adding to the buffer.
 *  Return the rwIndex of the next token to operate on.
 */
- (NSInteger) execute:(NSString *)buf;

- (NSString *)toString;
- (NSInteger) indexOf:(char)aChar inString:(NSString *)aString;
@end

@interface ANTLRInsertBeforeOp : RewriteOperation {
}

+ (ANTLRInsertBeforeOp *) newANTLRInsertBeforeOp:(NSInteger)anIndex Text:(NSString *)theText;
- (id) initWithIndex:(NSInteger)anIndex Text:(NSString *)theText;

@end

/** I'm going to try replacing range from x..y with (y-x)+1 ReplaceOp
 *  instructions.
 */
@interface ANTLRReplaceOp : RewriteOperation {
    NSInteger lastIndex;
}

@property (assign) NSInteger lastIndex;

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


@interface TokenRewriteStream : CommonTokenStream {
/** You may have multiple, named streams of rewrite operations.
 *  I'm calling these things "programs."
 *  Maps String (name) -> rewrite (List)
 */
HashMap *programs;

/** Map String (program name) -> Integer rwIndex */
HashMap *lastRewriteTokenIndexes;
}

@property (retain, getter=getPrograms, setter=setPrograms:) HashMap *programs;
@property (retain, getter=getLastRewriteTokenIndexes, setter=setLastRewriteTokenIndexes:) HashMap *lastRewriteTokenIndexes;

+ (TokenRewriteStream *)newTokenRewriteStream;
+ (TokenRewriteStream *)newTokenRewriteStream:(id<TokenSource>) aTokenSource;
+ (TokenRewriteStream *)newTokenRewriteStream:(id<TokenSource>) aTokenSource Channel:(NSInteger)aChannel;

- (id) init;
- (id)initWithTokenSource:(id<TokenSource>)aTokenSource;
- (id)initWithTokenSource:(id<TokenSource>)aTokenSource Channel:(NSInteger)aChannel;

- (HashMap *)getPrograms;
- (void)setPrograms:(HashMap *)aProgList;

- (void) rollback:(NSInteger)instructionIndex;
- (void) rollback:(NSString *)programName Index:(NSInteger)anInstructionIndex;
- (void) deleteProgram;
- (void) deleteProgram:(NSString *)programName;
- (void) insertAfterToken:(id<Token>)t Text:(NSString *)theText;
- (void) insertAfterIndex:(NSInteger)anIndex Text:(NSString *)theText;
- (void) insertAfterProgNam:(NSString *)programName Index:(NSInteger)anIndex Text:(NSString *)theText;


- (void) insertBeforeToken:(id<Token>)t Text:(NSString *)theText;
- (void) insertBeforeIndex:(NSInteger)anIndex Text:(NSString *)theText;
- (void) insertBeforeProgName:(NSString *)programName Index:(NSInteger)anIndex Text:(NSString *)theText;
- (void) replaceFromIndex:(NSInteger)anIndex Text:(NSString *)theText;
- (void) replaceFromIndex:(NSInteger)from ToIndex:(NSInteger)to Text:(NSString *)theText;
- (void) replaceFromToken:(id<Token>)indexT Text:(NSString *)theText;
- (void) replaceFromToken:(id<Token>)from ToToken:(id<Token>)to Text:(NSString *)theText;
- (void) replaceProgNam:(NSString *)programName Token:(id<Token>)from Token:(id<Token>)to Text:(NSString *)theText;
- (void) replaceProgNam:(NSString *)programName FromIndex:(NSInteger)from ToIndex:(NSInteger)to Text:(NSString *)theText;
- (void) delete:(NSInteger)anIndex;
- (void) delete:(NSInteger)from ToIndex:(NSInteger)to;
- (void) deleteToken:(id<Token>)indexT;
- (void) deleteFromToken:(id<Token>)from ToToken:(id<Token>)to;
- (void) delete:(NSString *)programName FromToken:(id<Token>)from ToToken:(id<Token>)to;
- (void) delete:(NSString *)programName FromIndex:(NSInteger)from ToIndex:(NSInteger)to;
- (NSInteger)getLastRewriteTokenIndex;
- (NSInteger)getLastRewriteTokenIndex:(NSString *)programName;
- (void)setLastRewriteTokenIndex:(NSString *)programName Index:(NSInteger)anInt;
- (HashMap *) getProgram:(NSString *)name;
- (HashMap *) initializeProgram:(NSString *)name;
- (NSString *)toOriginalString;
- (NSString *)toOriginalString:(NSInteger)start End:(NSInteger)end;
- (NSString *)toString;
- (NSString *)toString:(NSString *)programName;
- (NSString *)toStringFromStart:(NSInteger)start ToEnd:(NSInteger)end;
- (NSString *)toString:(NSString *)programName FromStart:(NSInteger)start ToEnd:(NSInteger)end;
- (HashMap *)reduceToSingleOperationPerIndex:(HashMap *)rewrites;
- (HashMap *)getKindOfOps:(HashMap *)rewrites KindOfClass:(Class)kind;
- (HashMap *)getKindOfOps:(HashMap *)rewrites KindOfClass:(Class)kind Index:(NSInteger)before;
- (NSString *)catOpText:(id)a PrevText:(id)b;
- (NSMutableString *)toDebugString;
- (NSMutableString *)toDebugStringFromStart:(NSInteger)start ToEnd:(NSInteger)end;
                    
@end
