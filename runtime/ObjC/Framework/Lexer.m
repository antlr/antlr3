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

#import <ANTLR/antlr.h>
#import "ANTLRLexer.h"

@implementation ANTLRLexer

@synthesize input;
@synthesize ruleNestingLevel;
#pragma mark Initializer

- (id) initWithCharStream:(id<ANTLRCharStream>)anInput
{
	self = [super initWithState:[[ANTLRRecognizerSharedState alloc] init]];
	if ( self != nil ) {
        input = [anInput retain];
        if (state.token != nil)
            [((ANTLRCommonToken *)state.token) setInput:anInput];
		ruleNestingLevel = 0;
	}
	return self;
}

- (id) initWithCharStream:(id<ANTLRCharStream>)anInput State:(ANTLRRecognizerSharedState *)aState
{
	self = [super initWithState:aState];
	if ( self != nil ) {
        input = [anInput retain];
        if (state.token != nil)
            [((ANTLRCommonToken *)state.token) setInput:anInput];
		ruleNestingLevel = 0;
	}
	return self;
}

- (void) dealloc
{
    if ( input ) [input release];
    [super dealloc];
}

- (id) copyWithZone:(NSZone *)aZone
{
    ANTLRLexer *copy;
	
    copy = [[[self class] allocWithZone:aZone] init];
    //    copy = [super copyWithZone:aZone]; // allocation occurs here
    if ( input != nil )
        copy.input = input;
    copy.ruleNestingLevel = ruleNestingLevel;
    return copy;
}

- (void) reset
{
    [super reset]; // reset all recognizer state variables
                   // wack Lexer state variables
    if ( input != nil ) {
        [input seek:0]; // rewind the input
    }
    if ( state == nil ) {
        return; // no shared state work to do
    }
    state.token = nil;
    state.type = ANTLRCommonToken.INVALID_TOKEN_TYPE;
    state.channel = ANTLRCommonToken.DEFAULT_CHANNEL;
    state.tokenStartCharIndex = -1;
    state.tokenStartCharPositionInLine = -1;
    state.tokenStartLine = -1;
    state.text = nil;
}

// token stuff
#pragma mark Tokens

- (id<ANTLRToken>)getToken
{
    return [state getToken]; 
}

- (void) setToken: (id<ANTLRToken>) aToken
{
    if (state.token != aToken) {
        [aToken retain];
        state.token = aToken;
    }
}


// this method may be overridden in the generated lexer if we generate a filtering lexer.
- (id<ANTLRToken>) nextToken
{
	while (YES) {
        [self setToken:nil];
        state.channel = ANTLRCommonToken.DEFAULT_CHANNEL;
        state.tokenStartCharIndex = input.index;
        state.tokenStartCharPositionInLine = input.charPositionInLine;
        state.tokenStartLine = input.line;
        state.text = nil;
        
        // [self setText:[self text]];
		if ([input LA:1] == ANTLRCharStreamEOF) {
            ANTLRCommonToken *eof = [ANTLRCommonToken newToken:input
                                                          Type:ANTLRTokenTypeEOF
                                                       Channel:ANTLRCommonToken.DEFAULT_CHANNEL
                                                         Start:input.index
                                                          Stop:input.index];
            [eof setLine:input.line];
            [eof setCharPositionInLine:input.charPositionInLine];
			return eof;
		}
		@try {
			[self mTokens];
            // SEL aMethod = @selector(mTokens);
            // [[self class] instancesRespondToSelector:aMethod];
            if ( state.token == nil)
                [self emit];
            else if ( state.token == [ANTLRCommonToken skipToken] ) {
                continue;
            }
			return state.token;
		}
		@catch (ANTLRNoViableAltException *nva) {
			[self reportError:nva];
			[self recover:nva];
		}
		@catch (ANTLRRecognitionException *e) {
			[self reportError:e];
		}
	}
}

- (void) mTokens
{   // abstract, defined in generated source as a starting point for matching
    [self doesNotRecognizeSelector:_cmd];
}

- (void) skip
{
    state.token = [ANTLRCommonToken skipToken];
}

- (id<ANTLRCharStream>) input
{
    return input; 
}

- (void) setInput:(id<ANTLRCharStream>) anInput
{
    if ( anInput != input ) {
        if ( input ) [input release];
    }
    input = nil;
    [self reset];
    input = anInput;
    [input retain];
}

/** Currently does not support multiple emits per nextToken invocation
 *  for efficiency reasons.  Subclass and override this method and
 *  nextToken (to push tokens into a list and pull from that list rather
 *  than a single variable as this implementation does).
 */
- (void) emit:(id<ANTLRToken>)aToken
{
	state.token = aToken;
}

/** The standard method called to automatically emit a token at the
 *  outermost lexical rule.  The token object should point into the
 *  char buffer start..stop.  If there is a text override in 'text',
 *  use that to set the token's text.  Override this method to emit
 *  custom Token objects.
 *
 *  If you are building trees, then you should also override
 *  Parser or TreeParser.getMissingSymbol().
 */
- (void) emit
{
	id<ANTLRToken> aToken = [ANTLRCommonToken newToken:input
                                                  Type:state.type
                                               Channel:state.channel
                                                 Start:state.tokenStartCharIndex
                                                  Stop:input.index-1];
	[aToken setLine:state.tokenStartLine];
    aToken.text = [self text];
	[aToken setCharPositionInLine:state.tokenStartCharPositionInLine];
    [aToken retain];
	[self emit:aToken];
	// [aToken release];
}

// matching
#pragma mark Matching
- (void) matchString:(NSString *)aString
{
    unichar c;
	unsigned int i = 0;
	unsigned int stringLength = [aString length];
	while ( i < stringLength ) {
		c = [input LA:1];
        if ( c != [aString characterAtIndex:i] ) {
			if ([state getBacktracking] > 0) {
				state.failed = YES;
				return;
			}
			ANTLRMismatchedTokenException *mte = [ANTLRMismatchedTokenException newExceptionChar:[aString characterAtIndex:i] Stream:input];
            mte.c = c;
			[self recover:mte];
			@throw mte;
		}
		i++;
		[input consume];
		state.failed = NO;
	}
}

- (void) matchAny
{
	[input consume];
}

- (void) matchChar:(unichar) aChar
{
	// TODO: -LA: is returning an int because it sometimes is used in the generated parser to compare lookahead with a tokentype.
	//		 try to change all those occurrences to -LT: if possible (i.e. if ANTLR can be made to generate LA only for lexer code)
    unichar charLA;
	charLA = [input LA:1];
	if ( charLA != aChar) {
		if ([state getBacktracking] > 0) {
			state.failed = YES;
			return;
		}
		ANTLRMismatchedTokenException  *mte = [ANTLRMismatchedTokenException newExceptionChar:aChar Stream:input];
        mte.c = charLA;
		[self recover:mte];
		@throw mte;
	}
	[input consume];
	state.failed = NO;
}

- (void) matchRangeFromChar:(unichar)fromChar to:(unichar)toChar
{
	unichar charLA = (unichar)[input LA:1];
	if ( charLA < fromChar || charLA > toChar ) {
		if ([state getBacktracking] > 0) {
			state.failed = YES;
			return;
		}
		ANTLRMismatchedRangeException  *mre = [ANTLRMismatchedRangeException
					newException:NSMakeRange((NSUInteger)fromChar,(NSUInteger)toChar)
							   stream:input];
        mre.c = charLA;
		[self recover:mre];
		@throw mre;
	}		
	[input consume];
	state.failed = NO;
}

	// info
#pragma mark Informational

- (NSUInteger) line
{
	return input.line;
}

- (NSUInteger) charPositionInLine
{
	return input.charPositionInLine;
}

- (NSInteger) index
{
    return 0;
}

- (NSString *) text
{
    if (state.text != nil) {
        return state.text;
    }
	return [input substringWithRange:NSMakeRange(state.tokenStartCharIndex, input.index-state.tokenStartCharIndex)];
}

- (void) setText:(NSString *) theText
{
    state.text = theText;
}

	// error handling
- (void) reportError:(ANTLRRecognitionException *)e
{
    /** TODO: not thought about recovery in lexer yet.
     *
     // if we've already reported an error and have not matched a token
     // yet successfully, don't report any errors.
     if ( errorRecovery ) {
     //System.err.print("[SPURIOUS] ");
     return;
     }
     errorRecovery = true;
     */
    
    [self displayRecognitionError:[self getTokenNames] Exception:e];
}

- (NSString *)getErrorMessage:(ANTLRRecognitionException *)e TokenNames:(AMutableArray *)tokenNames
{
/*    NSString *msg = [NSString stringWithFormat:@"Gotta fix getErrorMessage in ANTLRLexer.m--%@\n",
                     e.name];
 */
    NSString *msg = nil;
    if ( [e isKindOfClass:[ANTLRMismatchedTokenException class]] ) {
        ANTLRMismatchedTokenException *mte = (ANTLRMismatchedTokenException *)e;
        msg = [NSString stringWithFormat:@"mismatched character \"%@\" expecting \"%@\"",
               [self getCharErrorDisplay:mte.c], [self getCharErrorDisplay:mte.expecting]];
    }
    else if ( [e isKindOfClass:[ANTLRNoViableAltException class]] ) {
        ANTLRNoViableAltException *nvae = (ANTLRNoViableAltException *)e;
        // for development, can add "decision=<<"+nvae.grammarDecisionDescription+">>"
        // and "(decision="+nvae.decisionNumber+") and
        // "state "+nvae.stateNumber
        msg = [NSString stringWithFormat:@"no viable alternative at character \"%@\"",
               [self getCharErrorDisplay:(nvae.c)]];
    }
    else if ( [e isKindOfClass:[ANTLREarlyExitException class]] ) {
        ANTLREarlyExitException *eee = (ANTLREarlyExitException *)e;
        // for development, can add "(decision="+eee.decisionNumber+")"
        msg = [NSString stringWithFormat:@"required (...)+ loop did not match anything at character \"%@\"",
               [self getCharErrorDisplay:(eee.c)]];
    }
    else if ( [e isKindOfClass:[ANTLRMismatchedNotSetException class]] ) {
        ANTLRMismatchedNotSetException *mse = (ANTLRMismatchedNotSetException *)e;
        msg = [NSString stringWithFormat:@"mismatched character \"%@\"  expecting set \"%@\"",
               [self getCharErrorDisplay:(mse.c)], mse.expecting];
    }
    else if ( [e isKindOfClass:[ANTLRMismatchedSetException class]] ) {
        ANTLRMismatchedSetException *mse = (ANTLRMismatchedSetException *)e;
        msg = [NSString stringWithFormat:@"mismatched character \"%@\" expecting set \"%@\"",
               [self getCharErrorDisplay:(mse.c)], mse.expecting];
    }
    else if ( [e isKindOfClass:[ANTLRMismatchedRangeException class]] ) {
        ANTLRMismatchedRangeException *mre = (ANTLRMismatchedRangeException *)e;
        msg = [NSString stringWithFormat:@"mismatched character \"%@\" \"%@..%@\"",
               [self getCharErrorDisplay:(mre.c)], [self getCharErrorDisplay:(mre.range.location)],
               [self getCharErrorDisplay:(mre.range.location+mre.range.length-1)]];
    }
    else {
        msg = [super getErrorMessage:e TokenNames:[self getTokenNames]];
    }
    return msg;
}

- (NSString *)getCharErrorDisplay:(NSInteger)c
{
    NSString *s;
    switch ( c ) {
        case ANTLRTokenTypeEOF :
            s = @"<EOF>";
            break;
        case '\n' :
            s = @"\\n";
            break;
        case '\t' :
            s = @"\\t";
            break;
        case '\r' :
            s = @"\\r";
            break;
        default:
            s = [NSString stringWithFormat:@"%c", (char)c];
            break;
    }
    return s;
}

/** Lexers can normally match any char in it's vocabulary after matching
 *  a token, so do the easy thing and just kill a character and hope
 *  it all works out.  You can instead use the rule invocation stack
 *  to do sophisticated error recovery if you are in a fragment rule.
 */
- (void)recover:(ANTLRRecognitionException *)re
{
    //System.out.println("consuming char "+(char)input.LA(1)+" during recovery");
    //re.printStackTrace();
    [input consume];
}

- (void)traceIn:(NSString *)ruleName Index:(NSInteger)ruleIndex
{
    NSString *inputSymbol = [NSString stringWithFormat:@"%c line=%d:%d\n", [input LT:1], input.line, input.charPositionInLine];
    [super traceIn:ruleName Index:ruleIndex Object:inputSymbol];
}

- (void)traceOut:(NSString *)ruleName Index:(NSInteger)ruleIndex
{
    NSString *inputSymbol = [NSString stringWithFormat:@"%c line=%d:%d\n", [input LT:1], input.line, input.charPositionInLine];
    [super traceOut:ruleName Index:ruleIndex Object:inputSymbol];
}

@end
