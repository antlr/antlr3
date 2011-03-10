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
  
=begin rdoc ANTLR3::AST

Name space containing all of the entities pertaining to tree construction and
tree parsing.

=end

module AST

autoload :Wizard, 'antlr3/tree/wizard'
autoload :Visitor, 'antlr3/tree/visitor'

####################################################################################################
############################################ Tree Parser ###########################################
####################################################################################################

=begin rdoc ANTLR3::AST::TreeParser

= TreeParser

TreeParser is the default base class of ANTLR-generated tree parsers. The class
tailors the functionality provided by Recognizer to the task of tree-pattern
recognition.

== About Tree Parsers

ANTLR generates three basic types of recognizers:
* lexers
* parsers
* tree parsers

Furthermore, it is capable of generating several different flavors of parser,
including parsers that take token input and use it to build Abstract Syntax
Trees (ASTs), tree structures that reflect the high-level syntactic and semantic
structures defined by the language.

You can take the information encapsulated by the AST and process it directly in
a program. However, ANTLR also provides a means to create a recognizer which is
capable of walking through the AST, verifying its structure and performing
custom actions along the way -- tree parsers.

Tree parsers are created from tree grammars. ANTLR-generated tree parsers
closely mirror the general structure of regular parsers and lexers.

For more in-depth coverage of the topic, check out the ANTLR documentation
(http://www.antlr.org).

== The Tree Parser API

Like Parser, the class does not stray too far from the Recognizer API.
Mainly, it customizes a few methods specifically to deal with tree nodes
(instead of basic tokens), and adds some helper methods for working with trees.

Like all ANTLR recognizers, tree parsers contained a shared state structure and
an input stream, which should be a TreeNodeStream. ANTLR intends to keep its
tree features flexible and customizable, and thus it does not make any
assumptions about the class of the actual nodes it processes. One consequence of
this flexibility is that tree parsers also require an extra tree adaptor object,
the purpose of which is to provide a homogeneous interface for handling tree
construction and analysis of your tree nodes.

See Tree and TreeAdaptor for more information.

=end

class TreeParser < Recognizer
  def self.main( argv = ARGV, options = {} )
    if ::Hash === argv then argv, options = ARGV, argv end
    main = ANTLR3::Main::WalkerMain.new( self, options )
    block_given? ? yield( main ) : main.execute( argv )
  end
  
  def initialize( input, options = {} )
    super( options )
    @input = input
  end
  
  alias tree_node_stream input
  alias tree_node_stream= input=
  
  def source_name
    @input.source_name
  end
  
  def missing_symbol( error, expected_token_type, follow )
    name = token_name( expected_token_type ).to_s
    text = "<missing " << name << '>'
    tk = create_token do |t|
      t.text = text
      t.type = expected_token_type
    end
    return( CommonTree.new( tk ) )
  end
  
  def match_any( ignore = nil )
    @state.error_recovery = false
    
    look, adaptor = @input.look, @input.tree_adaptor
    if adaptor.child_count( look ) == 0
      @input.consume
      return
    end
    
    level = 0
    while type = @input.peek and type != EOF
      #token_type == EOF or ( token_type == UP && level == 0 )
      @input.consume
      case type
      when DOWN then level += 1
      when UP
        level -= 1
        level.zero? and break
      end
    end
  end
  
  def mismatch( input, type, follow = nil )
    raise MismatchedTreeNode.new( type, input )
  end
  
  def error_header( e )
    <<-END.strip!
    #{ grammar_file_name }: node from #{ 
      e.approximate_line_info? ? 'after ' : ''
    } line #{ e.line }:#{ e.column }
    END
  end
  
  def error_message( e )
    adaptor = e.input.adaptor
    e.token = adaptor.token( e.node )
    e.token ||= create_token do | tok |
      tok.type = adaptor.type_of( e.node )
      tok.text = adaptor.text_of( e.node )
    end
    return super( e )
  end
  
  def trace_in( rule_name, rule_index )
    super( rule_name, rule_index, @input.look )
  end
  
  def trace_out( rule_name, rule_index )
    super( rule_name, rule_index, @input.look )
  end
end

####################################################################################################
############################################ Tree Nodes ############################################
####################################################################################################

=begin rdoc ANTLR3::AST::Tree

= ANTLR Abstract Syntax Trees

As ANTLR is concerned, an Abstract Syntax Tree (AST) node is an object that
wraps a token, a list of child trees, and some information about the collective
source text embodied within the tree and its children.

The Tree module, like the Token and Stream modules, emulates an abstract base
class for AST classes; it specifies the attributes that are expected of basic
tree nodes as well as the methods trees need to implement.

== Terminology

While much of this terminology is probably familiar to most developers, the
following brief glossary is intended to clarify terminology used in code
throughout the AST library:

[payload] either a token value contained within a node or +nil+
[flat list (nil tree)] a tree node without a token payload, but with more 
                       than one children -- functions like an array of 
                       tree nodes
[root] a top-level tree node, i.e. a node that does not have a parent
[leaf] a node that does not have any children
[siblings] all other nodes sharing the same parent as some node
[ancestors] the list of successive parents from a tree node to the root node
[error node] a special node used to represent an erroneous series of tokens
             from an input stream

=end

module Tree
  
  #attr_accessor :parent
  attr_accessor :start_index
  attr_accessor :stop_index
  attr_accessor :child_index
  attr_reader :type
  attr_reader :text
  attr_reader :line
  attr_reader :column
  #attr_reader :children
  attr_reader :token
  
  
  def root?
    parent.nil?
  end
  alias detached? root?
  
  def root
    cursor = self
    until cursor.root?
      yield( parent_node = cursor.parent )
      cursor = parent_node
    end
    return( cursor )
  end
  
  #
  def leaf?
    children.nil? or children.empty?
  end
  
  def has_child?( node )
    children and children.include?( node )
  end
  
  def depth
    root? ? 0 : parent.depth + 1
  end
  
  def siblings
    root? and return []
    parent.children.reject { | c | c.equal?( self ) }
  end
  
  def each_ancestor
    block_given? or return( enum_for( :each_ancestor ) )
    cursor = self
    until cursor.root?
      yield( parent_node = cursor.parent )
      cursor = parent_node
    end
    return( self )
  end
  
  def ancestors
    each_ancestor.to_a
  end
  
  def walk
    block_given? or return( enum_for( :walk ) )
    stack = []
    cursor = self
    while true
      begin
        yield( cursor )
        stack.push( cursor.children.dup ) unless cursor.empty?
      rescue StopIteration
        # skips adding children to prune the node
      ensure
        break if stack.empty?
        cursor = stack.last.shift
        stack.pop if stack.last.empty?
      end
    end
    return self
  end
  
end


=begin rdoc ANTLR3::AST::BaseTree

A base implementation of an Abstract Syntax Tree Node. It mainly defines the
methods and attributes required to implement the parent-node-children
relationship that characterize a tree; it does not provide any logic concerning
a node's token <i>payload</i>.

=end

class BaseTree < ::Array
  attr_accessor :parent
  extend ClassMacros
  include Tree
  
  def initialize( node = nil )
    super()
    @parent = nil
    @child_index = 0
  end
  
  def children() self end
  
  alias child at
  alias child_count length
  
  def first_with_type( tree_type )
    find { | child | child.type == tree_type }
  end
  
  def add_child( child_tree )
    child_tree.nil? and return
    if child_tree.flat_list?
      self.equal?( child_tree.children ) and
        raise ArgumentError, "attempt to add child list to itself"
      child_tree.each_with_index do | child, index |
        child.parent = self
        child.child_index = length + index
      end
      concat( child_tree )
    else
      child_tree.child_index = length
      child_tree.parent = self
      self << child_tree
    end
    return( self )
  end
  
  def detach
    @parent = nil
    @child_index = -1
    return( self )
  end
  
  alias add_children concat
  alias each_child each
  
  def set_child( index, tree )
    return if tree.nil?
    tree.flat_list? and raise ArgumentError, "Can't set single child to a list"
    tree.parent = self
    tree.child_index = index
    self[ index ] = tree
  end
  
  def delete_child( index )
    killed = delete_at( index ) and freshen( index )
    return killed
  end

  def replace_children( start, stop, new_tree )
    start >= length or stop >= length and
      raise IndexError, ( <<-END ).gsub!( /^\s+\| /,'' )
      | indices span beyond the number of children:
      |  children.length = #{ length }
      |  start = #{ start_index.inspect }
      |  stop  = #{ stop_index.inspect }
      END
    new_children = new_tree.flat_list? ? new_tree : [ new_tree ]
    self[ start .. stop ] = new_children
    freshen( start_index )
    return self
  end
  
  def flat_list?
    false
  end
  
  def freshen( offset = 0 )
    for i in offset ... length
      node = self[ i ]
      node.child_index = i
      node.parent = self
    end
  end
  
  def sanity_check( parent = nil, i = -1 )
    parent == @parent or
      raise TreeInconsistency.failed_parent_check!( parent, @parent )
    i == @child_index or
      raise TreeInconsistency.failed_index_check!( i, @child_index )
    each_with_index do | child, index |
      child.sanity_check( self, index )
    end
  end
  
  def inspect
    empty? and return to_s
    buffer = ''
    buffer << '(' << to_s << ' ' unless flat_list?
    buffer << map { | c | c.inspect }.join( ' ' )
    buffer << ')' unless flat_list?
    return( buffer )
  end
  
  def walk
    block_given? or return( enum_for( :walk ) )
    stack = []
    cursor = self
    while true
      begin
        yield( cursor )
        stack.push( Array[ *cursor ] ) unless cursor.empty?
      rescue StopIteration
        # skips adding children to prune the node
      ensure
        break if stack.empty?
        cursor = stack.last.shift
        stack.pop if stack.last.empty?
      end
    end
    return self
  end
  
  def prune
    raise StopIteration
  end
  
  abstract :to_s
  #protected :sanity_check, :freshen
  
  def root?() @parent.nil? end
  alias leaf? empty?
end


=begin rdoc ANTLR3::AST::CommonTree

The default Tree class implementation used by ANTLR tree-related code.

A CommonTree object is a tree node that wraps a token <i>payload</i> (or a +nil+
value) and contains zero or more child tree nodes. Additionally, it tracks
information about the range of data collectively spanned by the tree node: 

* the token stream start and stop indexes of tokens contained throughout 
  the tree 
* that start and stop positions of the character input stream from which 
  the tokens were defined

Tracking this information simplifies tasks like extracting a block of code or
rewriting the input stream. However, depending on the purpose of the
application, building trees with all of this extra information may be
unnecessary. In such a case, a more bare-bones tree class could be written
(optionally using the BaseTree class or the Token module). Define a customized
TreeAdaptor class to handle tree construction and manipulation for the
customized node class, and recognizers will be able to build, rewrite, and parse
the customized lighter-weight trees.

=end

class CommonTree < BaseTree
  def initialize( payload = nil )
    super()
    @start_index = -1
    @stop_index = -1
    @child_index = -1
    case payload
    when CommonTree then   # copy-constructor style init
      @token       = payload.token
      @start_index = payload.start_index
      @stop_index  = payload.stop_index
    when nil, Token then @token = payload
    else raise ArgumentError,
      "Invalid argument type: %s (%p)" % [ payload.class, payload ]
    end
  end
  
  def initialize_copy( orig )
    super
    clear
    @parent = nil
  end
  
  def copy_node
    return self.class.new( @token )
  end
  
  def flat_list?
    @token.nil?
  end
  
  def type
    @token ? @token.type : 0
  end
  
  def text
    @token.text rescue nil
  end
  
  def line
    if @token.nil? or @token.line == 0
      return ( empty? ? 0 : first.line )
    end
    return @token.line
  end
  
  def column
    if @token.nil? or @token.column == -1
      return( empty? ? 0 : first.column )
    end
    return @token.column
  end
  
  def start_index
    @start_index == -1 and @token and return @token.index
    return @start_index
  end
  
  def stop_index
    @stop_index == -1 and @token and return @token.index
    return @stop_index
  end
  
  alias token_start_index= start_index=
  alias token_stop_index= stop_index=
  alias token_start_index start_index
  alias token_stop_index stop_index
  
  def name
    @token.name rescue 'INVALID'
  end
  
  def token_range
    unknown_boundaries? and infer_boundaries
    @start_index .. @stop_index
  end
  
  def source_range
    unknown_boundaries? and infer_boundaries
    tokens = map do | node |
      tk = node.token and tk.index >= 0 ? tk : nil
    end
    tokens.compact!
    first, last = tokens.minmax_by { |t| t.index }
    first.start .. last.stop
  end
  
  def infer_boundaries
    if empty? and @start_index < 0 || @stop_index < 0
      @start_index = @stop_index = @token.index rescue -1
      return
    end
    for child in self do child.infer_boundaries end
    return if @start_index >= 0 and @stop_index >= 0
    
    @start_index = first.start_index
    @stop_index  = last.stop_index
    return nil
  end
  
  def unknown_boundaries?
    @start_index < 0 or @stop_index < 0
  end
  
  def to_s
    flat_list? ? 'nil' : @token.text.to_s
  end
  
  def pretty_print( printer )
    text = @token ? @token.text : 'nil'
    text =~ /\s+/ and
      text = text.dump
    
    if empty?
      printer.text( text )
    else
      endpoints = @token ? [ "(#{ text }", ')' ] : [ '', '' ]
      printer.group( 1, *endpoints ) do
        for child in self
          printer.breakable
          printer.pp( child )
        end
      end
    end
  end
  
end

=begin rdoc ANTLR3::AST::CommonErrorNode

Represents a series of erroneous tokens from a token stream input

=end

class CommonErrorNode < CommonTree
  include ANTLR3::Error
  include ANTLR3::Constants
  
  attr_accessor :input, :start, :stop, :error
  
  def initialize( input, start, stop, error )
    super( nil )
    stop = start if stop.nil? or
      ( stop.token_index < start.token_index and stop.type != EOF )
    @input = input
    @start = start
    @stop = stop
    @error = error
  end
  
  def flat_list?
    return false
  end
  
  def type
    INVALID_TOKEN_TYPE
  end
  
  def text
    case @start
    when Token
      i = @start.token_index
      j = ( @stop.type == EOF ) ? @input.size : @stop.token_index
      @input.to_s( i, j )            # <- the bad text
    when Tree
      @input.to_s( @start, @stop )   # <- the bad text
    else
      "<unknown>"
    end
  end
  
  def to_s
    case @error
    when MissingToken
      "<missing type: #{ @error.missing_type }>"
    when UnwantedToken
      "<extraneous: #{ @error.token.inspect }, resync = #{ text }>"
    when MismatchedToken
      "<mismatched token: #{ @error.token.inspect }, resync = #{ text }>"
    when NoViableAlternative
      "<unexpected: #{ @error.token.inspect }, resync = #{ text }>"
    else "<error: #{ text }>"
    end
  end
  
end

Constants::INVALID_NODE = CommonTree.new( ANTLR3::INVALID_TOKEN )

####################################################################################################
########################################### Tree Adaptors ##########################################
####################################################################################################

=begin rdoc ANTLR3::AST::TreeAdaptor

Since a tree can be represented by a multitude of formats, ANTLR's tree-related
code mandates the use of Tree Adaptor objects to build and manipulate any actual
trees. Using an adaptor object permits a single recognizer to work with any
number of different tree structures without adding rigid interface requirements
on customized tree structures. For example, if you want to represent trees using
simple arrays of arrays, you just need to design an appropriate tree adaptor and
provide it to the parser.

Tree adaptors are tasked with:

* copying and creating tree nodes and tokens
* defining parent-child relationships between nodes
* cleaning up / normalizing a full tree structure after construction
* reading and writing the attributes ANTLR expects of tree nodes
* providing node access and iteration

=end

module TreeAdaptor
  include TokenFactory
  include Constants
  include Error
  
  def add_child( tree, child )
    tree.add_child( child ) if tree and child
  end
  
  def child_count( tree )
    tree.child_count
  end
  
  def child_index( tree )
    tree.child_index rescue 0
  end
  
  def child_of( tree, index )
    tree.nil? ? nil : tree.child( index )
  end
  
  def copy_node( tree_node )
    tree_node and tree_node.dup
  end

  def copy_tree( tree, parent = nil )
    tree or return nil
    new_tree = copy_node( tree )
    set_child_index( new_tree, child_index( tree ) )
    set_parent( new_tree, parent )
    each_child( tree ) do | child |
      new_sub_tree = copy_tree( child, new_tree )
      add_child( new_tree, new_sub_tree )
    end
    return new_tree
  end
  
  def delete_child( tree, index )
    tree.delete_child( index )
  end
  
  
  def each_child( tree )
    block_given? or return enum_for( :each_child, tree )
    for i in 0 ... child_count( tree )
      yield( child_of( tree, i ) )
    end
    return tree
  end
  
  def each_ancestor( tree, include_tree = true )
    block_given? or return enum_for( :each_ancestor, tree, include_tree )
    if include_tree
      begin yield( tree ) end while tree = parent_of( tree )
    else
      while tree = parent_of( tree ) do yield( tree ) end
    end
  end
  
  def flat_list?( tree )
    tree.flat_list?
  end
  
  def empty?( tree )
    child_count( tree ).zero?
  end
  
  def parent( tree )
    tree.parent
  end
  
  def replace_children( parent, start, stop, replacement )
    parent and parent.replace_children( start, stop, replacement )
  end

  def rule_post_processing( root )
    if root and root.flat_list?
      case root.child_count
      when 0 then root = nil
      when 1
        root = root.child( 0 ).detach
      end
    end
    return root
  end
  
  def set_child_index( tree, index )
    tree.child_index = index
  end

  def set_parent( tree, parent )
    tree.parent = parent
  end
  
  def set_token_boundaries( tree, start_token = nil, stop_token = nil )
    return unless tree
    start = stop = 0
    start_token and start = start_token.index
    stop_token  and stop  = stop_token.index
    tree.start_index = start
    tree.stop_index = stop
    return tree
  end

  def text_of( tree )
    tree.text rescue nil
  end

  def token( tree )
    CommonTree === tree ? tree.token : nil
  end

  def token_start_index( tree )
    tree ? tree.token_start_index : -1
  end
  
  def token_stop_index( tree )
    tree ? tree.token_stop_index : -1
  end
  
  def type_name( tree )
    tree.name rescue 'INVALID'
  end
  
  def type_of( tree )
    tree.type rescue INVALID_TOKEN_TYPE
  end
  
  def unique_id( node )
    node.hash
  end
  
end

=begin rdoc ANTLR3::AST::CommonTreeAdaptor

The default tree adaptor used by ANTLR-generated tree code. It, of course,
builds and manipulates CommonTree nodes.

=end

class CommonTreeAdaptor
  extend ClassMacros
  include TreeAdaptor
  include ANTLR3::Constants
  
  def initialize( token_class = ANTLR3::CommonToken )
    @token_class = token_class
  end
  
  def create_flat_list
    return create_with_payload( nil )
  end
  alias create_flat_list! create_flat_list
  
  def become_root( new_root, old_root )
    new_root = create( new_root ) if new_root.is_a?( Token )
    old_root or return( new_root )
    
    new_root = create_with_payload( new_root ) unless CommonTree === new_root
    if new_root.flat_list?
      count = new_root.child_count
      if count == 1
        new_root = new_root.child( 0 )
      elsif count > 1
        raise TreeInconsistency.multiple_roots!
      end
    end
    
    new_root.add_child( old_root )
    return new_root
  end
  
  def create_from_token( token_type, from_token, text = nil )
    from_token = from_token.dup
    from_token.type = token_type
    from_token.text = text.to_s if text
    tree = create_with_payload( from_token )
    return tree
  end
  
  def create_from_type( token_type, text )
    from_token = create_token( token_type, DEFAULT_CHANNEL, text )
    create_with_payload( from_token )
  end
  
  def create_error_node( input, start, stop, exc )
    CommonErrorNode.new( input, start, stop, exc )
  end
  
  def create_with_payload( payload )
    return CommonTree.new( payload )
  end

  def create( *args )
    n = args.length
    if n == 1 and args.first.is_a?( Token ) then create_with_payload( args[ 0 ] )
    elsif n == 2 and Integer === args.first and String === args[ 1 ]
      create_from_type( *args )
    elsif n >= 2 and Integer === args.first
      create_from_token( *args )
    else
      sig = args.map { |f| f.class }.join( ', ' )
      raise TypeError, "No create method with this signature found: (#{ sig })"
    end
  end
  
  creation_methods = %w(
    create_from_token create_from_type
    create_error_node create_with_payload
    create
  )
  
  for method_name in creation_methods
    bang_method = method_name + '!'
    alias_method( bang_method, method_name )
    deprecate( bang_method, "use method ##{ method_name } instead" )
  end
  
  def rule_post_processing( root )
    if root and root.flat_list?
      if root.empty? then root = nil
      elsif root.child_count == 1 then root = root.first.detach
      end
    end
    return root
  end
  
  def empty?( tree )
    tree.empty?
  end
  
  def each_child( tree )
    block_given? or return enum_for( :each_child, tree )
    tree.each do | child |
      yield( child )
    end
  end
  
end


####################################################################################################
########################################### Tree Streams ###########################################
####################################################################################################

=begin rdoc ANTLR3::AST::TreeNodeStream

TreeNodeStreams flatten two-dimensional tree structures into one-dimensional
sequences. They preserve the two-dimensional structure of the tree by inserting
special +UP+ and +DOWN+ nodes.

Consider a hypothetical tree:

  [A]
   +--[B]
   |   +--[C]
   |   `--[D]
   `--[E]
       `--[F]

A tree node stream would serialize the tree into the following sequence:

  A DOWN B DOWN C D UP E DOWN F UP UP EOF

Other than serializing a tree into a sequence of nodes, a tree node stream
operates similarly to other streams. They are commonly used by tree parsers as
the main form of input. #peek, like token streams, returns the type of the token
of the next node. #look returns the next full tree node.

=end

module TreeNodeStream
  extend ClassMacros
  include Stream
  include Constants
  
  abstract :at
  abstract :look
  abstract :tree_source
  abstract :token_stream
  abstract :tree_adaptor
  abstract :unique_navigation_nodes=
  abstract :to_s
  abstract :replace_children
end

=begin rdoc ANTLR3::AST::CommonTreeNodeStream

An implementation of TreeNodeStream tailed for streams based on CommonTree
objects. CommonTreeNodeStreams are the default input streams for tree parsers.

=end

class CommonTreeNodeStream
  include TreeNodeStream
  
  attr_accessor :token_stream
  attr_reader :adaptor, :position
  
  def initialize( *args )
    options = args.last.is_a?( ::Hash ) ? args.pop : {}
    case n = args.length
    when 1
      @root = args.first
      @token_stream = @adaptor = @nodes = @down = @up = @eof = nil
    when 2
      @adaptor, @root = args
      @token_stream = @nodes = @down = @up = @eof = nil
    when 3
      parent, start, stop = *args
      @adaptor = parent.adaptor
      @root = parent.root
      @nodes = parent.nodes[ start ... stop ]
      @down = parent.down
      @up = parent.up
      @eof = parent.eof
      @token_stream = parent.token_stream
    when 0
      raise ArgumentError, "wrong number of arguments (0 for 1)"
    else raise ArgumentError, "wrong number of arguments (#{ n } for 3)"
    end
    @adaptor ||= options.fetch( :adaptor ) { CommonTreeAdaptor.new }
    @token_stream ||= options[ :token_stream ]
    @down  ||= options.fetch( :down ) { @adaptor.create_from_type( DOWN, 'DOWN' ) }
    @up    ||= options.fetch( :up )   { @adaptor.create_from_type( UP, 'UP' ) }
    @eof   ||= options.fetch( :eof )  { @adaptor.create_from_type( EOF, 'EOF' ) }
    @nodes ||= []
    
    @unique_navigation_nodes = options.fetch( :unique_navigation_nodes, false )
    @position = -1
    @last_marker = nil
    @calls = []
  end
  
  def fill_buffer( tree = @root )
    @nodes << tree unless nil_tree = @adaptor.flat_list?( tree )
    unless @adaptor.empty?( tree )
      add_navigation_node( DOWN ) unless nil_tree
      @adaptor.each_child( tree ) { | c | fill_buffer( c ) }
      add_navigation_node( UP ) unless nil_tree
    end
    @position = 0 if tree == @root
    return( self )
  end
  
  def node_index( node )
    @position == -1 and fill_buffer
    return @nodes.index( node )
  end
  
  def add_navigation_node( type )
    navigation_node =
      case type
      when DOWN
        has_unique_navigation_nodes? ? @adaptor.create_from_type( DOWN, 'DOWN' ) : @down
      else
        has_unique_navigation_nodes? ? @adaptor.create_from_type( UP, 'UP' ) : @up
      end
    @nodes << navigation_node
  end
  
  def at( index )
    @position == -1 and fill_buffer
    @nodes.at( index )
  end
  
  def look( k = 1 )
    @position == -1 and fill_buffer
    k == 0 and return nil
    k < 0 and return self.look_behind( -k )
    
    absolute = @position + k - 1
    @nodes.fetch( absolute, @eof )
  end
  
  def current_symbol
    look
  end
  
  def look_behind( k = 1 )
    k == 0 and return nil
    absolute = @position - k
    return( absolute < 0 ? nil : @nodes.fetch( absolute, @eof ) )
  end
  
  def tree_source
    @root
  end
  
  def source_name
    self.token_stream.source_name
  end
  
  def tree_adaptor
    @adaptor
  end
  
  def has_unique_navigation_nodes?
    return @unique_navigation_nodes
  end
  attr_writer :unique_navigation_nodes
  
  def consume
    @position == -1 and fill_buffer
    node = @nodes.fetch( @position, @eof )
    @position += 1
    return( node )
  end
  
  def peek( i = 1 )
    @adaptor.type_of look( i )
  end
  
  alias >> peek
  def <<( k )
    self >> -k
  end
  
  def mark
    @position == -1 and fill_buffer
    @last_marker = @position
    return @last_marker
  end
  
  def release( marker = nil )
    # do nothing?
  end
  
  alias index position
  
  def rewind( marker = @last_marker, release = true )
    seek( marker )
  end

  def seek( index )
    @position == -1 and fill_buffer
    @position = index
  end
  
  def push( index )
    @calls << @position
    seek( index )
  end
  
  def pop
    pos = @calls.pop and seek( pos )
    return pos
  end
  
  def reset
    @position = 0
    @last_marker = 0
    @calls = []
  end
  
  def replace_children( parent, start, stop, replacement )
    parent and @adaptor.replace_children( parent, start, stop, replacement )
  end
  
  def size
    @position == -1 and fill_buffer
    return @nodes.length
  end
  
  def inspect
    @position == -1 and fill_buffer
    @nodes.map { |nd| @adaptor.type_name( nd ) }.join( ' ' )
  end
  
  def extract_text( start = nil, stop = nil )
    start.nil? || stop.nil? and return nil
    @position == -1 and fill_buffer
    
    if @token_stream
      from = @adaptor.token_start_index( start )
      to = 
        case @adaptor.type_of( stop )
        when UP then @adaptor.token_stop_index( start )
        when EOF then to = @nodes.length - 2
        else @adaptor.token_stop_index( stop )
        end
      return @token_stream.extract_text( from, to )
    end
    
    buffer = ''
    for node in @nodes
      if node == start ... node == stop  # <-- hey look, it's the flip flop operator
        buffer << @adaptor.text_of( node ) #|| ' ' << @adaptor.type_of( node ).to_s )
      end
    end
    return( buffer )
  end
  
  def each
    @position == -1 and fill_buffer
    block_given? or return enum_for( :each )
    for node in @nodes do yield( node ) end
    self
  end
  
  include Enumerable
  
  def to_a
    return @nodes.dup
  end
  
  def extract_text( start = nil, stop = nil )
    @position == -1 and fill_buffer
    start ||= @nodes.first
    stop  ||= @nodes.last
    
    if @token_stream
      case @adaptor.type_of( stop )
      when UP
        stop_index = @adaptor.token_stop_index( start )
      when EOF
        return extract_text( start, @nodes[ - 2 ] )
      else
        stop_index = @adaptor.token_stop_index( stop )
      end
      
      start_index = @adaptor.token_start_index( start )
      return @token_stream.extract_text( start_index, stop_index )
    else
      start_index = @nodes.index( start ) || @nodes.length
      stop_index  = @nodes.index( stop )  || @nodes.length
      return( 
        @nodes[ start_index .. stop_index ].map do | n |
          @adaptor.text_of( n ) or " " + @adaptor.type_of( n ).to_s
        end.join( '' )
      )
    end
  end
  
  alias to_s extract_text
  
#private
#  
#  def linear_node_index( node )
#    @position == -1 and fill_buffer
#    @nodes.each_with_index do |n, i|
#      node == n and return(i)
#    end
#    return -1
#  end
end

=begin rdoc ANTLR3::AST::RewriteRuleElementStream

Special type of stream that is used internally by tree-building and tree-
rewriting parsers.

=end

class RewriteRuleElementStream # < Array
  extend ClassMacros
  include Error
  
  def initialize( adaptor, element_description, elements = nil )
    @cursor = 0
    @single_element = nil
    @elements = nil
    @dirty = false
    @element_description = element_description
    @adaptor = adaptor
    if elements.instance_of?( Array )
      @elements = elements
    else
      add( elements )
    end
  end
  
  def reset
    @cursor = 0
    @dirty = true
  end
  
  def add( el )
    return( nil ) unless el
    case
    when ! el then return( nil )
    when @elements then @elements << el
    when @single_element.nil? then @single_element = el
    else
      @elements = [ @single_element, el ]
      @single_element = nil
      return( @elements )
    end
  end
  
  def next_tree
    if @dirty or @cursor >= length && length == 1
      return dup( __next__ )
    end
    __next__
  end
  
  abstract :dup
  
  def to_tree( el )
    return el
  end
  
  def has_next?
    return( @single_element && @cursor < 1 or
           @elements && @cursor < @elements.length )
  end
  
  def size
    @single_element and return 1
    @elements and return @elements.length
    return 0
  end
  
  alias length size
  
private
  
  def __next__
    l = length
    case
    when l.zero?
      raise Error::RewriteEmptyStream.new( @element_description )
    when @cursor >= l
      l == 1 and return to_tree( @single_element )
      raise RewriteCardinalityError.new( @element_description )
    when @single_element
      @cursor += 1
      return( to_tree( @single_element ) )
    else
      out = to_tree( @elements.at( @cursor ) )
      @cursor += 1
      return( out )
    end
  end
end


=begin rdoc ANTLR3::AST::RewriteRuleTokenStream

Special type of stream that is used internally by tree-building and tree-
rewriting parsers.

=end
class RewriteRuleTokenStream < RewriteRuleElementStream
  def next_node
    return @adaptor.create_with_payload( __next__ )
  end
  
  alias :next :__next__
  public :next
  
  def dup( el )
    raise TypeError, "dup can't be called for a token stream"
  end
end

=begin rdoc ANTLR3::AST::RewriteRuleSubtreeStream

Special type of stream that is used internally by tree-building and tree-
rewriting parsers.

=end

class RewriteRuleSubtreeStream < RewriteRuleElementStream
  def next_node
    if @dirty or @cursor >= length && length == 1
      return @adaptor.copy_node( __next__ )
    end
    return __next__
  end
  
  def dup( el )
    @adaptor.copy_tree( el )
  end
end

=begin rdoc ANTLR3::AST::RewriteRuleNodeStream

Special type of stream that is used internally by tree-building and tree-
rewriting parsers.

=end

class RewriteRuleNodeStream < RewriteRuleElementStream
  alias next_node __next__
  public :next_node
  def to_tree( el )
    @adaptor.copy_node( el )
  end
  
  def dup( el )
    raise TypeError, "dup can't be called for a node stream"
  end
end
end

include AST
end
