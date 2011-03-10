#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3'
require 'test/unit'
require 'spec'

class TestDFA < Test::Unit::TestCase
  def setup
    @A = ANTLR3::Scope.new( :a, :b )
    @B = ANTLR3::Scope.new( 'count = 3' )
    @C = ANTLR3::Scope.new( 'a', 'b = 0', 'c = {}' )
  end
  
  def test_members
    @A.members.map( &:to_s ).should == %w( a b )
    @B.members.map( &:to_s ).should == %w( count )
    @C.members.map( &:to_s ).should == %w( a b c )
  end
  
  def test_defaults_without_arguments
    @A.new.to_a.should == [ nil, nil ]
    @B.new.to_a.should == [ 3 ]
    @C.new.to_a.should == [ nil, 0, {} ]
  end
  
  def test_C_defaults_with_arguments
    c = @C.new( Object )
    c.a.should == Object
    c.b.should == 0
    c.c.should == {}
  end
  
  def test_B_defaults_with_arguments
    b = @B.new( 7000 )
    b.count.should == 7000
  end
  
  def test_A_defaults_with_arguments
    a = @A.new( "apple", :orange )
    a.a.should == 'apple'
    a.b.should == :orange
  end
  
end
