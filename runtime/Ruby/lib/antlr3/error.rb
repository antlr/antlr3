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

# ANTLR3 exception hierarchy
# - ported from the ANTLR3 Python Runtime library by
#   Kyle Yetter (kcy5b@yahoo.com)
module ANTLR3

# for compatibility with rubinius, which does not implement StopIteration yet
unless defined?( StopIteration )
  StopIteration = Class.new( StandardError )
end

module Error

=begin rdoc ANTLR3::Error::BacktrackingFailed

error:: BacktrackingFailed
used by:: all recognizers
occurs when::
  recognizer is in backtracking mode (i.e. r.state.backtracking > 0)
  and the decision path the recognizer is currently attempting
  hit a point of failure
notes::
  - functions more as an internal signal, simillar to exception
    classes such as StopIteration and SystemExit
  - used to inform the recognizer that it needs to rewind
    the input to the point at which it started the decision
    and then either try another possible decision path or
    declare failure
  - not a subclass of RecognitionError

=end

class BacktrackingFailed < StandardError; end
  
  # To avoid English-only error messages and to generally make things
  # as flexible as possible, these exceptions are not created with strings,
  # but rather the information necessary to generate an error.  Then
  # the various reporting methods in Parser and Lexer can be overridden
  # to generate a localized error message.  For example, MismatchedToken
  # exceptions are built with the expected token type.
  # So, don't expect getMessage() to return anything.
  #
  # Note that as of Java 1.4, you can access the stack trace, which means
  # that you can compute the complete trace of rules from the start symbol.
  # This gives you considerable context information with which to generate
  # useful error messages.
  #
  # ANTLR generates code that throws exceptions upon recognition error and
  # also generates code to catch these exceptions in each rule.  If you
  # want to quit upon first error, you can turn off the automatic error
  # handling mechanism using rulecatch action, but you still need to
  # override methods mismatch and recoverFromMismatchSet.
  #
  # In general, the recognition exceptions can track where in a grammar a
  # problem occurred and/or what was the expected input.  While the parser
  # knows its state (such as current input symbol and line info) that
  # state can change before the exception is reported so current token index
  # is computed and stored at exception time.  From this info, you can
  # perhaps print an entire line of input not just a single token, for example.
  # Better to just say the recognizer had a problem and then let the parser
  # figure out a fancy report.

=begin rdoc ANTLR3::Error::RecognitionError

The base class of the variety of syntax errors that can occur during the
recognition process. These errors all typically concern an expectation built in
to the recognizer by the rules of a grammar and an input symbol which failed to
fit the expectation.

=end

class RecognitionError < StandardError
  include ANTLR3::Constants
  attr_accessor :input, :index, :line, :column, :symbol, :token, :source_name
  
  def initialize( input = nil )
    @index = @line =  @column = nil
    @approximate_line_info = false
    if @input = input
      @index = input.index
      @source_name = @input.source_name rescue nil
      case @input
      when TokenStream
        @token = @symbol = input.look
        @line   = @symbol.line
        @column = @symbol.column
      when CharacterStream
        @token = @symbol = input.peek || EOF
        @line   = @input.line
        @column = @input.column
      when AST::TreeNodeStream
        @symbol = @input.look
        if @symbol.respond_to?( :line ) and @symbol.respond_to?( :column )
          @line, @column = @symbol.line, @symbol.column
        else
          extract_from_node_stream( @input )
        end
      else
        @symbol = @input.look
        if @symbol.respond_to?( :line ) and @symbol.respond_to?( :column )
          @line, @column = @symbol.line, @symbol.column
        elsif @input.respond_to?( :line ) and @input.respond_to?( :column )
          @line, @column = @input.line, @input.column
        end
      end
    end
    super( message )
  end
  
  def approximate_line_info?
    @approximate_line_info
  end
  
  def unexpected_type
    case @input
    when TokenStream
      @symbol.type
    when AST::TreeNodeStream
      adaptor = @input.adaptor
      return adaptor.type( @symbol )
    else
      return @symbol
    end
  end
  
  def location
    if @source_name then "in #@source_name @ line #@line:#@column"
    else "line #@line:#@column"
    end
  end
  
  alias inspect message
  
private
  
  def extract_from_node_stream( nodes )
    adaptor = nodes.adaptor
    payload = adaptor.token( @symbol )
    
    if payload
      @token = payload
      if payload.line <= 0
        i = -1
        while prior_node = nodes.look( i )
          prior_payload = adaptor.token( prior_node )
          if prior_payload and prior_payload.line > 0
            @line = prior_payload.line
            @column = prior_payload.column
            @approximate_line_info = true
            break
          end
          i -= 1
        end
      else
        @line = payload.line
        @column = payload.column
      end
    elsif @symbol.is_a?( AST::Tree )
      @line = @symbol.line
      @column = @symbol.column
      @symbol.is_a?( AST::CommonTree ) and @token = @symbol.token
    else
      type = adaptor.type( @symbol )
      text = adaptor.text( @symbol )
      token_class = @input.token_class rescue CommonToken
      @token = token_class.new
      @token.type = type
      @token.text = text
      @token
    end
  end
end

=begin rdoc ANTLR3::Error::MismatchedToken

type:: MismatchedToken
used by:: lexers and parsers
occurs when::
  The recognizer expected to match a symbol <tt>x</tt> at the current input
  position, but it saw a different symbol <tt>y</tt> instead.

=end

class MismatchedToken < RecognitionError
  attr_reader :expecting
  
  def initialize( expecting, input )
    @expecting = expecting
    super( input )
  end
  
  def message
    "%s: %p %p" % [ self.class, unexpected_type, @expecting.inspect ]
  end
end

=begin rdoc ANTLR3::Error::UnwantedToken

TODO: this does not appear to be used by any code

=end

class UnwantedToken < MismatchedToken
  def unexpected_token
    return @token
  end
  
  def message
    exp = @expecting == INVALID_TOKEN_TYPE ? '' : ", expected %p" % @expecting
    text = @symbol.text rescue nil
    "%s: found=%p%s" % [ self.class, text, exp ]
  end
end

=begin rdoc ANTLR3::Error::MissingToken

error:: MissingToken
used by:: parsers and tree parsers
occurs when::
  The recognizer expected to match some symbol, but it sees a different symbol.
  The symbol it sees is actually what the recognizer expected to match next.

=== Example

grammar:

  grammar MissingTokenExample;

  options { language = Ruby; }
  
  @members {
    def report_error(e)
      raise e
    end
  }
  
  missing: A B C;
  
  A: 'a';
  B: 'b';
  C: 'c';

in ruby:

  require 'MissingTokenExampleLexer'
  require 'MissingTokenExampleParser'
  
  lexer = MissingTokenExample::Lexer.new( "ac" )  # <= notice the missing 'b'
  tokens = ANTLR3::CommonTokenStream.new( lexer )
  parser = MissingTokenExample::Parser.new( tokens )
  
  parser.missing
  # raises ANTLR3::Error::MissingToken: at "c"

=end

class MissingToken < MismatchedToken
  attr_accessor :inserted
  def initialize( expecting, input, inserted )
    super( expecting, input )
    @inserted = inserted
  end
  
  def missing_type
    return @expecting
  end
  
  def message
    if @inserted and @symbol
      "%s: inserted %p at %p" %
        [ self.class, @inserted, @symbol.text ]
    else
      msg = self.class.to_s
      msg << ': at %p' % token.text unless @token.nil?
      return msg
    end
  end
end

=begin rdoc ANTLR3::Error::MismatchedRange

error:: MismatchedRange
used by:: all recognizers 
occurs when::
  A recognizer expected to match an input symbol (either a character value or
  an integer token type value) that falls into a range of possible values, but
  instead it saw a symbol that falls outside the expected range.

=end

class MismatchedRange < RecognitionError
  attr_accessor :min, :max
  def initialize( min, max, input )
    @min = min
    @max = max
    super( input )
  end
  
  def message
    "%s: %p not in %p..%p" %
      [ self.class, unexpected_type, @min, @max ]
  end
end

=begin rdoc ANTLR3::Error::MismatchedSet

error:: MismatchedSet
used by:: all recognizers
occurs when::
  A recognizer expects the current input symbol to be a member of a set of
  possible symbol values, but the current symbol does not match.

=end

class MismatchedSet < RecognitionError
  attr_accessor :expecting
  def initialize( expecting, input )
    super( input )
    @expecting = expecting
  end
  
  def message
    "%s: %p not in %p" %
      [ self.class, unexpected_type, @expecting ]
  end
end

=begin rdoc ANTLR3::Error::MismatchedNotSet

error:: MismatchedNotSet
used by:: all recognizers
occurs when::
  A recognizer expected to match symbol that is not in some set of symbols but
  failed.

=end

class MismatchedNotSet < MismatchedSet
  def message
    '%s: %p != %p' %
      [ self.class, unexpected_type, @expecting ]
  end
end

=begin rdoc ANTLR3::Error::NoViableAlternative

error:: NoViableAlternative
used by:: all recognizers
occurs when::
  A recognizer must choose between multiple possible recognition paths based
  upon the current and future input symbols, but it has determined that
  the input does not suit any of the possible recognition alternatives.

In ANTLR terminology, a rule is composed of one or more _alternatives_,
specifications seperated by <tt>|</tt> characters. An alternative is composed of
a series of elements, including _subrules_ -- rule specifications enclosed
within parentheses. When recognition code enters a rule method (or a subrule
block) that has multiple alternatives, the recognizer must decide which one of
the multiple possible paths to follow by checking a number of future input
symbols. Thus, NoViableAlternative errors indicate that the current input does
not fit any of the possible paths.

In lexers, this error is often raised by the main +tokens!+ rule, which must
choose between all possible token rules. If raised by +tokens+, it means the
current input does not appear to be part of any token specification.

=end

class NoViableAlternative < RecognitionError
  attr_accessor :grammar_decision_description, :decision_number, :state_number
  def initialize( grammar_decision_description, decision_number, state_number, input )
    @grammar_decision_description = grammar_decision_description
    @decision_number = decision_number
    @state_number = state_number
    super( input )
  end
  
  def message
    '%s: %p != [%p]' %
      [ self.class, unexpected_type, @grammar_decision_description ]
  end
end

=begin rdoc ANTLR3::Error::EarlyExit

error:: EarlyExit
used by:: all recognizers
occurs when::
  The recognizer is in a <tt>(..)+</tt> subrule, meaning the recognizer must
  match the body of the subrule one or more times. If it fails to match at least
  one occurence of the subrule, the recognizer will raise an EarlyExit
  exception.

== Example

consider a grammar like:
  lexer grammar EarlyExitDemo;
  ...
  ID: 'a'..'z' ('0'..'9')+;
  
now in ruby

  require 'EarlyExitDemo'
  
  input = ANTLR3::StringStream.new( "ab" )
  lexer = EarlyExitDemo::Lexer.new( input )
  lexer.next_token
  # -> raises EarlyExit: line 1:1 required (...)+ loop did not match 
  #                      anything at character "b"

=end

class EarlyExit < RecognitionError
  attr_accessor :decision_number
  
  def initialize( decision_number, input )
    @decision_number = decision_number
    super( input )
  end
  
  def message
    "The recognizer did not match anything for a (..)+ loop."
  end
  
end

=begin rdoc ANTLR3::Error::FailedPredicate

error:: FailedPredicate
used by:: all recognizers
occurs when::
  A recognizer is in a rule with a predicate action element, and the predicating
  action code evaluated to a +false+ value.

=end

class FailedPredicate < RecognitionError
  attr_accessor :input, :rule_name, :predicate_text
  def initialize( input, rule_name, predicate_text )
    @rule_name = rule_name
    @predicate_text = predicate_text
    super( input )
  end
  
  def inspect
    '%s(%s, { %s }?)' % [ self.class.name, @rule_name, @predicate_text ]
  end
  
  def message
    "rule #@rule_name failed predicate: { #@predicate_text }?"
  end
end

=begin rdoc ANTLR3::Error::MismatchedTreeNode

error:: MismatchedTreeNode
used by:: tree parsers
occurs when::
  A tree parser expects to match a tree node containing a specific type of
  token, but the current tree node's token type does not match. It's essentially
  the same as MismatchedToken, but used specifically for tree nodes.

=end

class MismatchedTreeNode < RecognitionError
  attr_accessor :expecting, :input
  def initialize( expecting, input )
    @expecting = expecting
    super( input )
  end
  
  def message
    '%s: %p != %p' %
      [ self.class, unexpected_type, @expecting ]
  end
end

=begin rdoc ANTLR3::Error::RewriteCardinalityError

error:: RewriteCardinalityError
used by:: tree-rewriting parsers and tree parsers
occurs when::
  There is an inconsistency between the number of appearances of some symbol
  on the left side of a rewrite rule and the number of the same symbol
  seen on the right side of a rewrite rule

=end

class RewriteCardinalityError < StandardError
  attr_accessor :element_description
  def initialize( element_description )
    @element_description = element_description
    super( message )
  end
  
  def message
    "%s: %s" % [ self.class, @element_description ]
  end
end

=begin rdoc ANTLR3::Error::RewriteEarlyExit

error:: RewriteEarlyExit
used by:: tree-rewriting parsers and tree parsers
occurs when::
  A tree-rewrite rule requires one or more occurence of a symbol, but none
  have been seen.

=end

class RewriteEarlyExit < RewriteCardinalityError
  attr_accessor :element_description
  def initialize( element_description = nil )
    super( element_description )
  end
end

=begin rdoc ANTLR3::Error::RewriteEmptyStream

error:: RewriteEmptyStream
used by:: tree-rewriting parsers and tree parsers

=end

class RewriteEmptyStream < RewriteCardinalityError; end

=begin rdoc ANTLR3::Error::TreeInconsistency

error:: TreeInconsistency
used by:: classes that deal with tree structures
occurs when::
  A tree node's data is inconsistent with the overall structure to which it
  belongs.

situations that result in tree inconsistencies:

1. A node has a child node with a +@parent+ attribute different than the node.
2. A node has a child at index +n+, but the child's +@child_index+ value is not
   +n+
3. An adaptor encountered a situation where multiple tree nodes have been
   simultaneously requested as a new tree root.

=end

class TreeInconsistency < StandardError
  def self.failed_index_check!( expected, real )
    new( 
      "%s: child indexes don't match -> expected %d found %d" %
      [ self, expected, real ]
    )
  end
  
  def self.failed_parent_check!( expected, real )
    new( 
      "%s: parents don't match; expected %p found %p" %
      [ self, expected, real ]
    )
  end
  
  def self.multiple_roots!
    new "%s: attempted to change more than one node to root" % self
  end
end

module_function

def MismatchedToken( expecting, input = @input )
  MismatchedToken.new( expecting, input )
end

def UnwantedToken( expecting, input = @input )
  UnwantedToken.new( expecting, input )
end

def MissingToken( expecting, inserted, input = @input )
  MissingToken.new( expecting, input, inserted )
end

def MismatchedRange( min, max, input = @input )
  MismatchedRange.new( min, max, input )
end

def MismatchedSet( expecting, input = @input )
  MismatchedSet.new( expecting, input )
end

def MismatchedNotSet( expecting, input = @input )
  MismatchedNotSet.new( expecting, input )
end

def NoViableAlternative( description, decision, state, input = @input )
  NoViableAlternative.new( description, decision, state, input )
end

def EarlyExit( decision, input = @input )
  EarlyExit.new( decision, input )
end

def FailedPredicate( rule, predicate, input = @input )
  FailedPredicate.new( input, rule, predicate )
end

def MismatchedTreeNode( expecting, input = @input )
  MismatchedTreeNode.new( expecting, input )
end

def RewriteCardinalityError( element_description )
  RewriteCardinalityError.new( element_description )
end

def RewriteEarlyExit( element_description = nil )
  RewriteEarlyExit.new( element_description )
end

def RewriteEmptyStream( element_description )
  RewriteEmptyStream.new( element_description )
end

end
  
include Error

=begin rdoc ANTLR3::Bug



=end

class Bug < StandardError
  def initialize( message = nil, *args )
    message = "something occurred that should not occur within unmodified, " <<
              "ANTLR-generated source code: #{ message }"
    super( message, *args )
  end
end

end
