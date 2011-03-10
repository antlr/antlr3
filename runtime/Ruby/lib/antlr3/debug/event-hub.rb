#!/usr/bin/ruby
# encoding: utf-8

module ANTLR3
module Debug
=begin rdoc ANTLR3::Debug::EventHub

A special event listener that intercepts debug events and forwards them to other
debug event listners. As debug-mode recognizers are able to send event
information to only one listener, EventHubs provide a simple solution in
situations where multiple event listners are desired.

=end
class EventHub
  include ANTLR3::Debug::EventListener
  attr_reader :listeners
  
  def initialize( *listeners )
    @listeners = [ listeners ].flatten!
    @listeners.compact!
  end
  
  def add( *listeners )
    @listeners.push( *listeners )
  end

  def add_child( root, child )
    for listener in @listeners
      listener.add_child( root, child )
    end
  end
  
  def backtrack( level )
    for listener in @listeners
      listener.backtrack( level )
    end
  end
  
  def become_root( new_root, old_root )
    for listener in @listeners
      listener.become_root( new_root, old_root )
    end
  end
  
  def begin_backtrack( level )
    for listener in @listeners
      listener.begin_backtrack( level )
    end
  end
  
  def begin_resync()
    for listener in @listeners
      listener.begin_resync()
    end
  end
  
  def commence()
    for listener in @listeners
      listener.commence()
    end
  end
  
  def consume_hidden_token( tree )
    for listener in @listeners
      listener.consume_hidden_token( tree )
    end
  end
  
  def consume_node( tree )
    for listener in @listeners
      listener.consume_node( tree )
    end
  end
  
  def consume_token( tree )
    for listener in @listeners
      listener.consume_token( tree )
    end
  end
  
  def create_node( node, token )
    for listener in @listeners
      listener.create_node( node, token )
    end
  end
  
  def end_backtrack( level, successful )
    for listener in @listeners
      listener.end_backtrack( level, successful )
    end
  end
  
  def end_resync()
    for listener in @listeners
      listener.end_resync()
    end
  end
  
  def enter_alternative( alt )
    for listener in @listeners
      listener.enter_alternative( alt )
    end
  end
  
  def enter_decision( decision_number )
    for listener in @listeners
      listener.enter_decision( decision_number )
    end
  end
  
  def enter_rule( grammar_file_name, rule_name )
    for listener in @listeners
      listener.enter_rule( grammar_file_name, rule_name )
    end
  end
  
  def enter_sub_rule( decision_number )
    for listener in @listeners
      listener.enter_sub_rule( decision_number )
    end
  end
  
  def error_node( tree )
    for listener in @listeners
      listener.error_node( tree )
    end
  end
  
  def exit_decision( decision_number )
    for listener in @listeners
      listener.exit_decision( decision_number )
    end
  end
  
  def exit_rule( grammar_file_name, rule_name )
    for listener in @listeners
      listener.exit_rule( grammar_file_name, rule_name )
    end
  end
  
  def exit_sub_rule( decision_number )
    for listener in @listeners
      listener.exit_sub_rule( decision_number )
    end
  end
  
  def flat_node( tree )
    for listener in @listeners
      listener.flat_node( tree )
    end
  end
  
  def location( line, position )
    for listener in @listeners
      listener.location( line, position )
    end
  end
  
  def look( i, tree )
    for listener in @listeners
      listener.look( i, tree )
    end
  end
  
  def mark( marker )
    for listener in @listeners
      listener.mark( marker )
    end
  end
  
  def recognition_exception( exception )
    for listener in @listeners
      listener.recognition_exception( exception )
    end
  end
  
  def resync()
    for listener in @listeners
      listener.resync()
    end
  end
  
  def rewind( marker )
    for listener in @listeners
      listener.rewind( marker )
    end
  end
  
  def semantic_predicate( result, predicate )
    for listener in @listeners
      listener.semantic_predicate( result, predicate )
    end
  end
  
  def set_token_boundaries( tree, token_start_index, token_stop_index )
    for listener in @listeners
      listener.set_token_boundaries( tree, token_start_index, token_stop_index )
    end
  end
  
  def terminate()
    for listener in @listeners
      listener.terminate()
    end
  end
  
end

end
end
