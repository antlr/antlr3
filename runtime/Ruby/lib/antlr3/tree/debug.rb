#!/usr/bin/ruby
# encoding: utf-8

module ANTLR3
module Debug
=begin rdoc ANTLR3::Debug::TreeAdaptor

Adds debugging event hooks to TreeAdaptor objects

=end
module TreeAdaptor
  
  def self.wrap( adaptor, debug_listener = nil )
    adaptor.extend( self )
    adaptor.debug_listener = debug_listener
    return( adaptor )
  end
  
  attr_accessor :debug_listener
  
  def create_with_payload( payload )
    node = super
    @debug_listener.create_node( node, payload )
    return node
  end
  
  def create_from_token( token_type, from_token, text = nil )
    node = super
    @debug_listener.create_node( node )
    return node
  end
  
  def create_from_type( token_type, text )
    node = super
    @debug_listener.create_node( node )
    return node
  end
  
  def create_error_node( input, start, stop, exc )
    node = super
    node.nil? or @debug_listener.error_node( node )
    return node
  end
  
  def copy_tree( tree )
    t = super
    simulate_tree_construction( t )
    return t
  end
  
  def simulate_tree_construction( tree )
    @debug_listener.create_node( tree )
    child_count( tree ).times do |i|
      child = self.child_of( tree, i )
      simulate_tree_construction( child )
      @debug_listener.add_child( tree, child )
    end
  end
  
  def copy_node( tree_node )
    duplicate = super
    @debug_listener.create_node duplicate
    return duplicate
  end
  
  def create_flat_list
    node = super
    @debug_listener.flat_node( node )
    return node
  end
  
  def add_child( tree, child )
    case child
    when Token
      node = create_with_payload( child )
      add_child( tree, node )
    else
      tree.nil? || child.nil? and return
      super( tree, child )
      @debug_listener.add_child( tree, child )
    end
  end
  
  def become_root( new_root, old_root )
    case new_root
    when Token
      n = create_with_payload( new_root )
      super( n, old_root )
    else
      n = super( new_root, old_root )
    end
    @debug_listener.become_root( new_root, old_root )
    return n
  end
  
  def set_token_boundaries( tree, start_token, stop_token )
    super( tree, start_token, stop_token )
    return unless tree && start_token && stop_token
    @debug_listener.set_token_boundaries( tree,
      start_token.token_index, stop_token.token_index )
  end
end

=begin rdoc ANTLR3::Debug::TreeNodeStream

A module that wraps token stream methods with debugging event code. A debuggable
parser will <tt>extend</tt> its input stream with this module if the stream is
not already a Debug::TreeNodeStream.

=end
class TreeNodeStream
  
  def self.wrap( stream, debug_listener = nil )
    stream.extend( self )
    stream.debug_listener ||= debug_listener
  end
  attr_accessor :debug_listener
  
  def consume
    node = @input >> 1
    super
    @debug_listener.consume_node( node )
  end
  
  def look( i = 1 )
    node = super
    id = @adaptor.unique_id( node )
    text = @adaptor.text_of( node )
    type = @adaptor.type_of( node )
    @debug_listener.look( i, node )
    return( node )
  end
  
  def peek( i = 1 )
    node = self >> 1
    id = @adaptor.unique_id( node )
    text = @adaptor.text_of( node )
    type = @adaptor.type_of( node )
    @debug_listener.look( i, node )
    return( type )
  end
  
  def mark
    @last_marker = super
    @debug_listener.mark( @last_marker )
    return( @last_marker )
  end
  
  def rewind( marker = nil )
    @debug_listener.rewind( marker )
    super( marker || @last_marker )
  end

=begin   This actually differs with reset in CommonTreeNodeStream -- why is this one blank?
  def reset
    # do nothing
  end
=end

end


end
end
