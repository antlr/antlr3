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

=begin rdoc ANTLR3::Token

At a minimum, tokens are data structures that bind together a chunk of text and
a corresponding type symbol, which categorizes/characterizes the content of the
text. Tokens also usually carry information about their location in the input,
such as absolute character index, line number, and position within the line (or
column).

Furthermore, ANTLR tokens are assigned a "channel" number, an extra degree of
categorization that groups things on a larger scale. Parsers will usually ignore
tokens that have channel value 99 (the HIDDEN_CHANNEL), so you can keep things
like comment and white space huddled together with neighboring tokens,
effectively ignoring them without discarding them.

ANTLR tokens also keep a reference to the source stream from which they
originated. Token streams will also provide an index value for the token, which
indicates the position of the token relative to other tokens in the stream,
starting at zero. For example, the 22nd token pulled from a lexer by
CommonTokenStream will have index value 21.

== Token as an Interface

This library provides a token implementation (see CommonToken). Additionally,
you may write your own token class as long as you provide methods that give
access to the attributes expected by a token. Even though most of the ANTLR
library tries to use duck-typing techniques instead of pure object-oriented type
checking, it's a good idea to include this ANTLR3::Token into your customized
token class.

=end

module Token
  include ANTLR3::Constants
  include Comparable
  
  # the token's associated chunk of text
  attr_accessor :text
  
  # the integer value associated with the token's type
  attr_accessor :type
  
  # the text's starting line number within the source (indexed starting at 1)
  attr_accessor :line
  
  # the text's starting position in the line within the source (indexed starting at 0)
  attr_accessor :column
  
  # the integer value of the channel to which the token is assigned
  attr_accessor :channel
  
  # the index of the token with respect to other the other tokens produced during lexing
  attr_accessor :index
  
  # a reference to the input stream from which the token was extracted
  attr_accessor :input
  
  # the absolute character index in the input at which the text starts
  attr_accessor :start
  
  # the absolute character index in the input at which the text ends
  attr_accessor :stop

  alias :input_stream :input
  alias :input_stream= :input=
  alias :token_index :index
  alias :token_index= :index=
  
  #
  # The match operator has been implemented to match against several different
  # attributes of a token for convenience in quick scripts
  #
  # @example Match against an integer token type constant
  #   token =~ VARIABLE_NAME   => true/false
  # @example Match against a token type name as a Symbol
  #   token =~ :FLOAT          => true/false
  # @example Match the token text against a Regular Expression
  #   token =~ /^@[a-z_]\w*$/i
  # @example Compare the token's text to a string
  #   token =~ "class"
  # 
  def =~ obj
    case obj
    when Integer then type == obj
    when Symbol then name == obj.to_s
    when Regexp then obj =~ text
    when String then text == obj
    else super
    end
  end
  
  #
  # Tokens are comparable by their stream index values
  # 
  def <=> tk2
    index <=> tk2.index
  end
  
  def initialize_copy( orig )
    self.index   = -1
    self.type    = orig.type
    self.channel = orig.channel
    self.text    = orig.text.clone if orig.text
    self.start   = orig.start
    self.stop    = orig.stop
    self.line    = orig.line
    self.column  = orig.column
    self.input   = orig.input
  end
  
  def concrete?
    input && start && stop ? true : false
  end
  
  def imaginary?
    input && start && stop ? false : true
  end
  
  def name
    token_name( type )
  end
  
  def source_name
    i = input and i.source_name
  end
  
  def hidden?
    channel == HIDDEN_CHANNEL
  end
  
  def source_text
    concrete? ? input.substring( start, stop ) : text
  end
  
  #
  # Sets the token's channel value to HIDDEN_CHANNEL
  # 
  def hide!
    self.channel = HIDDEN_CHANNEL
  end
  
  def inspect
    text_inspect    = text  ? "[#{ text.inspect }] " : ' '
    text_position   = line > 0  ? "@ line #{ line } col #{ column } " : ''
    stream_position = start ? "(#{ range.inspect })" : ''
    
    front =  index >= 0 ? "#{ index } " : ''
    rep = front << name << text_inspect <<
                text_position << stream_position
    rep.strip!
    channel == DEFAULT_CHANNEL or rep << " (#{ channel.to_s })"
    return( rep )
  end
  
  def pretty_print( printer )
    printer.text( inspect )
  end
  
  def range
    start..stop rescue nil
  end
  
  def to_i
    index.to_i
  end
  
  def to_s
    text.to_s
  end
  
private
  
  def token_name( type )
    BUILT_IN_TOKEN_NAMES[ type ]
  end
end

CommonToken = Struct.new( :type, :channel, :text, :input, :start,
                         :stop, :index, :line, :column )

=begin rdoc ANTLR3::CommonToken

The base class for the standard implementation of Token. It is implemented as a
simple Struct as tokens are basically simple data structures binding together a
bunch of different information and Structs are slightly faster than a standard
Object with accessor methods implementation.

By default, ANTLR generated ruby code will provide a customized subclass of
CommonToken to track token-type names efficiently for debugging, inspection, and
general utility. Thus code generated for a standard combo lexer-parser grammar
named XYZ will have a base module named XYZ and a customized CommonToken
subclass named XYZ::Token.

Here is the token structure attribute list in order:

* <tt>type</tt>
* <tt>channel</tt>
* <tt>text</tt>
* <tt>input</tt>
* <tt>start</tt>
* <tt>stop</tt>
* <tt>index</tt>
* <tt>line</tt>
* <tt>column</tt>

=end

class CommonToken
  include Token
  DEFAULT_VALUES = { 
    :channel => DEFAULT_CHANNEL,
    :index   => -1,
    :line    =>  0,
    :column  => -1
  }.freeze
  
  def self.token_name( type )
    BUILT_IN_TOKEN_NAMES[ type ]
  end
  
  def self.create( fields = {} )
    fields = DEFAULT_VALUES.merge( fields )
    args = members.map { |name| fields[ name.to_sym ] }
    new( *args )
  end
  
  # allows you to make a copy of a token with a different class
  def self.from_token( token )
    new( 
      token.type,  token.channel, token.text ? token.text.clone : nil,
      token.input, token.start,   token.stop, -1, token.line, token.column
    )
  end
  
  def initialize( type = nil, channel = DEFAULT_CHANNEL, text = nil,
                 input = nil, start = nil, stop = nil, index = -1,
                 line = 0, column = -1 )
    super
    block_given? and yield( self )
    self.text.nil? && self.start && self.stop and
      self.text = self.input.substring( self.start, self.stop )
  end
  
  alias :input_stream :input
  alias :input_stream= :input=
  alias :token_index :index
  alias :token_index= :index=
end

module Constants
  
  # End of File / End of Input character and token type
  EOF_TOKEN = CommonToken.new( EOF ).freeze
  INVALID_TOKEN = CommonToken.new( INVALID_TOKEN_TYPE ).freeze
  SKIP_TOKEN = CommonToken.new( INVALID_TOKEN_TYPE ).freeze  
end



=begin rdoc ANTLR3::TokenSource

TokenSource is a simple mixin module that demands an
implementation of the method #next_token. In return, it
defines methods #next and #each, which provide basic
iterator methods for token generators. Furthermore, it
includes Enumerable to provide the standard Ruby iteration
methods to token generators, like lexers.

=end

module TokenSource
  include Constants
  include Enumerable
  extend ClassMacros
  
  abstract :next_token
  
  def next
    token = next_token()
    raise StopIteration if token.nil? || token.type == EOF
    return token
  end
  
  def each
    block_given? or return enum_for( :each )
    while token = next_token and token.type != EOF
      yield( token )
    end
    return self
  end

  def to_stream( options = {} )
    if block_given?
      CommonTokenStream.new( self, options ) { | t, stream | yield( t, stream ) }
    else
      CommonTokenStream.new( self, options )
    end
  end
end


=begin rdoc ANTLR3::TokenFactory

There are a variety of different entities throughout the ANTLR runtime library
that need to create token objects This module serves as a mixin that provides
methods for constructing tokens.

Including this module provides a +token_class+ attribute. Instance of the
including class can create tokens using the token class (which defaults to
ANTLR3::CommonToken). Token classes are presumed to have an #initialize method
that can be called without any parameters and the token objects are expected to
have the standard token attributes (see ANTLR3::Token).

=end

module TokenFactory
  attr_writer :token_class
  def token_class
    @token_class ||= begin
      self.class.token_class rescue
      self::Token rescue
      ANTLR3::CommonToken
    end
  end
  
  def create_token( *args )
    if block_given?
      token_class.new( *args ) do |*targs|
        yield( *targs )
      end
    else
      token_class.new( *args )
    end
  end
end


=begin rdoc ANTLR3::TokenScheme

TokenSchemes exist to handle the problem of defining token types as integer
values while maintaining meaningful text names for the types. They are
dynamically defined modules that map integer values to constants with token-type
names.

---

Fundamentally, tokens exist to take a chunk of text and identify it as belonging
to some category, like "VARIABLE" or "INTEGER". In code, the category is
represented by an integer -- some arbitrary value that ANTLR will decide to use
as it is creating the recognizer. The purpose of using an integer (instead of
say, a ruby symbol) is that ANTLR's decision logic often needs to test whether a
token's type falls within a range, which is not possible with symbols.

The downside of token types being represented as integers is that a developer
needs to be able to reference the unknown type value by name in action code.
Furthermore, code that references the type by name and tokens that can be
inspected with names in place of type values are more meaningful to a developer.

Since ANTLR requires token type names to follow capital-letter naming
conventions, defining types as named constants of the recognizer class resolves
the problem of referencing type values by name. Thus, a token type like
``VARIABLE'' can be represented by a number like 5 and referenced within code by
+VARIABLE+. However, when a recognizer creates tokens, the name of the token's
type cannot be seen without using the data defined in the recognizer.

Of course, tokens could be defined with a name attribute that could be specified
when tokens are created. However, doing so would make tokens take up more space
than necessary, as well as making it difficult to change the type of a token
while maintaining a correct name value.

TokenSchemes exist as a technique to manage token type referencing and name
extraction. They:

1. keep token type references clear and understandable in recognizer code
2. permit access to a token's type-name independently of recognizer objects
3. allow multiple classes to share the same token information

== Building Token Schemes

TokenScheme is a subclass of Module. Thus, it has the method
<tt>TokenScheme.new(tk_class = nil) { ... module-level code ...}</tt>, which
will evaluate the block in the context of the scheme (module), similarly to
Module#module_eval. Before evaluating the block, <tt>.new</tt> will setup the
module with the following actions:

1. define a customized token class (more on that below)
2. add a new constant, TOKEN_NAMES, which is a hash that maps types to names
3. dynamically populate the new scheme module with a couple instance methods
4. include ANTLR3::Constants in the new scheme module

As TokenScheme the class functions as a metaclass, figuring out some of the
scoping behavior can be mildly confusing if you're trying to get a handle of the
entity for your own purposes. Remember that all of the instance methods of
TokenScheme function as module-level methods of TokenScheme instances, ala
+attr_accessor+ and friends.

<tt>TokenScheme#define_token(name_symbol, int_value)</tt> adds a constant
definition <tt>name_symbol</tt> with the value <tt>int_value</tt>. It is
essentially like <tt>Module#const_set</tt>, except it forbids constant
overwriting (which would mess up recognizer code fairly badly) and adds an
inverse type-to-name map to its own <tt>TOKEN_NAMES</tt> table.
<tt>TokenScheme#define_tokens</tt> is a convenience method for defining many
types with a hash pairing names to values.

<tt>TokenScheme#register_name(value, name_string)</tt> specifies a custom
type-to-name definition. This is particularly useful for the anonymous tokens
that ANTLR generates for literal strings in the grammar specification. For
example, if you refer to the literal <tt>'='</tt> in some parser rule in your
grammar, ANTLR will add a lexer rule for the literal and give the token a name
like <tt>T__<i>x</i></tt>, where <tt><i>x</i></tt> is the type's integer value.
Since this is pretty meaningless to a developer, generated code should add a
special name definition for type value <tt><i>x</i></tt> with the string
<tt>"'='"</tt>.

=== Sample TokenScheme Construction

  TokenData = ANTLR3::TokenScheme.new do
    define_tokens(
      :INT  => 4,
      :ID   => 6,
      :T__5 => 5,
      :WS   => 7
    )
    
    # note the self:: scoping below is due to the fact that
    # ruby lexically-scopes constant names instead of
    # looking up in the current scope
    register_name(self::T__5, "'='")
  end
  
  TokenData::ID           # => 6
  TokenData::T__5         # => 5
  TokenData.token_name(4) # => 'INT'
  TokenData.token_name(5) # => "'='"
  
  class ARecognizerOrSuch < ANTLR3::Parser
    include TokenData
    ID   # => 6
  end

== Custom Token Classes and Relationship with Tokens

When a TokenScheme is created, it will define a subclass of ANTLR3::CommonToken
and assigned it to the constant name +Token+. This token class will both include
and extend the scheme module. Since token schemes define the private instance
method <tt>token_name(type)</tt>, instances of the token class are now able to
provide their type names. The Token method <tt>name</tt> uses the
<tt>token_name</tt> method to provide the type name as if it were a simple
attribute without storing the name itself.

When a TokenScheme is included in a recognizer class, the class will now have
the token types as named constants, a type-to-name map constant +TOKEN_NAMES+,
and a grammar-specific subclass of ANTLR3::CommonToken assigned to the constant
Token. Thus, when recognizers need to manufacture tokens, instead of using the
generic CommonToken class, they can create tokens using the customized Token
class provided by the token scheme.

If you need to use a token class other than CommonToken, you can pass the class
as a parameter to TokenScheme.new, which will be used in place of the
dynamically-created CommonToken subclass.

=end

class TokenScheme < ::Module
  include TokenFactory
  
  def self.new( tk_class = nil, &body )
    super() do
      tk_class ||= Class.new( ::ANTLR3::CommonToken )
      self.token_class = tk_class
      
      const_set( :TOKEN_NAMES, ::ANTLR3::Constants::BUILT_IN_TOKEN_NAMES.clone )
      
      @types  = ::ANTLR3::Constants::BUILT_IN_TOKEN_NAMES.invert
      @unused = ::ANTLR3::Constants::MIN_TOKEN_TYPE
      
      scheme = self
      define_method( :token_scheme ) { scheme }
      define_method( :token_names )  { scheme::TOKEN_NAMES }
      define_method( :token_name ) do |type|
        begin
          token_names[ type ] or super
        rescue NoMethodError
          ::ANTLR3::CommonToken.token_name( type )
        end
      end
      module_function :token_name, :token_names
      
      include ANTLR3::Constants
      
      body and module_eval( &body )
    end
  end
  
  def self.build( *token_names )
    token_names = [ token_names ].flatten!
    token_names.compact!
    token_names.uniq!
    tk_class = Class === token_names.first ? token_names.shift : nil
    value_maps, names = token_names.partition { |i| Hash === i }
    new( tk_class ) do
      for value_map in value_maps
        define_tokens( value_map )
      end
      
      for name in names
        define_token( name )
      end
    end
  end
  
  
  def included( mod )
    super
    mod.extend( self )
  end
  private :included
  
  attr_reader :unused, :types
  
  def define_tokens( token_map = {} )
    for token_name, token_value in token_map
      define_token( token_name, token_value )
    end
    return self
  end
  
  def define_token( name, value = nil )
    name = name.to_s
    
    if current_value = @types[ name ]
      # token type has already been defined
      # raise an error unless value is the same as the current value
      value ||= current_value
      unless current_value == value
        raise NameError.new( 
          "new token type definition ``#{ name } = #{ value }'' conflicts " <<
          "with existing type definition ``#{ name } = #{ current_value }''", name
        )
      end
    else
      value ||= @unused
      if name =~ /^[A-Z]\w*$/
        const_set( name, @types[ name ] = value )
      else
        constant = "T__#{ value }"
        const_set( constant, @types[ constant ] = value )
        @types[ name ] = value
      end
      register_name( value, name ) unless built_in_type?( value )
    end
    
    value >= @unused and @unused = value + 1
    return self
  end
  
  def register_names( *names )
    if names.length == 1 and Hash === names.first
      names.first.each do |value, name|
        register_name( value, name )
      end
    else
      names.each_with_index do |name, i|
        type_value = Constants::MIN_TOKEN_TYPE + i
        register_name( type_value, name )
      end
    end
  end
  
  def register_name( type_value, name )
    name = name.to_s.freeze
    if token_names.has_key?( type_value )
      current_name = token_names[ type_value ]
      current_name == name and return name
      
      if current_name == "T__#{ type_value }"
        # only an anonymous name is registered -- upgrade the name to the full literal name
        token_names[ type_value ] = name
      elsif name == "T__#{ type_value }"
        # ignore name downgrade from literal to anonymous constant
        return current_name
      else
        error = NameError.new( 
          "attempted assignment of token type #{ type_value }" <<
          " to name #{ name } conflicts with existing name #{ current_name }", name
        )
        raise error
      end
    else
      token_names[ type_value ] = name.to_s.freeze
    end
  end
  
  def built_in_type?( type_value )
    Constants::BUILT_IN_TOKEN_NAMES.fetch( type_value, false ) and true
  end
  
  def token_defined?( name_or_value )
    case value
    when Integer then token_names.has_key?( name_or_value )
    else const_defined?( name_or_value.to_s )
    end
  end
  
  def []( name_or_value )
    case name_or_value
    when Integer then token_names.fetch( name_or_value, nil )
    else const_get( name_or_value.to_s ) rescue token_names.index( name_or_value )
    end
  end
  
  def token_class
    self::Token
  end
  
  def token_class=( klass )
    Class === klass or raise( TypeError, "token_class must be a Class" )
    Util.silence_warnings do
      klass < self or klass.send( :include, self )
      const_set( :Token, klass )
    end
  end
  
end

end
