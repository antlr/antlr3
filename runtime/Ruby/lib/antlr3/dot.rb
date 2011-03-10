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
require 'erb'

module ANTLR3

=begin rdoc ANTLR3::DOT

An extra utility for generating graphviz DOT file representations of ANTLR
Abstract Syntax Tree nodes.

This module has been directly ported to Ruby from the ANTLR Python runtime
library.

=end

module DOT
  class Context
    def []=( var, value )
      instance_variable_set( :"@#{ var }", value )
    end
    def []( var )
      instance_variable_get( :"@#{ var }" )
    end
    
    def initialize( template, vars = {} )
      @__template__ = template
      vars.each do |var, value|
        self[ var ] = value
      end
    end
    
    def to_s
      @__template__.result( binding )
    end
  end
  class TreeGenerator
    TREE_TEMPLATE = ERB.new( Util.tidy( <<-END ) )
    | digraph {
    |   ordering=out;
    |   ranksep=.4;
    |   node [shape=plaintext, fixedsize=true, fontsize=11, fontname="Courier",
    |         width=.25, height=.25];
    |   edge [arrowsize=.5];
    |   <%= @nodes.join("\n  ") %>
    |   <%= @edges.join("\n  ") %>
    | }
    END
    
    NODE_TEMPLATE = ERB.new( Util.tidy( <<-END ) )
    | <%= @name %> [label="<%= @text %>"];
    END
    
    EDGE_TEMPLATE = ERB.new( Util.tidy( <<-END ) )
    | <%= @parent %> -> <%= @child %>; // "<%= @parent_text %>" -> "<%= @child_text %>"
    END
    
    def self.generate( tree, adaptor = nil, tree_template = TREE_TEMPLATE,
                      edge_template = EDGE_TEMPLATE )
      new.to_dot( tree, adaptor, tree_template, edge_template )
    end
    
    def initialize
      @node_number = 0
      @node_to_number_map = Hash.new do |map, node|
        map[ node ] = @node_number
        @node_number += 1
        @node_number - 1
      end
    end
    
    def to_dot( tree, adaptor = nil, tree_template = TREE_TEMPLATE,
               edge_template = EDGE_TEMPLATE )
      adaptor ||= AST::CommonTreeAdaptor.new
      @node_number = 0
      tree_template = Context.new( tree_template, :nodes => [], :edges => [] )
      define_nodes( tree, adaptor, tree_template )
      
      @node_number = 0
      define_edges( tree, adaptor, tree_template, edge_template )
      return tree_template.to_s
    end
    
    def define_nodes( tree, adaptor, tree_template, known_nodes = nil )
      known_nodes ||= Set.new
      tree.nil? and return
      n = adaptor.child_count( tree )
      n == 0 and return
      number = node_number( tree )
      unless known_nodes.include?( number )
        parent_node_template = node_template_for( adaptor, child )
        tree_template[ :nodes ] << parent_node_template
        known_nodes.add( number )
      end
      
      n.times do |index|
        child = adaptor.child_of( tree, index )
        number = @node_to_number_map[ child ]
        unless known_nodes.include?( number )
          node_template = node_template_for( adaptor, child )
          tree_template[ :nodes ] << node_template
          known_nodes.add( number )
        end
        
        define_nodes( child, adaptor, tree_template, edge_template )
      end
    end
    
    def define_edges( tree, adaptor, tree_template, edge_template )
      tree.nil? or return
      
      n = adaptor.child_count( tree )
      n == 0 and return
      
      parent_name = 'n%i' % @node_to_number_map[ tree ]
      parent_text = adaptor.text_of( tree )
      n.times do |index|
        child = adaptor.child_of( tree, index )
        child_text = adaptor.text_of( child )
        child_name = 'n%i' % @node_to_number_map[ tree ]
        edge_template = Context.new( edge_template,
          :parent => parent_name, :child => child_name,
          :parent_text => parent_text, :child_text => child_text
        )
        tree_template[ :edges ] << edge_template
        define_edges( child, adaptor, tree_template, edge_template )
      end
    end
    
    def node_template_for( adaptor, tree )
      text = adaptor.text_of( tree )
      node_template = Context.new( NODE_TEMPLATE )
      unique_name = 'n%i' % @node_to_number_map[ tree ]
      node_template[ :name ] = unique_name
      text and text = text.gsub( /"/, '\\"' )
      node_template[ :text ] = text
      return node_template
    end
  end
end
end
