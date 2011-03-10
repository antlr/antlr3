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


=begin rdoc ANTLR3::Stream

= ANTLR3 Streams

This documentation first covers the general concept of streams as used by ANTLR
recognizers, and then discusses the specific <tt>ANTLR3::Stream</tt> module.

== ANTLR Stream Classes

ANTLR recognizers need a way to walk through input data in a serialized IO-style
fashion. They also need some book-keeping about the input to provide useful
information to developers, such as current line number and column. Furthermore,
to implement backtracking and various error recovery techniques, recognizers
need a way to record various locations in the input at a number of points in the
recognition process so the input state may be restored back to a prior state.

ANTLR bundles all of this functionality into a number of Stream classes, each
designed to be used by recognizers for a specific recognition task. Most of the
Stream hierarchy is implemented in antlr3/stream.rb, which is loaded by default
when 'antlr3' is required.

---

Here's a brief overview of the various stream classes and their respective
purpose:

StringStream::
  Similar to StringIO from the standard Ruby library, StringStream wraps raw
  String data in a Stream interface for use by ANTLR lexers.
FileStream::
  A subclass of StringStream, FileStream simply wraps data read from an IO or
  File object for use by lexers.
CommonTokenStream::
  The job of a TokenStream is to read lexer output and then provide ANTLR
  parsers with the means to sequential walk through series of tokens.
  CommonTokenStream is the default TokenStream implementation.
TokenRewriteStream::
  A subclass of CommonTokenStream, TokenRewriteStreams provide rewriting-parsers
  the ability to produce new output text from an input token-sequence by
  managing rewrite "programs" on top of the stream.
CommonTreeNodeStream::
  In a similar fashion to CommonTokenStream, CommonTreeNodeStream feeds tokens
  to recognizers in a sequential fashion. However, the stream object serializes
  an Abstract Syntax Tree into a flat, one-dimensional sequence, but preserves
  the two-dimensional shape of the tree using special UP and DOWN tokens. The
  sequence is primarily used by ANTLR Tree Parsers. *note* -- this is not
  defined in antlr3/stream.rb, but antlr3/tree.rb

---

The next few sections cover the most significant methods of all stream classes. 

=== consume / look / peek

<tt>stream.consume</tt> is used to advance a stream one unit. StringStreams are
advanced by one character and TokenStreams are advanced by one token.

<tt>stream.peek(k = 1)</tt> is used to quickly retrieve the object of interest
to a recognizer at look-ahead position specified by <tt>k</tt>. For
<b>StringStreams</b>, this is the <i>integer value of the character</i>
<tt>k</tt> characters ahead of the stream cursor. For <b>TokenStreams</b>, this
is the <i>integer token type of the token</i> <tt>k</tt> tokens ahead of the
stream cursor.

<tt>stream.look(k = 1)</tt> is used to retrieve the full object of interest at
look-ahead position specified by <tt>k</tt>. While <tt>peek</tt> provides the
<i>bare-minimum lightweight information</i> that the recognizer needs,
<tt>look</tt> provides the <i>full object of concern</i> in the stream. For
<b>StringStreams</b>, this is a <i>string object containing the single
character</i> <tt>k</tt> characters ahead of the stream cursor. For
<b>TokenStreams</b>, this is the <i>full token structure</i> <tt>k</tt> tokens
ahead of the stream cursor.

<b>Note:</b> in most ANTLR runtime APIs for other languages, <tt>peek</tt> is
implemented by some method with a name like <tt>LA(k)</tt> and <tt>look</tt> is
implemented by some method with a name like <tt>LT(k)</tt>. When writing this
Ruby runtime API, I found this naming practice both confusing, ambiguous, and
un-Ruby-like. Thus, I chose <tt>peek</tt> and <tt>look</tt> to represent a
quick-look (peek) and a full-fledged look-ahead operation (look). If this causes
confusion or any sort of compatibility strife for developers using this
implementation, all apologies.

=== mark / rewind / release

<tt>marker = stream.mark</tt> causes the stream to record important information
about the current stream state, place the data in an internal memory table, and
return a memento, <tt>marker</tt>. The marker object is typically an integer key
to the stream's internal memory table.

Used in tandem with, <tt>stream.rewind(mark = last_marker)</tt>, the marker can
be used to restore the stream to an earlier state. This is used by recognizers
to perform tasks such as backtracking and error recovery.

<tt>stream.release(marker = last_marker)</tt> can be used to release an existing
state marker from the memory table.

=== seek

<tt>stream.seek(position)</tt> moves the stream cursor to an absolute position
within the stream, basically like typical ruby <tt>IO#seek</tt> style methods.
However, unlike <tt>IO#seek</tt>, ANTLR streams currently always use absolute
position seeking.

== The Stream Module

<tt>ANTLR3::Stream</tt> is an abstract-ish base mixin for all IO-like stream
classes used by ANTLR recognizers.

The module doesn't do much on its own besides define arguably annoying
``abstract'' pseudo-methods that demand implementation when it is mixed in to a
class that wants to be a Stream. Right now this exists as an artifact of porting
the ANTLR Java/Python runtime library to Ruby. In Java, of course, this is
represented as an interface. In Ruby, however, objects are duck-typed and
interfaces aren't that useful as programmatic entities -- in fact, it's mildly
wasteful to have a module like this hanging out. Thus, I may axe it.

When mixed in, it does give the class a #size and #source_name attribute
methods.

Except in a small handful of places, most of the ANTLR runtime library uses
duck-typing and not type checking on objects. This means that the methods which
manipulate stream objects don't usually bother checking that the object is a
Stream and assume that the object implements the proper stream interface. Thus,
it is not strictly necessary that custom stream objects include ANTLR3::Stream,
though it isn't a bad idea.

=end

module Stream
  include ANTLR3::Constants
  extend ClassMacros
  
  ##
  # :method: consume
  # used to advance a stream one unit (such as character or token)
  abstract :consume
  
  ##
  # :method: peek( k = 1 )
  # used to quickly retreive the object of interest to a recognizer at lookahead
  # position specified by <tt>k</tt> (such as integer value of a character or an
  # integer token type)
  abstract :peek
  
  ##
  # :method: look( k = 1 )
  # used to retreive the full object of interest at lookahead position specified
  # by <tt>k</tt> (such as a character string or a token structure)
  abstract :look
  
  ##
  # :method: mark
  # saves the current position for the purposes of backtracking and
  # returns a value to pass to #rewind at a later time
  abstract :mark
  
  ##
  # :method: index
  # returns the current position of the stream
  abstract :index
  
  ##
  # :method: rewind( marker = last_marker )
  # restores the stream position using the state information previously saved
  # by the given marker
  abstract :rewind
  
  ##
  # :method: release( marker = last_marker )
  # clears the saved state information associated with the given marker value
  abstract :release
  
  ##
  # :method: seek( position )
  # move the stream to the given absolute index given by +position+
  abstract :seek
  
  ##
  # the total number of symbols in the stream
  attr_reader :size
  
  ##
  # indicates an identifying name for the stream -- usually the file path of the input
  attr_accessor :source_name
end

=begin rdoc ANTLR3::CharacterStream

CharacterStream further extends the abstract-ish base mixin Stream to add
methods specific to navigating character-based input data. Thus, it serves as an
immitation of the Java interface for text-based streams, which are primarily
used by lexers.

It adds the ``abstract'' method, <tt>substring(start, stop)</tt>, which must be
implemented to return a slice of the input string from position <tt>start</tt>
to position <tt>stop</tt>. It also adds attribute accessor methods <tt>line</tt>
and <tt>column</tt>, which are expected to indicate the current line number and
position within the current line, respectively.

== A Word About <tt>line</tt> and <tt>column</tt> attributes

Presumably, the concept of <tt>line</tt> and <tt>column</tt> attirbutes of text
are familliar to most developers. Line numbers of text are indexed from number 1
up (not 0). Column numbers are indexed from 0 up. Thus, examining sample text:

  Hey this is the first line.
  Oh, and this is the second line.

Line 1 is the string "Hey this is the first line\\n". If a character stream is at
line 2, character 0, the stream cursor is sitting between the characters "\\n"
and "O".

*Note:* most ANTLR runtime APIs for other languages refer to <tt>column</tt>
with the more-precise, but lengthy name <tt>charPositionInLine</tt>. I prefered
to keep it simple and familliar in this Ruby runtime API.

=end

module CharacterStream
  include Stream
  extend ClassMacros
  include Constants
  
  ##
  # :method: substring(start,stop)
  abstract :substring
  
  attr_accessor :line
  attr_accessor :column
end


=begin rdoc ANTLR3::TokenStream

TokenStream further extends the abstract-ish base mixin Stream to add methods
specific to navigating token sequences. Thus, it serves as an imitation of the
Java interface for token-based streams, which are used by many different
components in ANTLR, including parsers and tree parsers.

== Token Streams

Token streams wrap a sequence of token objects produced by some token source,
usually a lexer. They provide the operations required by higher-level
recognizers, such as parsers and tree parsers for navigating through the
sequence of tokens. Unlike simple character-based streams, such as StringStream,
token-based streams have an additional level of complexity because they must
manage the task of "tuning" to a specific token channel.

One of the main advantages of ANTLR-based recognition is the token
<i>channel</i> feature, which allows you to hold on to all tokens of interest
while only presenting a specific set of interesting tokens to a parser. For
example, if you need to hide whitespace and comments from a parser, but hang on
to them for some other purpose, you have the lexer assign the comments and
whitespace to channel value HIDDEN as it creates the tokens.

When you create a token stream, you can tune it to some specific channel value.
Then, all <tt>peek</tt>, <tt>look</tt>, and <tt>consume</tt> operations only
yield tokens that have the same value for <tt>channel</tt>. The stream skips
over any non-matching tokens in between.

== The TokenStream Interface

In addition to the abstract methods and attribute methods provided by the base
Stream module, TokenStream adds a number of additional method implementation
requirements and attributes.

=end

module TokenStream
  include Stream
  extend ClassMacros
  
  ##
  # expected to return the token source object (such as a lexer) from which
  # all tokens in the stream were retreived
  attr_reader :token_source
  
  ##
  # expected to return the value of the last marker produced by a call to 
  # <tt>stream.mark</tt>
  attr_reader :last_marker
  
  ##
  # expected to return the integer index of the stream cursor
  attr_reader :position
  
  ##
  # the integer channel value to which the stream is ``tuned''
  attr_accessor :channel
  
  ##
  # :method: to_s(start=0,stop=tokens.length-1)
  # should take the tokens between start and stop in the sequence, extract their text
  # and return the concatenation of all the text chunks
  abstract :to_s
  
  ##
  # :method: at( i )
  # return the stream symbol at index +i+
  abstract :at
end

=begin rdoc ANTLR3::StringStream

A StringStream's purpose is to wrap the basic, naked text input of a recognition
system. Like all other stream types, it provides serial navigation of the input;
a recognizer can arbitrarily step forward and backward through the stream's
symbols as it requires. StringStream and its subclasses are they main way to
feed text input into an ANTLR Lexer for token processing.

The stream's symbols of interest, of course, are character values. Thus, the
#peek method returns the integer character value at look-ahead position
<tt>k</tt> and the #look method returns the character value as a +String+. They
also track various pieces of information such as the line and column numbers at
the current position.

=== Note About Text Encoding

This version of the runtime library primarily targets ruby version 1.8, which
does not have strong built-in support for multi-byte character encodings. Thus,
characters are assumed to be represented by a single byte -- an integer between
0 and 255. Ruby 1.9 does provide built-in encoding support for multi-byte
characters, but currently this library does not provide any streams to handle
non-ASCII encoding. However, encoding-savvy recognition code is a future
development goal for this project.

=end

class StringStream
  NEWLINE = ?\n.ord
  
  include CharacterStream
  
  # current integer character index of the stream
  attr_reader :position
  
  # the current line number of the input, indexed upward from 1
  attr_reader :line
  
  # the current character position within the current line, indexed upward from 0
  attr_reader :column
  
  # the name associated with the stream -- usually a file name
  # defaults to <tt>"(string)"</tt>
  attr_accessor :name
  
  # the entire string that is wrapped by the stream
  attr_reader :data
  attr_reader :string
  
  if RUBY_VERSION =~ /^1\.9/
    
    # creates a new StringStream object where +data+ is the string data to stream.
    # accepts the following options in a symbol-to-value hash:
    #
    # [:file or :name] the (file) name to associate with the stream; default: <tt>'(string)'</tt>
    # [:line] the initial line number; default: +1+
    # [:column] the initial column number; default: +0+
    # 
    def initialize( data, options = {} )      # for 1.9
      @string   = data.to_s.encode( Encoding::UTF_8 ).freeze
      @data     = @string.codepoints.to_a.freeze
      @position = options.fetch :position, 0
      @line     = options.fetch :line, 1
      @column   = options.fetch :column, 0
      @markers  = []
      @name   ||= options[ :file ] || options[ :name ] # || '(string)'
      mark
    end
    
    #
    # identical to #peek, except it returns the character value as a String
    # 
    def look( k = 1 )               # for 1.9
      k == 0 and return nil
      k += 1 if k < 0
      
      index = @position + k - 1
      index < 0 and return nil
      
      @string[ index ]
    end
    
  else
    
    # creates a new StringStream object where +data+ is the string data to stream.
    # accepts the following options in a symbol-to-value hash:
    #
    # [:file or :name] the (file) name to associate with the stream; default: <tt>'(string)'</tt>
    # [:line] the initial line number; default: +1+
    # [:column] the initial column number; default: +0+
    # 
    def initialize( data, options = {} )    # for 1.8
      @data = data.to_s
      @data.equal?( data ) and @data = @data.clone
      @data.freeze
      @string = @data
      @position = options.fetch :position, 0
      @line = options.fetch :line, 1
      @column = options.fetch :column, 0
      @markers = []
      @name ||= options[ :file ] || options[ :name ] # || '(string)'
      mark
    end
    
    #
    # identical to #peek, except it returns the character value as a String
    # 
    def look( k = 1 )                        # for 1.8
      k == 0 and return nil
      k += 1 if k < 0
      
      index = @position + k - 1
      index < 0 and return nil
      
      c = @data[ index ] and c.chr
    end
    
  end
  
  def size
    @data.length
  end
  
  alias length size
  
  # 
  # rewinds the stream back to the start and clears out any existing marker entries
  # 
  def reset
    initial_location = @markers.first
    @position, @line, @column = initial_location
    @markers.clear
    @markers << initial_location
    return self
  end
  
  #
  # advance the stream by one character; returns the character consumed
  # 
  def consume
    c = @data[ @position ] || EOF
    if @position < @data.length
      @column += 1
      if c == NEWLINE
        @line += 1
        @column = 0
      end
      @position += 1
    end
    return( c )
  end
  
  #
  # return the character at look-ahead distance +k+ as an integer. <tt>k = 1</tt> represents
  # the current character. +k+ greater than 1 represents upcoming characters. A negative
  # value of +k+ returns previous characters consumed, where <tt>k = -1</tt> is the last
  # character consumed. <tt>k = 0</tt> has undefined behavior and returns +nil+
  # 
  def peek( k = 1 )
    k == 0 and return nil
    k += 1 if k < 0
    index = @position + k - 1
    index < 0 and return nil
    @data[ index ] or EOF
  end
  
  #
  # return a substring around the stream cursor at a distance +k+
  # if <tt>k >= 0</tt>, return the next k characters
  # if <tt>k < 0</tt>, return the previous <tt>|k|</tt> characters
  # 
  def through( k )
    if k >= 0 then @string[ @position, k ] else
      start = ( @position + k ).at_least( 0 ) # start cannot be negative or index will wrap around
      @string[ start ... @position ]
    end
  end
  
  # operator style look-ahead
  alias >> look
  
  # operator style look-behind
  def <<( k )
    self << -k
  end
  
  alias index position
  alias character_index position
  
  alias source_name name
  
  #
  # Returns true if the stream appears to be at the beginning of a new line.
  # This is an extra utility method for use inside lexer actions if needed.
  # 
  def beginning_of_line?
    @position.zero? or @data[ @position - 1 ] == NEWLINE
  end
  
  #
  # Returns true if the stream appears to be at the end of a new line.
  # This is an extra utility method for use inside lexer actions if needed.
  # 
  def end_of_line?
    @data[ @position ] == NEWLINE #if @position < @data.length
  end
  
  #
  # Returns true if the stream has been exhausted.
  # This is an extra utility method for use inside lexer actions if needed.
  # 
  def end_of_string?
    @position >= @data.length
  end

  #
  # Returns true if the stream appears to be at the beginning of a stream (position = 0).
  # This is an extra utility method for use inside lexer actions if needed.
  # 
  def beginning_of_string?
    @position == 0
  end
  
  alias eof? end_of_string?
  alias bof? beginning_of_string?
  
  #
  # record the current stream location parameters in the stream's marker table and
  # return an integer-valued bookmark that may be used to restore the stream's
  # position with the #rewind method. This method is used to implement backtracking.
  # 
  def mark
    state = [ @position, @line, @column ].freeze
    @markers << state
    return @markers.length - 1
  end
  
  #
  # restore the stream to an earlier location recorded by #mark. If no marker value is
  # provided, the last marker generated by #mark will be used.
  # 
  def rewind( marker = @markers.length - 1, release = true )
    ( marker >= 0 and location = @markers[ marker ] ) or return( self )
    @position, @line, @column = location
    release( marker ) if release
    return self
  end
  
  #
  # the total number of markers currently in existence
  # 
  def mark_depth
    @markers.length
  end
  
  #
  # the last marker value created by a call to #mark
  # 
  def last_marker
    @markers.length - 1
  end
  
  #
  # let go of the bookmark data for the marker and all marker
  # values created after the marker.
  # 
  def release( marker = @markers.length - 1 )
    marker.between?( 1, @markers.length - 1 ) or return
    @markers.pop( @markers.length - marker )
    return self
  end
  
  #
  # jump to the absolute position value given by +index+.
  # note: if +index+ is before the current position, the +line+ and +column+
  #       attributes of the stream will probably be incorrect
  # 
  def seek( index )
    index = index.bound( 0, @data.length )  # ensures index is within the stream's range
    if index > @position
      skipped = through( index - @position )
      if lc = skipped.count( "\n" ) and lc.zero?
        @column += skipped.length
      else
        @line += lc
        @column = skipped.length - skipped.rindex( "\n" ) - 1
      end
    end
    @position = index
    return nil
  end
  
  # 
  # customized object inspection that shows:
  # * the stream class
  # * the stream's location in <tt>index / line:column</tt> format
  # * +before_chars+ characters before the cursor (6 characters by default)
  # * +after_chars+ characters after the cursor (10 characters by default)
  # 
  def inspect( before_chars = 6, after_chars = 10 )
    before = through( -before_chars ).inspect
    @position - before_chars > 0 and before.insert( 0, '... ' )
    
    after = through( after_chars ).inspect
    @position + after_chars + 1 < @data.length and after << ' ...'
    
    location = "#@position / line #@line:#@column"
    "#<#{ self.class }: #{ before } | #{ after } @ #{ location }>"
  end
  
  #
  # return the string slice between position +start+ and +stop+
  # 
  def substring( start, stop )
    @string[ start, stop - start + 1 ]
  end
  
  #
  # identical to String#[]
  # 
  def []( start, *args )
    @string[ start, *args ]
  end
end


=begin rdoc ANTLR3::FileStream

FileStream is a character stream that uses data stored in some external file. It
is nearly identical to StringStream and functions as use data located in a file
while automatically setting up the +source_name+ and +line+ parameters. It does
not actually use any buffered IO operations throughout the stream navigation
process. Instead, it reads the file data once when the stream is initialized.

=end

class FileStream < StringStream
  
  #
  # creates a new FileStream object using the given +file+ object.
  # If +file+ is a path string, the file will be read and the contents
  # will be used and the +name+ attribute will be set to the path.
  # If +file+ is an IO-like object (that responds to :read),
  # the content of the object will be used and the stream will
  # attempt to set its +name+ object first trying the method #name
  # on the object, then trying the method #path on the object.
  #
  # see StringStream.new for a list of additional options
  # the constructer accepts
  # 
  def initialize( file, options = {} )
    case file
    when $stdin then
      data = $stdin.read
      @name = '(stdin)'
    when ARGF
      data = file.read
      @name = file.path
    when ::File then
      file = file.clone
      file.reopen( file.path, 'r' )
      @name = file.path
      data = file.read
      file.close
    else
      if file.respond_to?( :read )
        data = file.read
        if file.respond_to?( :name ) then @name = file.name
        elsif file.respond_to?( :path ) then @name = file.path
        end
      else
        @name = file.to_s
        if test( ?f, @name ) then data = File.read( @name )
        else raise ArgumentError, "could not find an existing file at %p" % @name
        end
      end
    end
    super( data, options )
  end
  
end

=begin rdoc ANTLR3::CommonTokenStream

CommonTokenStream serves as the primary token stream implementation for feeding
sequential token input into parsers.

Using some TokenSource (such as a lexer), the stream collects a token sequence,
setting the token's <tt>index</tt> attribute to indicate the token's position
within the stream. The streams may be tuned to some channel value; off-channel
tokens will be filtered out by the #peek, #look, and #consume methods.

=== Sample Usage

  
  source_input = ANTLR3::StringStream.new("35 * 4 - 1")
  lexer = Calculator::Lexer.new(source_input)
  tokens = ANTLR3::CommonTokenStream.new(lexer)
  
  # assume this grammar defines whitespace as tokens on channel HIDDEN
  # and numbers and operations as tokens on channel DEFAULT
  tokens.look         # => 0 INT['35'] @ line 1 col 0 (0..1)
  tokens.look(2)      # => 2 MULT["*"] @ line 1 col 2 (3..3)
  tokens.tokens(0, 2)
    # => [0 INT["35"] @line 1 col 0 (0..1), 
    #     1 WS[" "] @line 1 col 2 (1..1), 
    #     2 MULT["*"] @ line 1 col 3 (3..3)]
    # notice the #tokens method does not filter off-channel tokens
  
  lexer.reset
  hidden_tokens = 
    ANTLR3::CommonTokenStream.new(lexer, :channel => ANTLR3::HIDDEN)
  hidden_tokens.look # => 1 WS[' '] @ line 1 col 2 (1..1)

=end

class CommonTokenStream
  include TokenStream
  include Enumerable
  
  #
  # constructs a new token stream using the +token_source+ provided. +token_source+ is
  # usually a lexer, but can be any object that implements +next_token+ and includes
  # ANTLR3::TokenSource.
  #
  # If a block is provided, each token harvested will be yielded and if the block
  # returns a +nil+ or +false+ value, the token will not be added to the stream --
  # it will be discarded.
  #
  # === Options
  # [:channel] The channel value the stream should be tuned to initially
  # [:source_name] The source name (file name) attribute of the stream
  # 
  # === Example
  #
  #   # create a new token stream that is tuned to channel :comment, and
  #   # discard all WHITE_SPACE tokens
  #   ANTLR3::CommonTokenStream.new(lexer, :channel => :comment) do |token|
  #     token.name != 'WHITE_SPACE'
  #   end
  # 
  def initialize( token_source, options = {} )
    case token_source
    when CommonTokenStream
      # this is useful in cases where you want to convert a CommonTokenStream
      # to a RewriteTokenStream or other variation of the standard token stream
      stream = token_source
      @token_source = stream.token_source
      @channel = options.fetch( :channel ) { stream.channel or DEFAULT_CHANNEL }
      @source_name = options.fetch( :source_name ) { stream.source_name }
      tokens = stream.tokens.map { | t | t.dup }
    else
      @token_source = token_source
      @channel = options.fetch( :channel, DEFAULT_CHANNEL )
      @source_name = options.fetch( :source_name ) {  @token_source.source_name rescue nil }
      tokens = @token_source.to_a
    end
    @last_marker = nil
    @tokens = block_given? ? tokens.select { | t | yield( t, self ) } : tokens
    @tokens.each_with_index { |t, i| t.index = i }
    @position = 
      if first_token = @tokens.find { |t| t.channel == @channel }
        @tokens.index( first_token )
      else @tokens.length
      end
  end
  
  #
  # resets the token stream and rebuilds it with a potentially new token source.
  # If no +token_source+ value is provided, the stream will attempt to reset the
  # current +token_source+ by calling +reset+ on the object. The stream will
  # then clear the token buffer and attempt to harvest new tokens. Identical in
  # behavior to CommonTokenStream.new, if a block is provided, tokens will be
  # yielded and discarded if the block returns a +false+ or +nil+ value.
  # 
  def rebuild( token_source = nil )
    if token_source.nil?
      @token_source.reset rescue nil
    else @token_source = token_source
    end
    @tokens = block_given? ? @token_source.select { |token| yield( token ) } :   
                             @token_source.to_a
    @tokens.each_with_index { |t, i| t.index = i }
    @last_marker = nil
    @position = 
      if first_token = @tokens.find { |t| t.channel == @channel }
        @tokens.index( first_token )
      else @tokens.length
      end
    return self
  end
  
  #
  # tune the stream to a new channel value
  # 
  def tune_to( channel )
    @channel = channel
  end
  
  def token_class
    @token_source.token_class
  rescue NoMethodError
    @position == -1 and fill_buffer
    @tokens.empty? ? CommonToken : @tokens.first.class
  end
  
  alias index position
  
  def size
    @tokens.length
  end
  
  alias length size
  
  ###### State-Control ################################################
  
  #
  # rewind the stream to its initial state
  # 
  def reset
    @position = 0
    @position += 1 while token = @tokens[ @position ] and
                         token.channel != @channel
    @last_marker = nil
    return self
  end
  
  #
  # bookmark the current position of the input stream
  # 
  def mark
    @last_marker = @position
  end
  
  def release( marker = nil )
    # do nothing
  end
  
  
  def rewind( marker = @last_marker, release = true )
    seek( marker )
  end
  
  #
  # saves the current stream position, yields to the block,
  # and then ensures the stream's position is restored before
  # returning the value of the block
  #  
  def hold( pos = @position )
    block_given? or return enum_for( :hold, pos )
    begin
      yield
    ensure
      seek( pos )
    end
  end
  
  ###### Stream Navigation ###########################################
  
  #
  # advance the stream one step to the next on-channel token
  # 
  def consume
    token = @tokens[ @position ] || EOF_TOKEN
    if @position < @tokens.length
      @position = future?( 2 ) || @tokens.length
    end
    return( token )
  end
  
  #
  # jump to the stream position specified by +index+
  # note: seek does not check whether or not the
  #       token at the specified position is on-channel,
  #
  def seek( index )
    @position = index.to_i.bound( 0, @tokens.length )
    return self
  end
  
  #
  # return the type of the on-channel token at look-ahead distance +k+. <tt>k = 1</tt> represents
  # the current token. +k+ greater than 1 represents upcoming on-channel tokens. A negative
  # value of +k+ returns previous on-channel tokens consumed, where <tt>k = -1</tt> is the last
  # on-channel token consumed. <tt>k = 0</tt> has undefined behavior and returns +nil+
  # 
  def peek( k = 1 )
    tk = look( k ) and return( tk.type )
  end
  
  #
  # operates simillarly to #peek, but returns the full token object at look-ahead position +k+
  #
  def look( k = 1 )
    index = future?( k ) or return nil
    @tokens.fetch( index, EOF_TOKEN )
  end
  
  alias >> look
  def << k
    self >> -k
  end
  
  #
  # returns the index of the on-channel token at look-ahead position +k+ or nil if no other
  # on-channel tokens exist
  # 
  def future?( k = 1 )
    @position == -1 and fill_buffer
    
    case
    when k == 0 then nil
    when k < 0 then past?( -k )
    when k == 1 then @position
    else
      # since the stream only yields on-channel
      # tokens, the stream can't just go to the
      # next position, but rather must skip
      # over off-channel tokens
      ( k - 1 ).times.inject( @position ) do |cursor, |
        begin
          tk = @tokens.at( cursor += 1 ) or return( cursor )
          # ^- if tk is nil (i.e. i is outside array limits)
        end until tk.channel == @channel
        cursor
      end
    end
  end
  
  #
  # returns the index of the on-channel token at look-behind position +k+ or nil if no other
  # on-channel tokens exist before the current token
  # 
  def past?( k = 1 )
    @position == -1 and fill_buffer
    
    case
    when k == 0 then nil
    when @position - k < 0 then nil
    else
      
      k.times.inject( @position ) do |cursor, |
        begin
          cursor <= 0 and return( nil )
          tk = @tokens.at( cursor -= 1 ) or return( nil )
        end until tk.channel == @channel
        cursor
      end
      
    end
  end
  
  #
  # yields each token in the stream (including off-channel tokens)
  # If no block is provided, the method returns an Enumerator object.
  # #each accepts the same arguments as #tokens
  # 
  def each( *args )
    block_given? or return enum_for( :each, *args )
    tokens( *args ).each { |token| yield( token ) }
  end
  
  
  #
  # yields each token in the stream with the given channel value
  # If no channel value is given, the stream's tuned channel value will be used.
  # If no block is given, an enumerator will be returned. 
  # 
  def each_on_channel( channel = @channel )
    block_given? or return enum_for( :each_on_channel, channel )
    for token in @tokens
      token.channel == channel and yield( token )
    end
  end
  
  #
  # iterates through the token stream, yielding each on channel token along the way.
  # After iteration has completed, the stream's position will be restored to where
  # it was before #walk was called. While #each or #each_on_channel does not change
  # the positions stream during iteration, #walk advances through the stream. This
  # makes it possible to look ahead and behind the current token during iteration.
  # If no block is given, an enumerator will be returned. 
  # 
  def walk
    block_given? or return enum_for( :walk )
    initial_position = @position
    begin
      while token = look and token.type != EOF
        consume
        yield( token )
      end
      return self
    ensure
      @position = initial_position
    end
  end
  
  # 
  # returns a copy of the token buffer. If +start+ and +stop+ are provided, tokens
  # returns a slice of the token buffer from <tt>start..stop</tt>. The parameters
  # are converted to integers with their <tt>to_i</tt> methods, and thus tokens
  # can be provided to specify start and stop. If a block is provided, tokens are
  # yielded and filtered out of the return array if the block returns a +false+
  # or +nil+ value. 
  # 
  def tokens( start = nil, stop = nil )
    stop.nil?  || stop >= @tokens.length and stop = @tokens.length - 1
    start.nil? || stop < 0 and start = 0
    tokens = @tokens[ start..stop ]
    
    if block_given?
      tokens.delete_if { |t| not yield( t ) }
    end
    
    return( tokens )
  end
  
  
  def at( i )
    @tokens.at i
  end
  
  #
  # identical to Array#[], as applied to the stream's token buffer
  # 
  def []( i, *args )
    @tokens[ i, *args ]
  end
  
  ###### Standard Conversion Methods ###############################
  def inspect
    string = "#<%p: @token_source=%p @ %p/%p" %
      [ self.class, @token_source.class, @position, @tokens.length ]
    tk = look( -1 ) and string << " #{ tk.inspect } <--"
    tk = look( 1 ) and string << " --> #{ tk.inspect }"
    string << '>'
  end
  
  #
  # fetches the text content of all tokens between +start+ and +stop+ and
  # joins the chunks into a single string
  # 
  def extract_text( start = 0, stop = @tokens.length - 1 )
    start = start.to_i.at_least( 0 )
    stop = stop.to_i.at_most( @tokens.length )
    @tokens[ start..stop ].map! { |t| t.text }.join( '' )
  end
  
  alias to_s extract_text
  
end

end
