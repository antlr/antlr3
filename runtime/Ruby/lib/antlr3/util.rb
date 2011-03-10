#!/usr/bin/ruby
# encoding: utf-8

module ANTLR3
module Util

module_function
  
  def snake_case( str )
    str = str.to_s.gsub( /([A-Z]+)([A-Z][a-z])/,'\1_\2' )
    str.gsub!( /([a-z\d])([A-Z])/,'\1_\2' )
    str.tr!( "-", "_" )
    str.downcase!
    str
  end
  
  def parse_version( version_string )
    version_string.split( '.' ).map! do | segment |
      segment.to_i
    end.freeze
  end
  
  def tidy( here_doc, flow = false )
    here_doc.gsub!( /^ *\| ?/, '' )
    if flow
      here_doc.strip!
      here_doc.gsub!( /\s+/, ' ' )
    end
    return here_doc
  end
  
  def silence_warnings
    verbosity, $VERBOSE = $VERBOSE, nil
    return yield
  ensure
    $VERBOSE = verbosity
  end
  
end

module ClassMacros

private
  
  def shared_attribute( name, *additional_members )
    attr_reader name
    
    additional_writers = additional_members.inject( '' ) do |src, attr|
      src << "@#{ attr } = value if @#{ attr }\n"
    end
    
    file, line, = caller[ 1 ].split( ':', 3 )
    class_eval( <<-END, file, line.to_i )
      def #{ name }= value
        @#{ name } = value
        
        each_delegate do |del|
          del.#{ name } = value
        end
        
        #{ additional_writers }
      end
    END
  end
  
  def abstract( name, message = nil )
    message ||= "abstract method -- #{ self.class }::#{ name } has not been implemented"
    file, line, = caller[ 1 ].split( ':', 3 )
    class_eval( <<-END, file, line.to_i )
      def #{ name }( * )
        raise TypeError, #{ message.to_s.inspect }
      end
    END
  end
  
  def deprecate( name, extra_message = nil )
    hidden_name = "deprecated_#{ name }"
    method_defined?( hidden_name ) and return
    
    alias_method( hidden_name, name )
    private( hidden_name )
    
    message = "warning: method #{ self }##{ name } is deprecated"
    extra_message and message << '; ' << extra_message.to_s
    
    class_eval( <<-END )
      def #{ name }( *args, &block )
        warn( #{ message.inspect } )
        #{ hidden_name }( *args, &block )
      end
    END
  end
  
  def alias_accessor( alias_name, attr_name )
    alias_method( alias_name, attr_name )
    alias_method( :"#{ alias_name }=", :"#{ attr_name }=" )
  end

end

end

class Integer

  # Returns the lower of self or x.
  #
  #   4.at_least(5)  #=> 5
  #   6.at_least(5)  #=> 6
  #
  #   CREDIT Florian Gross

  def at_least( x )
    ( self >= x ) ? self : x
  end

  # Returns the greater of self or x.
  #
  #   4.at_most(5)  #=> 4
  #   6.at_most(5)  #=> 5
  #
  #   CREDIT Florian Gross

  def at_most( x )
    ( self <= x ) ? self : x
  end

  # Returns self if above the given lower bound, or
  # within the given lower and upper bounds,
  # otherwise returns the the bound of which the
  # value falls outside.
  #
  #   4.bound(3)    #=> 4
  #   4.bound(5)    #=> 5
  #   4.bound(2,7)  #=> 4
  #   9.bound(2,7)  #=> 7
  #   1.bound(2,7)  #=> 2
  #
  #   CREDIT Trans

  def bound( lower, upper=nil )
    return lower if self < lower
    return self unless upper
    return upper if self > upper
    return self
  end

end


class Range
  def covers?( range )
    range.first >= first or return false
    if exclude_end?
      range.exclude_end? ? last >= range.last : last > range.last
    else
      range.exclude_end? ? last.succ >= range.last : last >= range.last
    end
  end
  
  def covered_by?( range )
    range.covers?( self )
  end
  
  def overlaps?( range )
    range.include?( first ) or include?( range.first )
  end
  
  def disjoint?( range )
    not overlaps?( range )
  end
  
end
