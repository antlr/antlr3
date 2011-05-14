//
//  ANTLRBaseRecognizer.m
//  ANTLR
//
//  Created by Alan Condit on 6/16/10.
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

#import "ANTLRBaseRecognizer.h"
#import "ANTLRHashRule.h"
#import "ANTLRRuleMemo.h"
#import "ANTLRCommonToken.h"
#import "ANTLRMap.h"

extern NSInteger debug;

@implementation ANTLRBaseRecognizer

static AMutableArray *_tokenNames;
static NSString *_grammarFileName;
static NSString *NEXT_TOKEN_RULE_NAME;

@synthesize state;
@synthesize grammarFileName;
//@synthesize failed;
@synthesize sourceName;
//@synthesize numberOfSyntaxErrors;
@synthesize tokenNames;

+ (void) initialize
{
    NEXT_TOKEN_RULE_NAME = [NSString stringWithString:@"nextToken"];
    [NEXT_TOKEN_RULE_NAME retain];
}

+ (ANTLRBaseRecognizer *) newANTLRBaseRecognizer
{
    return [[ANTLRBaseRecognizer alloc] init];
}

+ (ANTLRBaseRecognizer *) newANTLRBaseRecognizerWithRuleLen:(NSInteger)aLen
{
    return [[ANTLRBaseRecognizer alloc] initWithLen:aLen];
}

+ (ANTLRBaseRecognizer *) newANTLRBaseRecognizer:(ANTLRRecognizerSharedState *)aState
{
	return [[ANTLRBaseRecognizer alloc] initWithState:aState];
}

+ (AMutableArray *)getTokenNames
{
    return _tokenNames;
}

+ (void)setTokenNames:(AMutableArray *)theTokNams
{
    if ( _tokenNames != theTokNams ) {
        if ( _tokenNames ) [_tokenNames release];
        [theTokNams retain];
    }
    _tokenNames = theTokNams;
}

+ (void)setGrammarFileName:(NSString *)aFileName
{
    if ( _grammarFileName != aFileName ) {
        if ( _grammarFileName ) [_grammarFileName release];
        [aFileName retain];
    }
    [_grammarFileName retain];
}

- (id) init
{
	if ((self = [super init]) != nil) {
        if (state == nil) {
            state = [[ANTLRRecognizerSharedState newANTLRRecognizerSharedState] retain];
        }
        tokenNames = _tokenNames;
        if ( tokenNames ) [tokenNames retain];
        grammarFileName = _grammarFileName;
        if ( grammarFileName ) [grammarFileName retain];
        state._fsp = -1;
        state.errorRecovery = NO;		// are we recovering?
        state.lastErrorIndex = -1;
        state.failed = NO;				// indicate that some match failed
        state.syntaxErrors = 0;
        state.backtracking = 0;			// the level of backtracking
        state.tokenStartCharIndex = -1;
	}
	return self;
}

- (id) initWithLen:(NSInteger)aLen
{
	if ((self = [super init]) != nil) {
        if (state == nil) {
            state = [[ANTLRRecognizerSharedState newANTLRRecognizerSharedStateWithRuleLen:aLen] retain];
        }
        tokenNames = _tokenNames;
        if ( tokenNames ) [tokenNames retain];
        grammarFileName = _grammarFileName;
        if ( grammarFileName ) [grammarFileName retain];
        state._fsp = -1;
        state.errorRecovery = NO;		// are we recovering?
        state.lastErrorIndex = -1;
        state.failed = NO;				// indicate that some match failed
        state.syntaxErrors = 0;
        state.backtracking = 0;			// the level of backtracking
        state.tokenStartCharIndex = -1;
	}
	return self;
}

- (id) initWithState:(ANTLRRecognizerSharedState *)aState
{
	if ((self = [super init]) != nil) {
		state = aState;
        if (state == nil) {
            state = [ANTLRRecognizerSharedState newANTLRRecognizerSharedState];
        }
        [state retain];
        tokenNames = _tokenNames;
        if ( tokenNames ) [tokenNames retain];
        grammarFileName = _grammarFileName;
        if ( grammarFileName ) [grammarFileName retain];
        state._fsp = -1;
        state.errorRecovery = NO;		// are we recovering?
        state.lastErrorIndex = -1;
        state.failed = NO;				// indicate that some match failed
        state.syntaxErrors = 0;
        state.backtracking = 0;			// the level of backtracking
        state.tokenStartCharIndex = -1;
	}
	return self;
}

- (void)dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in ANTLRBaseRecognizer" );
#endif
	if ( grammarFileName ) [grammarFileName release];
	if ( tokenNames ) [tokenNames release];
	if ( state ) [state release];
	[super dealloc];
}

// reset the recognizer to the initial state. does not touch the token source!
// this can be extended by the grammar writer to reset custom ivars
- (void) reset
{
    if ( state == nil )
        return; 
    if ( state.following != nil ) {
        if ( [state.following count] )
            [state.following removeAllObjects];
    }
    state._fsp = -1;
    state.errorRecovery = NO;		// are we recovering?
    state.lastErrorIndex = -1;
    state.failed = NO;				// indicate that some match failed
    state.syntaxErrors = 0;
    state.backtracking = 0;			// the level of backtracking
    state.tokenStartCharIndex = -1;
    if ( state.ruleMemo != nil ) {
        if ( [state.ruleMemo count] )
            [state.ruleMemo removeAllObjects];
    }
}

- (BOOL) getFailed
{
	return [state getFailed];
}

- (void) setFailed:(BOOL)flag
{
	[state setFailed:flag];
}

- (ANTLRRecognizerSharedState *) getState
{
	return state;
}

- (void) setState:(ANTLRRecognizerSharedState *) theState
{
	if (state != theState) {
		if ( state ) [state release];
		state = theState;
		[state retain];
	}
}

- (id)input
{
    return nil; // Must be overriden in inheriting class
}

- (void)skip // override in inheriting class
{
    return;
}

-(id) match:(id<ANTLRIntStream>)anInput TokenType:(NSInteger)ttype Follow:(ANTLRBitSet *)follow
{
	id matchedSymbol = [self getCurrentInputSymbol:anInput];
	if ([anInput LA:1] == ttype) {
		[anInput consume];
		state.errorRecovery = NO;
		state.failed = NO;
		return matchedSymbol;
	}
	if (state.backtracking > 0) {
		state.failed = YES;
		return matchedSymbol;
	}
	matchedSymbol = [self recoverFromMismatchedToken:anInput TokenType:ttype Follow:follow];
	return matchedSymbol;
}

-(void) matchAny:(id<ANTLRIntStream>)anInput
{
    state.errorRecovery = NO;
    state.failed = NO;
    [anInput consume];
}

-(BOOL) mismatchIsUnwantedToken:(id<ANTLRIntStream>)anInput TokenType:(NSInteger)ttype
{
    return [anInput LA:2] == ttype;
}

-(BOOL) mismatchIsMissingToken:(id<ANTLRIntStream>)anInput Follow:(ANTLRBitSet *) follow
{
    if ( follow == nil ) {
        // we have no information about the follow; we can only consume
        // a single token and hope for the best
        return NO;
    }
    // compute what can follow this grammar element reference
    if ( [follow member:ANTLRTokenTypeEOR] ) {
        ANTLRBitSet *viableTokensFollowingThisRule = [self computeContextSensitiveRuleFOLLOW];
        follow = [follow or:viableTokensFollowingThisRule];
        if ( state._fsp >= 0 ) { // remove EOR if we're not the start symbol
            [follow remove:(ANTLRTokenTypeEOR)];
        }
    }
    // if current token is consistent with what could come after set
    // then we know we're missing a token; error recovery is free to
    // "insert" the missing token
    
    //System.out.println("viable tokens="+follow.toString(getTokenNames()));
    //System.out.println("LT(1)="+((TokenStream)input).LT(1));
    
    // BitSet cannot handle negative numbers like -1 (EOF) so I leave EOR
    // in follow set to indicate that the fall of the start symbol is
    // in the set (EOF can follow).
    if ( [follow member:[anInput LA:1]] || [follow member:ANTLRTokenTypeEOR] ) {
        //System.out.println("LT(1)=="+((TokenStream)input).LT(1)+" is consistent with what follows; inserting...");
        return YES;
    }
    return NO;
}

/** Report a recognition problem.
 *
 *  This method sets errorRecovery to indicate the parser is recovering
 *  not parsing.  Once in recovery mode, no errors are generated.
 *  To get out of recovery mode, the parser must successfully match
 *  a token (after a resync).  So it will go:
 *
 * 		1. error occurs
 * 		2. enter recovery mode, report error
 * 		3. consume until token found in resynch set
 * 		4. try to resume parsing
 * 		5. next match() will reset errorRecovery mode
 *
 *  If you override, make sure to update syntaxErrors if you care about that.
 */
-(void) reportError:(ANTLRRecognitionException *) e
{
    // if we've already reported an error and have not matched a token
    // yet successfully, don't report any errors.
    if ( state.errorRecovery ) {
        //System.err.print("[SPURIOUS] ");
        return;
    }
    state.syntaxErrors++; // don't count spurious
    state.errorRecovery = YES;
    
    [self displayRecognitionError:[self getTokenNames] Exception:e];
}

-(void) displayRecognitionError:(AMutableArray *)theTokNams Exception:(ANTLRRecognitionException *)e
{
    NSString *hdr = [self getErrorHeader:e];
    NSString *msg = [self getErrorMessage:e TokenNames:theTokNams];
    [self emitErrorMessage:[NSString stringWithFormat:@" %@ %@", hdr, msg]];
}

/** What error message should be generated for the various
 *  exception types?
 *
 *  Not very object-oriented code, but I like having all error message
 *  generation within one method rather than spread among all of the
 *  exception classes. This also makes it much easier for the exception
 *  handling because the exception classes do not have to have pointers back
 *  to this object to access utility routines and so on. Also, changing
 *  the message for an exception type would be difficult because you
 *  would have to subclassing exception, but then somehow get ANTLR
 *  to make those kinds of exception objects instead of the default.
 *  This looks weird, but trust me--it makes the most sense in terms
 *  of flexibility.
 *
 *  For grammar debugging, you will want to override this to add
 *  more information such as the stack frame with
 *  getRuleInvocationStack(e, this.getClass().getName()) and,
 *  for no viable alts, the decision description and state etc...
 *
 *  Override this to change the message generated for one or more
 *  exception types.
 */
- (NSString *)getErrorMessage:(ANTLRRecognitionException *)e TokenNames:(AMutableArray *)theTokNams
{
    // NSString *msg = [e getMessage];
    NSString *msg;
    if ( [e isKindOfClass:[ANTLRUnwantedTokenException class]] ) {
        ANTLRUnwantedTokenException *ute = (ANTLRUnwantedTokenException *)e;
        NSString *tokenName=@"<unknown>";
        if ( ute.expecting == ANTLRTokenTypeEOF ) {
            tokenName = @"EOF";
        }
        else {
            tokenName = (NSString *)[theTokNams objectAtIndex:ute.expecting];
        }
        msg = [NSString stringWithFormat:@"extraneous input %@ expecting %@", [self getTokenErrorDisplay:[ute getUnexpectedToken]],
               tokenName];
    }
    else if ( [e isKindOfClass:[ANTLRMissingTokenException class] ] ) {
        ANTLRMissingTokenException *mte = (ANTLRMissingTokenException *)e;
        NSString *tokenName=@"<unknown>";
        if ( mte.expecting== ANTLRTokenTypeEOF ) {
            tokenName = @"EOF";
        }
        else {
            tokenName = [theTokNams objectAtIndex:mte.expecting];
        }
        msg = [NSString stringWithFormat:@"missing %@ at %@", tokenName, [self getTokenErrorDisplay:(e.token)] ];
    }
    else if ( [e isKindOfClass:[ANTLRMismatchedTokenException class]] ) {
        ANTLRMismatchedTokenException *mte = (ANTLRMismatchedTokenException *)e;
        NSString *tokenName=@"<unknown>";
        if ( mte.expecting== ANTLRTokenTypeEOF ) {
            tokenName = @"EOF";
        }
        else {
            tokenName = [theTokNams objectAtIndex:mte.expecting];
        }
        msg = [NSString stringWithFormat:@"mismatched input %@ expecting %@",[self getTokenErrorDisplay:(e.token)], tokenName];
    }
    else if ( [e isKindOfClass:[ANTLRMismatchedTreeNodeException class]] ) {
        ANTLRMismatchedTreeNodeException *mtne = (ANTLRMismatchedTreeNodeException *)e;
        NSString *tokenName=@"<unknown>";
        if ( mtne.expecting==ANTLRTokenTypeEOF ) {
            tokenName = @"EOF";
        }
        else {
            tokenName = [theTokNams objectAtIndex:mtne.expecting];
        }
        msg = [NSString stringWithFormat:@"mismatched tree node: %@ expecting %@", mtne.node, tokenName];
    }
    else if ( [e isKindOfClass:[ANTLRNoViableAltException class]] ) {
        //NoViableAltException *nvae = (NoViableAltException *)e;
        // for development, can add "decision=<<"+nvae.grammarDecisionDescription+">>"
        // and "(decision="+nvae.decisionNumber+") and
        // "state "+nvae.stateNumber
        msg = [NSString stringWithFormat:@"no viable alternative at input %@", [self getTokenErrorDisplay:e.token]];
    }
    else if ( [e isKindOfClass:[ANTLREarlyExitException class]] ) {
        //ANTLREarlyExitException *eee = (ANTLREarlyExitException *)e;
        // for development, can add "(decision="+eee.decisionNumber+")"
        msg =[NSString stringWithFormat: @"required (...)+ loop did not match anything at input ", [self getTokenErrorDisplay:e.token]];
    }
    else if ( [e isKindOfClass:[ANTLRMismatchedSetException class]] ) {
        ANTLRMismatchedSetException *mse = (ANTLRMismatchedSetException *)e;
        msg = [NSString stringWithFormat:@"mismatched input %@ expecting set %@",
               [self getTokenErrorDisplay:(e.token)],
               mse.expecting];
    }
#pragma warning NotSet not yet implemented.
    else if ( [e isKindOfClass:[ANTLRMismatchedNotSetException class] ] ) {
        ANTLRMismatchedNotSetException *mse = (ANTLRMismatchedNotSetException *)e;
        msg = [NSString stringWithFormat:@"mismatched input %@ expecting set %@",
               [self getTokenErrorDisplay:(e.token)],
               mse.expecting];
    }
    else if ( [e isKindOfClass:[ANTLRFailedPredicateException class]] ) {
        ANTLRFailedPredicateException *fpe = (ANTLRFailedPredicateException *)e;
        msg = [NSString stringWithFormat:@"rule %@ failed predicate: { %@ }?", fpe.ruleName, fpe.predicate];
    }
    else {
        msg = [NSString stringWithFormat:@"Exception= %@\n", e.name];
    }
    return msg;
}

/** Get number of recognition errors (lexer, parser, tree parser).  Each
 *  recognizer tracks its own number.  So parser and lexer each have
 *  separate count.  Does not count the spurious errors found between
 *  an error and next valid token match
 *
 *  See also reportError()
 */
- (NSInteger) getNumberOfSyntaxErrors
{
    return state.syntaxErrors;
}

/** What is the error header, normally line/character position information? */
- (NSString *)getErrorHeader:(ANTLRRecognitionException *)e
{
    return [NSString stringWithFormat:@"line %d:%d", e.line, e.charPositionInLine];
}

/** How should a token be displayed in an error message? The default
 *  is to display just the text, but during development you might
 *  want to have a lot of information spit out.  Override in that case
 *  to use t.toString() (which, for CommonToken, dumps everything about
 *  the token). This is better than forcing you to override a method in
 *  your token objects because you don't have to go modify your lexer
 *  so that it creates a new Java type.
 */
- (NSString *)getTokenErrorDisplay:(id<ANTLRToken>)t
{
    NSString *s = t.text;
    if ( s == nil ) {
        if ( t.type == ANTLRTokenTypeEOF ) {
            s = @"<EOF>";
        }
        else {
            s = [NSString stringWithFormat:@"<%@>", t.type];
        }
    }
    s = [s stringByReplacingOccurrencesOfString:@"\n" withString:@"\\\\n"];
    s = [s stringByReplacingOccurrencesOfString:@"\r" withString:@"\\\\r"];
    s = [s stringByReplacingOccurrencesOfString:@"\t" withString:@"\\\\t"];
    return [NSString stringWithFormat:@"\'%@\'", s];
}
                                        
/** Override this method to change where error messages go */
- (void) emitErrorMessage:(NSString *) msg
{
//    System.err.println(msg);
    NSLog(@"%@", msg);
}

/** Recover from an error found on the input stream.  This is
 *  for NoViableAlt and mismatched symbol exceptions.  If you enable
 *  single token insertion and deletion, this will usually not
 *  handle mismatched symbol exceptions but there could be a mismatched
 *  token that the match() routine could not recover from.
 */
- (void)recover:(id<ANTLRIntStream>)anInput Exception:(ANTLRRecognitionException *)re
{
    if ( state.lastErrorIndex == anInput.index ) {
        // uh oh, another error at same token index; must be a case
        // where LT(1) is in the recovery token set so nothing is
        // consumed; consume a single token so at least to prevent
        // an infinite loop; this is a failsafe.
        [anInput consume];
    }
    state.lastErrorIndex = anInput.index;
    ANTLRBitSet *followSet = [self computeErrorRecoverySet];
    [self beginResync];
    [self consumeUntilFollow:anInput Follow:followSet];
    [self endResync];
}

- (void) beginResync
{
    
}

- (void) endResync
{
    
}
                            
/*  Compute the error recovery set for the current rule.  During
 *  rule invocation, the parser pushes the set of tokens that can
 *  follow that rule reference on the stack; this amounts to
 *  computing FIRST of what follows the rule reference in the
 *  enclosing rule. This local follow set only includes tokens
 *  from within the rule; i.e., the FIRST computation done by
 *  ANTLR stops at the end of a rule.
 *
 *  EXAMPLE
 *
 *  When you find a "no viable alt exception", the input is not
 *  consistent with any of the alternatives for rule r.  The best
 *  thing to do is to consume tokens until you see something that
 *  can legally follow a call to r *or* any rule that called r.
 *  You don't want the exact set of viable next tokens because the
 *  input might just be missing a token--you might consume the
 *  rest of the input looking for one of the missing tokens.
 *
 *  Consider grammar:
 *
 *  a : '[' b ']'
 *    | '(' b ')'
 *    ;
 *  b : c '^' INT ;
 *  c : ID
 *    | INT
 *    ;
 *
 *  At each rule invocation, the set of tokens that could follow
 *  that rule is pushed on a stack.  Here are the various "local"
 *  follow sets:
 *
 *  FOLLOW(b1_in_a) = FIRST(']') = ']'
 *  FOLLOW(b2_in_a) = FIRST(')') = ')'
 *  FOLLOW(c_in_b) = FIRST('^') = '^'
 *
 *  Upon erroneous input "[]", the call chain is
 *
 *  a -> b -> c
 *
 *  and, hence, the follow context stack is:
 *
 *  depth  local follow set     after call to rule
 *    0         <EOF>                    a (from main())
 *    1          ']'                     b
 *    3          '^'                     c
 *
 *  Notice that ')' is not included, because b would have to have
 *  been called from a different context in rule a for ')' to be
 *  included.
 *
 *  For error recovery, we cannot consider FOLLOW(c)
 *  (context-sensitive or otherwise).  We need the combined set of
 *  all context-sensitive FOLLOW sets--the set of all tokens that
 *  could follow any reference in the call chain.  We need to
 *  resync to one of those tokens.  Note that FOLLOW(c)='^' and if
 *  we resync'd to that token, we'd consume until EOF.  We need to
 *  sync to context-sensitive FOLLOWs for a, b, and c: {']','^'}.
 *  In this case, for input "[]", LA(1) is in this set so we would
 *  not consume anything and after printing an error rule c would
 *  return normally.  It would not find the required '^' though.
 *  At this point, it gets a mismatched token error and throws an
 *  exception (since LA(1) is not in the viable following token
 *  set).  The rule exception handler tries to recover, but finds
 *  the same recovery set and doesn't consume anything.  Rule b
 *  exits normally returning to rule a.  Now it finds the ']' (and
 *  with the successful match exits errorRecovery mode).
 *
 *  So, you cna see that the parser walks up call chain looking
 *  for the token that was a member of the recovery set.
 *
 *  Errors are not generated in errorRecovery mode.
 *
 *  ANTLR's error recovery mechanism is based upon original ideas:
 *
 *  "Algorithms + Data Structures = Programs" by Niklaus Wirth
 *
 *  and
 *
 *  "A note on error recovery in recursive descent parsers":
 *  http://portal.acm.org/citation.cfm?id=947902.947905
 *
 *  Later, Josef Grosch had some good ideas:
 *
 *  "Efficient and Comfortable Error Recovery in Recursive Descent
 *  Parsers":
 *  ftp://www.cocolab.com/products/cocktail/doca4.ps/ell.ps.zip
 *
 *  Like Grosch I implemented local FOLLOW sets that are combined
 *  at run-time upon error to avoid overhead during parsing.
 */
- (ANTLRBitSet *) computeErrorRecoverySet
{
    return [self combineFollows:NO];
}

/** Compute the context-sensitive FOLLOW set for current rule.
 *  This is set of token types that can follow a specific rule
 *  reference given a specific call chain.  You get the set of
 *  viable tokens that can possibly come next (lookahead depth 1)
 *  given the current call chain.  Contrast this with the
 *  definition of plain FOLLOW for rule r:
 *
 *   FOLLOW(r)={x | S=>*alpha r beta in G and x in FIRST(beta)}
 *
 *  where x in T* and alpha, beta in V*; T is set of terminals and
 *  V is the set of terminals and nonterminals.  In other words,
 *  FOLLOW(r) is the set of all tokens that can possibly follow
 *  references to r in *any* sentential form (context).  At
 *  runtime, however, we know precisely which context applies as
 *  we have the call chain.  We may compute the exact (rather
 *  than covering superset) set of following tokens.
 *
 *  For example, consider grammar:
 *
 *  stat : ID '=' expr ';'      // FOLLOW(stat)=={EOF}
 *       | "return" expr '.'
 *       ;
 *  expr : atom ('+' atom)* ;   // FOLLOW(expr)=={';','.',')'}
 *  atom : INT                  // FOLLOW(atom)=={'+',')',';','.'}
 *       | '(' expr ')'
 *       ;
 *
 *  The FOLLOW sets are all inclusive whereas context-sensitive
 *  FOLLOW sets are precisely what could follow a rule reference.
 *  For input input "i=(3);", here is the derivation:
 *
 *  stat => ID '=' expr ';'
 *       => ID '=' atom ('+' atom)* ';'
 *       => ID '=' '(' expr ')' ('+' atom)* ';'
 *       => ID '=' '(' atom ')' ('+' atom)* ';'
 *       => ID '=' '(' INT ')' ('+' atom)* ';'
 *       => ID '=' '(' INT ')' ';'
 *
 *  At the "3" token, you'd have a call chain of
 *
 *    stat -> expr -> atom -> expr -> atom
 *
 *  What can follow that specific nested ref to atom?  Exactly ')'
 *  as you can see by looking at the derivation of this specific
 *  input.  Contrast this with the FOLLOW(atom)={'+',')',';','.'}.
 *
 *  You want the exact viable token set when recovering from a
 *  token mismatch.  Upon token mismatch, if LA(1) is member of
 *  the viable next token set, then you know there is most likely
 *  a missing token in the input stream.  "Insert" one by just not
 *  throwing an exception.
 */
- (ANTLRBitSet *)computeContextSensitiveRuleFOLLOW
{
    return [self combineFollows:YES];
}

// what is exact? it seems to only add sets from above on stack
// if EOR is in set i.  When it sees a set w/o EOR, it stops adding.
// Why would we ever want them all?  Maybe no viable alt instead of
// mismatched token?
- (ANTLRBitSet *)combineFollows:(BOOL) exact
{
    NSInteger top = state._fsp;
    ANTLRBitSet *followSet = [[ANTLRBitSet newANTLRBitSet] retain];
    for (int i = top; i >= 0; i--) {
        ANTLRBitSet *localFollowSet = (ANTLRBitSet *)[state.following objectAtIndex:i];
        /*
         System.out.println("local follow depth "+i+"="+
         localFollowSet.toString(getTokenNames())+")");
         */
        [followSet orInPlace:localFollowSet];
        if ( exact ) {
            // can we see end of rule?
            if ( [localFollowSet member:ANTLRTokenTypeEOR] ) {
                // Only leave EOR in set if at top (start rule); this lets
                // us know if have to include follow(start rule); i.e., EOF
                if ( i > 0 ) {
                    [followSet remove:ANTLRTokenTypeEOR];
                }
            }
            else { // can't see end of rule, quit
                break;
            }
        }
    }
    return followSet;
}

/** Attempt to recover from a single missing or extra token.
 *
 *  EXTRA TOKEN
 *
 *  LA(1) is not what we are looking for.  If LA(2) has the right token,
 *  however, then assume LA(1) is some extra spurious token.  Delete it
 *  and LA(2) as if we were doing a normal match(), which advances the
 *  input.
 *
 *  MISSING TOKEN
 *
 *  If current token is consistent with what could come after
 *  ttype then it is ok to "insert" the missing token, else throw
 *  exception For example, Input "i=(3;" is clearly missing the
 *  ')'.  When the parser returns from the nested call to expr, it
 *  will have call chain:
 *
 *    stat -> expr -> atom
 *
 *  and it will be trying to match the ')' at this point in the
 *  derivation:
 *
 *       => ID '=' '(' INT ')' ('+' atom)* ';'
 *                          ^
 *  match() will see that ';' doesn't match ')' and report a
 *  mismatched token error.  To recover, it sees that LA(1)==';'
 *  is in the set of tokens that can follow the ')' token
 *  reference in rule atom.  It can assume that you forgot the ')'.
 */
- (id<ANTLRToken>)recoverFromMismatchedToken:(id<ANTLRIntStream>)anInput
                       TokenType:(NSInteger)ttype
                          Follow:(ANTLRBitSet *)follow
{
    ANTLRRecognitionException *e = nil;
    // if next token is what we are looking for then "delete" this token
    if ( [self mismatchIsUnwantedToken:anInput TokenType:ttype] ) {
        e = [ANTLRUnwantedTokenException newException:ttype Stream:anInput];
        /*
         System.err.println("recoverFromMismatchedToken deleting "+
         ((TokenStream)input).LT(1)+
         " since "+((TokenStream)input).LT(2)+" is what we want");
         */
        [self beginResync];
        [anInput consume]; // simply delete extra token
        [self endResync];
        [self reportError:e];  // report after consuming so AW sees the token in the exception
                         // we want to return the token we're actually matching
        id matchedSymbol = [self getCurrentInputSymbol:anInput];
        [anInput consume]; // move past ttype token as if all were ok
        return matchedSymbol;
    }
    // can't recover with single token deletion, try insertion
    if ( [self mismatchIsMissingToken:anInput Follow:follow] ) {
        id<ANTLRToken> inserted = [self getMissingSymbol:anInput Exception:e TokenType:ttype Follow:follow];
        e = [ANTLRMissingTokenException newException:ttype Stream:anInput With:inserted];
        [self reportError:e];  // report after inserting so AW sees the token in the exception
        return inserted;
    }
    // even that didn't work; must throw the exception
    e = [ANTLRMismatchedTokenException newException:ttype Stream:anInput];
    @throw e;
}

/** Not currently used */
-(id) recoverFromMismatchedSet:(id<ANTLRIntStream>)anInput
                     Exception:(ANTLRRecognitionException *)e
                        Follow:(ANTLRBitSet *) follow
{
    if ( [self mismatchIsMissingToken:anInput Follow:follow] ) {
        // System.out.println("missing token");
        [self reportError:e];
        // we don't know how to conjure up a token for sets yet
        return [self getMissingSymbol:anInput Exception:e TokenType:ANTLRTokenTypeInvalid Follow:follow];
    }
    // TODO do single token deletion like above for Token mismatch
    @throw e;
}

/** Match needs to return the current input symbol, which gets put
 *  into the label for the associated token ref; e.g., x=ID.  Token
 *  and tree parsers need to return different objects. Rather than test
 *  for input stream type or change the IntStream interface, I use
 *  a simple method to ask the recognizer to tell me what the current
 *  input symbol is.
 * 
 *  This is ignored for lexers.
 */
- (id) getCurrentInputSymbol:(id<ANTLRIntStream>)anInput
{
    return nil;
}

/** Conjure up a missing token during error recovery.
 *
 *  The recognizer attempts to recover from single missing
 *  symbols. But, actions might refer to that missing symbol.
 *  For example, x=ID {f($x);}. The action clearly assumes
 *  that there has been an identifier matched previously and that
 *  $x points at that token. If that token is missing, but
 *  the next token in the stream is what we want we assume that
 *  this token is missing and we keep going. Because we
 *  have to return some token to replace the missing token,
 *  we have to conjure one up. This method gives the user control
 *  over the tokens returned for missing tokens. Mostly,
 *  you will want to create something special for identifier
 *  tokens. For literals such as '{' and ',', the default
 *  action in the parser or tree parser works. It simply creates
 *  a CommonToken of the appropriate type. The text will be the token.
 *  If you change what tokens must be created by the lexer,
 *  override this method to create the appropriate tokens.
 */
- (id)getMissingSymbol:(id<ANTLRIntStream>)anInput
             Exception:(ANTLRRecognitionException *)e
             TokenType:(NSInteger)expectedTokenType
                Follow:(ANTLRBitSet *)follow
{
    return nil;
}


-(void) consumeUntilTType:(id<ANTLRIntStream>)anInput TokenType:(NSInteger)tokenType
{
    //System.out.println("consumeUntil "+tokenType);
    int ttype = [anInput LA:1];
    while (ttype != ANTLRTokenTypeEOF && ttype != tokenType) {
        [anInput consume];
        ttype = [anInput LA:1];
    }
}

/** Consume tokens until one matches the given token set */
-(void) consumeUntilFollow:(id<ANTLRIntStream>)anInput Follow:(ANTLRBitSet *)set
{
    //System.out.println("consumeUntil("+set.toString(getTokenNames())+")");
    int ttype = [anInput LA:1];
    while (ttype != ANTLRTokenTypeEOF && ![set member:ttype] ) {
        //System.out.println("consume during recover LA(1)="+getTokenNames()[input.LA(1)]);
        [anInput consume];
        ttype = [anInput LA:1];
    }
}

/** Push a rule's follow set using our own hardcoded stack */
- (void)pushFollow:(ANTLRBitSet *)fset
{
    if ( (state._fsp +1) >= [state.following count] ) {
        //        AMutableArray *f = [AMutableArray arrayWithCapacity:[[state.following] count]*2];
        //        System.arraycopy(state.following, 0, f, 0, state.following.length);
        //        state.following = f;
        [state.following addObject:fset];
        [fset retain];
        state._fsp++;
    }
    else {
        [state.following replaceObjectAtIndex:++state._fsp withObject:fset];
    }
}

- (ANTLRBitSet *)popFollow
{
    ANTLRBitSet *fset;

    if ( state._fsp >= 0 && [state.following count] > 0 ) {
        fset = [state.following objectAtIndex:state._fsp--];
        [state.following removeLastObject];
        return fset;
    }
    else {
        NSLog( @"Attempted to pop a follow when none exists on the stack\n" );
    }
    return nil;
}

/** Return List<String> of the rules in your parser instance
 *  leading up to a call to this method.  You could override if
 *  you want more details such as the file/line info of where
 *  in the parser java code a rule is invoked.
 *
 *  This is very useful for error messages and for context-sensitive
 *  error recovery.
 */
- (AMutableArray *)getRuleInvocationStack
{
    NSString *parserClassName = [[self className] retain];
    return [self getRuleInvocationStack:[ANTLRRecognitionException newException] Recognizer:parserClassName];
}

/** A more general version of getRuleInvocationStack where you can
 *  pass in, for example, a RecognitionException to get it's rule
 *  stack trace.  This routine is shared with all recognizers, hence,
 *  static.
 *
 *  TODO: move to a utility class or something; weird having lexer call this
 */
- (AMutableArray *)getRuleInvocationStack:(ANTLRRecognitionException *)e
                                Recognizer:(NSString *)recognizerClassName
{
    // char *name;
    AMutableArray *rules = [[AMutableArray arrayWithCapacity:20] retain];
    NSArray *stack = [e callStackSymbols];
    int i = 0;
    for (i = [stack count]-1; i >= 0; i--) {
        NSString *t = [stack objectAtIndex:i];
        // NSLog(@"stack %d = %@\n", i, t);
        if ( [t commonPrefixWithString:@"org.antlr.runtime." options:NSLiteralSearch] ) {
            // id aClass = objc_getClass( [t UTF8String] );
            continue; // skip support code such as this method
        }
        if ( [t isEqualTo:NEXT_TOKEN_RULE_NAME] ) {
            // name = sel_getName(method_getName(method));
            // NSString *aMethod = [NSString stringWithFormat:@"%s", name];
            continue;
        }
        if ( ![t isEqualTo:recognizerClassName] ) {
            // name = class_getName( [t UTF8String] );
            continue; // must not be part of this parser
        }
        [rules addObject:t];
    }
#ifdef DONTUSEYET
    StackTraceElement[] stack = e.getStackTrace();
    int i = 0;
    for (i=stack.length-1; i>=0; i--) {
        StackTraceElement t = stack[i];
        if ( [t getClassName().startsWith("org.antlr.runtime.") ) {
            continue; // skip support code such as this method
        }
              if ( [[t getMethodName] equals:NEXT_TOKEN_RULE_NAME] ) {
            continue;
        }
              if ( ![[t getClassName] equals:recognizerClassName] ) {
            continue; // must not be part of this parser
        }
              [rules addObject:[t getMethodName]];
    }
#endif
    [stack release];
    return rules;
}

- (NSInteger) getBacktrackingLevel
{
    return [state getBacktracking];
}
      
- (void) setBacktrackingLevel:(NSInteger)level
{
    [state setBacktracking:level];
}
      
        /** Used to print out token names like ID during debugging and
 *  error reporting.  The generated parsers implement a method
 *  that overrides this to point to their String[] tokenNames.
 */
- (NSArray *)getTokenNames
{
    return tokenNames;
}

/** For debugging and other purposes, might want the grammar name.
 *  Have ANTLR generate an implementation for this method.
 */
- (NSString *)getGrammarFileName
{
    return grammarFileName;
}

- (NSString *)getSourceName
{
    return nil;
}

/** A convenience method for use most often with template rewrites.
 *  Convert a List<Token> to List<String>
 */
- (AMutableArray *)toStrings:(AMutableArray *)tokens
{
    if ( tokens == nil )
        return nil;
    AMutableArray *strings = [AMutableArray arrayWithCapacity:[tokens count]];
    id object;
    NSInteger i = 0;
    for (object in tokens) {
        [strings addObject:[object text]];
        i++;
    }
    return strings;
}

/** Given a rule number and a start token index number, return
 *  ANTLR_MEMO_RULE_UNKNOWN if the rule has not parsed input starting from
 *  start index.  If this rule has parsed input starting from the
 *  start index before, then return where the rule stopped parsing.
 *  It returns the index of the last token matched by the rule.
 *
 *  For now we use a hashtable and just the slow Object-based one.
 *  Later, we can make a special one for ints and also one that
 *  tosses out data after we commit past input position i.
 */
- (NSInteger)getRuleMemoization:(NSInteger)ruleIndex StartIndex:(NSInteger)ruleStartIndex
{
    NSNumber *stopIndexI;
    ANTLRHashRule *aHashRule;
    if ( (aHashRule = [state.ruleMemo objectAtIndex:ruleIndex]) == nil ) {
        aHashRule = [ANTLRHashRule newANTLRHashRuleWithLen:17];
        [state.ruleMemo insertObject:aHashRule atIndex:ruleIndex];
    }
    stopIndexI = [aHashRule getRuleMemoStopIndex:ruleStartIndex];
    if ( stopIndexI == nil ) {
        return ANTLR_MEMO_RULE_UNKNOWN;
    }
    return [stopIndexI integerValue];
}

/** Has this rule already parsed input at the current index in the
 *  input stream?  Return the stop token index or MEMO_RULE_UNKNOWN.
 *  If we attempted but failed to parse properly before, return
 *  MEMO_RULE_FAILED.
 *
 *  This method has a side-effect: if we have seen this input for
 *  this rule and successfully parsed before, then seek ahead to
 *  1 past the stop token matched for this rule last time.
 */
- (BOOL)alreadyParsedRule:(id<ANTLRIntStream>)anInput RuleIndex:(NSInteger)ruleIndex
{
    NSInteger aStopIndex = [self getRuleMemoization:ruleIndex StartIndex:anInput.index];
    if ( aStopIndex == ANTLR_MEMO_RULE_UNKNOWN ) {
        // NSLog(@"rule %d not yet encountered\n", ruleIndex);
        return NO;
    }
    if ( aStopIndex == ANTLR_MEMO_RULE_FAILED ) {
        if (debug) NSLog(@"rule %d will never succeed\n", ruleIndex);
        state.failed = YES;
    }
    else {
        if (debug) NSLog(@"seen rule %d before; skipping ahead to %d failed = %@\n", ruleIndex, aStopIndex+1, state.failed?@"YES":@"NO");
        [anInput seek:(aStopIndex+1)]; // jump to one past stop token
    }
    return YES;
}
      
/** Record whether or not this rule parsed the input at this position
 *  successfully.  Use a standard java hashtable for now.
 */
- (void)memoize:(id<ANTLRIntStream>)anInput
      RuleIndex:(NSInteger)ruleIndex
     StartIndex:(NSInteger)ruleStartIndex
{
    ANTLRRuleStack *aRuleStack;
    NSInteger stopTokenIndex;

    aRuleStack = state.ruleMemo;
    stopTokenIndex = (state.failed ? ANTLR_MEMO_RULE_FAILED : (anInput.index-1));
    if ( aRuleStack == nil ) {
        if (debug) NSLog(@"!!!!!!!!! memo array is nil for %@", [self getGrammarFileName]);
        return;
    }
    if ( ruleIndex >= [aRuleStack length] ) {
        if (debug) NSLog(@"!!!!!!!!! memo size is %d, but rule index is %d", [state.ruleMemo length], ruleIndex);
        return;
    }
    if ( [aRuleStack objectAtIndex:ruleIndex] != nil ) {
        [aRuleStack putHashRuleAtRuleIndex:ruleIndex StartIndex:ruleStartIndex StopIndex:stopTokenIndex];
    }
    return;
}
   
/** return how many rule/input-index pairs there are in total.
 *  TODO: this includes synpreds. :(
 */
- (NSInteger)getRuleMemoizationCacheSize
{
    ANTLRRuleStack *aRuleStack;
    ANTLRHashRule *aHashRule;

    int aCnt = 0;
    aRuleStack = state.ruleMemo;
    for (NSUInteger i = 0; aRuleStack != nil && i < [aRuleStack length]; i++) {
        aHashRule = [aRuleStack objectAtIndex:i];
        if ( aHashRule != nil ) {
            aCnt += [aHashRule count]; // how many input indexes are recorded?
        }
    }
    return aCnt;
}

#pragma warning Have to fix traceIn and traceOut.
- (void)traceIn:(NSString *)ruleName Index:(NSInteger)ruleIndex Object:(id)inputSymbol
{
    NSLog(@"enter %@ %@", ruleName, inputSymbol);
    if ( state.backtracking > 0 ) {
        NSLog(@" backtracking=%s", ((state.backtracking==YES)?"YES":"NO"));
    }
    NSLog(@"\n");
}

- (void)traceOut:(NSString *)ruleName Index:(NSInteger)ruleIndex Object:(id)inputSymbol
{
    NSLog(@"exit %@ -- %@", ruleName, inputSymbol);
    if ( state.backtracking > 0 ) {
        NSLog(@" backtracking=%s %s", state.backtracking?"YES":"NO", state.failed ? "failed":"succeeded");
    }
    NSLog(@"\n");
}


// call a syntactic predicate methods using its selector. this way we can support arbitrary synpreds.
- (BOOL) evaluateSyntacticPredicate:(SEL)synpredFragment // stream:(id<ANTLRIntStream>)input
{
    id<ANTLRIntStream> input;

    state.backtracking++;
    // input = state.token.input;
    input = self.input;
    int start = [input mark];
    @try {
        [self performSelector:synpredFragment];
    }
    @catch (ANTLRRecognitionException *re) {
        NSLog(@"impossible synpred: %@", re.name);
    }
    BOOL success = (state.failed == NO);
    [input rewind:start];
    state.backtracking--;
    state.failed = NO;
    return success;
}
              
@end
                               
