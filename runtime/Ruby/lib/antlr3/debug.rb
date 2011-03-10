#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3'

=begin LICENSE

[The "BSD licence"]
Copyright (c) 2009-2010 Kyle Yetter
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 3. The name of the author may not be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=end

module ANTLR3
  
=begin rdoc ANTLR3::Debug

Namespace for all debugging-related class and module definitions.

=end

module Debug

DEFAULT_PORT = 49100

# since there are many components to the debug-mode
# section of the antlr3 runtime library, most of which
# are not used simultaneously, debug.rb contains the
# base of the debug library and the various listeners
# and tree-related code are autloaded on-demand
autoload :EventSocketProxy, 'antlr3/debug/socket'
autoload :RemoteEventSocketListener, 'antlr3/debug/socket'
autoload :TraceEventListener, 'antlr3/debug/trace-event-listener'
autoload :RecordEventListener, 'antlr3/debug/record-event-listener'
autoload :RuleTracer, 'antlr3/debug/rule-tracer'
autoload :EventHub, 'antlr3/debug/event-hub'
autoload :TreeAdaptor, 'antlr3/tree/debug'
autoload :TreeNodeStream, 'antlr3/tree/debug'

RecognizerSharedState = Struct.new( 
  # the rule invocation depth
  :rule_invocation_stack,
  # a boolean flag to indicate whether or not the current decision is cyclic
  :cyclic_decision,
  # a stack that tracks follow sets for error recovery
  :following,
  # a flag indicating whether or not the recognizer is in error recovery mode
  :error_recovery,
  # the index in the input stream of the last error
  :last_error_index,
  # tracks the backtracking depth
  :backtracking,
  # if a grammar is compiled with the memoization option, this will
  # be set to a hash mapping previously parsed rules to cached indices
  :rule_memory,
  # tracks the number of syntax errors seen so far
  :syntax_errors,
  # holds newly constructed tokens for lexer rules
  :token,
  # the input stream index at which the token starts
  :token_start_position,
  # the input stream line number at which the token starts
  :token_start_line,
  # the input stream column at which the token starts
  :token_start_column,
  # the channel value of the target token
  :channel,
  # the type value of the target token
  :type,
  # the text of the target token
  :text
)

=begin rdoc ANTLR3::Debug::RecognizerSharedState

ANTLR3::Debug::RecognizerSharedState is identical to
ANTLR3::RecognizerSharedState, but adds additional fields used for recognizers
generated in debug or profiling mode.

=end
class RecognizerSharedState
  def initialize
    super( [], false, [], false, -1, 0, nil, 0, nil, -1 )
    # ^-- same as this --v 
    # self.following = []
    # self.error_recovery = false
    # self.last_error_index = -1
    # self.backtracking = 0
    # self.syntax_errors = 0
    # self.rule_level = 0
    # self.token_start_position = -1
  end
  
  def reset!
    self.following.clear
    self.error_recovery = false
    self.last_error_index = -1
    self.backtracking = 0
    self.rule_memory and rule_memory.clear
    self.syntax_errors = 0
    self.token = nil
    self.token_start_position = -1
    self.token_start_line = nil
    self.token_start_column = nil
    self.channel = nil
    self.type = nil
    self.text = nil
    self.rule_invocation_stack.clear
  end
  
end

=begin rdoc ANTLR3::Debug::ParserEvents

ParserEvents adds debugging event hook methods and functionality that is
required by the code ANTLR generated when called with the <tt>-debug</tt>
switch.

=end
module ParserEvents
  include ANTLR3::Error
  
  def self.included( klass )
    super
    if klass.is_a?( ::Class )
      def klass.debug?
        true
      end
    end
  end
  
  
  attr_reader :debug_listener
  
  def initialize( stream, options = {} )
    @debug_listener = options[ :debug_listener ] ||= begin
      EventSocketProxy.new( self, options ).handshake
    end
    options[ :state ] ||= Debug::RecognizerSharedState.new
    super( stream, options )
    if @input.is_a?( Debug::TokenStream )
      @input.debug_listener ||= @debug_listener
    else
      @input = Debug::TokenStream.wrap( @input, @debug_listener )
    end
  end
  
  def rule_level
    @state.rule_invocation_stack.length
  end
  
  def cyclic_decision?
    @state.cyclic_decision
  end
  
  def cyclic_decision=( flag )
    @state.cyclic_decision = flag
  end
  
  # custom attribute writer for debug_listener
  # propegates the change in listener to the
  # parser's debugging input stream
  def debug_listener=( dbg )
    @debug_listener = dbg
    @input.debug_listener = dbg rescue nil
  end
  
  def begin_resync
    @debug_listener.begin_resync
    super
  end
  
  def end_resync
    @debug_listener.end_resync
    super
  end
  
  # TO-DO: is this pointless?
  def resync
    begin_resync
    yield( self )
  ensure
    end_resync
  end
  
  def begin_backtrack
    @debug_listener.begin_backtrack( @state.backtracking )
  end
  
  def end_backtrack( successful )
    @debug_listener.end_backtrack( @state.backtracking, successful )
  end
  
  def backtrack
    @state.backtracking += 1
    @debug_listener.begin_backtrack( @state.backtracking )
    start = @input.mark
    success =
      begin yield
      rescue BacktrackingFailed then false
      else true
      end
    return success
  ensure
    @input.rewind( start )
    @debug_listener.end_backtrack( @state.backtracking, ( success rescue nil ) )
    @state.backtracking -= 1
  end
  
  def report_error( exc )
    ANTLR3::RecognitionError === exc and
      @debug_listener.recognition_exception( exc )
    super
  end
  
  def missing_symbol( error, expected_type, follow )
    symbol = super
    @debug_listener.consume_node( symbol )
    return( symbol )
  end
  
  def in_rule( grammar_file, rule_name )
    @state.rule_invocation_stack.empty? and @debug_listener.commence
    @debug_listener.enter_rule( grammar_file, rule_name )
    @state.rule_invocation_stack.push( grammar_file, rule_name )
    yield
  ensure
    @state.rule_invocation_stack.pop( 2 )
    @debug_listener.exit_rule( grammar_file, rule_name )
    @state.rule_invocation_stack.empty? and @debug_listener.terminate
  end
  
  def rule_invocation_stack
    @state.rule_invocation_stack.each_slice( 2 ).to_a
  end
  
  def predicate?( description )
    result = yield
    @debug_listener.semantic_predicate( result, description )
    return result
  end
  
  def in_alternative( alt_number )
    @debug_listener.enter_alternative( alt_number )
  end
  
  def in_subrule( decision_number )
    @debug_listener.enter_subrule( decision_number )
    yield
  ensure
    @debug_listener.exit_subrule( decision_number )
  end
  
  def in_decision( decision_number )
    @debug_listener.enter_decision( decision_number )
    yield
  ensure
    @debug_listener.exit_decision( decision_number )
  end
end


=begin rdoc ANTLR3::Debug::TokenStream

A module that wraps token stream methods with debugging event code. A debuggable
parser will <tt>extend</tt> its input stream with this module if the stream is
not already a Debug::TokenStream.

=end
module TokenStream
  
  def self.wrap( stream, debug_listener = nil )
    stream.extend( self )
    stream.instance_eval do
      @initial_stream_state = true
      @debug_listener = debug_listener
      @last_marker = nil
    end
    return( stream )
  end
  attr_reader :last_marker
  attr_accessor :debug_listener
  
  def consume
    @initial_stream_state and consume_initial_hidden_tokens
    a = index + 1 # the next position IF there are no hidden tokens in between
    t = super
    b = index     # the actual position after consuming
    @debug_listener.consume_token( t ) if @debug_listener
    
    # if b > a, report the consumption of hidden tokens
    for i in a...b
      @debug_listener.consume_hidden_token at( i )
    end
  end
  
  
  # after a token stream fills up its buffer
  # by exhausting its token source, it may
  # skip to an initial position beyond the first
  # actual token, if there are hidden tokens
  # at the beginning of the stream.
  #
  # This private method is used to
  # figure out if any hidden tokens
  # were skipped initially, and then
  # report their consumption to
  # the debug listener
  def consume_initial_hidden_tokens
    first_on_channel_token_index = self.index
    first_on_channel_token_index.times do |index|
      @debug_listener.consume_hidden_token at( index )
    end
    @initial_stream_state = false
  end
  
  private :consume_initial_hidden_tokens
  
  ############################################################################################
  ###################################### Stream Methods ######################################
  ############################################################################################
  
  def look( steps = 1 )
    @initial_stream_state and consume_initial_hidden_tokens
    token = super( steps )
    @debug_listener.look( steps, token )
    return token
  end
  
  def peek( steps = 1 )
    look( steps ).type
  end
  
  def mark
    @last_marker = super
    @debug_listener.mark( @last_marker )
    return @last_marker
  end
  
  def rewind( marker = nil, release = true )
    @debug_listener.rewind( marker )
    super
  end
end

=begin rdoc ANTLR3::Debug::EventListener

A listener that simply records text representations of the events. Useful for debugging the
debugging facility ;) Subclasses can override the record() method (which defaults to printing
to stdout) to record the events in a different way.

=end
module EventListener
  PROTOCOL_VERSION = '2'
  # The parser has just entered a rule. No decision has been made about
  # which alt is predicted.  This is fired AFTER init actions have been
  # executed.  Attributes are defined and available etc...
  # The grammarFileName allows composite grammars to jump around among
  # multiple grammar files.
  
  def enter_rule( grammar_file, rule_name )
    # do nothing
  end
  
  # Because rules can have lots of alternatives, it is very useful to
  # know which alt you are entering.  This is 1..n for n alts.
  
  def enter_alternative( alt )
    # do nothing
  end
  
  # This is the last thing executed before leaving a rule.  It is
  # executed even if an exception is thrown.  This is triggered after
  # error reporting and recovery have occurred (unless the exception is
  # not caught in this rule).  This implies an "exitAlt" event.
  # The grammarFileName allows composite grammars to jump around among
  # multiple grammar files.
  
  def exit_rule( grammar_file, rule_name )
    # do nothing
  end

  # Track entry into any (...) subrule other EBNF construct
  
  def enter_subrule( decision_number )
    # do nothing
  end

  def exit_subrule( decision_number )
    # do nothing
  end
  
  # Every decision, fixed k or arbitrary, has an enter/exit event
  # so that a GUI can easily track what look/consume events are
  # associated with prediction.  You will see a single enter/exit
  # subrule but multiple enter/exit decision events, one for each
  # loop iteration.
  
  def enter_decision( decision_number )
    # do nothing
  end

  def exit_decision( decision_number )
    # do nothing
  end

  # An input token was consumed; matched by any kind of element.
  # Trigger after the token was matched by things like match(), matchAny().
  
  def consume_token( tree )
    # do nothing
  end

  # An off-channel input token was consumed.
  # Trigger after the token was matched by things like match(), matchAny().
  # (unless of course the hidden token is first stuff in the input stream).
  
  def consume_hidden_token( tree )
    # do nothing
  end

  # Somebody (anybody) looked ahead.  Note that this actually gets
  # triggered by both peek and look calls.  The debugger will want to know
  # which Token object was examined.  Like consumeToken, this indicates
  # what token was seen at that depth.  A remote debugger cannot look
  # ahead into a file it doesn't have so look events must pass the token
  # even if the info is redundant.
  
  def look( i, tree )
    # do nothing
  end

  # The parser is going to look arbitrarily ahead; mark this location,
  # the token stream's marker is sent in case you need it.
  
  def mark( marker )
    # do nothing
  end

  # After an arbitrairly long look as with a cyclic DFA (or with
  # any backtrack), this informs the debugger that stream should be
  # rewound to the position associated with marker.
  
  def rewind( marker = nil )
    # do nothing
  end

  def begin_backtrack( level )
    # do nothing
  end

  def end_backtrack( level, successful )
    # do nothing
  end
  
  def backtrack( level )
    begin_backtrack( level )
    successful = yield( self )
    end_backtrack( level, successful )
  end

  # To watch a parser move through the grammar, the parser needs to
  # inform the debugger what line/charPos it is passing in the grammar.
  # For now, this does not know how to switch from one grammar to the
  # other and back for island grammars etc...
  # This should also allow breakpoints because the debugger can stop
  # the parser whenever it hits this line/pos.
  
  def location( line, position )
    # do nothing
  end

  # A recognition exception occurred such as NoViableAltError.  I made
  # this a generic event so that I can alter the exception hierachy later
  # without having to alter all the debug objects.
  # Upon error, the stack of enter rule/subrule must be properly unwound.
  # If no viable alt occurs it is within an enter/exit decision, which
  # also must be rewound.  Even the rewind for each mark must be unwount.
  # In the Java target this is pretty easy using try/finally, if a bit
  # ugly in the generated code.  The rewind is generated in DFA.predict()
  # actually so no code needs to be generated for that.  For languages
  # w/o this "finally" feature (C++?), the target implementor will have
  # to build an event stack or something.
  # Across a socket for remote debugging, only the RecognitionError
  # data fields are transmitted.  The token object or whatever that
  # caused the problem was the last object referenced by look.  The
  # immediately preceding look event should hold the unexpected Token or
  # char.
  # Here is a sample event trace for grammar:
  # b : C ({;}A|B) // {;} is there to prevent A|B becoming a set
  # | D
  # ;
  # The sequence for this rule (with no viable alt in the subrule) for
  # input 'c c' (there are 3 tokens) is:
  # commence
  # look
  # enterRule b
  # location 7 1
  # enter decision 3
  # look
  # exit decision 3
  # enterAlt1
  # location 7 5
  # look
  # consumeToken [c/<4>,1:0]
  # location 7 7
  # enterSubRule 2
  # enter decision 2
  # look
  # look
  # recognitionError NoViableAltError 2 1 2
  # exit decision 2
  # exitSubRule 2
  # beginResync
  # look
  # consumeToken [c/<4>,1:1]
  # look
  # endResync
  # look(-1)
  # exitRule b
  # terminate
  
  def recognition_exception( exception )
    # do nothing
  end

  # Indicates the recognizer is about to consume tokens to resynchronize
  # the parser.  Any consume events from here until the recovered event
  # are not part of the parse--they are dead tokens.
  
  def begin_resync()
    # do nothing
  end

  # Indicates that the recognizer has finished consuming tokens in order
  # to resychronize.  There may be multiple beginResync/endResync pairs
  # before the recognizer comes out of errorRecovery mode (in which
  # multiple errors are suppressed).  This will be useful
  # in a gui where you want to probably grey out tokens that are consumed
  # but not matched to anything in grammar.  Anything between
  # a beginResync/endResync pair was tossed out by the parser.
  
  def end_resync()
    # do nothing
  end
  
  def resync
    begin_resync
    yield( self )
    end_resync
  end

  # A semantic predicate was evaluate with this result and action text
  
  def semantic_predicate( result, predicate )
    # do nothing
  end
  
  # Announce that parsing has begun.  Not technically useful except for
  # sending events over a socket.  A GUI for example will launch a thread
  # to connect and communicate with a remote parser.  The thread will want
  # to notify the GUI when a connection is made.  ANTLR parsers
  # trigger this upon entry to the first rule (the ruleLevel is used to
  # figure this out).
  
  def commence(  )
    # do nothing
  end

  # Parsing is over; successfully or not.  Mostly useful for telling
  # remote debugging listeners that it's time to quit.  When the rule
  # invocation level goes to zero at the end of a rule, we are done
  # parsing.
  
  def terminate(  )
    # do nothing
  end

  # Input for a tree parser is an AST, but we know nothing for sure
  # about a node except its type and text (obtained from the adaptor).
  # This is the analog of the consumeToken method.  Again, the ID is
  # the hashCode usually of the node so it only works if hashCode is
  # not implemented.  If the type is UP or DOWN, then
  # the ID is not really meaningful as it's fixed--there is
  # just one UP node and one DOWN navigation node.
  
  def consume_node( tree )
    # do nothing
  end
  
  # A nil was created (even nil nodes have a unique ID...
  # they are not "null" per se).  As of 4/28/2006, this
  # seems to be uniquely triggered when starting a new subtree
  # such as when entering a subrule in automatic mode and when
  # building a tree in rewrite mode.
  # If you are receiving this event over a socket via
  # RemoteDebugEventSocketListener then only tree.ID is set.
  
  def flat_node( tree )
    # do nothing
  end

  # Upon syntax error, recognizers bracket the error with an error node
  # if they are building ASTs.
  
  def error_node( tree )
    # do nothing
  end

  # Announce a new node built from token elements such as type etc...
  # If you are receiving this event over a socket via
  # RemoteDebugEventSocketListener then only tree.ID, type, text are
  # set.
  
  def create_node( node, token = nil )
    # do nothing
  end

  # Make a node the new root of an existing root.
  # Note: the newRootID parameter is possibly different
  # than the TreeAdaptor.becomeRoot() newRoot parameter.
  # In our case, it will always be the result of calling
  # TreeAdaptor.becomeRoot() and not root_n or whatever.
  # The listener should assume that this event occurs
  # only when the current subrule (or rule) subtree is
  # being reset to newRootID.
  # If you are receiving this event over a socket via
  # RemoteDebugEventSocketListener then only IDs are set.
  # @see antlr3.tree.TreeAdaptor.becomeRoot()
  
  def become_root( new_root, old_root )
    # do nothing
  end

  # Make childID a child of rootID.
  # If you are receiving this event over a socket via
  # RemoteDebugEventSocketListener then only IDs are set.
  # @see antlr3.tree.TreeAdaptor.addChild()
  
  def add_child( root, child )
    # do nothing
  end

  # Set the token start/stop token index for a subtree root or node.
  # If you are receiving this event over a socket via
  # RemoteDebugEventSocketListener then only tree.ID is set.
  
  def set_token_boundaries( tree, token_start_index, token_stop_index )
    # do nothing
  end
  
  def examine_rule_memoization( rule )
    # do nothing
  end
  
  def on( event_name, &block )
    sclass = class << self; self; end
    sclass.send( :define_method, event_name, &block )
  end
  
  EVENTS = [ 
    :add_child, :backtrack, :become_root, :begin_backtrack,
    :begin_resync, :commence, :consume_hidden_token,
    :consume_node, :consume_token, :create_node, :end_backtrack,
    :end_resync, :enter_alternative, :enter_decision, :enter_rule,
    :enter_sub_rule, :error_node, :exit_decision, :exit_rule,
    :exit_sub_rule, :flat_node, :location, :look, :mark,
    :recognition_exception, :resync, :rewind,
    :semantic_predicate, :set_token_boundaries, :terminate
  ].freeze

end
end
end
