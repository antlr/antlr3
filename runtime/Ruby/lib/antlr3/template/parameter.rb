#!/usr/bin/ruby

module ANTLR3
module Template
Parameter = Struct.new( :name, :default )
class Parameter
  def to_s
    if block then "&#{ name }"
    elsif splat then "*#{ name }"
    elsif default then "#{ name } = #{ default }"
    else name.dup
    end
  end
end

class ParameterList < ::Array
  attr_accessor :splat, :block
  
  def self.default
    new.add( :values ) do | p |
      p.default = '{}'
    end
  end
  
  def names
    names = map { | param | param.name.to_s }
    @splat and names << @splat.to_s
    @block and names << @block.to_s
    return( names )
  end
  
  def add( name, default = nil )
    param =
      case name
      when Parameter then name
      else Parameter.new( name.to_s )
      end
    if options
      default = options[ :default ] and param.default = default
      param.splat = options.fetch( :splat, false )
      param.block = options.fetch( :block, false )
    end
    block_given? and yield( param )
    push( param )
    return( self )
  end
  
  def to_s
    signature = join( ', ' )
    @splat and signature << ", *" << @splat.to_s
    @block and signature << ", &" << @block.to_s
    return( signature )
  end
end
end
end
