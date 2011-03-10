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
module AST

=begin rdoc ANTLR3::AST::Visitor

AST::Visitor is an extra utility class for working with tree objects. Visitor
objects are similar to plain vanilla iterators, but provide two action hooks,
instead a standard single iteration block. The <tt>visit(tree)</tt> method walks
through each node of the tree (top-down left-to-right). If +pre_action+ is
defined, a node is yielded to the block when it has been initially entered. If
+post_action+ is defined, a node is yielded to the block after all of its
children have been visited.

=end

class Visitor
  def initialize( adaptor = nil )
    @adaptor = adaptor || CommonTreeAdaptor.new()
    @pre_action = nil
    @post_action = nil
    block_given? and yield( self )
  end
  
  def pre_action( &block )
    block_given? and @pre_action = block
    return @pre_action
  end
  
  def post_action( &block )
    block_given? and @post_action = block
    return @post_action
  end
  
  def visit( tree, pre_action = nil, post_action = nil )
    flat = @adaptor.flat_list?( tree )
    before = pre_action || @pre_action
    after = post_action || @post_action
    
    tree = before.call( tree ) unless before.nil? or flat
    @adaptor.child_count( tree ).times do |index|
      child = @adaptor.child_of( tree, index )
      visit( child, pre_action, post_action )
    end
    tree = after.call( tree ) unless after.nil? or flat
    
    return tree
  end
end
end
end
