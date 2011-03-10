#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3'
require 'test/unit'
require 'spec'

class DFASubclass < ANTLR3::DFA
  EOT = [1, 2].freeze
  EOF = [3, 4].freeze
  MAX = [5, 6].freeze
  MIN = [7, 8].freeze
  ACCEPT = [9, 10, 11].freeze
  SPECIAL = [12].freeze
  TRANSITION = [
    [13, 14, 15, 16].freeze,
    [].freeze
  ].freeze
end

class TestDFA < Test::Unit::TestCase
  def test_init
    dfa = DFASubclass.new(nil, 1)
    dfa.eot.should == DFASubclass::EOT
    dfa.eof.should == DFASubclass::EOF
    dfa.max.should == DFASubclass::MAX
    dfa.min.should == DFASubclass::MIN
    dfa.accept.should == DFASubclass::ACCEPT
    dfa.special.should == DFASubclass::SPECIAL
    dfa.transition.should == DFASubclass::TRANSITION
  end
  
  def test_unpack
    packed = [
      1, 3, 1, 4, 2, -1, 1, 5, 18, -1, 1, 2,
      25, -1, 1, 6, 6, -1, 26, 6, 4, -1, 1, 6,
      1, -1, 26, 6
    ]
    unpacked = [
      3, 4, -1, -1, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
     -1, -1, -1, -1, -1, -1, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1,
     -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
      6, -1, -1, -1, -1, -1, -1, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
      6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, -1, -1, -1, -1, 6, -1,
      6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
      6, 6, 6, 6, 6
    ]
    
    ANTLR3::DFA.unpack(*packed).should == unpacked
  end
  
end
