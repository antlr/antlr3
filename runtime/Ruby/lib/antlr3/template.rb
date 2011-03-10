#!/usr/bin/ruby


require 'erb'
require 'antlr3'

module ANTLR3
module Template
module Builder
  extend ClassMacros
  
  module ClassMethods
    attr_writer :template_library
    
    def template_library
      @template_library ||= ANTLR3::Template::Group.new
    end
    
    def return_scope_members
      super.push( :template )
    end
    
    def load_templates( group_file )
      @template_library = 
        ANTLR3::Template::Group.load( group_file )
    end
    
    def define_template( name, source, &block )
      template_library.define_template( name, source, &block )
    end
  end
  
  def self.included( klass )
    super
    Class === klass and klass.extend( ClassMethods )
  end
  
  def initialize( input, options = {} )
    templates = @templates || options.fetch( :templates ) do
      self.class.template_library or ANTLR3::Template::Group.new
    end
    super( input, options )
    self.templates = templates
  end
  
  shared_attribute( :templates )
  
  def create_template( source, values = {} )
    @templates.new( source, values )
  end
  
  def fetch_template( name, values = {} )
    @templates.fetch( name, values )
  end
end

module RewriteBuilder
  include Builder
  
  def self.included( klass )
    super
    Class === klass and klass.extend( Builder::ClassMethods )
  end
  
private
  
  def cast_input( input, options )
    case input
    when TokenSource then TokenRewriteStream.new( input, options )
    when IO, String
      if lexer_class = self.class.associated_lexer
        TokenRewriteStream.new( lexer_class.new( input, options ), options )
      else
        raise ArgumentError, Util.tidy( <<-END, true )
        | unable to automatically convert input #{ input.inspect }
        | to a ANTLR3::TokenStream object as #{ self.class }
        | does not appear to have an associated lexer class
        END
      end
    else
      super
    end
  end
  
end


autoload :GroupFile, 'antlr3/template/group-file'

class Group < Module
  autoload :Lexer, 'antlr3/template/group-file'
  autoload :Parser, 'antlr3/template/group-file'
  
  def self.parse( source, options = {} )
    namespace = options.fetch( :namespace, ::Object )
    lexer  = Lexer.new( source, options )
    parser = Parser.new( lexer, options )
    return( parser.group( namespace ) )
  end
  
  def self.load( group_file, options = {} )
    unless( File.file?( group_file ) )
      dir = $LOAD_PATH.find do | d |
        File.file?( File.join( dir, group_file ) )
      end or raise( LoadError, "no such template group file to load %s" % group_file )
      group_file = File.join( dir, group_file )
    end
    namespace = options.fetch( :namespace, ::Object )
    input = ANTLR3::FileStream.new( group_file, options )
    lexer = Lexer.new( input, options )
    parser = Parser.new( lexer, options )
    return( parser.group( namespace ) )
  end
  
  def self.new( &block )
    super do
      const_set( :TEMPLATES, {} )
      block_given? and module_eval( &block )
    end
  end
  
  def new( source, values = {} )
    erb = ERB.new( source, nil, '%' )
    template = Context.new( values )
    template.extend( self )
    sclass = class << template; self; end
    erb.def_method( sclass, 'to_s' )
    return( template )
  end
  
  def fetch( name, values = {} )
    self::TEMPLATES.fetch( name.to_s ).new( values )
  end
  
  def templates
    self::TEMPLATES
  end
  
  def template_defined?( name )
    self::TEMPLATES.has_key?( name.to_s )
  end
  
  def define_template( name, source, parameters = nil, &block )
    name = name.to_s.dup.freeze
    Context.define( self, name, parameters ) do | tclass |
      self::TEMPLATES[ name ] = tclass
      ERB.new( source, nil, '%' ).def_method( tclass, 'to_s' )
      
      define_template_methods( tclass )
    end
    return( self )
  end
  
  def alias_template( new_name, old_name )
    new_name, old_name = new_name.to_s.dup.freeze, old_name.to_s
    context = self::TEMPLATES.fetch( old_name.to_s ) do
      raise( NameError,
        "undefined template `%s' for template group %p" % [ old_name, self ]
      )
    end
    context.define_alias( new_name ) do | tclass |
      self::TEMPLATES[ new_name ] = tclass
      define_template_methods( tclass )
    end
    return( self )
  end
  
private
  
  def define_template_methods( context )
    name = context.name
    if params = context.parameters
      init = params.names.map do | param |
        "___[ #{ param.inspect } ] = #{ param }"
      end.join( "\n" )
      
      module_eval( <<-END )
        module_function
        
        def #{ name }( #{ params } )
          TEMPLATES[ #{ name.inspect } ].new do | ___ |
            #{ init }
          end
        end
        
        def #{ name }!( #{ params } )
          TEMPLATES[ #{ name.inspect } ].new do | ___ |
            #{ init }
          end.to_s
        end
      END
      
    else
      
      module_eval( <<-END )
        module_function
        
        def #{ name }( values = {} )
          TEMPLATES[ #{ name.inspect } ].new( values )
        end
        
        def #{ name }!( values = {} )
          TEMPLATES[ #{ name.inspect } ].new( values ).to_s
        end
      END
      
    end
  end
end

class Context
  VARIABLE_FORM = /^(@)?[a-z_\x80-\xff][\w\x80-\xff]*$/
  SETTER_FORM = /^([a-z_\x80-\xff][\w\x80-\xff]*)=$/
  ATTR_FORM = /^[a-z_\x80-\xff][\w\x80-\xff]*$/
  
  class << self
    attr_accessor :group, :name, :parameters
    protected :group=, :name=
    
    def define_alias( name )
      new = clone
      new.name = name
      new.group = @group
      block_given? and yield( new )
      return( new )
    end
    
    def define( group, name, parameters )
      Class.new( self ) do
        include( group )
        
        @group = group
        @name  = name
        @parameters = parameters
        
        block_given? and yield( self )
      end
    end
  end
  
  def method_missing( method, *args )
    case name = method.to_s
    when SETTER_FORM then return( self[ $1 ] = args.first )
    when ATTR_FORM
      args.empty? and has_ivar?( name ) and return( self[ name ] )
    end
    super
  end
  
  def []=( name, value )
    instance_variable_set( make_ivar( name ), value )
  end
  
  def []( name )
    name = make_ivar( name )
    instance_variable_defined?( name ) ? instance_variable_get( name ) : nil
  end
  
  def <<( variable_map )
    variable_map.each_pair do | name, value |
      self[ name ] = value
    end
    return( self )
  end
  
  def initialize( variable_map = nil )
    variable_map and self << variable_map
    block_given? and yield( self )
  end
  
private
  
  def has_ivar?( name )
    instance_variable_defined?( make_ivar( name ) )
  end
  
  def make_ivar( name )
    name = name.to_s
    VARIABLE_FORM =~ name or
      raise ArgumentError, "cannot convert %p to an instance variable name" % name
    $1 ? name : "@#{ name }"
  end
  
end

Parameter = Struct.new( :name, :default )
class Parameter
  def to_s
    default ? "#{ name } = #{ default }" : "#{ name }"
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
  
  def add( name, options = nil )
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
