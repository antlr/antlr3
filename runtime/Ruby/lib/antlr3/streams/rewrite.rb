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

=begin rdoc ANTLR3::TokenRewriteStream

TokenRewriteStream is a specialized form of CommonTokenStream that provides simple stream editing functionality. By creating <i>rewrite programs</i>, new text output can be created based upon the tokens in the stream. The basic token stream itself is preserved, and text output is rendered on demand using the #to_s method.

=end

class TokenRewriteStream < CommonTokenStream

  unless defined?( RewriteOperation )
    RewriteOperation = Struct.new( :stream, :location, :text )
  end

=begin rdoc ANTLR3::TokenRewriteStream::RewriteOperation

RewiteOperation objects represent some particular editing command that should
be executed by a token rewrite stream at some time in future when the stream is
rendering a rewritten stream.

To perform token stream rewrites safely and efficiently, the rewrites are
executed lazily (that is, only when the rewritten text is explicitly requested).
Rewrite streams implement lazy rewriting by storing the parameters of
edit-inducing methods like +delete+ and +insert+ as RewriteOperation objects in
a rewrite program list.

The three subclasses of RewriteOperation, InsertBefore, Delete, and Replace,
define specific implementations of stream edits.

=end

  class RewriteOperation
    extend ClassMacros
    @operation_name = ''
    
    class << self
      ##
      # the printable name of operations represented by the class -- used for inspection
      attr_reader :operation_name
    end
    
    ##
    # :method: execute( buffer )
    # run the rewrite operation represented by this object and append the output to +buffer+
    abstract :execute
    
    ##
    # return the name of this operation as set by its class
    def name
      self.class.operation_name
    end
    
    ##
    # return a compact, readable representation of this operation
    def inspect
      return "(%s @ %p : %p)" % [ name, location, text ]
    end
  end
  

=begin rdoc ANTLR3::TokenRewriteStream::InsertBefore

Represents rewrite operation:

add string <tt>op.text</tt> to the rewrite output immediately before adding the
text content of the token at index <tt>op.index</tt>

=end
  
  class InsertBefore < RewriteOperation
    @operation_name = 'insert-before'.freeze
    
    alias index  location
    alias index= location=
    
    def execute( buffer )
      buffer << text.to_s
      token = stream[ location ]
      buffer << token.text.to_s if token
      return location + 1
    end
  end
  
=begin rdoc ANTLR3::TokenRewriteStream::Replace

Represents rewrite operation:

add text <tt>op.text</tt> to the rewrite buffer in lieu of the text of tokens
indexed within the range <tt>op.index .. op.last_index</tt>

=end
  
  class Replace < RewriteOperation
    
    @operation_name = 'replace'.freeze
    
    def initialize( stream, location, text )
      super( stream, nil, text )
      self.location = location
    end
    
    def location=( val )
      case val
      when Range then super( val )
      else
        val = val.to_i
        super( val..val )
      end
    end
    
    def execute( buffer )
      buffer << text.to_s unless text.nil?
      return( location.end + 1 )
    end
    
    def index
      location.first
    end
    
  end
  
=begin rdoc ANTLR3::TokenRewriteStream::Delete

Represents rewrite operation:

skip over the tokens indexed within the range <tt>op.index .. op.last_index</tt>
and do not add any text to the rewrite buffer

=end
  
  class Delete < Replace
    @operation_name = 'delete'.freeze
    
    def initialize( stream, location )
      super( stream, location, nil )
    end
  end
  
  class RewriteProgram
    def initialize( stream, name = nil )
      @stream = stream
      @name = name
      @operations = []
    end
    
    def replace( *range_arguments )
      range, text = cast_range( range_arguments, 1 )
      
      op = Replace.new( @stream, range, text )
      @operations << op
      return op
    end
    
    def insert_before( index, text )
      index = index.to_i
      index < 0 and index += @stream.length
      op = InsertBefore.new( @stream, index, text )
      @operations << op
      return op
    end
    
    def insert_after( index, text )
      index = index.to_i
      index < 0 and index += @stream.length
      op = InsertBefore.new( @stream, index + 1, text )
      @operations << op
      return op
    end
    
    def delete( *range_arguments )
      range, = cast_range( range_arguments )
      op = Delete.new( @stream, range )
      @operations << op
      return op
    end
  
    def reduce
      operations = @operations.reverse
      reduced = []
      
      until operations.empty?
        operation = operations.shift
        location = operation.location
        
        case operation
        when Replace
          operations.delete_if do |prior_operation|
            prior_location = prior_operation.location
            
            case prior_operation
            when InsertBefore
              location.include?( prior_location )
            when Replace
              if location.covers?( prior_location )
                true
              elsif location.overlaps?( prior_location )
                conflict!( operation, prior_operation )
              end
            end
          end
        when InsertBefore
          operations.delete_if do |prior_operation|
            prior_location = prior_operation.location
            
            case prior_operation
            when InsertBefore
              if prior_location == location
                operation.text += prior_operation.text
                true
              end
            when Replace
              if location == prior_location.first
                prior_operation.text = operation.text << prior_operation.text.to_s
                operation = nil
                break( false )
              elsif prior_location.include?( location )
                conflict!( operation, prior_operation )
              end
            end
          end
        end
        
        reduced.unshift( operation ) if operation
      end
      
      @operations.replace( reduced )
      
      @operations.inject( {} ) do |map, operation|
        other_operaiton = map[ operation.index ] and
          ANTLR3.bug!( Util.tidy( <<-END ) % [ self.class, operation, other_operaiton ] )
          | %s#reduce! should have left only one operation per index,
          | but %p conflicts with %p
          END
        map[ operation.index ] = operation
        map
      end
    end
    
    def execute( *range_arguments )
      if range_arguments.empty?
        range = 0 ... @stream.length
      else
        range, = cast_range( range_arguments )
      end
      
      output = ''
      
      tokens = @stream.tokens
      
      operations = reduce
      
      cursor = range.first
      while range.include?( cursor )
        if operation = operations.delete( cursor )
          cursor = operation.execute( output )
        else
          token = tokens[ cursor ]
          output << token.text if token
          cursor += 1
        end
      end
      if operation = operations.delete( cursor ) and
         operation.is_a?( InsertBefore )
        # catch edge 'insert-after' operations
        operation.execute( output )
      end
      
      return output
    end
    
    def clear
      @operations.clear
    end
    
    def undo( number_of_operations = 1 )
      @operations.pop( number_of_operations )
    end
    
    def conflict!( current, previous )
      message = 'operation %p overlaps with previous operation %p' % [ current, previous ]
      raise( RangeError, message, caller )
    end
    
    def cast_range( args, extra = 0 )
      single, pair = extra + 1, extra + 2
      case check_arguments( args, single, pair )
      when single
        loc = args.shift
        
        if loc.is_a?( Range )
          first, last = loc.first.to_i, loc.last.to_i
          loc.exclude_end? and last -= 1
          return cast_range( args.unshift( first, last ), extra )
        else
          loc = loc.to_i
          return cast_range( args.unshift( loc, loc ), extra )
        end
      when pair
        first, last = args.shift( 2 ).map! { |arg| arg.to_i }
        if first < 0 and last < 0
          first += @stream.length
          last += @stream.length
        else
          last < 0 and last += @stream.length
          first = first.at_least( 0 )
        end
        return( args.unshift( first .. last ) )
      end
    end
    
    def check_arguments( args, min, max )
      n = args.length
      if n < min
        raise ArgumentError,
          "wrong number of arguments (#{ args.length } for #{ min })",
          caller
      elsif n > max
        raise ArgumentError,
          "wrong number of arguments (#{ args.length } for #{ max })",
          caller
      else return n
      end
    end
    
    private :conflict!, :cast_range, :check_arguments
  end
    
  attr_reader :programs

  def initialize( token_source, options = {} )
    super( token_source, options )
    
    @programs = Hash.new do |programs, name|
      if name.is_a?( String )
        programs[ name ] = RewriteProgram.new( self, name )
      else programs[ name.to_s ]
      end
    end
    
    @last_rewrite_token_indexes = {}
  end
  
  def rewrite( program_name = 'default', range = nil )
    program = @programs[ program_name ]
    if block_given?
      yield( program )
      program.execute( range )
    else program
    end
  end
  
  def program( name = 'default' )
    return @programs[ name ]
  end
  
  def delete_program( name = 'default' )
    @programs.delete( name )
  end
  
  def original_string( start = 0, finish = size - 1 )
    @position == -1 and fill_buffer
    
    return( self[ start..finish ].map { |t| t.text }.join( '' ) )
  end

  def insert_before( *args )
    @programs[ 'default' ].insert_before( *args )
  end
  
  def insert_after( *args )
    @programs[ 'default' ].insert_after( *args )
  end
  
  def replace( *args )
    @programs[ 'default' ].replace( *args )
  end
  
  def delete( *args )
    @programs[ 'default' ].delete( *args )
  end
  
  def render( *arguments )
    case arguments.first
    when String, Symbol then name = arguments.shift.to_s
    else name = 'default'
    end
    @programs[ name ].execute( *arguments )
  end
end
end
