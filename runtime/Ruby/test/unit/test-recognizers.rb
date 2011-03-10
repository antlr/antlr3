#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3'
require 'test/unit'
require 'spec'

include ANTLR3

class TestTokenSource < Test::Unit::TestCase
  TrivialToken = Struct.new(:type) do
    include Token
  end
  class TestSource
    include TokenSource
    def initialize
      @tokens = (1..4).map { |i| TrivialToken[i] }
      @tokens << TrivialToken[EOF]
    end
    
    def next_token
      @tokens.shift
    end
  end
  
  def test_iterator_interface
    src = TestSource.new
    tokens = []
    src.each do |token|
      tokens << token.type
    end
    tokens.should == [1,2,3,4]
  end
  
end

class TestLexer < Test::Unit::TestCase
  class TLexer < Lexer
    @antlr_version = ANTLR3::ANTLR_VERSION.dup
  end
  def test_init
    stream = StringStream.new('foo')
    TLexer.new(stream)
  end
end

__END__
testrecognizers.py                           | LN | STATUS
---------------------------------------------+----+--------------
class TestBaseRecognizer(unittest.TestCase)  | 07 | [x]
    def testGetRuleInvocationStack(self)     | 10 | [x]
class TestTokenSource(unittest.TestCase)     | 20 | [x]
    def testIteratorInterface(self)          | 24 | [x]
class TestLexer(unittest.TestCase)           | 54 | [x]
    def testInit(self)                       | 56 | [x]