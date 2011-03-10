#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3'
require 'set'
require 'rake'
require 'rake/tasklib'
require 'shellwords'

module ANTLR3

=begin rdoc ANTLR3::CompileTask

A rake task-generating utility concerning ANTLR grammar file
compilation. This is a general utility -- the grammars do
not have to be targetted for Ruby output; it handles all
known ANTLR language targets.

  require 'antlr3/task'
  
  ANTLR3::CompileTask.define(
    :name => 'grammars', :output_directory => 'lib/parsers'
  ) do | t |
    t.grammar_set( 'antlr/MainParser.g', 'antlr/MainTree.g' )
    
    t.grammar_set( 'antlr/Template.g' ) do | gram |
      gram.output_directory = 'lib/parsers/template'
      gram.debug = true
    end
  end
  

TODO: finish documentation

=end

class CompileTask < Rake::TaskLib
  attr_reader :grammar_sets, :options
  attr_accessor :name
  
  def self.define( *grammar_files )
    lib = new( *grammar_files )
    block_given? and yield( lib )
    lib.define
    return( lib )
  end
  
  def initialize( *grammar_files )
    grammar_files = [ grammar_files ].flatten!
    options = Hash === grammar_files.last ? grammar_files.pop : {}
    @grammar_sets = []
    @name = options.fetch( :name, 'antlr-grammars' )
    @options = options
    @namespace = Rake.application.current_scope
    grammar_files.empty? or grammar_set( grammar_files )
  end
  
  def target_files
    @grammar_sets.inject( [] ) do | list, set |
      list.concat( set.target_files )
    end
  end
  
  def grammar_set( *grammar_files )
    grammar_files = [ grammar_files ].flatten!
    options = @options.merge( 
      Hash === grammar_files.last ? grammar_files.pop : {}
    )
    set = GrammarSet.new( grammar_files, options )
    block_given? and yield( set )
    @grammar_sets << set
    return( set )
  end
  
  def compile_task
    full_name = ( @namespace + [ @name, 'compile' ] ).join( ':' )
    Rake::Task[ full_name ]
  end
  
  def compile!
    compile_task.invoke
  end
  
  def clobber_task
    full_name = ( @namespace + [ @name, 'clobber' ] ).join( ':' )
    Rake::Task[ full_name ]
  end
  
  def clobber!
    clobber_task.invoke
  end
  
  def define
    namespace( @name ) do
      desc( "trash all ANTLR-generated source code" )
      task( 'clobber' ) do
        for set in @grammar_sets
          set.clean
        end
      end
      
      for set in @grammar_sets
        set.define_tasks
      end
      
      desc( "compile ANTLR grammars" )
      task( 'compile' => target_files )
    end
  end
  

#class CompileTask::GrammarSet
class GrammarSet
  attr_accessor :antlr_jar, :debug,
                :trace, :profile, :compile_options,
                :java_options
  attr_reader :load_path, :grammars
  attr_writer :output_directory
  
  def initialize( grammar_files, options = {} )
    @load_path = grammar_files.map { | f | File.dirname( f ) }
    @load_path.push( '.', @output_directory )
    
    if extra_load = options[ :load_path ]
      extra_load = [ extra_load ].flatten
      @load_path.unshift( extra_load )
    end
    @load_path.uniq!
    
    @grammars = grammar_files.map do | file |
      GrammarFile.new( self, file )
    end
    @output_directory = '.'
    dir = options[ :output_directory ] and @output_directory = dir.to_s
    
    @antlr_jar = options.fetch( :antlr_jar, ANTLR3.antlr_jar )
    @debug = options.fetch( :debug, false )
    @trace = options.fetch( :trace, false )
    @profile = options.fetch( :profile, false )
    @compile_options =
      case opts = options[ :compile_options ]
      when Array then opts
      else Shellwords.shellwords( opts.to_s )
      end
    @java_options =
      case opts = options[ :java_options ]
      when Array then opts
      else Shellwords.shellwords( opts.to_s )
      end
  end
  
  def target_files
    @grammars.map { | gram | gram.target_files }.flatten
  end
  
  def output_directory
    @output_directory || '.'
  end
  
  def define_tasks
    file( @antlr_jar )
    
    for grammar in @grammars
      deps = [ @antlr_jar ]
      if  vocab = grammar.token_vocab and
          tfile = find_tokens_file( vocab, grammar )
        file( tfile )
        deps << tfile
      end
      grammar.define_tasks( deps )
    end
  end
  
  def clean
    for grammar in @grammars
      grammar.clean
    end
    if test( ?d, output_directory ) and ( Dir.entries( output_directory ) - %w( . .. ) ).empty?
      rmdir( output_directory )
    end
  end
  
  def find_tokens_file( vocab, grammar )
    gram = @grammars.find { | gram | gram.name == vocab } and
      return( gram.tokens_file )
    file = locate( "#{ vocab }.tokens" ) and return( file )
    warn( Util.tidy( <<-END, true ) )
    | unable to locate .tokens file `#{ vocab }' referenced in #{ grammar.path }
    | -- ignoring dependency
    END
    return( nil )
  end
  
  def locate( file_name )
    dir = @load_path.find do | dir |
      File.file?( File.join( dir, file_name ) )
    end
    dir and return( File.join( dir, file_name ) )
  end
  
  def compile( grammar )
    dir = output_directory
    test( ?d, dir ) or FileUtils.mkpath( dir )
    sh( build_command( grammar ) )
  end
  
  def build_command( grammar )
    parts = [ 'java', '-cp', @antlr_jar ]
    parts.concat( @java_options )
    parts << 'org.antlr.Tool' << '-fo' << output_directory
    parts << '-debug' if @debug
    parts << '-profile' if @profile
    parts << '-trace' if @trace
    parts.concat( @compile_options )
    parts << grammar.path
    return parts.map! { | t | escape( t ) }.join( ' ' )
  end
  
  def escape( token )
    token = token.to_s.dup
    token.empty? and return( %('') )
    token.gsub!( /([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1" )
    token.gsub!( /\n/, "'\n'" )
    return( token )
  end
  
end

class GrammarFile
  LANGUAGES = { 
    "ActionScript" => [ ".as" ],
    "CSharp2" => [ ".cs" ],
    "C" => [ ".c", ".h" ],
    "ObjC" => [ ".m", ".h" ],
    "CSharp3" => [ ".cs" ],
    "Cpp" => [ ".cpp", ".h" ],
    "Ruby" => [ ".rb" ],
    "Java" => [ ".java" ],
    "JavaScript" => [ ".js" ],
    "Python" => [ ".py" ],
    "Delphi" => [ ".pas" ],
    "Perl5" => [ ".pm" ]
  }.freeze
  GRAMMAR_TYPES = %w(lexer parser tree combined)
  
  ##################################################################
  ######## CONSTRUCTOR #############################################
  ##################################################################
  
  def initialize( group, path, options = {} )
    @group = group
    @path = path.to_s
    @imports = []
    @language = 'Java'
    @token_vocab = nil
    @tasks_defined = false
    @extra_dependencies = []
    if extra = options[ :extra_dependencies ]
      extra = [ extra ].flatten
      @extra_dependencies.concat( extra )
    end
    
    study
    yield( self ) if block_given?
    fetch_imports
  end
  
  ##################################################################
  ######## ATTRIBUTES AND ATTRIBUTE-ISH METHODS ####################
  ##################################################################
  attr_reader :type, :name, :language, :source,
              :token_vocab, :imports, :imported_grammars,
              :path, :group
  
  for attr in [ :output_directory, :load_path, :antlr_jar ]
    class_eval( <<-END )
      def #{ attr }
        @group.#{ attr }
      end
    END
  end
  
  def lexer_files
    if lexer? then base = @name
    elsif combined? then base = @name + 'Lexer'
    else return( [] )
    end
    return( file_names( base ) )
  end
  
  def parser_files
    if parser? then base = @name
    elsif combined? then base = @name + 'Parser'
    else return( [] )
    end
    return( file_names( base ) )
  end
  
  def tree_parser_files
    return( tree? ? file_names( @name ) : [] )
  end
  
  def file_names( base )
    LANGUAGES.fetch( @language ).map do | ext |
      File.join( output_directory, base + ext )
    end
  end
  
  for type in GRAMMAR_TYPES
    class_eval( <<-END )
      def #{ type }?
        @type == #{ type.inspect }
      end
    END
  end
  
  def delegate_files( delegate_suffix )
    file_names( "#{ name }_#{ delegate_suffix }" )
  end
  
  def tokens_file
    File.join( output_directory, name + '.tokens' )
  end
  
  def target_files( all = true )
    targets = [ tokens_file ]
    
    for target_type in %w( lexer parser tree_parser )
      for file in self.send( :"#{ target_type }_files" )
        targets << file
      end
    end
    
    if all
      for grammar in @imported_grammars
        targets.concat( grammar.target_files )
      end
    end
    
    return targets
  end
  
  def update
    touch( @path )
  end
  
  def all_imported_files
    imported_files = []
    for grammar in @imported_grammars
      imported_files.push( grammar.path, *grammar.all_imported_files )
    end
    return imported_files
  end
  
  def clean
    deleted = []
    for target in target_files
      if test( ?f, target )
        rm( target )
        deleted << target
      end
    end
    
    for grammar in @imported_grammars
      deleted.concat( grammar.clean )
    end
    
    return deleted
  end
  
  def define_tasks( shared_depends )
    unless @tasks_defined
      depends = [ @path, *all_imported_files ]
      for f in depends
        file( f )
      end
      depends = shared_depends + depends
      
      target_files.each do | target |
        file( target => ( depends - [ target ] ) ) do   # prevents recursive .tokens file dependencies
          @group.compile( self )
        end
      end
      
      @tasks_defined = true
    end
  end
  
private
  
  def fetch_imports
    @imported_grammars = @imports.map do | imp |
      file = group.locate( "#{ imp }.g" ) or raise( Util.tidy( <<-END ) )
      | #{ @path }: unable to locate imported grammar file #{ imp }.g
      | search directories ( @load_path ):
      |   - #{ load_path.join( "\n  - " ) }
      END
      Imported.new( self, file )
    end
  end
  
  def study
    @source = File.read( @path )
    @source =~ /^\s*(lexer|parser|tree)?\s*grammar\s*(\S+)\s*;/ or
      raise Grammar::FormatError[ @source, @path ]
    @name = $2
    @type = $1 || 'combined'
    if @source =~ /^\s*options\s*\{(.*?)\}/m
      option_block = $1
      if option_block =~ /\s*language\s*=\s*(\S+)\s*;/
        @language = $1
        LANGUAGES.has_key?( @language ) or
          raise( Grammar::FormatError, "Unknown ANTLR target language: %p" % @language )
      end
      option_block =~ /\s*tokenVocab\s*=\s*(\S+)\s*;/ and
        @token_vocab = $1
    end
    
    @source.scan( /^\s*import\s+(\w+\s*(?:,\s*\w+\s*)*);/ ) do
      list = $1.strip
      @imports.concat( list.split( /\s*,\s*/ ) )
    end
  end
end # class Grammar

class GrammarFile::Imported < GrammarFile
  def initialize( owner, path )
    @owner = owner
    @path = path.to_s
    @imports = []
    @language = 'Java'
    @token_vocab = nil
    study
    fetch_imports
  end
  
  for attr in [ :load_path, :output_directory, :antlr_jar, :verbose, :group ]
    class_eval( <<-END )
      def #{ attr }
        @owner.#{ attr }
      end
    END
  end
  
  def delegate_files( suffix )
    @owner.delegate_files( "#{ @name }_#{ suffix }" )
  end
  
  def target_files
    targets = [ tokens_file ]
    targets.concat( @owner.delegate_files( @name ) )
    return( targets )
  end
end

class GrammarFile::FormatError < StandardError
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
      message << 'bad grammar source in file %p\n' % @file
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
end # class CompileTask
end # module ANTLR3
