#!/usr/bin/ruby
# encoding: utf-8

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
unless const_defined?( :RecognizerSharedState )

RecognizerSharedState = Struct.new( 
  :following,
  :error_recovery,
  :last_error_index,
  :backtracking,
  :rule_memory,
  :syntax_errors,
  :token,
  :token_start_position,
  :token_start_line,
  :token_start_column,
  :channel,
  :type,
  :text
)

=begin rdoc ANTLR3::RecognizerSharedState

A big Struct-based class containing most of the data that makes up a
recognizer's state. These attributes are externalized from the recognizer itself
so that recognizer delegation (which occurs when you import other grammars into
your grammar) can function; multiple recognizers can share a common state.

== Structure Attributes

following::
  a stack that tracks follow sets for error recovery
error_recovery::
  a flag indicating whether or not the recognizer is in error recovery mode
last_error_index::
  the index in the input stream of the last error
backtracking::
  tracks the backtracking depth
rule_memory::
  if a grammar is compiled with the memoization option, this will be 
  set to a hash mapping previously parsed rules to cached indices
syntax_errors::
  tracks the number of syntax errors seen so far
token::
  holds newly constructed tokens for lexer rules
token_start_position::
  the input stream index at which the token starts
token_start_line::
  the input stream line number at which the token starts
token_start_column::
  the input stream column at which the token starts
channel::
  the channel value of the target token
type::
  the type value of the target token
text::
  the text of the target token

=end

class RecognizerSharedState
  def initialize
    super( [], false, -1, 0, nil, 0, nil, -1 )
    # ^-- same as this --v 
    # self.following = []
    # self.error_recovery = false
    # self.last_error_index = -1
    # self.backtracking = 0
    # self.syntax_errors = 0
    # self.token_start_position = -1
  end
  
  
  # restores all of the state variables to their respective
  # initial default values
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
  end
end

end # unless const_defined?( :RecognizerSharedState )

=begin rdoc ANTLR3::Recognizer

= Scope

Scope is used to represent instances of ANTLR's various attribute scopes.
It is identical to Ruby's built-in Struct class, but it takes string
attribute declarations from the ANTLR grammar as parameters, and overrides
the #initialize method to set the default values if any are present in
the scope declaration.

  Block = Scope.new( "name", "depth = 0", "variables = {}" )
  Block.new                    # => #<struct Block name=nil, depth=0, variables={}>
  Block.new( "function" )      # => #<struct Block name="function", depth=0, variables={}>
  Block.new( 'a', 1, :x => 3 ) # => #<struct Block name="a", depth=1, variables={ :x => 3 }>

=end

class Scope < ::Struct
  def self.new( *declarations, &body )
    names = []
    defaults = {}
    for decl in declarations
      name, default = decl.to_s.split( /\s*=\s*/, 2 )
      names << ( name = name.to_sym )
      default and defaults[ name ] = default
    end
    super( *names ) do
      
      # If no defaults, leave the initialize method the same as
      # the struct's default initialize for speed. Otherwise,
      # overwrite the initialize to populate with default values.
      unless defaults.empty?
        parameters = names.map do | name |
          "#{ name } = " << defaults.fetch( name, 'nil' )
        end.join( ', ' )
        class_eval( <<-END )
          def initialize( #{ parameters } )
            super( #{ names.join( ', ' ) } )
          end
        END
      end
      
      body and class_eval( &body )
    end
  end
end

=begin rdoc ANTLR3::Recognizer

= Recognizer

As the base class of all ANTLR-generated recognizers, Recognizer provides
much of the shared functionality and structure used in the recognition process.
For all effective purposes, the class and its immediate subclasses Lexer,
Parser, and TreeParser are abstract classes. They can be instantiated, but
they're pretty useless on their own. Instead, to make useful code, you write an
ANTLR grammar and ANTLR will generate classes which inherit from one of the
recognizer base classes, providing the implementation of the grammar rules
itself. this group of classes to implement necessary tasks. Recognizer
defines methods related to:

* token and character matching
* prediction and recognition strategy
* recovering from errors
* reporting errors
* memoization
* simple rule tracing and debugging

=end

class Recognizer
  include Constants
  include Error
  include TokenFactory
  extend ClassMacros
  
  @rules = {}
  
  # inherited class methods and hooks
  class << self
    attr_reader :grammar_file_name,
                :antlr_version,
                :antlr_version_string,
                :library_version_string,
                :grammar_home
    
    attr_accessor :token_scheme, :default_rule
    
    # generated recognizer code uses this method to stamp
    # the code with the name of the grammar file and
    # the current version of ANTLR being used to generate
    # the code
    def generated_using( grammar_file, antlr_version, library_version = nil )
      @grammar_file_name = grammar_file.freeze
      @antlr_version_string = antlr_version.freeze
      @library_version = Util.parse_version( library_version )
      if @antlr_version_string =~ /^(\d+)\.(\d+)(?:\.(\d+)(?:b(\d+))?)?(.*)$/
        @antlr_version = [ $1, $2, $3, $4 ].map! { |str| str.to_i }
        timestamp = $5.strip
        #@antlr_release_time = $5.empty? ? nil : Time.parse($5)
      else
        raise "bad version string: %p" % version_string
      end
    end
    
    # this method is used to generate return-value structures for
    # rules with multiple return values. To avoid generating
    # a special class for ever rule in AST parsers and such
    # (where most rules have the same default set of return values),
    # each recognizer gets a default return value structure
    # assigned to the constant +Return+. Rules which don't
    # require additional custom members will have a rule-return
    # name constant that just points to the generic return
    # value. 
    def define_return_scope( *members )
      if members.empty? then generic_return_scope
      else
        members += return_scope_members
        Struct.new( *members )
      end
    end
    
    # used as a hook to add additional default members
    # to default return value structures
    # For example, all AST-building parsers override
    # this method to add an extra +:tree+ field to
    # all rule return structures.
    def return_scope_members
      [ :start, :stop ]
    end
    
    # sets up and returns the generic rule return
    # scope for a recognizer
    def generic_return_scope
      @generic_return_scope ||= begin
        struct = Struct.new( *return_scope_members )
        const_set( :Return, struct )
      end
    end
    
    def imported_grammars
      @imported_grammars ||= Set.new
    end
    
    def master_grammars
      @master_grammars ||= []
    end
    
    def master
      master_grammars.last
    end
    
    def masters( *grammar_names )
      for grammar in grammar_names
        unless master_grammars.include?( grammar )
          master_grammars << grammar
          attr_reader( Util.snake_case( grammar ) )
        end
      end
    end
    private :masters
    
    def imports( *grammar_names )
      for grammar in grammar_names
        imported_grammars.add?( grammar.to_sym ) and
          attr_reader( Util.snake_case( grammar ) )
      end
      return imported_grammars
    end
    private :imports
    
    def rules
      self::RULE_METHODS.dup rescue []
    end
    
    def default_rule
      @default_rule ||= rules.first
    end
    
    def debug?
      return false
    end
    
    def profile?
      return false
    end
    
    def Scope( *declarations, &body )
      Scope.new( *declarations, &body )
    end
    
    def token_class
      @token_class ||= begin
        self::Token            rescue
        superclass.token_class rescue
        ANTLR3::CommonToken
      end
    end
    private :generated_using
  end
  
  @grammar_file_name = nil
  @antlr_version = ANTLR3::ANTLR_VERSION
  @antlr_version_string = ANTLR3::ANTLR_VERSION_STRING
  
  def grammar_file_name
    self.class.grammar_file_name
  end
  
  def antlr_version
    self.class.antlr_version
  end
  
  def antlr_version_string
    self.class.antlr_version_string
  end
  
  attr_accessor :input
  attr_reader :state
  
  def each_delegate
    block_given? or return enum_for( __method__ )
    for grammar in self.class.imported_grammars
      del = __send__( Util.snake_case( grammar ) ) and
        yield( del )
    end
  end
  
  # Create a new recognizer. The constructor simply ensures that
  # all recognizers are initialized with a shared state object.
  # See the main recognizer subclasses for more specific
  # information about creating recognizer objects like
  # lexers and parsers.
  def initialize( options = {} )
    @state  = options[ :state ] || RecognizerSharedState.new
    @error_output = options.fetch( :error_output, $stderr )
    defined?( @input ) or @input = nil
    initialize_dfas
  end
  
  # Resets the recognizer's state data to initial values.
  # As a result, all error tracking and error recovery
  # data accumulated in the current state will be cleared.
  # It will also attempt to reset the input stream
  # via input.reset, but it ignores any errors received
  # from doing so. Thus the input stream is not guarenteed
  # to be rewound to its initial position
  def reset
    @state and @state.reset!
    @input and @input.reset rescue nil
  end
  
  # Attempt to match the current input symbol the token type
  # specified by +type+. If the symbol matches the type,
  # consume the current symbol and return its value. If
  # the symbol doesn't match, attempt to use the follow-set
  # data provided by +follow+ to recover from the mismatched
  # token. 
  def match( type, follow )
    matched_symbol = current_symbol
    if @input.peek == type
      @input.consume
      @state.error_recovery = false
      return matched_symbol
    end
    raise( BacktrackingFailed ) if @state.backtracking > 0
    return recover_from_mismatched_token( type, follow )
  end
  
  # match anything -- i.e. wildcard match. Simply consume
  # the current symbol from the input stream. 
  def match_any
    @state.error_recovery = false
    @input.consume
  end
  
  ##############################################################################################
  ###################################### Error Reporting #######################################
  ##############################################################################################
  ##############################################################################################
  
  # When a recognition error occurs, this method is the main
  # hook for carrying out the error reporting process. The
  # default implementation calls +display_recognition_error+
  # to display the error info on $stderr. 
  def report_error( e = $! )
    @state.error_recovery and return
    @state.syntax_errors += 1
    @state.error_recovery = true
    display_recognition_error( e )
  end
  
  # error reporting hook for presenting the information
  # The default implementation builds appropriate error
  # message text using +error_header+ and +error_message+,
  # and calls +emit_error_message+ to write the error
  # message out to some source
  def display_recognition_error( e = $! )
    header = error_header( e )
    message = error_message( e )
    emit_error_message( "#{ header } #{ message }" )
  end
  
  # used to construct an appropriate error message
  # based on the specific type of error and the
  # error's attributes
  def error_message( e = $! )
    case e
    when UnwantedToken
      token_name = token_name( e.expecting )
      "extraneous input #{ token_error_display( e.unexpected_token ) } expecting #{ token_name }"
    when MissingToken
      token_name = token_name( e.expecting )
      "missing #{ token_name } at #{ token_error_display( e.symbol ) }"
    when MismatchedToken
      token_name = token_name( e.expecting )
      "mismatched input #{ token_error_display( e.symbol ) } expecting #{ token_name }"
    when MismatchedTreeNode
      token_name = token_name( e.expecting )
      "mismatched tree node: #{ e.symbol } expecting #{ token_name }"
    when NoViableAlternative
      "no viable alternative at input " << token_error_display( e.symbol )
    when MismatchedSet
      "mismatched input %s expecting set %s" %
        [ token_error_display( e.symbol ), e.expecting.inspect ]
    when MismatchedNotSet
      "mismatched input %s expecting set %s" %
        [ token_error_display( e.symbol ), e.expecting.inspect ]
    when FailedPredicate
      "rule %s failed predicate: { %s }?" % [ e.rule_name, e.predicate_text ]
    else e.message
    end
  end
  
  # 
  # used to add a tag to the error message that indicates
  # the location of the input stream when the error
  # occurred
  # 
  def error_header( e = $! )
    e.location
  end
  
  # 
  # formats a token object appropriately for inspection
  # within an error message
  # 
  def token_error_display( token )
    unless text = token.text || ( token.source_text rescue nil )
      text =
        case
        when token.type == EOF then '<EOF>'
        when name = token_name( token.type ) rescue nil then "<#{ name }>"
        when token.respond_to?( :name ) then "<#{ token.name }>"
        else "<#{ token.type }>"
        end
    end
    return text.inspect
  end
  
  # 
  # Write the error report data out to some source. By default,
  # the error message is written to $stderr
  # 
  def emit_error_message( message )
    @error_output.puts( message ) if @error_output
  end
  
  ##############################################################################################
  ###################################### Error Recovery ########################################
  ##############################################################################################
  
  def recover( error = $! )
    @state.last_error_index == @input.index and @input.consume
    @state.last_error_index = @input.index
    
    follow_set = compute_error_recovery_set
    
    resync { consume_until( follow_set ) }
  end
  
  def resync
    begin_resync
    return( yield )
  ensure
    end_resync
  end
  
  # overridable hook method that is executed at the start of the
  # resyncing procedure in recover
  #
  # by default, it does nothing
  def begin_resync
    # do nothing
  end
  
  # overridable hook method that is after the resyncing procedure has completed
  #
  # by default, it does nothing
  def end_resync
    # do nothing
  end
  
  # (The following explanation has been lifted directly from the
  #  source code documentation of the ANTLR Java runtime library)
  # 
  # Compute the error recovery set for the current rule.  During
  # rule invocation, the parser pushes the set of tokens that can
  # follow that rule reference on the stack; this amounts to
  # computing FIRST of what follows the rule reference in the
  # enclosing rule. This local follow set only includes tokens
  # from within the rule; i.e., the FIRST computation done by
  # ANTLR stops at the end of a rule.
  # 
  # EXAMPLE
  # 
  # When you find a "no viable alt exception", the input is not
  # consistent with any of the alternatives for rule r.  The best
  # thing to do is to consume tokens until you see something that
  # can legally follow a call to r *or* any rule that called r.
  # You don't want the exact set of viable next tokens because the
  # input might just be missing a token--you might consume the
  # rest of the input looking for one of the missing tokens.
  # 
  # Consider grammar:
  # 
  #   a : '[' b ']'
  #     | '(' b ')'
  #     ;
  #   b : c '^' INT ;
  #   c : ID
  #     | INT
  #     ;
  # 
  # At each rule invocation, the set of tokens that could follow
  # that rule is pushed on a stack.  Here are the various "local"
  # follow sets:
  # 
  #   FOLLOW( b1_in_a ) = FIRST( ']' ) = ']'
  #   FOLLOW( b2_in_a ) = FIRST( ')' ) = ')'
  #   FOLLOW( c_in_b ) = FIRST( '^' ) = '^'
  # 
  # Upon erroneous input "[]", the call chain is
  # 
  #   a -> b -> c
  # 
  # and, hence, the follow context stack is:
  # 
  #   depth  local follow set     after call to rule
  #     0         \<EOF>                   a (from main( ) )
  #     1          ']'                     b
  #     3          '^'                     c
  # 
  # Notice that <tt>')'</tt> is not included, because b would have to have
  # been called from a different context in rule a for ')' to be
  # included.
  # 
  # For error recovery, we cannot consider FOLLOW(c)
  # (context-sensitive or otherwise).  We need the combined set of
  # all context-sensitive FOLLOW sets--the set of all tokens that
  # could follow any reference in the call chain.  We need to
  # resync to one of those tokens.  Note that FOLLOW(c)='^' and if
  # we resync'd to that token, we'd consume until EOF.  We need to
  # sync to context-sensitive FOLLOWs for a, b, and c: {']','^'}.
  # In this case, for input "[]", LA(1) is in this set so we would
  # not consume anything and after printing an error rule c would
  # return normally.  It would not find the required '^' though.
  # At this point, it gets a mismatched token error and throws an
  # exception (since LA(1) is not in the viable following token
  # set).  The rule exception handler tries to recover, but finds
  # the same recovery set and doesn't consume anything.  Rule b
  # exits normally returning to rule a.  Now it finds the ']' (and
  # with the successful match exits errorRecovery mode).
  # 
  # So, you cna see that the parser walks up call chain looking
  # for the token that was a member of the recovery set.
  # 
  # Errors are not generated in errorRecovery mode.
  # 
  # ANTLR's error recovery mechanism is based upon original ideas:
  # 
  # "Algorithms + Data Structures = Programs" by Niklaus Wirth
  # 
  # and
  # 
  # "A note on error recovery in recursive descent parsers":
  # http://portal.acm.org/citation.cfm?id=947902.947905
  # 
  # Later, Josef Grosch had some good ideas:
  # 
  # "Efficient and Comfortable Error Recovery in Recursive Descent
  # Parsers":
  # ftp://www.cocolab.com/products/cocktail/doca4.ps/ell.ps.zip
  # 
  # Like Grosch I implemented local FOLLOW sets that are combined
  # at run-time upon error to avoid overhead during parsing.
  def compute_error_recovery_set
    combine_follows( false )
  end
  
  def recover_from_mismatched_token( type, follow )
    if mismatch_is_unwanted_token?( type )
      err = UnwantedToken( type )
      resync { @input.consume }
      report_error( err )
      
      return @input.consume
    end
    
    if mismatch_is_missing_token?( follow )
      inserted = missing_symbol( nil, type, follow )
      report_error( MissingToken( type, inserted ) )
      return inserted
    end
    
    raise MismatchedToken( type )
  end
  
  def recover_from_mismatched_set( e, follow )
    if mismatch_is_missing_token?( follow )
      report_error( e )
      return missing_symbol( e, INVALID_TOKEN_TYPE, follow )
    end
    raise e
  end
  
  def recover_from_mismatched_element( e, follow )
    follow.nil? and return false
    if follow.include?( EOR_TOKEN_TYPE )
      viable_tokens = compute_context_sensitive_rule_follow
      follow = ( follow | viable_tokens ) - Set[ EOR_TOKEN_TYPE ]
    end
    if follow.include?( @input.peek )
      report_error( e )
      return true
    end
    return false
  end
  
  # Conjure up a missing token during error recovery.
  # 
  # The recognizer attempts to recover from single missing
  # symbols. But, actions might refer to that missing symbol.
  # For example, x=ID {f($x);}. The action clearly assumes
  # that there has been an identifier matched previously and that
  # $x points at that token. If that token is missing, but
  # the next token in the stream is what we want we assume that
  # this token is missing and we keep going. Because we
  # have to return some token to replace the missing token,
  # we have to conjure one up. This method gives the user control
  # over the tokens returned for missing tokens. Mostly,
  # you will want to create something special for identifier
  # tokens. For literals such as '{' and ',', the default
  # action in the parser or tree parser works. It simply creates
  # a CommonToken of the appropriate type. The text will be the token.
  # If you change what tokens must be created by the lexer,
  # override this method to create the appropriate tokens.
  def missing_symbol( error, expected_token_type, follow )
    return nil
  end
  
  def mismatch_is_unwanted_token?( type )
    @input.peek( 2 ) == type
  end
  
  def mismatch_is_missing_token?( follow )
    follow.nil? and return false
    if follow.include?( EOR_TOKEN_TYPE )
      viable_tokens = compute_context_sensitive_rule_follow
      follow = follow | viable_tokens
      
      follow.delete( EOR_TOKEN_TYPE ) unless @state.following.empty?
    end
    if follow.include?( @input.peek ) or follow.include?( EOR_TOKEN_TYPE )
      return true
    end
    return false
  end
  
  def syntax_errors?
    ( error_count = @state.syntax_errors ) > 0 and return( error_count )
  end
  
  # factor out what to do upon token mismatch so
  # tree parsers can behave differently.
  #
  # * override this method in your parser to do things
  #	  like bailing out after the first error
  #	* just raise the exception instead of
  #	  calling the recovery method.
  #
  def number_of_syntax_errors
    @state.syntax_errors
  end
  
  # 
  # Compute the context-sensitive +FOLLOW+ set for current rule.
  # This is set of token types that can follow a specific rule
  # reference given a specific call chain.  You get the set of
  # viable tokens that can possibly come next (look depth 1)
  # given the current call chain.  Contrast this with the
  # definition of plain FOLLOW for rule r:
  # 
  #    FOLLOW(r)={x | S=>*alpha r beta in G and x in FIRST(beta)}
  # 
  # where x in T* and alpha, beta in V*; T is set of terminals and
  # V is the set of terminals and nonterminals.  In other words,
  # FOLLOW(r) is the set of all tokens that can possibly follow
  # references to r in *any* sentential form (context).  At
  # runtime, however, we know precisely which context applies as
  # we have the call chain.  We may compute the exact (rather
  # than covering superset) set of following tokens.
  # 
  # For example, consider grammar:
  # 
  #   stat : ID '=' expr ';'      // FOLLOW(stat)=={EOF}
  #        | "return" expr '.'
  #        ;
  #   expr : atom ('+' atom)* ;   // FOLLOW(expr)=={';','.',')'}
  #   atom : INT                  // FOLLOW(atom)=={'+',')',';','.'}
  #        | '(' expr ')'
  #        ;
  # 
  # The FOLLOW sets are all inclusive whereas context-sensitive
  # FOLLOW sets are precisely what could follow a rule reference.
  # For input input "i=(3);", here is the derivation:
  # 
  #   stat => ID '=' expr ';'
  #        => ID '=' atom ('+' atom)* ';'
  #        => ID '=' '(' expr ')' ('+' atom)* ';'
  #        => ID '=' '(' atom ')' ('+' atom)* ';'
  #        => ID '=' '(' INT ')' ('+' atom)* ';'
  #        => ID '=' '(' INT ')' ';'
  # 
  # At the "3" token, you'd have a call chain of
  # 
  #   stat -> expr -> atom -> expr -> atom
  # 
  # What can follow that specific nested ref to atom?  Exactly ')'
  # as you can see by looking at the derivation of this specific
  # input.  Contrast this with the FOLLOW(atom)={'+',')',';','.'}.
  # 
  # You want the exact viable token set when recovering from a
  # token mismatch.  Upon token mismatch, if LA(1) is member of
  # the viable next token set, then you know there is most likely
  # a missing token in the input stream.  "Insert" one by just not
  # throwing an exception.
  # 
  def compute_context_sensitive_rule_follow
    combine_follows true
  end
  
  def combine_follows( exact )
    follow_set = Set.new
    @state.following.each_with_index.reverse_each do |local_follow_set, index|
      follow_set |= local_follow_set
      if exact
        if local_follow_set.include?( EOR_TOKEN_TYPE )
          follow_set.delete( EOR_TOKEN_TYPE ) if index > 0
        else
          break
        end
      end
    end
    return follow_set
  end
  
  # 
  # Match needs to return the current input symbol, which gets put
  # into the label for the associated token ref; e.g., x=ID.  Token
  # and tree parsers need to return different objects. Rather than test
  # for input stream type or change the IntStream interface, I use
  # a simple method to ask the recognizer to tell me what the current
  # input symbol is.
  # 
  # This is ignored for lexers.
  # 
  def current_symbol
    @input.look
  end
  
  # 
  # Consume input symbols until one matches a type within types
  # 
  # types can be a single symbol type or a set of symbol types
  # 
  def consume_until( types )
    types.is_a?( Set ) or types = Set[ *types ]
    type = @input.peek
    until type == EOF or types.include?( type )
      @input.consume
      type = @input.peek
    end
    return( type )
  end
  
  # 
  # Returns true if the recognizer is currently in a decision for which
  # backtracking has been enabled
  # 
  def backtracking?
    @state.backtracking > 0
  end
  
  def backtracking_level
    @state.backtracking
  end
  
  def backtracking_level=( n )
    @state.backtracking = n
  end
  
  def backtrack
    @state.backtracking += 1
    start = @input.mark
    success =
      begin yield
      rescue BacktrackingFailed then false
      else true
      end
    return success
  ensure
    @input.rewind( start )
    @state.backtracking -= 1
  end
  
  def syntactic_predicate?( name )
    backtrack { send name }
  end
  
  alias backtracking backtracking_level
  alias backtracking= backtracking_level=
  
  def rule_memoization( rule, start_index )
    @state.rule_memory.fetch( rule ) do
      @state.rule_memory[ rule ] = Hash.new( MEMO_RULE_UNKNOWN )
    end[ start_index ]
  end
  
  def already_parsed_rule?( rule )
    stop_index = rule_memoization( rule, @input.index )
    case stop_index
    when MEMO_RULE_UNKNOWN then return false
    when MEMO_RULE_FAILED
      raise BacktrackingFailed
    else
      @input.seek( stop_index + 1 )
    end
    return true
  end
  
  def memoize( rule, start_index, success )
    stop_index = success ? @input.index - 1 : MEMO_RULE_FAILED
    memo = @state.rule_memory[ rule ] and memo[ start_index ] = stop_index
  end
  
  def trace_in( rule_name, rule_index, input_symbol )
    @error_output.printf( "--> enter %s on %s", rule_name, input_symbol )
    @state.backtracking > 0 and @error_output.printf( 
      " (in backtracking mode: depth = %s)", @state.backtracking
    )
    @error_output.print( "\n" )
  end
  
  def trace_out( rule_name, rule_index, input_symbol )
    @error_output.printf( "<-- exit %s on %s", rule_name, input_symbol )
    @state.backtracking > 0 and @error_output.printf( 
      " (in backtracking mode: depth = %s)", @state.backtracking
    )
    @error_output.print( "\n" )
  end
  
private
  
  def initialize_dfas
    # do nothing
  end
end


# constant alias for compatibility with older versions of the
# runtime library
BaseRecognizer = Recognizer

=begin rdoc ANTLR3::Lexer

= Lexer

Lexer is the default superclass of all lexers generated by ANTLR. The class
tailors the core functionality provided by Recognizer to the task of
matching patterns in the text input and breaking the input into tokens.

== About Lexers

A lexer's job is to take input text and break it up into _tokens_ -- objects
that encapsulate a piece of text, a type label (such as ID or INTEGER), and the
position of the text with respect to the input. Thus, a lexer is essentially a
complicated iterator that steps through an input stream and produces a sequence
of tokens. Sometimes lexers are enough to carry out a goal on their own, such as
tasks like source code highlighting and simple code analysis. Usually, however,
the lexer converts text into tokens for use by a parser, which recognizes larger
structures within the text.

ANTLR parsers have a variety of entry points specified by parser rules, each of
which defines the structure of a specific type of sentence in a grammar. Lexers,
however, are primarily intended to have a single entry point. It looks at the
characters starting at the current input position, decides if the chunk of text
matches one of a number of possible token type definitions, wraps the chunk into
a token with information on its type and location, and advances the input stream
to the next place.

== ANTLR Lexers and the Lexer API

ANTLR-generated lexers will subclass this class, unless specified otherwise
within a grammar file. The generated class will provide an implementation of
each lexer rule as a method of the same name. The subclass will also provide an
implementation for the abstract method #m_tokens, the purpose of which is to
multiplex the token type definitions and predict what rule definition to execute
to fetch a token. The primary method in the lexer API, #next_token, uses
#m_tokens to fetch the next token and drive the iteration.

If the lexer is preparing tokens for use by an ANTLR generated parser, the lexer
will generally be used to build a TokenStream object. The following code example
demonstrates the typical setup for using ANTLR parsers and lexers in Ruby.
  
  # in HypotheticalLexer.rb
  module Hypothetical
  class Lexer < ANTLR3::Lexer
    # ...
    # ANTLR generated code
    # ...
  end
  end
  
  # in HypotheticalParser.rb
  module Hypothetical
  class Parser < ANTLR3::Parser
    # ...
    # more ANTLR generated code
    # ...
  end
  end
  
  # to take hypothetical source code and prepare it for parsing,
  # there is generally a four-step construction process
  
  source = "some hypothetical source code"
  input = ANTLR3::StringStream.new(source, :file => 'blah-de-blah.hyp')
  lexer = Hypothetical::Lexer.new( input )
  tokens = ANTLR3::CommonTokenStream.new( lexer )
  parser = Hypothetical::Parser.new( tokens )
  
  # if you're using the standard streams, ANTLR3::StringStream and
  # ANTLR3::CommonTokenStream, you can write the same process 
  # shown above more succinctly:
  
  lexer  = Hypothetical::Lexer.new("some hypothetical source code", :file => 'blah-de-blah.hyp')
  parser = Hypothetical::Parser.new( lexer )

=end
class Lexer < Recognizer
  include TokenSource
  @token_class = CommonToken
  
  def self.default_rule
    @default_rule ||= :token!
  end
  
  def self.main( argv = ARGV, options = {} )
    if argv.is_a?( ::Hash ) then argv, options = ARGV, argv end
    main = ANTLR3::Main::LexerMain.new( self, options )
    block_given? ? yield( main ) : main.execute( argv )
  end
  
  def self.associated_parser
    @associated_parser ||= begin
      @grammar_home and @grammar_home::Parser
    rescue NameError
      grammar_name = @grammar_home.name.split( "::" ).last
      begin
        require "#{ grammar_name }Parser"
        @grammar_home::Parser
      rescue LoadError, NameError
      end
    end
  end

  def initialize( input, options = {} )
    super( options )
    @input = cast_input( input, options )
  end
  
  def current_symbol
    nil
  end
  
  def next_token
    loop do
      @state.token = nil
      @state.channel = DEFAULT_CHANNEL
      @state.token_start_position = @input.index
      @state.token_start_column = @input.column
      @state.token_start_line = @input.line
      @state.text = nil
      @input.peek == EOF and return EOF_TOKEN
      begin
        token!
        
        case token = @state.token
        when nil then return( emit )
        when SKIP_TOKEN then next
        else
          return token
        end
      rescue NoViableAlternative => re
        report_error( re )
        recover( re )
      rescue Error::RecognitionError => re
        report_error( re )
      end
    end
  end
  
  def skip
    @state.token = SKIP_TOKEN
  end
  
  abstract :token!
  
  def exhaust
    self.to_a
  end
  
  def char_stream=( input )
    @input = nil
    reset()
    @input = input
  end
  
  def source_name
    @input.source_name
  end
  
  def emit( token = @state.token )
    token ||= create_token
    @state.token = token
    return token
  end
  
  def match( expected )
    case expected
    when String
      expected.each_byte do |char|
        unless @input.peek == char
          @state.backtracking > 0 and raise BacktrackingFailed
          error = MismatchedToken( char )
          recover( error )
          raise error
        end
        @input.consume()
      end
    else # single integer character
      unless @input.peek == expected
        @state.backtracking > 0 and raise BacktrackingFailed
        error = MismatchedToken( expected )
        recover( error )
        raise error
      end
      @input.consume
    end
    return true
  end
    
  def match_any
    @input.consume
  end
  
  def match_range( min, max )
    char = @input.peek
    if char.between?( min, max ) then @input.consume
    else
      @state.backtracking > 0 and raise BacktrackingFailed
      error = MismatchedRange( min.chr, max.chr )
      recover( error )
      raise( error )
    end
    return true
  end
  
  def line
    @input.line
  end
  
  def column
    @input.column
  end
  
  def character_index
    @input.index
  end
  
  def text
    @state.text and return @state.text
    @input.substring( @state.token_start_position, character_index - 1 )
  end
  
  def text=( text )
    @state.text = text
  end
  
  def report_error( e )
    display_recognition_error( e )
  end
  
  def error_message( e )
    char = character_error_display( e.symbol ) rescue nil
    case e
    when Error::MismatchedToken
      expecting = character_error_display( e.expecting )
      "mismatched character #{ char }; expecting #{ expecting }"
    when Error::NoViableAlternative
      "no viable alternative at character #{ char }"
    when Error::EarlyExit
      "required ( ... )+ loop did not match anything at character #{ char }"
    when Error::MismatchedNotSet
      "mismatched character %s; expecting set %p" % [ char, e.expecting ]
    when Error::MismatchedSet
      "mismatched character %s; expecting set %p" % [ char, e.expecting ]
    when Error::MismatchedRange
      a = character_error_display( e.min )
      b = character_error_display( e.max )
      "mismatched character %s; expecting set %s..%s" % [ char, a, b ]
    else super
    end
  end
  
  def character_error_display( char )
    case char
    when EOF then '<EOF>'
    when Integer then char.chr.inspect
    else char.inspect
    end
  end
  
  def recover( re )
    @input.consume
  end
  
  alias input= char_stream=
  
private
  
  def cast_input( input, options )
    case input
    when CharacterStream then input
    when ::String then StringStream.new( input, options )
    when ::IO, ARGF then FileStream.new( input, options )
    else input
    end
  end
  
  def trace_in( rule_name, rule_index )
    if symbol = @input.look and symbol != EOF then symbol = symbol.inspect
    else symbol = '<EOF>' end
    input_symbol = "#{ symbol } @ line #{ line } / col #{ column }"
    super( rule_name, rule_index, input_symbol )
  end
  
  def trace_out( rule_name, rule_index )
    if symbol = @input.look and symbol != EOF then symbol = symbol.inspect
    else symbol = '<EOF>' end
    input_symbol = "#{ symbol } @ line #{ line } / col #{ column }"
    super( rule_name, rule_index, input_symbol )
  end
  
  def create_token( &b )
    if block_given? then super( &b )
    else
      super do |t|
        t.input = @input
        t.type = @state.type
        t.channel = @state.channel
        t.start = @state.token_start_position
        t.stop = @input.index - 1
        t.line = @state.token_start_line
        t.text = self.text
        t.column = @state.token_start_column
      end
    end
  end
end


=begin rdoc ANTLR3::Parser

= Parser

Parser is the default base class of ANTLR-generated parser classes. The class
tailors the functionality provided by Recognizer to the task of parsing.

== About Parsing

This is just a lose overview of parsing. For considerably more in-depth coverage
of the topic, read the ANTLR documentation or check out the ANTLR website
(http://www.antlr.org).

A grammar defines the vocabulary and the sentence structure of a language. While
a lexer concerns the basic vocabulary symbols of the language, a parser's
primary task is to implement the sentence structure.

Parsers are set up by providing a stream of tokens, which is usually created by
a corresponding lexer. Then, the user requests a specific sentence-structure
within the grammar, such as "class_definition" or "xml_node", from the parser.
It iterates through the tokens, verifying the syntax of the sentence and
performing actions specified by the grammar. It stops when it encounters an
error or when it has matched the full sentence according to its defined
structure.

== ANTLR Parsers and the Parser API

Plain ANTLR-generated parsers directly subclass this class, unless specified
otherwise within the grammar options. The generated code will provide a method
for each parser rule defined in the ANTLR grammar, as well as any other
customized member attributes and methods specified in the source grammar.

This class does not override much of the functionality in Recognizer, and
thus the API closely mirrors Recognizer.

=end
class Parser < Recognizer
  def self.main( argv = ARGV, options = {} )
    if argv.is_a?( ::Hash ) then argv, options = ARGV, argv end
    main = ANTLR3::Main::ParserMain.new( self, options )
    block_given? ? yield( main ) : main.execute( argv )
  end
  
  def self.associated_lexer
    @associated_lexer ||= begin
      @grammar_home and @grammar_home::Lexer
    rescue NameError
      grammar_name = @grammar_home.name.split( "::" ).last
      begin
        require "#{ grammar_name }Lexer"
        @grammar_home::Lexer
      rescue LoadError, NameError
      end
    end
  end
  
  
  def initialize( input, options = {} )
    super( options )
    @input = nil
    reset
    @input = cast_input( input, options )
  end
  
  def missing_symbol( error, expected_type, follow )
    current = @input.look
    current = @input.look( -1 ) if current == ANTLR3::EOF_TOKEN
    t =
      case
      when current && current != ANTLR3::EOF_TOKEN then current.clone
      when @input.token_class then @input.token_class.new
      else ( create_token rescue CommonToken.new )
      end
    
    t.type = expected_type
    name = t.name.gsub( /(^<)|(>$)/,'' )
    t.text = "<missing #{ name }>"
    t.channel = DEFAULT_CHANNEL
    return( t )
  end
  
  def token_stream=( input )
    @input = nil
    reset
    @input = input
  end
  alias token_stream input
  
  def source_name
    @input.source_name
  end
  
  
private
  
  def trace_in( rule_name, rule_index )
    super( rule_name, rule_index, @input.look.inspect )
  end
  
  def trace_out( rule_name, rule_index )
    super( rule_name, rule_index, @input.look.inspect )
  end
  
  def cast_input( input, options )
    case input
    when TokenStream then input
    when TokenSource then CommonTokenStream.new( input, options )
    when IO, String, CharacterStream
      if lexer_class = self.class.associated_lexer
        CommonTokenStream.new( lexer_class.new( input, options ), options )
      else
        raise ArgumentError, Util.tidy( <<-END, true )
        | unable to automatically convert input #{ input.inspect }
        | to a ANTLR3::TokenStream object as #{ self.class }
        | does not appear to have an associated lexer class
        END
      end
    else
      # assume it's a stream if it at least implements peek and consume
      unless input.respond_to?( :peek ) and input.respond_to?( :consume )
        raise ArgumentError, Util.tidy( <<-END, true )
        | #{ self.class } requires a token stream as input, but
        | #{ input.inspect } was provided
        END
      end
      input
    end
  end
  
end

end
