#!/usr/bin/ruby
# encoding: utf-8

module ANTLR3

=begin rdoc ANTLR3::Main::InteractiveStringStream

A special stream used in the <b>interactive mode</b> of the Main scripts. It
uses Readline (if available) or standard IO#gets to fetch data on demand.

=end

class InteractiveStringStream < StringStream
  
  if RUBY_VERSION =~ /^1\.9/
    
    # creates a new StringStream object where +data+ is the string data to stream.
    # accepts the following options in a symbol-to-value hash:
    #
    # [:file or :name] the (file) name to associate with the stream; default: <tt>'(string)'</tt>
    # [:line] the initial line number; default: +1+
    # [:column] the initial column number; default: +0+
    # 
    def initialize( options = {}, &block )      # for 1.9
      @string = ''
      @data   = []
      @position = options.fetch :position, 0
      @line     = options.fetch :line, 1
      @column   = options.fetch :column, 0
      @markers  = []
      mark
      @initialized = @eof = false
      @readline = block or raise( ArgumentError, "no line-reading block was provided" )
      @name ||= options[ :file ] || options[ :name ] || '(interactive)'
    end
    
    def readline
      @initialized = true
      unless @eof
        if line = @readline.call
          line = line.to_s.encode( Encoding::UTF_8 )
          @string << line
          @data.concat( line.codepoints.to_a )
          return true
        else
          @eof = true
          return false
        end
      end
    end
    
  else
    
    # creates a new StringStream object where +data+ is the string data to stream.
    # accepts the following options in a symbol-to-value hash:
    #
    # [:file or :name] the (file) name to associate with the stream; default: <tt>'(string)'</tt>
    # [:line] the initial line number; default: +1+
    # [:column] the initial column number; default: +0+
    # 
    def initialize( options = {}, &block )
      @string = @data = ''
      @position = options.fetch :position, 0
      @line     = options.fetch :line, 1
      @column   = options.fetch :column, 0
      @markers = []
      mark
      @initialized = @eof = false
      @readline = block or raise( ArgumentError, "no line-reading block was provided" )
      @name ||= options[ :file ] || options[ :name ] || '(interactive)'
    end
    
    def readline
      @initialized = true
      unless @eof
        if line = @readline.call
          @data << line.to_s
          return true
        else
          @eof = true
          return false
        end
      end
    end
    
  end
  
  private :readline
  
  def consume
    @position < @data.size and return( super )
    unless @eof
      readline
      consume
    end
  end
  
  def peek( i = 1 )
    i.zero? and return 0
    i += 1 if i < 0
    index = @position + i - 1
    index < 0 and return 0
    
    if index < @data.size
      char = @data[ index ]
    elsif readline
      peek( i )
    else EOF
    end
  end
  
  def look( i = 1 )
    peek( i ).chr rescue EOF
  end
  
  def substring( start, stop )
    fill_through( stop )
    @string[ start .. stop ]
  end
  
private
  
  def fill_through( position )
    @eof and return
    if @position < 0 then fill_out
    else readline until ( @data.size > @position or @eof )
    end
  end
  
  def fill_out
    @eof and return
    readline until @eof
  end
end

end
