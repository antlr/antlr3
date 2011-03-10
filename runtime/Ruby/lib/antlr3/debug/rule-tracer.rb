#!/usr/bin/ruby
# encoding: utf-8

module ANTLR3
module Debug
=begin rdoc ANTLR3::Debug::RuleTracer

RuleTracer is simple debug event listener that writes the names of rule methods
as they are entered and exitted to an output stream.

=end
class RuleTracer
  include EventListener
  
  ARROW_IN = '--> '.freeze
  ARROW_OUT = '<-- '.freeze
  
  attr_reader :level
  attr_accessor :spaces_per_indent, :device
  
  def initialize( options = {} )
    @input = options[ :input ]
    @level = 0
    @spaces_per_indent = options[ :spaces_per_indent ] || 2
    @device = options[ :device ] || options[ :output ] || $stderr
  end
  
  def enter_rule( grammar_file, name )
    indent = @level * @spaces_per_indent
    
    @device.print( ' ' * indent, ARROW_IN, name )
    if @input
      input_symbol = @input.look || :EOF
      @device.puts( " look = %p" % input_symbol )
    else @device.print( "\n" )
    end
    
    @level += 1
  end
  
  def exit_rule( grammar_file, name )
    @level -= 1
    
    indent = @level * @spaces_per_indent
    
    @device.print( ' ' * indent, ARROW_OUT, name )
    if @input
      input_symbol = ( @input.look || :EOF )
      @device.puts( " look = %p" % input_symbol )
    else @device.print( "\n" )
    end
  end
end
end
end
