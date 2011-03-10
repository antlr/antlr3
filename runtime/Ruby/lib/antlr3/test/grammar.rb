#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3'
require 'antlr3/test/core-extensions'
require 'antlr3/test/call-stack'

if RUBY_VERSION =~ /^1\.9/
  require 'digest/md5'
  MD5 = Digest::MD5
else
  require 'md5'
end

module ANTLR3
module Test
module DependantFile
  attr_accessor :path, :force
  alias force? force
  
  GLOBAL_DEPENDENCIES = []
  
  def dependencies
    @dependencies ||= GLOBAL_DEPENDENCIES.clone
  end
  
  def depends_on( path )
    path = File.expand_path path.to_s
    dependencies << path if test( ?f, path )
    return path
  end
  
  def stale?
    force and return( true )
    target_files.any? do |target|
      not test( ?f, target ) or
        dependencies.any? { |dep| test( ?>, dep, target ) }
    end
  end
end # module DependantFile

class Grammar
  include DependantFile

  GRAMMAR_TYPES = %w(lexer parser tree combined)
  TYPE_TO_CLASS = { 
    'lexer'  => 'Lexer',
    'parser' => 'Parser',
    'tree'   => 'TreeParser'
  }
  CLASS_TO_TYPE = TYPE_TO_CLASS.invert

  def self.global_dependency( path )
    path = File.expand_path path.to_s
    GLOBAL_DEPENDENCIES << path if test( ?f, path )
    return path
  end
  
  def self.inline( source, *args )
    InlineGrammar.new( source, *args )
  end
  
  ##################################################################
  ######## CONSTRUCTOR #############################################
  ##################################################################
  def initialize( path, options = {} )
    @path = path.to_s
    @source = File.read( @path )
    @output_directory = options.fetch( :output_directory, '.' )
    @verbose = options.fetch( :verbose, $VERBOSE )
    study
    build_dependencies
    
    yield( self ) if block_given?
  end
  
  ##################################################################
  ######## ATTRIBUTES AND ATTRIBUTE-ISH METHODS ####################
  ##################################################################
  attr_reader :type, :name, :source
  attr_accessor :output_directory, :verbose
  
  def lexer_class_name
    self.name + "::Lexer"
  end
  
  def lexer_file_name
    if lexer? then base = name
    elsif combined? then base = name + 'Lexer'
    else return( nil )
    end
    return( base + '.rb' )
  end
  
  def parser_class_name
    name + "::Parser"
  end
  
  def parser_file_name
    if parser? then base = name
    elsif combined? then base = name + 'Parser'
    else return( nil )
    end
    return( base + '.rb' )
  end
  
  def tree_parser_class_name
    name + "::TreeParser"
  end

  def tree_parser_file_name
    tree? and name + '.rb'
  end
  
  def has_lexer?
    @type == 'combined' || @type == 'lexer'
  end
  
  def has_parser?
    @type == 'combined' || @type == 'parser'
  end
  
  def lexer?
    @type == "lexer"
  end
  
  def parser?
    @type == "parser"
  end
  
  def tree?
    @type == "tree"
  end
  
  alias has_tree? tree?
  
  def combined?
    @type == "combined"
  end
  
  def target_files( include_imports = true )
    targets = []
    
    for target_type in %w(lexer parser tree_parser)
      target_name = self.send( :"#{ target_type }_file_name" ) and
        targets.push( output_directory / target_name )
    end
    
    targets.concat( imported_target_files ) if include_imports
    return targets
  end
  
  def imports
    @source.scan( /^\s*import\s+(\w+)\s*;/ ).
      tap { |list| list.flatten! }
  end
  
  def imported_target_files
    imports.map! do |delegate|
      output_directory / "#{ @name }_#{ delegate }.rb"
    end
  end

  ##################################################################
  ##### COMMAND METHODS ############################################
  ##################################################################
  def compile( options = {} )
    if options[ :force ] or stale?
      compile!( options )
    end
  end
  
  def compile!( options = {} )
    command = build_command( options )
    
    blab( command )
    output = IO.popen( command ) do |pipe|
      pipe.read
    end
    
    case status = $?.exitstatus
    when 0, 130
      post_compile( options )
    else compilation_failure!( command, status, output )
    end
    
    return target_files
  end
  
  def clean!
    deleted = []
    for target in target_files
      if test( ?f, target )
        File.delete( target )
        deleted << target
      end
    end
    return deleted
  end
  
  def inspect
    sprintf( "grammar %s (%s)", @name, @path )
  end
  
private
  
  def post_compile( options )
    # do nothing for now
  end
  
  def blab( string, *args )
    $stderr.printf( string + "\n", *args ) if @verbose
  end
  
  def default_antlr_jar
    ENV[ 'ANTLR_JAR' ] || ANTLR3.antlr_jar
  end
  
  def compilation_failure!( command, status, output )
    for f in target_files
      test( ?f, f ) and File.delete( f )
    end
    raise CompilationFailure.new( self, command, status, output )
  end

  def build_dependencies
    depends_on( @path )
    
    if @source =~ /tokenVocab\s*=\s*(\S+)\s*;/
      foreign_grammar_name = $1
      token_file = output_directory / foreign_grammar_name + '.tokens'
      grammar_file = File.dirname( path ) / foreign_grammar_name << '.g'
      depends_on( token_file )
      depends_on( grammar_file )
    end    
  end
  
  def shell_escape( token )
    token = token.to_s.dup
    token.empty? and return "''"
    token.gsub!( /([^A-Za-z0-9_\-.,:\/@\n])/n, '\\\1' )
    token.gsub!( /\n/, "'\n'" )
    return token
  end
  
  def build_command( options )
    parts = %w(java)
    jar_path = options.fetch( :antlr_jar, default_antlr_jar )
    parts.push( '-cp', jar_path )
    parts << 'org.antlr.Tool'
    parts.push( '-fo', output_directory )
    options[ :profile ] and parts << '-profile'
    options[ :debug ]   and parts << '-debug'
    options[ :trace ]   and parts << '-trace'
    options[ :debug_st ] and parts << '-XdbgST'
    parts << File.expand_path( @path )
    parts.map! { |part| shell_escape( part ) }.join( ' ' ) << ' 2>&1'
  end
  
  def study
    @source =~ /^\s*(lexer|parser|tree)?\s*grammar\s*(\S+)\s*;/ or
      raise Grammar::FormatError[ source, path ]
    @name = $2
    @type = $1 || 'combined'
  end
end # class Grammar

class Grammar::InlineGrammar < Grammar
  attr_accessor :host_file, :host_line
  
  def initialize( source, options = {} )
    host = call_stack.find { |call| call.file != __FILE__ }
    
    @host_file = File.expand_path( options[ :file ] || host.file )
    @host_line = ( options[ :line ] || host.line )
    @output_directory = options.fetch( :output_directory, File.dirname( @host_file ) )
    @verbose = options.fetch( :verbose, $VERBOSE )
    
    @source = source.to_s.fixed_indent( 0 )
    @source.strip!
    
    study
    write_to_disk
    build_dependencies
    
    yield( self ) if block_given?
  end
  
  def output_directory
    @output_directory and return @output_directory
    File.basename( @host_file )
  end
  
  def path=( v )
    previous, @path = @path, v.to_s
    previous == @path or write_to_disk
  end
  
  def inspect
    sprintf( 'inline grammar %s (%s:%s)', name, @host_file, @host_line )
  end
  
private
  
  def write_to_disk
    @path ||= output_directory / @name + '.g'
    test( ?d, output_directory ) or Dir.mkdir( output_directory )
    unless test( ?f, @path ) and MD5.digest( @source ) == MD5.digest( File.read( @path ) )
      open( @path, 'w' ) { |f| f.write( @source ) }
    end
  end
end # class Grammar::InlineGrammar

class Grammar::CompilationFailure < StandardError
  JAVA_TRACE = /^(org\.)?antlr\.\S+\(\S+\.java:\d+\)\s*/
  attr_reader :grammar, :command, :status, :output
  
  def initialize( grammar, command, status, output )
    @command = command
    @status = status
    @output = output.gsub( JAVA_TRACE, '' )
    
    message = <<-END.here_indent! % [ command, status, grammar, @output ]
    | command ``%s'' failed with status %s
    | %p
    | ~ ~ ~ command output ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
    | %s
    END
    
    super( message.chomp! || message )
  end
end # error Grammar::CompilationFailure

class Grammar::FormatError < StandardError
  attr_reader :file, :source
  
  def self.[]( *args )
    new( *args )
  end
  
  def initialize( source, file = nil )
    @file = file
    @source = source
    message = ''
    if file.nil? # inline
      message << "bad inline grammar source:\n"
      message << ( "-" * 80 ) << "\n"
      message << @source
      message[ -1 ] == ?\n or message << "\n"
      message << ( "-" * 80 ) << "\n"
      message << "could not locate a grammar name and type declaration matching\n"
      message << "/^\s*(lexer|parser|tree)?\s*grammar\s*(\S+)\s*;/"
    else
      message << 'bad grammar source in file %p' % @file
      message << ( "-" * 80 ) << "\n"
      message << @source
      message[ -1 ] == ?\n or message << "\n"
      message << ( "-" * 80 ) << "\n"
      message << "could not locate a grammar name and type declaration matching\n"
      message << "/^\s*(lexer|parser|tree)?\s*grammar\s*(\S+)\s*;/"
    end
    super( message )
  end
end # error Grammar::FormatError

end
end
