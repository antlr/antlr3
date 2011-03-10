#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3'
require 'test/unit'
require 'spec'

include ANTLR3::Error

describe( ANTLR3::Error ) do
  
  example "raising an ANTLR bug exception" do
    proc {
      ANTLR3.bug!( 'whateva' )
    }.should raise_error( ANTLR3::Bug )
  end
  
  
end

#
#class TestRecognitionError < Test::Unit::TestCase
#  def test_init_none
#    RecognitionError.new()
#  end
#end
#
#class TestEarlyExit < Test::Unit::TestCase
#  def test_init_none
#    EarlyExit.new
#  end
#end
#
#class TestMismatchedNotSet  < Test::Unit::TestCase
#  def test_init_none
#    MismatchedNotSet.new
#  end
#end
#
#class TestMismatchedRange < Test::Unit::TestCase
#  def test_init_none
#    MismatchedSet.new
#  end
#end
#
#class TestMismatchedToken < Test::Unit::TestCase
#  def test_init_none
#    MismatchedToken.new
#  end
#end
#
#class TestNoViableAlternative < Test::Unit::TestCase
#  def test_init_none
#    NoViableAlternative.new
#  end
#end
