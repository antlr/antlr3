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

require 'optparse'
require 'antlr3'

module ANTLR3

=begin rdoc ANTLR3::Main

Namespace module for the quick script Main classes.

=end

module Main


=begin rdoc ANTLR3::Main::Options

Defines command-line options and attribute mappings shared by all types of
Main classes.

=end

module Options
  # the input encoding type; defaults to +nil+ (currently, not used)
  attr_accessor :encoding
  # the input stream used by the Main script; defaults to <tt>$stdin</tt>
  attr_accessor :input
  # a boolean flag indicating whether or not to run the Main
  # script in interactive mode; defaults to +false+
  attr_accessor :interactive
  attr_accessor :no_output
  attr_accessor :profile
  attr_accessor :debug_socket
  attr_accessor :ruby_prof
  
  def initialize( options = {} )
    @no_output    = options.fetch( :no_output, false )
    @profile      = options.fetch( :profile, false )
    @debug_socket = options.fetch( :debug_socket, false )
    @ruby_prof    = options.fetch( :ruby_prof, false )
    @encoding     = options.fetch( :encoding, nil )
    @interactive  = options.fetch( :interactive, false )
    @input        = options.fetch( :input, $stdin )
  end
  
  # constructs an OptionParser and parses the argument list provided by +argv+
  def parse_options( argv = ARGV )
    oparser = OptionParser.new do | o |
      o.separator 'Input Options:'
      
      o.on( '-i', '--input "text to process"', doc( <<-END ) ) { |val| @input = val }
      | a string to use as direct input to the recognizer
      END
      
      o.on( '-I', '--interactive', doc( <<-END ) ) { @interactive = true }
      | run an interactive session with the recognizer
      END
    end
    
    setup_options( oparser )
    return oparser.parse( argv )
  end
  
private
  
  def setup_options( oparser )
    # overridable hook to modify / append options
  end
  
  def doc( description_string )
    description_string.chomp!
    description_string.gsub!( /^ *\| ?/, '' )
    description_string.gsub!( /\s+/, ' ' )
    return description_string
  end
  
end

=begin rdoc ANTLR3::Main::Main

The base-class for the three primary Main script-runner classes.
It defines the skeletal structure shared by all main
scripts, but isn't particularly useful on its own.

=end

class Main
  include Options
  include Util
  attr_accessor :output, :error
  
  def initialize( options = {} )
    @input  = options.fetch( :input, $stdin )
    @output = options.fetch( :output, $stdout )
    @error  = options.fetch( :error, $stderr )
    @name   = options.fetch( :name, File.basename( $0, '.rb' ) )
    super
    block_given? and yield( self )
  end
  
  
  # runs the script
  def execute( argv = ARGV )
    args = parse_options( argv )
    setup
    
    @interactive and return execute_interactive
    
    in_stream = 
      case
      when @input.is_a?( ::String ) then StringStream.new( @input )
      when args.length == 1 && args.first != '-'
        ANTLR3::FileStream.new( args[ 0 ] )
      else ANTLR3::FileStream.new( @input )
      end
    case
    when @ruby_prof
      load_ruby_prof
      profile = RubyProf.profile do
        recognize( in_stream )
      end
      printer = RubyProf::FlatPrinter.new( profile )
      printer.print( @output )
    when @profile
      require 'profiler'
      Profiler__.start_profile
      recognize( in_stream )
      Profiler__.print_profile
    else
      recognize( in_stream )
    end
  end
  
private
  
  def recognize( *args )
    # overriden by subclasses
  end
  
  def execute_interactive
    @output.puts( tidy( <<-END ) )
    | ===================================================================
    | Ruby ANTLR Console for #{ $0 }
    | ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
    | * Enter source code lines 
    | * Enter EOF to finish up and exit
    |   (control+D on Mac/Linux/Unix or control+Z on Windows)
    | ===================================================================
    | 
    END
    
    read_method = 
      begin
        require 'readline'
        line_number = 0
        lambda do
          begin
            if line = Readline.readline( "#@name:#{ line_number += 1 }> ", true )
              line << $/
            else
              @output.print( "\n" ) # ensures result output is on a new line after EOF is entered
              nil
            end
          rescue Interrupt, EOFError
            retry
          end
          line << "\n" if line
        end
        
      rescue LoadError
        lambda do
          begin
            printf( "%s:%i> ", @name, @input.lineno )
            flush
            line = @input.gets or
              @output.print( "\n" ) # ensures result output is on a new line after EOF is entered
            line
          rescue Interrupt, EOFError
            retry
          end
          line
        end
      end
    
    stream = InteractiveStringStream.new( :name => @name, &read_method )
    recognize( stream )
  end
  
  def screen_width
    ( ENV[ 'COLUMNS' ] || 80 ).to_i
  end
  
  def attempt( lib, message = nil, exit_status = nil )
    yield
  rescue LoadError => error
    message or raise
    @error.puts( message )
    report_error( error )
    report_load_path
    exit( exit_status ) if exit_status
  rescue => error
    @error.puts( "received an error while attempting to load %p" % lib )
    report_error( error )
    exit( exit_status ) if exit_status
  end
  
  def report_error( error )
    puts!( "~ error details:" )
    puts!( '  [ %s ]' % error.class.name )
    message = error.to_s.gsub( /\n/, "\n     " )
    puts!( '  -> ' << message )
    for call in error.backtrace
      puts!( '     ' << call )
    end
  end
  
  def report_load_path
    puts!( "~ content of $LOAD_PATH: " )
    for dir in $LOAD_PATH
      puts!( "  - #{ dir }" )
    end
  end
  
  def setup
    # hook
  end
  
  def fetch_class( name )
    name.nil? || name.empty? and return( nil )
    unless constant_exists?( name )
      try_to_load( name )
      constant_exists?( name ) or return( nil )
    end
    
    name.split( /::/ ).inject( Object ) do |mod, name|
      # ::SomeModule splits to ['', 'SomeModule'] - so ignore empty strings
      name.empty? and next( mod ) 
      mod.const_get( name )
    end
  end
  
  def constant_exists?( name )
    eval( "defined?(#{ name })" ) == 'constant'
  end
  
  def try_to_load( name )
    if name =~ /(\w+)::(Lexer|Parser|TreeParser)$/
      retry_ok = true
      module_name, recognizer_type = $1, $2
      script = name.gsub( /::/, '' )
      begin
        return( require( script ) )
      rescue LoadError
        if retry_ok
          script, retry_ok = module_name, false
          retry
        else
          return( nil )
        end
      end
    end
  end
  
  %w(puts print printf flush).each do |method|
    class_eval( <<-END, __FILE__, __LINE__ )
      private
      
      def #{ method }(*args)
        @output.#{ method }(*args) unless @no_output
      end
      
      def #{ method }!( *args )
        @error.#{ method }(*args) unless @no_output
      end
    END
  end
end


=begin rdoc ANTLR3::Main::LexerMain

A class which implements a handy test script which is executed whenever an ANTLR
generated lexer file is run directly from the command line.

=end
class LexerMain < Main
  def initialize( lexer_class, options = {} )
    super( options )
    @lexer_class = lexer_class
  end
  
  def recognize( in_stream )
    lexer = @lexer_class.new( in_stream )
    
    loop do
      begin
        token = lexer.next_token
        if token.nil? || token.type == ANTLR3::EOF then break
        else display_token( token )
        end
      rescue ANTLR3::RecognitionError => error
        report_error( error )
        break
      end
    end
  end
  
  def display_token( token )
    case token.channel
    when ANTLR3::DEFAULT_CHANNEL
      prefix = '-->'
      suffix = ''
    when ANTLR3::HIDDEN_CHANNEL
      prefix = '#  '
      suffix = ' (hidden)'
    else
      prefix = '~~>'
      suffix = ' (channel %p)' % token.channel
    end
    
    printf( "%s %-15s %-15p @ line %-3i col %-3i%s\n",
           prefix, token.name, token.text,
           token.line, token.column, suffix )
  end
  
end

=begin rdoc ANTLR3::Main::ParserMain

A class which implements a handy test script which is executed whenever an ANTLR
generated parser file is run directly from the command line.

=end
class ParserMain < Main
  attr_accessor :lexer_class_name,
                :lexer_class,
                :parser_class,
                :parser_rule,
                :port,
                :log
  
  def initialize( parser_class, options = {} )
    super( options )
    @lexer_class_name = options[ :lexer_class_name ]
    @lexer_class      = options[ :lexer_class ]
    @parser_class     = parser_class
    @parser_rule = options[ :parser_rule ]
    if @debug = ( @parser_class.debug? rescue false )
      @trace = options.fetch( :trace, nil )
      @port = options.fetch( :port, ANTLR3::Debug::DEFAULT_PORT )
      @log  = options.fetch( :log, @error )
    end
    @profile = ( @parser_class.profile? rescue false )
  end
  
  def setup_options( opt )
    super
    
    opt.separator ""
    opt.separator( "Parser Configuration:" )
    
    opt.on( '--lexer-name CLASS_NAME', "name of the lexer class to use" ) { |val|
      @lexer_class_name = val
      @lexer_class = nil
    }
    
    opt.on( '--lexer-file PATH_TO_LIBRARY', "path to library defining the lexer class" ) { |val|
      begin
        test( ?f, val ) ? load( val ) : require( val )
      rescue LoadError
        warn( "unable to load the library specified by --lexer-file: #{ $! }" )
      end
    }
    
    opt.on( '--rule NAME', "name of the parser rule to execute" ) { |val| @parser_rule = val }
    
    if @debug
      opt.separator ''
      opt.separator "Debug Mode Options:"
      
      opt.on( '--trace', '-t', "print rule trace instead of opening a debug socket" ) do
        @trace = true
      end
      
      opt.on( '--port NUMBER', Integer, "port number to use for the debug socket" ) do |number|
        @port = number
      end
      
      opt.on( '--log PATH', "path of file to use to record socket activity",
             "(stderr by default)" ) do |path|
        @log = open( path, 'w' )
      end
    end
  end
  
  def setup
    unless @lexer_class ||= fetch_class( @lexer_class_name )
      if @lexer_class_name
        fail( "unable to locate the lexer class ``#@lexer_class_name''" )
      else
        unless @lexer_class = @parser_class.associated_lexer
          fail( doc( <<-END ) )
          | no lexer class has been specified with the --lexer-name option
          | and #@parser_class does not appear to have an associated
          | lexer class
          END
        end
      end
    end
    @parser_rule ||= @parser_class.default_rule or
      fail( "a parser rule name must be specified via --rule NAME" )
  end
  
  def recognize( in_stream )
    parser_options = {}
    if @debug
      if @trace
        parser_options[ :debug_listener ] = ANTLR3::Debug::RuleTracer.new
      else
        parser_options[ :port ] = @port
        parser_options[ :log ]  = @log
      end
    end
    lexer = @lexer_class.new( in_stream )
    # token_stream = CommonTokenStream.new( lexer )
    parser = @parser_class.new( lexer, parser_options )
    result = parser.send( @parser_rule ) and present( result )
    @profile and puts( parser.generate_report )
  end
  
  def present( return_value )
    ASTBuilder > @parser_class and return_value = return_value.tree
    if return_value
      text = 
        begin
          require 'pp'
          return_value.pretty_inspect
        rescue LoadError, NoMethodError
          return_value.inspect
        end
      puts( text )
    end
  end
  
end

=begin rdoc ANTLR3::Main::WalkerMain

A class which implements a handy test script which is executed whenever an ANTLR
generated tree walker (tree parser) file is run directly from the command line.

=end

class WalkerMain < Main
  attr_accessor :walker_class, :lexer_class, :parser_class
  
  def initialize( walker_class, options = {} )
    super( options )
    @walker_class = walker_class
    @lexer_class_name = options[ :lexer_class_name ]
    @lexer_class  = options[ :lexer_class ]
    @parser_class_name = options[ :parser_class_name ]
    @parser_class = options[ :parser_class ]
    if @debug = ( @parser_class.debug? rescue false )
      @port = options.fetch( :port, ANTLR3::Debug::DEFAULT_PORT )
      @log  = options.fetch( :log, @error )
    end
  end
  
  def setup_options( opt )
    super
    
    opt.separator ''
    opt.separator "Tree Parser Configuration:"
    
    opt.on( '--lexer-name CLASS_NAME', 'full name of the lexer class to use' ) { |val| @lexer_class_name = val }
    opt.on(
      '--lexer-file PATH_TO_LIBRARY',
      'path to load to make the lexer class available'
    ) { |val|
      begin
        test( ?f, val ) ? load( val ) : require( val )
      rescue LoadError
        warn( "unable to load the library `#{ val }' specified by --lexer-file: #{ $! }" )
      end
    }
    
    opt.on(
      '--parser-name CLASS_NAME',
      'full name of the parser class to use'
    ) { |val| @parser_class_name = val }
    opt.on(
      '--parser-file PATH_TO_LIBRARY',
      'path to load to make the parser class available'
    ) { |val|
      begin
        test( ?f, val ) ? load( val ) : require( val )
      rescue LoadError
        warn( "unable to load the library specified by --parser-file: #{ $! }" )
      end
    }
    
    opt.on( '--parser-rule NAME', "name of the parser rule to use on the input" ) { |val| @parser_rule = val }
    opt.on( '--rule NAME', "name of the rule to invoke in the tree parser" ) { |val| @walker_rule = val }
    
    if @debug
      opt.separator ''
      opt.separator "Debug Mode Options:"
      
      opt.on( '--port NUMBER', Integer, "port number to use for the debug socket" ) do |number|
        @port = number
      end
      opt.on( '--log PATH', "path of file to use to record socket activity",
             "(stderr by default)" ) do |path|
        @log = open( path, 'w' )
      end
    end
  end
  
  # TODO: finish the Main modules
  def setup
    unless @lexer_class ||= fetch_class( @lexer_class_name )
      fail( "unable to locate the lexer class #@lexer_class_name" )
    end
    unless @parser_class ||= fetch_class( @parser_class_name )
      fail( "unable to locate the parser class #@parser_class_name" )
    end
  end
  
  def recognize( in_stream )
    walker_options = {}
    if @debug
      walker_options[ :port ] = @port
      walker_options[ :log ] = @log
    end
    @lexer = @lexer_class.new( in_stream )
    @token_stream = ANTLR3::CommonTokenStream.new( @lexer )
    @parser = @parser_class.new( @token_stream )
    if result = @parser.send( @parser_rule )
      result.respond_to?( :tree ) or fail( "Parser did not return an AST for rule #@parser_rule" )
      @node_stream = ANTLR3::CommonTreeNodeStream.new( result.tree )
      @node_stream.token_stream = @token_stream
      @walker = @walker_class.new( @node_stream, walker_options )
      if result = @walker.send( @walker_rule )
        out = result.tree.inspect rescue result.inspect
        puts( out )
      else puts!( "walker.#@walker_rule returned nil" )
      end
    else puts!( "parser.#@parser_rule returned nil" )
    end
  end
end
end
end
