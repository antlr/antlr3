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

#import "TreeParser.h"

@implementation TreeParser

@synthesize input;

+ (id) newTreeParser:(id<TreeNodeStream>)anInput
{
    return [[TreeParser alloc] initWithStream:anInput];
}

+ (id) newTreeParser:(id<TreeNodeStream>)anInput State:(RecognizerSharedState *)theState
{
    return [[TreeParser alloc] initWithStream:anInput State:theState];
}

- (id) initWithStream:(id<TreeNodeStream>)theInput
{
	if ((self = [super init]) != nil) {
		[self setInput:theInput];
	}
	return self;
}

- (id) initWithStream:(id<TreeNodeStream>)theInput State:(RecognizerSharedState *)theState
{
	if ((self = [super init]) != nil) {
		[self setInput:theInput];
        state = theState;
	}
	return self;
}

- (void) dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in TreeParser" );
#endif
	if ( input ) [input release];
	[super dealloc];
}

- (void) reset
{
    [super reset]; // reset all recognizer state variables
    if ( input != nil ) {
        [input seek:0]; // rewind the input
    }
}

- (void) mismatch:(id<IntStream>)aStream tokenType:(TokenType)aTType follow:(ANTLRBitSet *)aBitset
{
	MismatchedTreeNodeException *mte = [MismatchedTreeNodeException newException:aTType Stream:aStream];
    [mte setNode:[((id<TreeNodeStream>)aStream) LT:1]];
	[self recoverFromMismatchedToken:aStream Type:aTType Follow:aBitset];
}

- (void) setTreeNodeStream:(id<TreeNodeStream>) anInput
{
    input = anInput;
}

- (id<TreeNodeStream>) getTreeNodeStream
{
    return input;
}

- (NSString *)getSourceName
{
    return [input getSourceName];
}

- (id) getCurrentInputSymbol:(id<IntStream>) anInput
{
    return [(id<TreeNodeStream>)anInput LT:1];
}

- (id) getMissingSymbol:(id<IntStream>)anInput
              Exception:(RecognitionException *)e
          ExpectedToken:(NSInteger)expectedTokenType
                 BitSet:(ANTLRBitSet *)follow
{
    NSString *tokenText =[NSString stringWithFormat:@"<missing %@ %d>", [self getTokenNames], expectedTokenType];
    //id<TreeAdaptor> anAdaptor = (id<TreeAdaptor>)[((id<TreeNodeStream>)e.input) getTreeAdaptor];
    //return [anAdaptor createToken:expectedTokenType Text:tokenText];
    return [CommonToken newToken:expectedTokenType Text:tokenText];
}

/** Match '.' in tree parser has special meaning.  Skip node or
 *  entire tree if node has children.  If children, scan until
 *  corresponding UP node.
 */
- (void) matchAny:(id<IntStream>)ignore
{ // ignore stream, copy of input
    state.errorRecovery = NO;
    state.failed = NO;
    id look = [input LT:1];
    if ( [((CommonTreeAdaptor *)[input getTreeAdaptor]) getChildCount:look] == 0) {
        [input consume]; // not subtree, consume 1 node and return
        return;
    }
    // current node is a subtree, skip to corresponding UP.
    // must count nesting level to get right UP
    int level=0;
    int tokenType = [((id<TreeAdaptor>)[input getTreeAdaptor]) getType:look];
    while ( tokenType != TokenTypeEOF && !( tokenType == TokenTypeUP && level == 0) ) {
        [input consume];
        look = [input LT:1];
        tokenType = [((id<TreeAdaptor>)[input getTreeAdaptor]) getType:look];
        if ( tokenType == TokenTypeDOWN ) {
            level++;
        }
        else if ( tokenType == TokenTypeUP ) {
            level--;
        }
    }
    [input consume]; // consume UP
}

/** We have DOWN/UP nodes in the stream that have no line info; override.
 *  plus we want to alter the exception type.  Don't try to recover
 *  from tree parser errors inline...
 */
- (id) recoverFromMismatchedToken:(id<IntStream>)anInput Type:(NSInteger)ttype Follow:(ANTLRBitSet *)follow
{
    @throw [MismatchedTreeNodeException newException:ttype Stream:anInput];
}

/** Prefix error message with the grammar name because message is
 *  always intended for the programmer because the parser built
 *  the input tree not the user.
 */
- (NSString *)getErrorHeader:(RecognitionException *)e
{
     return [NSString stringWithFormat:@"%@: node after line %@:%@",
            [self getGrammarFileName], e.line, e.charPositionInLine];
}

/** Tree parsers parse nodes they usually have a token object as
 *  payload. Set the exception token and do the default behavior.
 */
- (NSString *)getErrorMessage:(RecognitionException *)e  TokenNames:(AMutableArray *) theTokNams
{
    if ( [self isKindOfClass:[TreeParser class]] ) {
        CommonTreeAdaptor *adaptor = (CommonTreeAdaptor *)[((id<TreeNodeStream>)e.input) getTreeAdaptor];
        e.token = [adaptor getToken:((CommonTree *)e.node)];
        if ( e.token == nil ) { // could be an UP/DOWN node
            e.token = [CommonToken newToken:[adaptor getType:(CommonTree *)e.node]
                                                        Text:[adaptor getText:(CommonTree *)e.node]];
        }
    }
    return [super getErrorMessage:e TokenNames:theTokNams];
}

- (void) traceIn:(NSString *)ruleName Index:(NSInteger)ruleIndex
{
    [super traceIn:ruleName Index:ruleIndex Object:[input LT:1]];
}

- (void) traceOut:(NSString *)ruleName Index:(NSInteger)ruleIndex
{
    [super traceOut:ruleName Index:ruleIndex  Object:[input LT:1]];
}


@end
