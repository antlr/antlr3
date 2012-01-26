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

#import "ANTLRDFA.h"
#import <ANTLRToken.h>
#import <ANTLRNoViableAltException.h>

NSInteger debug = 0;

@implementation ANTLRDFA
@synthesize recognizer;
@synthesize decisionNumber;
@synthesize len;

- (id) initWithRecognizer:(ANTLRBaseRecognizer *) theRecognizer
{
	if ((self = [super init]) != nil) {
		recognizer = theRecognizer;
        [recognizer retain];
        debug = 0;
	}
	return self;
}

// using the tables ANTLR generates for the DFA based prediction this method simulates the DFA
// and returns the prediction of the alternative to be used.
- (NSInteger) predict:(id<ANTLRIntStream>)input
{
    if ( debug > 2 ) {
        NSLog(@"Enter DFA.predict for decision %d", decisionNumber);
    }
	int aMark = [input mark];
	int s = 0;
	@try {
		while (YES) {
			if ( debug > 2 )
                NSLog(@"DFA %d state %d LA(1)='%c'(%x)", decisionNumber, s, (unichar)[input LA:1], [input LA:1]);
			NSInteger specialState = special[s];
			if (specialState >= 0) {
				// this state is special in that it has some code associated with it. we cannot do this in a pure DFA so
				// we signal the caller accordingly.
				if ( debug > 2 ) {
                    NSLog(@"DFA %d state %d is special state %d", decisionNumber, s, specialState);
                }
				s = [self specialStateTransition:specialState Stream:input];
                if ( debug > 2 ) {
                    NSLog(@"DFA %d returns from special state %d to %d", decisionNumber, specialState, s);
                }
                if (s == -1 ) {
                    [self noViableAlt:s Stream:input];
                    return 0;
                }
				[input consume];
				continue;
			}
			if (accept[s] >= 1) {  // if this is an accepting state return the prediction
				if ( debug > 2 ) NSLog(@"accept; predict %d from state %d", accept[s], s);
				return accept[s];
			}
			// based on the lookahead lookup the next transition, consume and do transition
			// or signal that we have no viable alternative
			int c = [input LA:1];
			if ( (unichar)c >= min[s] && (unichar)c <= max[s]) {
				int snext = transition[s][c-min[s]];
				if (snext < 0) {
                    // was in range but not a normal transition
                    // must check EOT, which is like the else clause.
                    // eot[s]>=0 indicates that an EOT edge goes to another
                    // state.
					if (eot[s] >= 0) {
						if ( debug > 2 ) NSLog(@"EOT transition");
						s = eot[s];
						[input consume];
                        // TODO: I had this as return accept[eot[s]]
                        // which assumed here that the EOT edge always
                        // went to an accept...faster to do this, but
                        // what about predicated edges coming from EOT
                        // target?
						continue;
					}
					[self noViableAlt:s Stream:input];
					return 0;
				}
				s = snext;
				[input consume];
				continue;
			}
			
			if (eot[s] >= 0) {// EOT transition? we may still accept the input in the next state
				if ( debug > 2 ) NSLog(@"EOT transition");
				s = eot[s];
				[input consume];
				continue;
			}
			if ( c == ANTLRTokenTypeEOF && eof[s] >= 0) {  // we are at EOF and may even accept the input.
				if ( debug > 2 ) NSLog(@"accept via EOF; predict %d from %d", accept[eof[s]], eof[s]);
				return accept[eof[s]];
			}
			if ( debug > 2 ) {
                NSLog(@"no viable alt!\n");
                NSLog(@"min[%d] = %d\n", s, min[s]);
                NSLog(@"max[%d] = %d\n", s, min[s]);
                NSLog(@"eot[%d] = %d\n", s, min[s]);
                NSLog(@"eof[%d] = %d\n", s, min[s]);
                for (NSInteger p = 0; p < self.len; p++) {
                    NSLog(@"%d ", transition[s][p]);
                }
                NSLog(@"\n");
            }
			[self noViableAlt:s Stream:input];
            return 0;
		}
	}
	@finally {
		[input rewind:aMark];
	}
	return 0; // silence warning
}

- (void) noViableAlt:(NSInteger)state Stream:(id<ANTLRIntStream>)anInput
{
	if ([recognizer.state isBacktracking]) {
		[recognizer.state setFailed:YES];
		return;
	}
	ANTLRNoViableAltException *nvae = [ANTLRNoViableAltException newException:decisionNumber state:state stream:anInput];
	[self error:nvae];
	@throw nvae;
}

- (NSInteger) specialStateTransition:(NSInteger)state Stream:(id<ANTLRIntStream>)anInput
{
    @throw [ANTLRNoViableAltException newException:-1 state:state stream:anInput];
	return -1;
}

- (void) error:(ANTLRNoViableAltException *)nvae
{
	// empty, hook for debugger support
}

- (NSString *) description
{
	return @"subclass responsibility";
}

- (BOOL) evaluateSyntacticPredicate:(SEL)synpredFragment
{
	return [recognizer evaluateSyntacticPredicate:synpredFragment];
}

+ (void) setIsEmittingDebugInfo:(BOOL) shouldEmitDebugInfo
{
	debug = shouldEmitDebugInfo;
}

/** Given a String that has a run-length-encoding of some unsigned shorts
 *  like "\1\2\3\9", convert to short[] {2,9,9,9}.  We do this to avoid
 *  static short[] which generates so much init code that the class won't
 *  compile. :(
 */
- (short *) unpackEncodedString:(NSString *)encodedString
{
    // walk first to find how big it is.
    int size = 0;
    for (int i=0; i < [encodedString length]; i+=2) {
        size += [encodedString characterAtIndex:i];
    }
    __strong short *data = (short *)calloc(size, sizeof(short));
    int di = 0;
    for (int i=0; i < [encodedString length]; i+=2) {
        char n = [encodedString characterAtIndex:i];
        char v = [encodedString characterAtIndex:i+1];
        // add v n times to data
        for (int j = 0; j < n; j++) {
            data[di++] = v;
        }
    }
    return data;
}

/** Hideous duplication of code, but I need different typed arrays out :( */
- (char *) unpackEncodedStringToUnsignedChars:(NSString *)encodedString
{
    // walk first to find how big it is.
    int size = 0;
    for (int i=0; i < [encodedString length]; i+=2) {
        size += [encodedString characterAtIndex:i];
    }
    __strong short *data = (short *)calloc(size, sizeof(short));
    int di = 0;
    for (int i=0; i < [encodedString length]; i+=2) {
        char n = [encodedString characterAtIndex:i];
        char v = [encodedString characterAtIndex:i+1];
        // add v n times to data
        for (int j = 0; j < n; j++) {
            data[di++] = v;
        }
    }
    return (char *)data;
}

- (NSInteger)getDecision
{
    return decisionNumber;
}

- (void)setDecision:(NSInteger)aDecison
{
    decisionNumber = aDecison;
}

- (ANTLRBaseRecognizer *)getRecognizer
{
    return recognizer;
}

- (void)setRecognizer:(ANTLRBaseRecognizer *)aRecognizer
{
    if ( recognizer != aRecognizer ) {
        if ( recognizer ) [recognizer release];
        [aRecognizer retain];
    }
    recognizer = aRecognizer;
}

- (NSInteger)length
{
    return len;
}

@synthesize eot;
@synthesize eof;
@synthesize min;
@synthesize max;
@synthesize accept;
@synthesize special;
@synthesize transition;
@end
