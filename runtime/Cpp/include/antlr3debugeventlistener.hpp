/**
 * \file
 * The definition of all debugging events that a recognizer can trigger.
 *
 * \remark
 *  From the java implementation by Terence Parr...
 *  I did not create a separate AST debugging interface as it would create
 *  lots of extra classes and DebugParser has a dbg var defined, which makes
 *  it hard to change to ASTDebugEventListener.  I looked hard at this issue
 *  and it is easier to understand as one monolithic event interface for all
 *  possible events.  Hopefully, adding ST debugging stuff won't be bad.  Leave
 *  for future. 4/26/2006.
 */

#ifndef	ANTLR3_DEBUG_EVENT_LISTENER_HPP
#define	ANTLR3_DEBUG_EVENT_LISTENER_HPP

// [The "BSD licence"]
// Copyright (c) 2005-2009 Gokulakannan Somasundaram, ElectronDB

//
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

#include    "antlr3defs.hpp"

ANTLR_BEGIN_NAMESPACE()

/// Default debugging port
///
#define DEFAULT_DEBUGGER_PORT		0xBFCC;

/** The ANTLR3 debugging interface for communicating with ANLTR Works. Function comments
 *  mostly taken from the Java version.
 */

template<class ImplTraits>
class DebugEventListener  : public ImplTraits::AllocPolicyType
{
public:
	typedef typename ImplTraits::TreeType TreeType;
	typedef typename ImplTraits::StringType StringType;
	typedef typename ImplTraits::CommonTokenType CommonTokenType;
	typedef typename ImplTraits::TreeAdaptorType TreeAdaptorType;

private:
	/// The port number which the debug listener should listen on for a connection
	///
	ANTLR_UINT32		m_port;

	/// The socket structure we receive after a successful accept on the serverSocket
	///
	SOCKET				m_socket;

	/** The version of the debugging protocol supported by the providing
	 *  instance of the debug event listener.
	 */
	int					m_PROTOCOL_VERSION;

	/// The name of the grammar file that we are debugging
	///
	StringType			m_grammarFileName;

	/// Indicates whether we have already connected or not
	///
	bool			m_initialized;

	/// Used to serialize the values of any particular token we need to
	/// send back to the debugger.
	///
	StringType		m_tokenString;


	/// Allows the debug event system to access the adapter in use
	/// by the recognizer, if this is a tree parser of some sort.
	///
	TreeAdaptorType*	m_adaptor;


public:
	/// Wait for a connection from the debugger and initiate the
	/// debugging session.
	///
	virtual bool	handshake();

	/** The parser has just entered a rule.  No decision has been made about
	 *  which alt is predicted.  This is fired AFTER init actions have been
	 *  executed.  Attributes are defined and available etc...
	 */
	virtual void	enterRule( const char * grammarFileName, const char * ruleName);

	/** Because rules can have lots of alternatives, it is very useful to
	 *  know which alt you are entering.  This is 1..n for n alts.
	 */
	virtual void			enterAlt( int alt);

	/** This is the last thing executed before leaving a rule.  It is
	 *  executed even if an exception is thrown.  This is triggered after
	 *  error reporting and recovery have occurred (unless the exception is
	 *  not caught in this rule).  This implies an "exitAlt" event.
	 */
	virtual void			exitRule( const char * grammarFileName, const char * ruleName);

	/** Track entry into any (...) subrule other EBNF construct
	 */
	virtual void			enterSubRule( int decisionNumber);

	virtual void			exitSubRule( int decisionNumber);

	/** Every decision, fixed k or arbitrary, has an enter/exit event
	 *  so that a GUI can easily track what LT/consume events are
	 *  associated with prediction.  You will see a single enter/exit
	 *  subrule but multiple enter/exit decision events, one for each
	 *  loop iteration.
	 */
	virtual void			enterDecision( int decisionNumber);

	virtual void			exitDecision( int decisionNumber);

	/** An input token was consumed; matched by any kind of element.
	 *  Trigger after the token was matched by things like match(), matchAny().
	 */
	virtual void			consumeToken( CommonTokenType* t);

	/** An off-channel input token was consumed.
	 *  Trigger after the token was matched by things like match(), matchAny().
	 *  (unless of course the hidden token is first stuff in the input stream).
	 */
	virtual void			consumeHiddenToken( CommonTokenType* t);

	/** Somebody (anybody) looked ahead.  Note that this actually gets
	 *  triggered by both LA and LT calls.  The debugger will want to know
	 *  which Token object was examined.  Like consumeToken, this indicates
	 *  what token was seen at that depth.  A remote debugger cannot look
	 *  ahead into a file it doesn't have so LT events must pass the token
	 *  even if the info is redundant.
	 */
	virtual void			LT( int i, CommonTokenType* t);

	/** The parser is going to look arbitrarily ahead; mark this location,
	 *  the token stream's marker is sent in case you need it.
	 */
	virtual void			mark( ANTLR_MARKER marker);

	/** After an arbitrarily long lookahead as with a cyclic DFA (or with
	 *  any backtrack), this informs the debugger that stream should be
	 *  rewound to the position associated with marker.
	 */
	virtual void			rewind( ANTLR_MARKER marker);

	/** Rewind to the input position of the last marker.
	 *  Used currently only after a cyclic DFA and just
	 *  before starting a sem/syn predicate to get the
	 *  input position back to the start of the decision.
	 *  Do not "pop" the marker off the state.  mark(i)
	 *  and rewind(i) should balance still.
	 */
	virtual void			rewindLast();

	virtual void			beginBacktrack( int level);

	virtual void			endBacktrack( int level, bool successful);

	/** To watch a parser move through the grammar, the parser needs to
	 *  inform the debugger what line/charPos it is passing in the grammar.
	 *  For now, this does not know how to switch from one grammar to the
	 *  other and back for island grammars etc...
	 *
	 *  This should also allow breakpoints because the debugger can stop
	 *  the parser whenever it hits this line/pos.
	 */
	virtual void			location( int line, int pos);

	/** A recognition exception occurred such as NoViableAltException.  I made
	 *  this a generic event so that I can alter the exception hierarchy later
	 *  without having to alter all the debug objects.
	 *
	 *  Upon error, the stack of enter rule/subrule must be properly unwound.
	 *  If no viable alt occurs it is within an enter/exit decision, which
	 *  also must be rewound.  Even the rewind for each mark must be unwound.
	 *  In the Java target this is pretty easy using try/finally, if a bit
	 *  ugly in the generated code.  The rewind is generated in DFA.predict()
	 *  actually so no code needs to be generated for that.  For languages
	 *  w/o this "finally" feature (C++?), the target implementor will have
	 *  to build an event stack or something.
	 *
	 *  Across a socket for remote debugging, only the RecognitionException
	 *  data fields are transmitted.  The token object or whatever that
	 *  caused the problem was the last object referenced by LT.  The
	 *  immediately preceding LT event should hold the unexpected Token or
	 *  char.
	 *
	 *  Here is a sample event trace for grammar:
	 *
	 *  b : C ({;}A|B) // {;} is there to prevent A|B becoming a set
     *    | D
     *    ;
     *
	 *  The sequence for this rule (with no viable alt in the subrule) for
	 *  input 'c c' (there are 3 tokens) is:
	 *
	 *		commence
	 *		LT(1)
	 *		enterRule b
	 *		location 7 1
	 *		enter decision 3
	 *		LT(1)
	 *		exit decision 3
	 *		enterAlt1
	 *		location 7 5
	 *		LT(1)
	 *		consumeToken [c/<4>,1:0]
	 *		location 7 7
	 *		enterSubRule 2
	 *		enter decision 2
	 *		LT(1)
	 *		LT(1)
	 *		recognitionException NoViableAltException 2 1 2
	 *		exit decision 2
	 *		exitSubRule 2
	 *		beginResync
	 *		LT(1)
	 *		consumeToken [c/<4>,1:1]
	 *		LT(1)
	 *		endResync
	 *		LT(-1)
	 *		exitRule b
	 *		terminate
	 */
	template<typename ExceptionBaseType>
	void recognitionException( ExceptionBaseType* ) {}

	/** Indicates the recognizer is about to consume tokens to resynchronize
	 *  the parser.  Any consume events from here until the recovered event
	 *  are not part of the parse--they are dead tokens.
	 */
	virtual void			beginResync();

	/** Indicates that the recognizer has finished consuming tokens in order
	 *  to resynchronize.  There may be multiple beginResync/endResync pairs
	 *  before the recognizer comes out of errorRecovery mode (in which
	 *  multiple errors are suppressed).  This will be useful
	 *  in a gui where you want to probably grey out tokens that are consumed
	 *  but not matched to anything in grammar.  Anything between
	 *  a beginResync/endResync pair was tossed out by the parser.
	 */
	virtual void			endResync();

	/** A semantic predicate was evaluate with this result and action text
	*/
	virtual void			semanticPredicate( bool result, const char * predicate);

	/** Announce that parsing has begun.  Not technically useful except for
	 *  sending events over a socket.  A GUI for example will launch a thread
	 *  to connect and communicate with a remote parser.  The thread will want
	 *  to notify the GUI when a connection is made.  ANTLR parsers
	 *  trigger this upon entry to the first rule (the ruleLevel is used to
	 *  figure this out).
	 */
	virtual void			commence();

	/** Parsing is over; successfully or not.  Mostly useful for telling
	 *  remote debugging listeners that it's time to quit.  When the rule
	 *  invocation level goes to zero at the end of a rule, we are done
	 *  parsing.
	 */
	virtual void	terminate();

	/// Retrieve acknowledge response from the debugger. in fact this
	/// response is never used at the moment. So we just read whatever
	/// is in the socket buffer and throw it away.
	///
	virtual void	ack();

	// T r e e  P a r s i n g

	/** Input for a tree parser is an AST, but we know nothing for sure
	 *  about a node except its type and text (obtained from the adaptor).
	 *  This is the analog of the consumeToken method.  The ID is usually
	 *  the memory address of the node.
	 *  If the type is UP or DOWN, then
	 *  the ID is not really meaningful as it's fixed--there is
	 *  just one UP node and one DOWN navigation node.
	 *
	 *  Note that unlike the Java version, the node type of the C parsers
	 *  is always fixed as pANTLR3_BASE_TREE because all such structures
	 *  contain a super pointer to their parent, which is generally COMMON_TREE and within
	 *  that there is a super pointer that can point to a user type that encapsulates it.
	 *  Almost akin to saying that it is an interface pointer except we don't need to
	 *  know what the interface is in full, just those bits that are the base.
	 * @param t
	 */
	virtual void	consumeNode( TreeType* t);

	/** The tree parser looked ahead.  If the type is UP or DOWN,
	 *  then the ID is not really meaningful as it's fixed--there is
	 *  just one UP node and one DOWN navigation node.
	 */
	virtual void	LTT( int i, TreeType* t);


	// A S T  E v e n t s

	/** A nil was created (even nil nodes have a unique ID...
	 *  they are not "null" per se).  As of 4/28/2006, this
	 *  seems to be uniquely triggered when starting a new subtree
	 *  such as when entering a subrule in automatic mode and when
	 *  building a tree in rewrite mode.
     *
 	 *  If you are receiving this event over a socket via
	 *  RemoteDebugEventSocketListener then only t.ID is set.
	 */
	virtual void	nilNode( TreeType* t);

	/** If a syntax error occurs, recognizers bracket the error
	 *  with an error node if they are building ASTs. This event
	 *  notifies the listener that this is the case
	 */
	virtual void	errorNode( TreeType* t);

	/** Announce a new node built from token elements such as type etc...
	 *
	 *  If you are receiving this event over a socket via
	 *  RemoteDebugEventSocketListener then only t.ID, type, text are
	 *  set.
	 */
	virtual void	createNode( TreeType* t);

	/** Announce a new node built from an existing token.
	 *
	 *  If you are receiving this event over a socket via
	 *  RemoteDebugEventSocketListener then only node.ID and token.tokenIndex
	 *  are set.
	 */
	virtual void	createNodeTok( TreeType* node, CommonTokenType* token);

	/** Make a node the new root of an existing root.  See
	 *
	 *  Note: the newRootID parameter is possibly different
	 *  than the TreeAdaptor.becomeRoot() newRoot parameter.
	 *  In our case, it will always be the result of calling
	 *  TreeAdaptor.becomeRoot() and not root_n or whatever.
	 *
	 *  The listener should assume that this event occurs
	 *  only when the current subrule (or rule) subtree is
	 *  being reset to newRootID.
	 *
	 *  If you are receiving this event over a socket via
	 *  RemoteDebugEventSocketListener then only IDs are set.
	 *
	 *  @see org.antlr.runtime.tree.TreeAdaptor.becomeRoot()
	 */
	virtual void	becomeRoot( TreeType* newRoot, TreeType* oldRoot);

	/** Make childID a child of rootID.
	 *
	 *  If you are receiving this event over a socket via
	 *  RemoteDebugEventSocketListener then only IDs are set.
	 *
	 *  @see org.antlr.runtime.tree.TreeAdaptor.addChild()
	 */
	virtual void	addChild( TreeType* root, TreeType* child);

	/** Set the token start/stop token index for a subtree root or node.
	 *
	 *  If you are receiving this event over a socket via
	 *  RemoteDebugEventSocketListener then only t.ID is set.
	 */
	virtual void	setTokenBoundaries( TreeType* t, ANTLR_MARKER tokenStartIndex, ANTLR_MARKER tokenStopIndex);

	/// Free up the resources allocated to this structure
	///
	virtual ~DebugEventListener();
};

ANTLR_END_NAMESPACE()

#endif

