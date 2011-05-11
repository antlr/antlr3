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

#import <ANTLR/ACBTree.h>
#import <ANTLR/AMutableArray.h>
#import <ANTLR/AMutableDictionary.h>
#import <ANTLR/ANTLRBaseMapElement.h>
#import <ANTLR/ANTLRBaseRecognizer.h>
#import <ANTLR/ANTLRBaseStack.h>
#import <ANTLR/ANTLRBaseTree.h>
#import <ANTLR/ANTLRBaseTreeAdaptor.h>
#import <ANTLR/ANTLRBitSet.h>
#import <ANTLR/ANTLRBufferedTokenStream.h>
#import <ANTLR/ANTLRBufferedTreeNodeStream.h>
#import <ANTLR/ANTLRCharStream.h>
#import <ANTLR/ANTLRCharStreamState.h>
#import <ANTLR/ANTLRCommonErrorNode.h>
#import <ANTLR/ANTLRCommonToken.h>
#import <ANTLR/ANTLRCommonTokenStream.h>
#import <ANTLR/ANTLRCommonTree.h>
#import <ANTLR/ANTLRCommonTreeAdaptor.h>
#import <ANTLR/ANTLRCommonTreeNodeStream.h>
#import <ANTLR/ANTLRDFA.h>
#import <ANTLR/ANTLRDebug.h>
#import <ANTLR/ANTLRDebugEventProxy.h>
#import <ANTLR/ANTLRDebugEventListener.h>
#import <ANTLR/ANTLRDebugParser.h>
#import <ANTLR/ANTLRDebugTokenStream.h>
#import <ANTLR/ANTLRDebugTreeAdaptor.h>
#import <ANTLR/ANTLRDebugTreeNodeStream.h>
#import <ANTLR/ANTLRDebugTreeParser.h>
#import <ANTLR/ANTLRDoubleKeyMap.h>
#import <ANTLR/ANTLREarlyExitException.h>
#import <ANTLR/ANTLRError.h>
#import <ANTLR/ANTLRFailedPredicateException.h>
#import <ANTLR/ANTLRFastQueue.h>
#import <ANTLR/ANTLRFileStream.h>
#import <ANTLR/ANTLRHashMap.h>
#import <ANTLR/ANTLRHashRule.h>
#import <ANTLR/ANTLRInputStream.h>
#import <ANTLR/ANTLRIntArray.h>
#import <ANTLR/ANTLRIntStream.h>
#import <ANTLR/ANTLRLexer.h>
#import <ANTLR/ANTLRLexerRuleReturnScope.h>
#import <ANTLR/ANTLRLinkBase.h>
#import <ANTLR/ANTLRLookaheadStream.h>
#import <ANTLR/ANTLRMapElement.h>
#import <ANTLR/ANTLRMap.h>
#import <ANTLR/ANTLRMismatchedNotSetException.h>
#import <ANTLR/ANTLRMismatchedRangeException.h>
#import <ANTLR/ANTLRMismatchedSetException.h>
#import <ANTLR/ANTLRMismatchedTokenException.h>
#import <ANTLR/ANTLRMismatchedTreeNodeException.h>
#import <ANTLR/ANTLRMissingTokenException.h>
#import <ANTLR/ANTLRNodeMapElement.h>
#import <ANTLR/ANTLRNoViableAltException.h>
#import <ANTLR/ANTLRParser.h>
#import <ANTLR/ANTLRParserRuleReturnScope.h>
#import <ANTLR/ANTLRPtrBuffer.h>
#import <ANTLR/ANTLRReaderStream.h>
#import <ANTLR/ANTLRRecognitionException.h>
#import <ANTLR/ANTLRRecognizerSharedState.h>
#import <ANTLR/ANTLRRewriteRuleElementStream.h>
#import <ANTLR/ANTLRRewriteRuleNodeStream.h>
#import <ANTLR/ANTLRRewriteRuleSubtreeStream.h>
#import <ANTLR/ANTLRRewriteRuleTokenStream.h>
#import <ANTLR/ANTLRRuleMemo.h>
#import <ANTLR/ANTLRRuleStack.h>
#import <ANTLR/ANTLRRuleReturnScope.h>
#import <ANTLR/ANTLRRuntimeException.h>
#import <ANTLR/ANTLRStreamEnumerator.h>
#import <ANTLR/ANTLRStringStream.h>
#import <ANTLR/ANTLRSymbolStack.h>
#import <ANTLR/ANTLRToken+DebuggerSupport.h>
#import <ANTLR/ANTLRToken.h>
#import <ANTLR/ANTLRTokenRewriteStream.h>
#import <ANTLR/ANTLRTokenSource.h>
#import <ANTLR/ANTLRTokenStream.h>
#import <ANTLR/ANTLRTree.h>
#import <ANTLR/ANTLRTreeAdaptor.h>
#import <ANTLR/ANTLRTreeException.h>
#import <ANTLR/ANTLRTreeIterator.h>
#import <ANTLR/ANTLRTreeNodeStream.h>
#import <ANTLR/ANTLRTreeParser.h>
#import <ANTLR/ANTLRTreeRuleReturnScope.h>
#import <ANTLR/ANTLRUnbufferedTokenStream.h>
//#import <ANTLR/ANTLRUnbufferedCommonTreeNodeStream.h>
//#import <ANTLR/ANTLRUnbufferedCommonTreeNodeStreamState.h>
#import <ANTLR/ANTLRUniqueIDMap.h>
#import <ANTLR/ANTLRUnwantedTokenException.h>
#import <ANTLR/ArrayIterator.h>
