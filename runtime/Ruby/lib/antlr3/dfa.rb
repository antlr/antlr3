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

=begin rdoc ANTLR3::DFA

DFA is a class that implements a finite state machine that chooses between
alternatives in a rule based upon lookahead symbols from an input stream.

Deterministic Finite Automata (DFA) are finite state machines that are capable
of recognizing <i>regular languages</i>. For more background on the subject,
check out http://en.wikipedia.org/wiki/Deterministic_finite-state_machine or
check out general ANTLR documentation at http://www.antlr.org

ANTLR implements most of its decision logic directly using code branching
structures in methods. However, for certain types of decisions, ANTLR will
generate a special DFA class definition to implement a decision.

Conceptually, these state machines are defined by a number of states, each state
represented by an integer indexed upward from zero. State number +0+ is the
<i>start state</i> of the machine; every prediction will begin in state +0+. At
each step, the machine examines the next symbol on the input stream, checks the
value against the transition parameters associated with the current state, and
either moves to a new state number to repeat the process or decides that the
machine cannot transition any further. If the machine cannot transition any
further and the current state is defined as an <i>accept state</i>, an
alternative has been chosen successfully and the prediction procedure ends. If
the current state is not an <i>accept state</i>, the prediction has failed and
there is <i>no viable alternative</i>.

In generated code, ANTLR defines DFA states using seven parameters, each defined
as a member of seven seperate array constants -- +MIN+, +MAX+, +EOT+, +EOF+,
+SPECIAL+, +ACCEPT+, and +TRANSITION+. The parameters that characterize state
+s+ are defined by the value of these lists at index +s+.

MIN[s]::
  The smallest value of the next input symbol that has 
  a transition for state +s+
MAX[s]::
  The largest value of the next input symbol that has 
  a transition for state +s+
TRANSITION[s]::
  A list that defines the next state number based upon
  the current input symbol.
EOT[s]::
  If positive, it specifies a state transition in 
  situations where a non-matching input symbol does
  not indicate failure.
SPECIAL[s]::
  If positive, it indicates that the prediction 
  algorithm must defer to a special code block 
  to determine the next state. The value is used
  by the special state code to determine the next
  state.
ACCEPT[s]::
  If positive and there are no possible state
  transitions, this is the alternative number
  that has been predicted
EOF[s]::
  If positive and the input stream has been exhausted,
  this is the alternative number that has been predicted.

For more information on the prediction algorithm, check out the #predict method
below.

=end

class DFA
  include Constants
  include Error
  
  attr_reader :recognizer, :decision_number, :eot, :eof, :min, :max,
              :accept, :special, :transition, :special_block
  
  class << self
    attr_reader :decision, :eot, :eof, :min, :max,
                :accept, :special, :transition
    
    def unpack( *data )
      data.empty? and return [].freeze
      
      n = data.length / 2
      size = 0
      n.times { |i| size += data[ 2*i ] }
      if size > 1024
        values = Hash.new( 0 )
        data.each_slice( 2 ) do |count, value|
          values[ value ] += count
        end
        default = values.keys.max_by { |v| values[ v ] }
        
        unpacked = Hash.new( default )
        position = 0
        data.each_slice( 2 ) do |count, value|
          unless value == default
            count.times { |i| unpacked[ position + i ] = value }
          end
          position += count
        end
      else
        unpacked = []
        data.each_slice( 2 ) do |count, value|
          unpacked.fill( value, unpacked.length, count )
        end
      end
      
      return unpacked
    end
    
  end
  
  def initialize( recognizer, decision_number = nil,
                 eot = nil, eof = nil, min = nil, max = nil,
                 accept = nil, special = nil,
                 transition = nil, &special_block )
    @recognizer = recognizer
    @decision_number = decision_number || self.class.decision
    @eot = eot || self.class::EOT #.eot
    @eof = eof || self.class::EOF #.eof
    @min = min || self.class::MIN #.min
    @max = max || self.class::MAX #.max
    @accept = accept || self.class::ACCEPT #.accept
    @special = special || self.class::SPECIAL #.special
    @transition = transition || self.class::TRANSITION #.transition
    @special_block = special_block
  rescue NameError => e
    raise unless e.message =~ /uninitialized constant/
    constant = e.name
    message = Util.tidy( <<-END )
    | No #{ constant } information provided.
    | DFA cannot be instantiated without providing state array information.
    | When DFAs are generated by ANTLR, this information should already be
    | provided in the DFA subclass constants.
    END
  end
  
  if RUBY_VERSION =~ /^1\.9/
    
    def predict( input )
      mark = input.mark
      state = 0
      
      50000.times do
        special_state = @special[ state ]
        if special_state >= 0
          state = @special_block.call( special_state )
          if state == -1
            no_viable_alternative( state, input )
            return 0
          end
          input.consume
          next
        end
        @accept[ state ] >= 1 and return @accept[ state ]
        
        # look for a normal char transition
        
        c = input.peek.ord
        # the @min and @max arrays contain the bounds of the character (or token type)
        # ranges for the transition decisions
        if c.between?( @min[ state ], @max[ state ] )
          # c - @min[state] is the position of the character within the range
          # so for a range like ?a..?z, a match of ?a would be 0,
          # ?c would be 2, and ?z would be 25
          next_state = @transition[ state ][ c - @min[ state ] ]
          if next_state < 0
            if @eot[ state ] >= 0
              state = @eot[ state ]
              input.consume
              next
            end
            no_viable_alternative( state, input )
            return 0
          end
          
          state = next_state
          input.consume
          next
        end
        
        if @eot[ state ] >= 0
          state = @eot[ state ]
          input.consume()
          next
        end
        
        ( c == EOF && @eof[ state ] >= 0 ) and return @accept[ @eof[ state ] ]
        no_viable_alternative( state, input )
        return 0
      end
      
      ANTLR3.bug!( Util.tidy( <<-END ) )
      | DFA BANG!
      |   The prediction loop has exceeded a maximum limit of 50000 iterations
      | ----
      | decision: #@decision_number
      | description: #{ description }
      END
    ensure
      input.rewind( mark )
    end
    
  else
    
    def predict( input )
      mark = input.mark
      state = 0
      
      50000.times do
        special_state = @special[ state ]
        if special_state >= 0
          state = @special_block.call( special_state )
          if state == -1
            no_viable_alternative( state, input )
            return 0
          end
          input.consume
          next
        end
        @accept[ state ] >= 1 and return @accept[ state ]
        
        # look for a normal char transition
        
        c = input.peek
        # the @min and @max arrays contain the bounds of the character (or token type)
        # ranges for the transition decisions
        if c.between?( @min[ state ], @max[ state ] )
          # c - @min[state] is the position of the character within the range
          # so for a range like ?a..?z, a match of ?a would be 0,
          # ?c would be 2, and ?z would be 25
          next_state = @transition[ state ][ c - @min[ state ] ]
          if next_state < 0
            if @eot[ state ] >= 0
              state = @eot[ state ]
              input.consume
              next
            end
            no_viable_alternative( state, input )
            return 0
          end
          
          state = next_state
          input.consume()
          next
        end
        if @eot[ state ] >= 0
          state = @eot[ state ]
          input.consume()
          next
        end
        ( c == EOF && @eof[ state ] >= 0 ) and return @accept[ @eof[ state ] ]
        no_viable_alternative( state, input )
        return 0
      end
      
      ANTLR3.bug!( Util.tidy( <<-END ) )
      | DFA BANG!
      |   The prediction loop has exceeded a maximum limit of 50000 iterations
      | ----
      | decision: #@decision_number
      | description: #{ description }
      END
    ensure
      input.rewind( mark )
    end
    
  end
  
  def no_viable_alternative( state, input )
    raise( BacktrackingFailed ) if @recognizer.state.backtracking > 0
    except = NoViableAlternative.new( description, @decision_number, state, input )
    error( except )
    raise( except )
  end
  
  def error( except )
    # overridable debugging hook
  end
  
  def special_state_transition( state, input )
    return -1
  end
  
  def description
    return "n/a"
  end
end
end
