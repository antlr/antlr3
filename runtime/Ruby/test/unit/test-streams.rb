#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3'
require 'test/unit'
require 'spec'


include ANTLR3

class TestStringStream < Test::Unit::TestCase
  def setup
    @stream = StringStream.new( "oh\nhey!\n" )
  end
  
  def test_size
    @stream.size.should == 8
  end
  
  def test_index
    @stream.index.should == 0
  end
  
  def test_consume
    @stream.consume # o
    @stream.index.should == 1
    @stream.column.should == 1
    @stream.line.should == 1
    
    @stream.consume  # h
    @stream.index.should == 2
    @stream.column.should == 2
    @stream.line.should == 1
    
    @stream.consume # \n
    @stream.index.should == 3
    @stream.column.should == 0
    @stream.line.should == 2
    
    @stream.consume #  h
    @stream.index.should == 4
    @stream.column.should == 1
    @stream.line.should == 2
    
    @stream.consume # e
    @stream.index.should == 5
    @stream.column.should == 2
    @stream.line.should == 2
    
    @stream.consume # y
    @stream.index.should == 6
    @stream.column.should == 3
    @stream.line.should == 2
    
    @stream.consume # !
    @stream.index.should == 7
    @stream.column.should == 4
    @stream.line.should == 2
    
    @stream.consume # \n
    @stream.index.should == 8
    @stream.column.should == 0
    @stream.line.should == 3
    
    @stream.consume # EOF
    @stream.index.should == 8
    @stream.column.should == 0
    @stream.line.should == 3
    
    @stream.consume # EOF
    @stream.index.should == 8
    @stream.column.should == 0
    @stream.line.should == 3
  end
  
  def test_reset
    2.times { @stream.consume }
    @stream.reset
    @stream.index.should == 0
    @stream.line.should == 1
    @stream.column.should == 0
    @stream.peek(1).should == ?o.ord
  end
  
  def test_look
    @stream.look(1).should == 'o'
    @stream.look(2).should == 'h'
    @stream.look(3).should == "\n"
    @stream.peek(1).should == ?o.ord
    @stream.peek(2).should == ?h.ord
    @stream.peek(3).should == ?\n.ord
    
    6.times { @stream.consume }
    @stream.look(1).should == '!'
    @stream.look(2).should == "\n"
    @stream.look(3).should be_nil
    @stream.peek(1).should == ?!.ord
    @stream.peek(2).should == ?\n.ord
    @stream.peek(3).should == EOF
  end
  
  def test_substring
    @stream.substring(0,0).should == 'o'
    @stream.substring(0,1).should == 'oh'
    @stream.substring(0,8).should == "oh\nhey!\n"
    @stream.substring(3,6).should == "hey!"
  end
  
  def test_seek_forward
    @stream.seek(3)
    @stream.index.should == 3
    @stream.line.should == 2
    @stream.column.should == 0
    @stream.peek(1).should == ?h.ord
  end
  
  def test_mark
    @stream.seek(4)
    marker = @stream.mark
    marker.should == 1
    
    2.times { @stream.consume }
    marker = @stream.mark
    
    marker.should == 2
  end
  
  def test_release_last
    @stream.seek(4)
    marker1 = @stream.mark
    
    2.times { @stream.consume }
    marker2 = @stream.mark
    
    @stream.release
    @stream.mark_depth.should == 2
    @stream.release
    @stream.mark_depth.should == 1
  end
  
  def test_release_nested
    @stream.seek(4)
    marker1 = @stream.mark()
    
    @stream.consume()
    marker2 = @stream.mark()
    
    @stream.consume()
    marker3 = @stream.mark()
    
    @stream.release(marker2)
    @stream.mark_depth.should == 2

  end
  
  def test_rewind_last
    @stream.seek(4)

    marker = @stream.mark
    @stream.consume
    @stream.consume

    @stream.rewind
    @stream.mark_depth.should == 1
    @stream.index.should == 4
    @stream.line.should == 2
    @stream.column.should == 1
    @stream.peek(1).should == ?e.ord
    
  end

  def test_through
    @stream.through( 2 ).should == 'oh'
    @stream.through( -2 ).should == ''
    @stream.seek( 5 )
    @stream.through( 0 ).should == ''
    @stream.through( 1 ).should == 'y'
    @stream.through( -2 ).should == 'he'
    @stream.through( 5 ).should == "y!\n"
  end
  
  def test_rewind_nested
    @stream.seek(4)
    marker1 = @stream.mark()
    
    @stream.consume
    marker2 = @stream.mark
    
    @stream.consume
    marker3 = @stream.mark
    
    @stream.rewind(marker2)
    @stream.mark_depth.should == 2
    @stream.index().should == 5
    @stream.line.should == 2
    @stream.column.should == 2
    @stream.peek(1).should == ?y.ord    
  end
end

class TestFileStream < Test::Unit::TestCase
  
  
  def test_no_encoding
    
    path = File.join(File.dirname(__FILE__), 'sample-input/file-stream-1')
    @stream = FileStream.new(path)
    
    @stream.seek(4)
    marker1 = @stream.mark()
    
    @stream.consume()
    marker2 = @stream.mark()
    
    @stream.consume()
    marker3 = @stream.mark()
    
    @stream.rewind(marker2)
    @stream.index().should == 5
    @stream.line.should == 2
    @stream.column.should == 1
    @stream.mark_depth.should == 2
    @stream.look(1).should == 'a'
    @stream.peek(1).should == ?a.ord
  end
  
  def test_encoded
    
  end
end

class TestInputStream < Test::Unit::TestCase
  def test_no_encoding
    
  end
  
  def test_encoded
    
  end
end

class TestCommonTokenStream < Test::Unit::TestCase
  class MockSource
    include ANTLR3::TokenSource
    attr_accessor :tokens
    def initialize
      @tokens = []
    end
    def next_token
      @tokens.shift
    end
  end
  
  # vvvvvvvv tests vvvvvvvvv
  def test_init
    @source = MockSource.new
    @stream = CommonTokenStream.new( @source )
    @stream.position.should == 0
  end
  
  def test_rebuild
    @source1 = MockSource.new
    @source2 = MockSource.new
    @source2.tokens << new_token( 10, :channel => ANTLR3::HIDDEN ) << new_token( 11 )
    @stream = CommonTokenStream.new( @source1 )
    
    @stream.position.should == 0
    @stream.tokens.length.should == 0
    
    @stream.rebuild( @source2 )
    @stream.token_source.should == @source2
    @stream.position.should == 1
    @stream.tokens.should have( 2 ).things
  end
  
  def test_look_empty_source
    @source = MockSource.new
    @stream = CommonTokenStream.new(@source)
    @stream.look.should == ANTLR3::EOF_TOKEN
  end
  
  def test_look1
    @source = MockSource.new
    @source.tokens << new_token(12)
    @stream = CommonTokenStream.new(@source)
    @stream.look(1).type.should == 12
  end
  
  def test_look1_with_hidden
    # FIX
    @source = MockSource.new
    @source.tokens << new_token(12, :channel => ANTLR3::HIDDEN_CHANNEL) <<
      new_token(13)
    @stream = CommonTokenStream.new(@source)
    @stream.look(1).type.should == 13
  end
  
  def test_look2_beyond_end
    @source = MockSource.new
    @source.tokens << new_token(12) <<
      new_token(13, :channel => ANTLR3::HIDDEN_CHANNEL)
    
    @stream = CommonTokenStream.new(@source)
    @stream.look(2).type.should == EOF
  end
  
  def test_look_negative
    @source = MockSource.new
    @source.tokens << new_token(12) << new_token(13)
    @stream = CommonTokenStream.new(@source)
    @stream.consume
    
    @stream.look(-1).type.should == 12
  end
  
  def test_lb1
    @source = MockSource.new
    @source.tokens << new_token(12) << new_token(13)
    @stream = CommonTokenStream.new(@source)
    
    @stream.consume
    @stream.look(-1).type.should == 12
  end
  
  def test_look_zero
    # FIX
    @source = MockSource.new
    @source.tokens << new_token(12) << new_token(13)
    @stream = CommonTokenStream.new(@source)
    @stream.look(0).should == nil
  end
  
  def test_lb_beyond_begin
    @source = MockSource.new
    @source.tokens << new_token(10) <<
      new_token(11, :channel => HIDDEN_CHANNEL) <<
      new_token(12, :channel => HIDDEN_CHANNEL) <<
      new_token(13)
    @stream = CommonTokenStream.new(@source)
    
    @stream.look(-1).should == nil
    2.times { @stream.consume }
    @stream.look(-3).should == nil
  end
  
  def test_fill_buffer
    @source = MockSource.new
    @source.tokens << new_token(12) << new_token(13) <<  new_token(14) << new_token(EOF)
    @stream = CommonTokenStream.new(@source)
    
    @stream.instance_variable_get(:@tokens).length.should == 3
    @stream.tokens[0].type.should == 12
    @stream.tokens[1].type.should == 13
    @stream.tokens[2].type.should == 14
  end
  
  def test_consume
    @source = MockSource.new
    @source.tokens << new_token(12) << new_token(13) << new_token(EOF)
    @stream = CommonTokenStream.new(@source)
    @stream.peek.should == 12
    @stream.consume
    @stream.peek.should == 13
    @stream.consume
    @stream.peek.should == EOF
    @stream.consume
    @stream.peek.should == EOF
  end
  
  def test_seek
    @source = MockSource.new
    @source.tokens << new_token(12) << new_token(13) << new_token(EOF)
    @stream = CommonTokenStream.new(@source)
    
    @stream.peek(1).should == 12
    @stream.seek(2).peek.should == EOF
    @stream.seek(0).peek.should == 12
    @stream.seek(-3).position.should == 0
    @stream.seek(10).position.should == 2
  end
  
  def test_mark_rewind
    @source = MockSource.new
    @source.tokens << new_token(12) << new_token(13) << new_token(EOF)
    @stream = CommonTokenStream.new(@source)
    @stream.consume
    marker = @stream.mark
    @stream.consume
    @stream.rewind(marker)
    @stream.peek(1).should == 13
  end
  
  def test_to_string
    @source = MockSource.new
    @source.tokens << new_token(12, 'foo') <<
      new_token(13, 'bar') << new_token(14, 'gnurz') <<
      new_token(15, 'blarz')
    @stream = CommonTokenStream.new(@source)
    @stream.to_s.should == "foobargnurzblarz"
    @stream.to_s(1,2).should == 'bargnurz'
    @stream.to_s(@stream[1], @stream[-2]).should == 'bargnurz'
  end

  def new_token(type, opts = {})
    fields = {}
    case type
    when Hash then fields.update(type)
    else
      fields[:type] = type
    end
    case opts
    when Hash then fields.update(opts)
    when String then fields[:text] = opts
    end
    CommonToken.create(fields)
  end
  
end


__END__
teststreams.py                                | LN  | STATUS
----------------------------------------------+-----+--------------
class TestStringStream(unittest.TestCase)     | 009 | [x]
  def testSize(self)                          | 012 | [x]
  def testIndex(self)                         | 020 | [x]
  def testConsume(self)                       | 028 | [x]
  def testReset(self)                         | 079 | [x]
  def testLA(self)                            | 094 | [x]
  def testSubstring(self)                     | 111 | [x]
  def testSeekForward(self)                   | 122 | [x]
  def testMark(self)                          | 150 | [x]
  def testReleaseLast(self)                   | 167 | [x]
  def testReleaseNested(self)                 | 186 | [x]
  def testRewindLast(self)                    | 204 | [x]
  def testRewindNested(self)                  | 223 | [x]
class TestFileStream(unittest.TestCase)       | 245 | [o]
  def testNoEncoding(self)                    | 249 | [x]
  def testEncoded(self)                       | 272 | [ ]
class TestInputStream(unittest.TestCase)      | 296 | [ ]
  def testNoEncoding(self)                    | 299 | [ ]
  def testEncoded(self)                       | 322 | [ ]
class TestCommonTokenStream(unittest.TestCase)| 345 | [ ]
  def setUp(self)                             | 348 | [x]
  def testInit(self)                          | 369 | [x]
  def testSetTokenSource(self)                | 376 | [x]
  def testLTEmptySource(self)                 | 385 | [x]
  def testLT1(self)                           | 394 | [x]
  def testLT1WithHidden(self)                 | 407 | [x]
  def testLT2BeyondEnd(self)                  | 424 | [x]
  def testLTNegative(self)                    | 442 | [x]
  def testLB1(self)                           | 461 | [x]
  def testLTZero(self)                        | 479 | [x]
  def testLBBeyondBegin(self)                 | 496 | [x]
  def testFillBuffer(self)                    | 523 | [x]
  def testConsume(self)                       | 551 | [x]
  def testSeek(self)                          | 579 | [x]
  def testMarkRewind(self)                    | 604 | [x]
  def testToString(self)                      | 631 | [x]

