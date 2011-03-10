#!/usr/bin/ruby

unless defined? Call
  
Call = Struct.new( :file, :line, :method )
class Call
  
  def self.parse( call_string )
    parts = call_string.split( ':', 3 )
    file = parts.shift
    line = parts.shift.to_i
    if parts.empty?
        return Call.new( file, line )
    else
        mstring = parts.shift
        match = mstring.match( /`(.+)'/ )
        method = match ? match[ 1 ] : nil
        return Call.new( file, line, method )
    end
  end
  
  def self.convert_backtrace( trace )
    trace.map { |c| parse c }
  end
  
  def irb?
    self.file == '(irb)'
  end
  
  def e_switch?
    self.file == '-e'
  end
  
  def to_s
    string = '%s:%i' % [ file, line ]
    method and string << ":in `%s'" % method
    return( string )
  end
  
  def inspect
    to_s.inspect
  end
end

module Kernel
  def call_stack( depth = 1 )
    Call.convert_backtrace( caller( depth + 1 ) )
  end
end

class Exception
  def backtrace!
    Call.convert_backtrace( backtrace )
  end
end

end # unless defined? Call
