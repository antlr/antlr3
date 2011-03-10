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

require 'antlr3'

module ANTLR3
module AST

=begin rdoc ANTLR3::AST::Wizard

AST::Wizard is an extra utility class that allows quick creation of AST objects
using definitions writing in ANTLR-style tree definition syntax. It can also
define <i>tree patterns</i>, objects that are conceptually similar to regular
expressions. Patterns allow a simple method for recursively searching through an
AST for a particular node structure. These features make tree wizards useful
while testing and debugging AST constructing parsers and tree parsers. This
library has been ported to Ruby directly from the ANTLR Python runtime API.

See
http://www.antlr.org/wiki/display/~admin/2007/07/02/Exploring+Concept+of+TreeWizard
for more background on the concept of a tree wizard.

== Usage

  # setting up and creating a tree wizard
  token_names = Array.new(4, '') + %w(VAR NUMBER EQ PLUS MINUS MULT DIV)
  adaptor     = ANTLR3::AST::CommonTreeAdaptor.new
  wizard      = ANTLR3::AST::Wizard.new(adaptor, token_names)
  
  # building trees
  lone_node = wizard.create "VAR[x]"   # => x
  lone_node.type                       # => 4  # = VAR
  lone_node.text                       # => "x"
  
  expression_node = wizard.create "(MINUS VAR NUMBER)"
    # => (MINUS VAR NUMBER)
  statement_node = wizard.create "(EQ[=] VAR[x] (PLUS[+] NUMBER[1] NUMBER[2]))" 
    # => (= x (+ 1 2))
  deep_node = wizard.create(<<-TREE)
    (MULT[*] NUMBER[1] 
      (MINUS[-] 
        (MULT[*] NUMBER[3]    VAR[x])
        (DIV[/]  VAR[y] NUMBER[3.14])
        (MULT[*] NUMBER[4]    VAR[z])
      )
    )
  TREE
    # => (* 1 (- (* 3 x) (/ y 3.14) (* 4 z))
  
  bad_tree_syntax = wizard.create "(+ 1 2)"
    # => nil - invalid node names
  
  # test whether a tree matches a pattern
  wizard.match(expression_node, '(MINUS VAR .)') # => true
  wizard.match(lone_node, 'NUMBER NUMBER')       # => false
  
  # extract nodes matching a pattern
  wizard.find(statement_node, '(PLUS . .)')
  # => [(+ 1 2)]
  wizard.find(deep_node, 4)  # where 4 is the value of type VAR
  # => [x, y, z]
  
  # iterate through the tree and extract nodes with pattern labels
  wizard.visit(deep_node, '(MULT %n:NUMBER %v:.)') do |node, parent, local_index, labels|
    printf "n = %p\n, v = %p\n", labels['n'], labels['v']
  end
    # => prints out:
    # n = 3, v = x
    # n = 4, v = z
  
== Tree Construction Syntax
  
  Simple Token Node:     TK
  Token Node With Text:  TK[text]
  Flat Node List:        (nil TK1 TK2)
  General Node:          (RT TK1 TK2)
  Complex Nested Node:   (RT (SUB1[sometext] TK1) TK2 (SUB2 TK3 TK4[moretext]))

=== Additional Syntax for Tree Matching Patterns

  Match Any Token Node:  .
  Label a Node:          %name:TK

=end

class Wizard
  
  include Constants
  include Util

=begin rdoc ANTLR3::AST::Wizard::PatternLexer

A class that is used internally by AST::Wizard to tokenize tree patterns

=end

  class PatternLexer
    include ANTLR3::Constants
    
    autoload :StringScanner, 'strscan'
    
    PATTERNS = [ 
      [ :space, /\s+/ ],
      [ :identifier, /[a-z_]\w*/i ],
      [ :open, /\(/ ],
      [ :close, /\)/ ],
      [ :percent, /%/ ],
      [ :colon, /:/ ],
      [ :dot, /\./ ],
      [ :argument, /\[((?:[^\[\]\\]|\\\[|\\\]|\\.)*?)\]/ ]
    ]
    
    attr_reader :text, :error, :pattern
    def initialize( pattern )
      @pattern = pattern.to_s
      @scanner = StringScanner.new( pattern )
      @text = ''
      @error = false
    end
    
    def next_token
      begin
        @scanner.eos? and return EOF
        
        type, = PATTERNS.find do |type, pattern|
          @scanner.scan( pattern )
        end
        
        case type
        when nil
          type, @text, @error = EOF, '', true
          break
        when :identifier then @text = @scanner.matched
        when :argument
          # remove escapes from \] sequences in the text argument
          ( @text = @scanner[ 1 ] ).gsub!( /\\(?=[\[\]])/, '' )
        end
      end while type == :space
      
      return type
    end
    
    alias error? error
  end
  

=begin rdoc ANTLR3::AST::Wizard::Pattern

A class that is used internally by AST::Wizard to construct AST tree objects
from a tokenized tree pattern

=end

  class PatternParser
    def self.parse( pattern, token_scheme, adaptor )
      lexer = PatternLexer.new( pattern )
      new( lexer, token_scheme, adaptor ).pattern
    end
    
    include ANTLR3::Constants
    
    def initialize( tokenizer, token_scheme, adaptor )
      @tokenizer = tokenizer
      @token_scheme = token_scheme
      @adaptor   = adaptor
      @token_type = tokenizer.next_token
    end
    
    def pattern
      case @token_type
      when :open then return parse_tree
      when :identifier
        node = parse_node
        @token_type == EOF and return node
        return nil
      end
      return nil
    end
    
    CONTINUE_TYPES = [ :open, :identifier, :percent, :dot ]
    
    def parse_tree
      @token_type != :open and return nil
      @token_type = @tokenizer.next_token
      root = parse_node or return nil
      
      loop do
        case @token_type
        when :open
          subtree = parse_tree
          @adaptor.add_child( root, subtree )
        when :identifier, :percent, :dot
          child = parse_node or return nil
          @adaptor.add_child( root, child )
        else break
        end
      end
      @token_type == :close or return nil
      @token_type = @tokenizer.next_token
      return root
    end
    
    def parse_node
      label = nil
      if @token_type == :percent
        ( @token_type = @tokenizer.next_token ) == :identifier or return nil
        label = @tokenizer.text
        ( @token_type = @tokenizer.next_token ) == :colon or return nil
        @token_type = @tokenizer.next_token
      end
      
      if @token_type == :dot
        @token_type = @tokenizer.next_token
        wildcard_payload = CommonToken.create( :type => 0, :text => '.' )
        node = WildcardPattern.new( wildcard_payload )
        label and node.label = label
        return node
      end
      
      @token_type == :identifier or return nil
      token_name = @tokenizer.text
      @token_type = @tokenizer.next_token
      token_name == 'nil' and return @adaptor.create_flat_list
      
      text = token_name
      arg = nil
      if @token_type == :argument
        arg = @tokenizer.text
        text = arg
        @token_type = @tokenizer.next_token
      end
      
      node_type = @token_scheme[ token_name ] || INVALID_TOKEN_TYPE
      node = @adaptor.create_from_type( node_type, text )
      
      if Pattern === node
        node.label, node.has_text_arg = label, arg
      end
      return node
    end
  end
  

=begin rdoc ANTLR3::AST::Wizard::Pattern

A simple tree class that represents the skeletal structure of tree. It is used
to validate tree structures as well as to extract nodes that match the pattern.

=end

  class Pattern < CommonTree
    def self.parse( pattern_str, scheme )
      PatternParser.parse( 
        pattern_str, scheme, PatternAdaptor.new( scheme.token_class )
      )
    end
    
    attr_accessor :label, :has_text_arg
    alias :has_text_arg? :has_text_arg
    
    def initialize( payload )
      super( payload )
      @label = nil
      @has_text_arg = nil
    end
    
    def to_s
      prefix = @label ? '%' << @label << ':' : ''
      return( prefix << super )
    end
  end
  
=begin rdoc ANTLR3::AST::Wizard::WildcardPattern

A simple tree node used to represent the operation "match any tree node type" in
a tree pattern. They are represented by '.' in tree pattern specifications.

=end
  
  class WildcardPattern < Pattern; end
  

=begin rdoc ANTLR3::AST::Wizard::PatternAdaptor

A customized TreeAdaptor used by AST::Wizards to build tree patterns.

=end

  class PatternAdaptor < CommonTreeAdaptor
    def create_with_payload( payload )
      return Pattern.new( payload )
    end
  end

  attr_accessor :token_scheme, :adaptor

  def initialize( options = {} )
    @token_scheme = options.fetch( :token_scheme ) do
      TokenScheme.build( options[ :token_class ], options[ :tokens ] )
    end
    @adaptor = options.fetch( :adaptor ) do
      CommonTreeAdaptor.new( @token_scheme.token_class )
    end
  end
  
  def create( pattern )
    PatternParser.parse( pattern, @token_scheme, @adaptor )
  end
  
  def index( tree, map = {} )
    tree or return( map )
    type = @adaptor.type_of( tree )
    elements = map[ type ] ||= []
    elements << tree
    @adaptor.each_child( tree ) { | child | index( child, map ) }
    return( map )
  end
  
  def find( tree, what )
    case what
    when Integer then find_token_type( tree, what )
    when String  then find_pattern( tree, what )
    when Symbol  then find_token_type( tree, @token_scheme[ what ] )
    else raise ArgumentError, "search subject must be a token type (integer) or a string"
    end
  end
  
  def find_token_type( tree, type )
    nodes = []
    visit( tree, type ) { | t, | nodes << t }
    return nodes
  end
  
  def find_pattern( tree, pattern )
    subtrees = []
    visit_pattern( tree, pattern ) { | t, | subtrees << t }
    return( subtrees )
  end
  
  def visit( tree, what = nil, &block )
    block_given? or return enum_for( :visit, tree, what )
    Symbol === what and what = @token_scheme[ what ]
    case what
    when nil then visit_all( tree, &block )
    when Integer then visit_type( tree, nil, what, &block )
    when String  then visit_pattern( tree, what, &block )
    else raise( ArgumentError, tidy( <<-'END', true ) )
      | The 'what' filter argument must be a tree
      | pattern (String) or a token type (Integer)
      | -- got #{ what.inspect }
      END
    end
  end
  
  def visit_all( tree, parent = nil, &block )
    index = @adaptor.child_index( tree )
    yield( tree, parent, index, nil )
    @adaptor.each_child( tree ) do | child |
      visit_all( child, tree, &block )
    end
  end
  
  def visit_type( tree, parent, type, &block )
    tree.nil? and return( nil )
    index = @adaptor.child_index( tree )
    @adaptor.type_of( tree ) == type and yield( tree, parent, index, nil )
    @adaptor.each_child( tree ) do | child |
      visit_type( child, tree, type, &block )
    end
  end
  
  def visit_pattern( tree, pattern, &block )
    pattern = Pattern.parse( pattern, @token_scheme )
    
    if pattern.nil? or pattern.flat_list? or pattern.is_a?( WildcardPattern )
      return( nil )
    end
    
    visit( tree, pattern.type ) do | tree, parent, child_index, labels |
      labels = match!( tree, pattern ) and
        yield( tree, parent, child_index, labels )
    end
  end
  
  def match( tree, pattern )
    pattern = Pattern.parse( pattern, @token_scheme )
    
    return( match!( tree, pattern ) )
  end
  
  def match!( tree, pattern, labels = {} )
    tree.nil? || pattern.nil? and return false
    unless pattern.is_a? WildcardPattern
      @adaptor.type_of( tree ) == pattern.type or return false
      pattern.has_text_arg && ( @adaptor.text_of( tree ) != pattern.text ) and
        return false
    end
    labels[ pattern.label ] = tree if labels && pattern.label
    
    number_of_children = @adaptor.child_count( tree )
    return false unless number_of_children == pattern.child_count
    
    number_of_children.times do |index|
      actual_child = @adaptor.child_of( tree, index )
      pattern_child = pattern.child( index )
      
      return( false ) unless match!( actual_child, pattern_child, labels )
    end
    
    return labels
  end
  
  def equals( tree_a, tree_b, adaptor = @adaptor )
    tree_a && tree_b or return( false )
    
    adaptor.type_of( tree_a ) == adaptor.type_of( tree_b ) or return false
    adaptor.text_of( tree_a ) == adaptor.text_of( tree_b ) or return false
    
    child_count_a = adaptor.child_count( tree_a )
    child_count_b = adaptor.child_count( tree_b )
    child_count_a == child_count_b or return false
    
    child_count_a.times do | i |
      child_a = adaptor.child_of( tree_a, i )
      child_b = adaptor.child_of( tree_b, i )
      equals( child_a, child_b, adaptor ) or return false
    end
    return true
  end
  
  
  DOT_DOT_PATTERN = /.*[^\.]\\.{2}[^\.].*/
  DOUBLE_ETC_PATTERN = /.*\.{3}\s+\.{3}.*/
  
  def in_context?( tree, context )
    case context
    when DOT_DOT_PATTERN then raise ArgumentError, "invalid syntax: .."
    when DOUBLE_ETC_PATTERN then raise ArgumentError, "invalid syntax: ... ..."
    end
    
    context = context.gsub( /([^\.\s])\.{3}([^\.])/, '\1 ... \2' )
    context.strip!
    nodes = context.split( /\s+/ )
    
    while tree = @adaptor.parent( tree ) and node = nodes.pop
      if node == '...'
        node = nodes.pop or return( true )
        tree = @adaptor.each_ancestor( tree ).find do | t |
          @adaptor.type_name( t ) == node
        end or return( false )
      end
      @adaptor.type_name( tree ) == node or return( false )
    end
    
    return( false ) if tree.nil? and not nodes.empty?
    return true
  end
  
  private :match!
end
end
end
