#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3'
require 'antlr3/test/core-extensions'
require 'antlr3/test/grammar'
require 'antlr3/test/call-stack'

require 'test/unit'
require 'spec'

module ANTLR3
module Test
module Location
  attr_accessor :test_path
  
  def test_group
    File.basename( test_path, '.rb' )
  end
  
  def test_directory
    File.dirname( test_path )
  end
  
  def local_path( *parts )
    File.join( test_directory, *parts )
  end
  
  def output_directory( name = test_group )
    local_path( name )
  end
  
end # module Location

module NameSpace
  
  #
  # import( ruby_file )   => [ new constants, ... ]
  # Read the source code from the path given by +ruby_file+ and
  # evaluate it within the class body. Return new constants
  # created in the class after the evaluation.
  # 
  def import( ruby_file )
    constants_before = constants
    class_eval( File.read( ruby_file ), ruby_file, 1 )
    constants - constants_before
  end
  
  def import_grammar_targets( grammar )
    for file in grammar.target_files
      import( file )
    end
  end
end

module GrammarManager
  include Location
  include NameSpace
  
  DEFAULT_COMPILE_OPTIONS = {}
  
  def add_default_compile_option( name, value )
    DEFAULT_COMPILE_OPTIONS[ name ] = value
  end
  module_function :add_default_compile_option
  
  if ANTLR_JAR = ENV[ 'ANTLR_JAR' ] || ANTLR3.antlr_jar
    add_default_compile_option( :antlr_jar, ANTLR_JAR )
    
    Grammar.global_dependency( ANTLR_JAR )
  end
  
  #
  # Compile and load inline grammars on demand when their constant name
  # is referenced in the code. This makes it easier to catch big errors
  # quickly as test cases are run, instead of waiting a few minutes
  # for all grammars to compile, and then discovering there's a big dumb
  # error ruining most of the grammars.
  # 
  def const_missing( name )
    if g = grammars[ name.to_s ]
      compile( g )
      grammars.delete( name.to_s )
      const_get( name )
    elsif superclass.respond_to?( :grammars )
      superclass.const_missing( name )
      # ^-- for some reason, in ruby 1.9, rspec runs examples as instances of
      # anonymous subclasses, of the actual test class, which messes up the
      # assumptions made in the test code. Grammars are stored in @grammars belonging
      # to the test class, so in 1.9, this method is called with @grammars = {}
      # since it's a subclass
    else
      super
    end
  end
  
  # 
  # An index of grammar file objects created in the test class
  # (defined inline or loaded from a file)
  # 
  def grammars
    @grammars ||= {}
  end
  
  def grammar_count
    grammars.length
  end
  
  def load_grammar( name )
    path = local_path( name.to_s )
    path =~ /\.g$/ or path << '.g'
    grammar = Grammar.new( path, :output_directory => output_directory )
    register_grammar( grammar )
    return grammar
  end
  
  def inline_grammar( source, options = {} )
    call = call_stack.find { |call| call.file != __FILE__ }
    grammar = Grammar.inline source,
                :output_directory => output_directory,
                :file => ( call.file rescue nil ),
                :line => ( call.line rescue nil )
    register_grammar( grammar )
    return grammar
  end
  
  def compile_options( defaults = nil )
    @compile_options ||= DEFAULT_COMPILE_OPTIONS.clone
    @compile_options.update( defaults ) if defaults
    return @compile_options
  end
  
  def compile( grammar, options = {} )
    grammar.compile( compile_options.merge( options ) )
    import_grammar_targets( grammar )
    return grammar
  end
  
private
  
  def register_grammar( grammar )
    name = grammar.name
    @grammars ||= {}
    
    if conflict = @grammars[ name ] and conflict.source != grammar.source
      message = "Multiple grammars exist with the name ``#{ name }''"
      raise NameError, message
    else
      @grammars[ name ] = grammar
    end
  end
end # module GrammarManager

class Functional < ::Test::Unit::TestCase
  extend GrammarManager
  
  def self.inherited( klass )
    super
    klass.test_path = call_stack[ 0 ].file
  end
  
  def local_path( *args )
    self.class.local_path( *args )
  end
  
  def test_path
    self.class.test_path
  end
  
  def output_directory
    self.class.output_directory
  end
  
  def inline_grammar( source )
    call = call_stack.find { |call| call.file != __FILE__ }
    grammar = Grammar.inline source,
                :output_directory => output_directory,
                :file => call.file,
                :line => call.line
  end
  
  def compile_and_load( grammar, options = {} )
    self.class.compile( grammar, options )
  end
end # class Functional



module CaptureOutput
  require 'stringio'
  def output_buffer
    defined?( @output_buffer ) or @output_buffer = StringIO.new( '' )
    @output_buffer
  end
  
  def output
    output_buffer.string
  end
  
  def say( *args )
    output_buffer.puts( *args )
  end
  
  def capture( *args )
    output_buffer.write( *args )
  end
end

module RaiseErrors
  def emit_error_message( msg )
    # do nothing
  end
  
  def report_error( error )
    raise error
  end
end

module CollectErrors
  def reported_errors
    defined?( @reported_errors ) or @reported_errors = []
    return @reported_errors
  end
  
  def emit_error_message( msg )
    reported_errors << msg
  end
end

end # module Test
end # module ANTLR3
