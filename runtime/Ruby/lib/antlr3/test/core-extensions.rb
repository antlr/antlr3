#!/usr/bin/ruby
# encoding: utf-8

class String
  def /( subpath )
    File.join( self, subpath.to_s )
  end

  def here_indent( chr = '| ' )
    dup.here_indent!( chr )
  end

  def here_indent!( chr = '| ' )
    chr = Regexp.escape( chr )
    exp = Regexp.new( "^ *#{ chr }" )
    self.gsub!( exp,'' )
    return self
  end

  def here_flow( chr = '| ' )
    dup.here_flow!( chr )
  end

  def here_flow!( chr = '| ' )
    here_indent!( chr ).gsub!( /\n\s+/,' ' )
    return( self )
  end

  # Indent left or right by n spaces.
  # (This used to be called #tab and aliased as #indent.)
  #
  #  CREDIT: Gavin Sinclair
  #  CREDIT: Trans

  def indent( n )
    if n >= 0
      gsub( /^/, ' ' * n )
    else
      gsub( /^ {0,#{ -n }}/, "" )
    end
  end

  # Outdent just indents a negative number of spaces.
  #
  #  CREDIT: Noah Gibbs

  def outdent( n )
    indent( -n )
  end
  
  # Returns the shortest length of leading whitespace for all non-blank lines
  #
  #   n = %Q(
  #     a = 3
  #       b = 4
  #   ).level_of_indent  #=> 2
  #
  #   CREDIT: Kyle Yetter
  def level_of_indent
    self.scan( /^ *(?=\S)/ ).map { |space| space.length }.min || 0
  end
  
  def fixed_indent( n )
    self.outdent( self.level_of_indent ).indent( n )
  end
  
  # Provides a margin controlled string.
  #
  #   x = %Q{
  #         | This
  #         |   is
  #         |     margin controlled!
  #         }.margin
  #
  #
  #   NOTE: This may still need a bit of tweaking.
  #
  #  CREDIT: Trans

  def margin( n=0 )
    #d = /\A.*\n\s*(.)/.match( self )[1]
    #d = /\A\s*(.)/.match( self)[1] unless d
    d = ( ( /\A.*\n\s*(.)/.match( self ) ) ||
        ( /\A\s*(.)/.match( self ) ) )[ 1 ]
    return '' unless d
    if n == 0
      gsub( /\n\s*\Z/,'' ).gsub( /^\s*[#{ d }]/, '' )
    else
      gsub( /\n\s*\Z/,'' ).gsub( /^\s*[#{ d }]/, ' ' * n )
    end
  end

  # Expands tabs to +n+ spaces.  Non-destructive.  If +n+ is 0, then tabs are
  # simply removed.  Raises an exception if +n+ is negative.
  #
  # Thanks to GGaramuno for a more efficient algorithm.  Very nice.
  #
  #  CREDIT: Gavin Sinclair
  #  CREDIT: Noah Gibbs
  #  CREDIT: GGaramuno

  def expand_tabs( n=8 )
    n = n.to_int
    raise ArgumentError, "n must be >= 0" if n < 0
    return gsub( /\t/, "" ) if n == 0
    return gsub( /\t/, " " ) if n == 1
    str = self.dup
    while
      str.gsub!( /^([^\t\n]*)(\t+)/ ) { |f|
        val = ( n * $2.size - ( $1.size % n ) )
        $1 << ( ' ' * val )
      }
    end
    str
  end


  # The reverse of +camelcase+. Makes an underscored of a camelcase string.
  #
  # Changes '::' to '/' to convert namespaces to paths.
  #
  # Examples
  #   "SnakeCase".snakecase           #=> "snake_case"
  #   "Snake-Case".snakecase          #=> "snake_case"
  #   "SnakeCase::Errors".underscore  #=> "snake_case/errors"

  def snakecase
    gsub( /::/, '/' ).  # NOT SO SURE ABOUT THIS -T
    gsub( /([A-Z]+)([A-Z][a-z])/,'\1_\2' ).
    gsub( /([a-z\d])([A-Z])/,'\1_\2' ).
    tr( "-", "_" ).
    downcase
  end
  
end


class Module
  # Returns the module's container module.
  #
  #   module Example
  #     class Demo
  #     end
  #   end
  #
  #   Example::Demo.modspace   #=> Example
  #
  # See also Module#basename.
  #
  #   CREDIT: Trans

  def modspace
    space = name[ 0...( name.rindex( '::' ) || 0 ) ]
    space.empty? ? Object : eval( space )
  end
end

module Kernel
  autoload :Tempfile, 'tempfile'
  
  def screen_width( out=STDERR )
    default_width = ENV[ 'COLUMNS' ] || 80
    tiocgwinsz = 0x5413
    data = [ 0, 0, 0, 0 ].pack( "SSSS" )
    if out.ioctl( tiocgwinsz, data ) >= 0 then
      rows, cols, xpixels, ypixels = data.unpack( "SSSS" )
      if cols >= 0 then cols else default_width end
    else
      default_width
    end
  rescue Exception => e
    default_width rescue ( raise e )
  end
end


class File
  
  # given some target path string, and an optional reference path
  # (Dir.pwd by default), this method returns a string containing
  # the relative path of the target path from the reference path
  # 
  # Examples:
  #    File.relative_path('rel/path')   # => './rel/path'
  #    File.relative_path('/some/abs/path', '/some')  # => './abs/path'
  #    File.relative_path('/some/file.txt', '/some/abs/path')  # => '../../file.txt'
  def self.relative_path( target, reference = Dir.pwd )
    pair = [ target, reference ].map! do |path|
      File.expand_path( path.to_s ).split( File::Separator ).tap do |list|
        if list.empty? then list << String.new( File::Separator )
        elsif list.first.empty? then list.first.replace( File::Separator )
        end
      end
    end

    target_list, reference_list = pair
    while target_list.first == reference_list.first
      target_list.shift
      reference_list.shift or break
    end
    
    relative_list = Array.new( reference_list.length, '..' )
    relative_list.empty? and relative_list << '.'
    relative_list.concat( target_list ).compact!
    return relative_list.join( File::Separator )
  end
  
end

class Dir
  defined?( DOTS ) or DOTS = %w(. ..).freeze
  def self.children( directory )
    entries = Dir.entries( directory ) - DOTS
    entries.map! do |entry|
      File.join( directory, entry )
    end
  end
  
  def self.mkpath( path )
    $VERBOSE and $stderr.puts( "INFO: Dir.mkpath(%p)" % path )
    test( ?d, path ) and return( path )
    parent = File.dirname( path )
    test( ?d, parent ) or mkpath( parent )
    Dir.mkdir( path )
    return( path )
  end
  
end

class Array

  # Pad an array with a given <tt>value</tt> upto a given <tt>length</tt>.
  #
  #   [0,1,2].pad(6,"a")  #=> [0,1,2,"a","a","a"]
  #
  # If <tt>length</tt> is a negative number padding will be added
  # to the beginning of the array.
  #
  #   [0,1,2].pad(-6,"a")  #=> ["a","a","a",0,1,2]
  #
  #  CREDIT: Richard Laugesen

  def pad( len, val=nil )
    return dup if self.size >= len.abs
    if len < 0
      Array.new( ( len+size ).abs,val ) + self
    else
      self + Array.new( len-size,val )
    end
  end

  # Like #pad but changes the array in place.
  #
  #    a = [0,1,2]
  #    a.pad!(6,"x")
  #    a  #=> [0,1,2,"x","x","x"]
  #
  #  CREDIT: Richard Laugesen

  def pad!( len, val=nil )
    return self if self.size >= len.abs
    if len < 0
      replace Array.new( ( len+size ).abs,val ) + self
    else
      concat Array.new( len-size,val )
    end
  end

end
