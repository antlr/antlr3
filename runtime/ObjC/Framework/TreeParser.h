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

#import <Foundation/Foundation.h>
#import "BaseRecognizer.h"
#import "TreeNodeStream.h"
#import "CommonTreeAdaptor.h"
#import "MismatchedTreeNodeException.h"

@interface TreeParser : BaseRecognizer {
	id<TreeNodeStream> input;
}

@property (retain, getter=input, setter=setInput:) id<TreeNodeStream> input;

+ (id) newTreeParser:(id<TreeNodeStream>)anInput;
+ (id) newTreeParser:(id<TreeNodeStream>)anInput State:(RecognizerSharedState *)state;

- (id) initWithStream:(id<TreeNodeStream>)theInput;
- (id) initWithStream:(id<TreeNodeStream>)theInput
                State:(RecognizerSharedState *)state;


- (id<TreeNodeStream>)input;
- (void) setInput:(id<TreeNodeStream>)anInput;

- (void) setTreeNodeStream:(id<TreeNodeStream>) anInput;
- (id<TreeNodeStream>) getTreeNodeStream;

- (NSString *)getSourceName;

- (id) getCurrentInputSymbol:(id<IntStream>) anInput;

- (id) getMissingSymbol:(id<IntStream>)input
              Exception:(RecognitionException *) e
          ExpectedToken:(NSInteger) expectedTokenType
                 BitSet:(ANTLRBitSet *)follow;

/** Match '.' in tree parser has special meaning.  Skip node or
 *  entire tree if node has children.  If children, scan until
 *  corresponding UP node.
 */
- (void) matchAny:(id<IntStream>)ignore;

/** We have DOWN/UP nodes in the stream that have no line info; override.
 *  plus we want to alter the exception type.  Don't try to recover
 *  from tree parser errors inline...
 */
- (id) recoverFromMismatchedToken:(id<IntStream>)anInput
                             Type:(NSInteger)ttype
                           Follow:(ANTLRBitSet *)follow;

/** Prefix error message with the grammar name because message is
 *  always intended for the programmer because the parser built
 *  the input tree not the user.
 */
- (NSString *)getErrorHeader:(RecognitionException *)e;

- (NSString *)getErrorMessage:(RecognitionException *)e TokenNames:(AMutableArray *) tokenNames;

- (void) traceIn:(NSString *)ruleName Index:(NSInteger)ruleIndex;
- (void) traceOut:(NSString *)ruleName Index:(NSInteger)ruleIndex;

@end
