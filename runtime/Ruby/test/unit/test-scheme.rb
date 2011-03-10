#!/usr/bin/ruby
# encoding: utf-8
require 'antlr3'
require 'test/unit'
require 'spec'

include ANTLR3

describe TokenScheme do
  before do
    @ts = TokenScheme.new do
      define_tokens(:A => 4, :B => 5, :T__6 => 6)
      register_names('A', 'B', "'+'")
    end
    @a_class = Class.new do
      class << self
        attr_accessor :token_scheme
      end
    end
    @a_class.send(:include, @ts)
    
    @an_instance = @a_class.new
  end
  
  example "token schemes define tokens as constants" do
    @ts::A.should == 4
    @ts::B.should == 5
    @ts::T__6.should == 6
    @ts::EOF.should == -1
  end
  
  example "token schemes track human-friendly token names" do
    @ts::TOKEN_NAMES.should == {
      0 => "<invalid>", -1 => "<EOF>", 1 => "<EOR>",
      2 => "<DOWN>", 3 => "<UP>", 4 => "A",
      5 => "B", 6 => "'+'"
    }
    @ts.token_name(5).should == 'B'
    @ts.token_name(6).should == "'+'"
    @ts.token_name(-1).should == '<EOF>'
    @ts.token_name(7).should == '<UNKNOWN: 7>'
  end
  
  
  example 'class-level results of including a token scheme' do
    #@a_class.token_scheme.should == @ts
    
    @a_class::A.should == 4
    @a_class::B.should == 5
    @a_class::T__6.should == 6
    @a_class::EOF.should == -1
    
    @a_class.send(:token_names).should == {
      0 => "<invalid>", -1 => "<EOF>", 1 => "<EOR>",
      2 => "<DOWN>", 3 => "<UP>", 4 => "A",
      5 => "B", 6 => "'+'"
    }
  end
  
  example 'instance-level results of including a token scheme' do
  end
end
