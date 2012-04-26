//
//  ParseTree.h
//  ANTLR
//
//  Created by Alan Condit on 7/12/10.
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
#import "BaseTree.h"
#import "CommonToken.h"
#import "AMutableArray.h"

@interface ParseTree : BaseTree <BaseTree> {
	__strong id<Token> payload;
	__strong AMutableArray *hiddenTokens;
}
/** A record of the rules used to match a token sequence.  The tokens
 *  end up as the leaves of this tree and rule nodes are the interior nodes.
 *  This really adds no functionality, it is just an alias for CommonTree
 *  that is more meaningful (specific) and holds a String to display for a node.
 */
+ (id<BaseTree>)newParseTree:(id<Token>)label;
- (id)initWithLabel:(id<Token>)label;

- (id<BaseTree>)dupNode;
- (NSInteger)type;
- (NSString *)text;
- (NSInteger)getTokenStartIndex;
- (void)setTokenStartIndex:(NSInteger)index;
- (NSInteger)getTokenStopIndex;
- (void)setTokenStopIndex:(NSInteger)index;
- (NSString *)description;
- (NSString *)toString;
- (NSString *)toStringWithHiddenTokens;
- (NSString *)toInputString;
- (void)_toStringLeaves:(NSMutableString *)buf;

@property (retain) id<Token> payload;
@property (retain) AMutableArray *hiddenTokens;
@end
