#!/usr/bin/ruby
# encoding: utf-8

module ANTLR3
module Debug
=begin rdoc ANTLR3::Debug::EventListener

A listener that simply records text representations of the events.
Useful for debugging the debugging facility ;)
Subclasses can override the record() method (which defaults to printing to
stdout) to record the events in a different way.

=end
class TraceEventListener
  include EventListener
  
  def initialize( adaptor = nil, device = $stderr )
    super()
    @device = device
    @adaptor = adaptor ||= ANTLR3::AST::CommonTreeAdaptor.new
  end
  
  def record( event_message, *interpolation_arguments )
    event_message = event_message.to_s << "\n"
    @device.printf( event_message, *interpolation_arguments )
  end
  
  def enter_alternative( alt_number )
    record "(%s): number=%s", __method__, alt_number
  end
  
  def enter_rule( grammar_file_name, rule_name )
    record "(%s): rule=%s", __method__, rule_name
  end
  
  def exit_rule( grammar_file_name, rule_name )
    record "(%s): rule=%s", __method__, rule_name
  end
  
  def enter_subrule( decision_number )
    record "(%s): decision=%s", __method__, decision_number
  end
  
  def exit_subrule( decision_number )
    record "(%s): decision=%s", __method__, decision_number
  end
  
  def location( line, position )
    record '(%s): line=%s position=%s', __method__, line, position
  end
  
  def consume_node( tree )
    record '(%s) unique_id=%s text=%p type=%s[%s]', __method__, @adaptor.unique_id( tree ),
           @adaptor.text_of( tree ), @adaptor.type_name( tree ), @adaptor.type_of( tree )
  end
  
  def look( i, tree )
    record '(%s): k=%s unique_id=%s text=%p type=%s[%s]', __method__, i, @adaptor.unique_id( tree ),
            @adaptor.text_of( tree ), @adaptor.type_name( tree ), @adaptor.type_of( tree )
  end
  
  def flat_node( tree )
    record '(%s): unique_id=%s', __method__, @adaptor.unique_id( tree )
  end
  
  def create_node( tree, token = nil )
    unless token
      record '(%s): unique_id=%s text=%p type=%s[%s]', __method__, @adaptor.unique_id( tree ),
            @adaptor.text_of( tree ), @adaptor.type_name( tree ), @adaptor.type_of( tree )
    else
      record '(%s): unique_id=%s type=%s[%s]', __method__, @adaptor.unique_id( tree ),
              @adaptor.type_of( tree ), @adaptor.type_name( tree ), @adaptor.type_of( tree )
    end
  end
  
  def become_root( new_root, old_root )
    record '(%s): old_root_id=%s new_root_id=%s', __method__, @adaptor.unique_id( new_root ),
            @adaptor.unique_id( old_root )
  end
  
  def add_child( root, child )
    record '(%s): root_id=%s child_id=%s', __method__, @adaptor.unique_id( root ),
            @adaptor.unique_id( child )
  end
  
  def set_token_boundaries( tree, token_start_index, token_stop_index )
    record '(%s): unique_id=%s index_range=%s..%s', __method__, @adaptor.unique_id( tree ),
            token_start_index, token_stop_index
  end
end # class TraceEventListener
end # module Debug
end # module ANTLR3
