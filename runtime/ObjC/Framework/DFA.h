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
#import "CharStream.h"
#import "NoViableAltException.h"

@interface DFA : NSObject {
	// the tables are set by subclasses to their own static versions.
	const NSInteger *eot;
	const NSInteger *eof;
	const unichar *min;
	const unichar *max;
	const NSInteger *accept;
	const NSInteger *special;
	const NSInteger **transition;
	
	__strong BaseRecognizer *recognizer;
	NSInteger decisionNumber;
    NSInteger len;
}

- (id) initWithRecognizer:(id) theRecognizer;
// simulate the DFA using the static tables and predict an alternative
- (NSInteger) predict:(id<CharStream>)anInput;
- (void) noViableAlt:(NSInteger)state Stream:(id<IntStream>)anInput;

- (NSInteger) specialStateTransition:(NSInteger)state Stream:(id<IntStream>)anInput;
// - (NSInteger) specialStateTransition:(NSInteger) state;
//- (unichar) specialTransition:(unichar) state symbol:(NSInteger) symbol;

// hook for debugger support
- (void) error:(NoViableAltException *)nvae;

- (NSString *) description;
- (BOOL) evaluateSyntacticPredicate:(SEL)synpredFragment;

+ (void) setIsEmittingDebugInfo:(BOOL) shouldEmitDebugInfo;

- (NSInteger *) unpackEncodedString:(NSString *)encodedString;
- (short *) unpackEncodedStringToUnsignedChars:(NSString *)encodedString;
- (NSInteger)getDecision;
- (void)setDecision:(NSInteger)aDecison;

- (BaseRecognizer *)getRecognizer;
- (void)setRecognizer:(BaseRecognizer *)aRecognizer;
- (NSInteger)length;

@property const NSInteger *eot;
@property const NSInteger *eof;
@property const unichar *min;
@property const unichar *max;
@property const NSInteger *accept;
@property const NSInteger *special;
@property const NSInteger **transition;

@property (retain, getter=getRecognizer,setter=setRecognizer:) BaseRecognizer *recognizer;
@property (assign, getter=getDecision,setter=setDecision:) NSInteger decisionNumber;
@property (assign, getter=getLen,setter=setLen:) NSInteger len;
@end
