#!/usr/bin/ruby
# encoding: utf-8

require 'spec'
require 'antlr3/template'
require 'antlr3/util'

include ANTLR3
MethodDescription = Struct.new( :name, :body, :arguments )
TEMPLATE_NAMES = %w( method class_definition attribute )
SAMPLE_GROUP_FILE = File.join(
  File.dirname( __FILE__ ), 'sample-input', 'template-group'
)

describe Template::Context do
  example "creating an empty context" do
    context = Template::Context.new
    context.instance_variables.should be_empty
  end
  
  example "creating a context with a variable map" do
    context = Template::Context.new(
      :a => 1, :b => 2
    )
    
    vars = context.instance_variables.map { | i | i.to_s }
    vars.should include( '@a' )
    vars.should include( '@b' )
    
    context.instance_variable_get( '@a' ).should == 1
    context.instance_variable_get( '@b' ).should == 2
  end
  
  example "fetching variable values from []" do
    context = Template::Context.new(
      :a => 1, :b => 2
    )
    
    context[ :a ].should == 1
    context[ 'a' ].should == 1
    context[ :b ].should == 2
    context[ 'b' ].should == 2
  end
  
  example "defining variables with []=" do
    context = Template::Context.new( :a => 3 )
    context[ :a ] = 1
    context[ 'b' ] = 2
    
    context.instance_variable_get( '@a' ).should == 1
    context.instance_variable_get( '@b' ).should == 2
  end
  
  example "using method missing to assign values" do
    context = Template::Context.new( :a => 3 )
    context.a = 1
    context.b = 2
    
    context.instance_variable_get( '@a' ).should == 1
    context.instance_variable_get( '@b' ).should == 2
  end
  
  example "using method missing to get variable values" do
    context = Template::Context.new( :a => 1, :b => 2)
    
    context.a.should == 1
    context.b.should == 2
  end
  
end


shared_examples_for "template groups" do
  include ANTLR3::Util
  
  example "template definitions" do
    templates = @group.templates
    templates.should_not be_empty
    templates.should equal @group::TEMPLATES
    
    names = templates.keys
    
    names.should have(3).things
    for template_name in TEMPLATE_NAMES
      names.should include template_name
      template_class = templates[ template_name ]
      template_class.should be_a_kind_of Class
      template_class.superclass.should equal Template::Context
      template_class.should be < @group # it should include the group module
    end
  end
  
  example "template_defined?( name ) should verify whether a template is defined in a group" do
    for name in TEMPLATE_NAMES
      @group.template_defined?( name ).should be_true
      @group.template_defined?( name.to_s ).should be_true
    end
    
    @group.template_defined?( :something_else ).should be_false
  end
  
  example "template method definitions" do
    for name in TEMPLATE_NAMES
      @group.should respond_to( name )
      @group.should respond_to( "#{ name }!" )
      if RUBY_VERSION =~ /^1\.9/
        @group.private_instance_methods.should include name.to_sym
        @group.private_instance_methods.should include :"#{ name }!"
      else
        @group.private_instance_methods.should include name.to_s
        @group.private_instance_methods.should include "#{ name }!"
      end
    end
  end
  
  example "template method operation" do
    value = @group.class_definition
    value.should be_a_kind_of Template::Context
    
    value = @group.class_definition!
    value.should be_a_kind_of String
    
    value = @group.attribute( :name => 'a' )
    value.should be_a_kind_of Template::Context
  end
end

describe Template::Group, "dynamic template definition" do
  include ANTLR3::Util
  
  before :each do
    @group = Template::Group.new do
      extend ANTLR3::Util
      define_template( :class_definition, tidy( <<-'END'.chomp ) )
      | class <%= @name %><% if @superclass %> < <%= @superclass %><% end %>
      | % if @attributes
      | 
      | % for attr, access in @attributes 
      | <%= attribute( :name => attr, :access => ( access || 'rw' ) ).to_s.chomp %>
      | % end
      | % end
      | % if @methods
      | % for method in ( @methods || [] )
      | <%= method( method ) %>
      | % end
      | % end
      | end
      END
      
      define_template( :attribute, tidy( <<-'END'.chomp ) )
      | % case @access.to_s.downcase
      | % when 'r'
      |   attr_reader :<%= @name %>
      | % when 'w'
      |   attr_writer :<%= @name %>
      | % else
      |   attr_accessor :<%= @name %>
      | % end
      END
      
      define_template( :method, tidy( <<-'END'.chomp ) )
      |   
      |   def <%= @name %><% if @arguments and not @arguments.empty? %>( <%= @arguments.join( ', ' ) %> )<% end %>
      | <%= @body.gsub( /^/, '    ' ) %>
      |   end
      END
    end
  end
  
  it_should_behave_like "template groups"
  
  example "template object string rendering" do
    attributes = [
      %w( family ),
      %w( name r )
    ]
          
    methods = [
      MethodDescription.new( 'eat', %q[puts( "ate %s %s" % [ number, @name ] )], %w( number ) ),
      MethodDescription.new( :to_s, '@name.to_s.dup' )
    ]
    
    vegetable = @group.class_definition(
      :name => 'Vegetable',
      :superclass => 'Food',
      :attributes => attributes,
      :methods => methods
    )
    
    vegetable.to_s.should == tidy( <<-END.chomp )
    | class Vegetable < Food
    |
    |   attr_accessor :family
    |   attr_reader :name
    |   
    |   def eat( number )
    |     puts( "ate %s %s" % [ number, @name ] )
    |   end
    |   
    |   def to_s
    |     @name.to_s.dup
    |   end
    | end
    END
  end
end

describe Template::Group, "loading a template definition file" do
  
  before :each do
    @group = Template::Group.load( SAMPLE_GROUP_FILE )
  end
  
  it_should_behave_like "template groups"
  
  example "template object string rendering" do
    attributes = [
      %w( family ),
      %w( name r )
    ]
          
    methods = [
      MethodDescription.new( 'eat', %q[puts( "ate %s %s" % [ number, @name ] )], %w( number ) ),
      MethodDescription.new( :to_s, '@name.to_s.dup' )
    ]
    
    vegetable = @group.class_definition(
      :name => 'Vegetable',
      :superclass => 'Food',
      :attributes => attributes,
      :methods => methods
    )
    
    vegetable.to_s.should == tidy( <<-END.chomp )
    | class Vegetable < Food
    |
    |   attr_accessor :family
    |   attr_reader :name
    |   
    |   def eat( number )
    |     puts( "ate %s %s" % [ number, @name ] )
    |   end
    |   
    |   def to_s
    |     @name.to_s.dup
    |   end
    | end
    END
  end
end
