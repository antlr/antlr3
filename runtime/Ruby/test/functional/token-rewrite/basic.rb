#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestRewritingLexerOutputDirectly < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    lexer grammar SimpleRewriting;
    options {
        language = Ruby;
    }
    
    A: 'a';
    B: 'b';
    C: 'c';
  END
  
  def rewrite( input, expected )
    lexer = SimpleRewriting::Lexer.new( input )
    tokens = ANTLR3::TokenRewriteStream.new( lexer )
    yield( tokens )
    tokens.render.should == expected
    return( tokens )
  end

  example 'insert before' do
    rewrite( 'abc', '0abc' ) do |stream|
      stream.insert_before( 0, '0' )
    end
  end
  
  example 'insert after last index' do
    rewrite( 'abc', 'abcx' ) do |stream|
      stream.insert_after( 2, 'x' )
    end
  end
  
  example 'insert before after middle index' do
    rewrite( 'abc', 'axbxc' ) do |stream|
      stream.insert_before 1, 'x'
      stream.insert_after 1, 'x'
    end
  end
  
  example 'replace index 0' do
    rewrite( 'abc', 'xbc' ) do |stream|
      stream.replace( 0, 'x' )
    end
  end
  
  example 'replace last index' do
    rewrite( 'abc', 'abx' ) do |stream|
      stream.replace 2, 'x'
    end
  end
  
  example 'replace last index' do
    rewrite( 'abc', 'abx' ) do |stream|
      stream.replace( 2, 'x' )
    end
  end
  
  example 'replace middle index' do
    rewrite( 'abc', 'axc' ) do |stream|
      stream.replace 1, 'x'
    end
  end
  
  example 'replace middle index' do
    rewrite( 'abc', 'ayc' ) do |stream|
      stream.replace 1, 'x'
      stream.replace 1, 'y'
    end
  end
  
  example 'replace middle index 1 insert before' do
    rewrite( 'abc', '_ayc' ) do |stream|
      stream.insert_before 0, '_'
      stream.replace 1, 'x'
      stream.replace 1, 'y'
    end
  end
  
  example 'replace then delete middle index' do
    rewrite( 'abc', 'ac' ) do |stream|
      stream.replace 1, 'x'
      stream.delete 1
    end
  end
  
  example 'insert then replace same index' do
    rewrite 'abc', 'xbc' do |stream|
      stream.insert_before 0, '0'
      stream.replace 0, 'x'
    end
  end
  
  example 'insert middle index' do
    rewrite( "abc", "ayxbc" ) do |stream|
      stream.insert_before( 1, "x" )
      stream.insert_before( 1, "y" )
    end
  end
  
  example 'insert then replace index0' do
    rewrite( "abc", "zbc" ) do |stream|
      stream.insert_before( 0, "x" )
      stream.insert_before( 0, "y" )
      stream.replace( 0, "z" )
    end
  end
  
  example 'replace then insert before last index' do
    rewrite( "abc", "abyx" ) do |stream|
      stream.replace( 2, "x" )
      stream.insert_before( 2, "y" )
    end
  end
  
  example 'insert then replace last index' do
    rewrite( "abc", "abx" ) do |stream|
      stream.insert_before( 2, "y" )
      stream.replace( 2, "x" )
    end
  end
  
  example 'replace then insert after last index' do
    rewrite( "abc", "abxy" ) do |stream|
      stream.replace( 2, "x" )
      stream.insert_after( 2, "y" )
    end
  end
  
  example 'replace range then insert at left edge' do
    rewrite( "abcccba", "abyxba" ) do |stream|
      stream.replace( 2, 4, "x" )
      stream.insert_before( 2, "y" )
    end
  end
  
  example 'replace range then insert after right edge' do
    rewrite( "abcccba", "abxyba" ) do |stream|
      stream.replace( 2, 4, "x" )
      stream.insert_after( 4, "y" )
    end
  end
  
  example 'replace all' do
    rewrite( "abcccba", "x" ) do |stream|
      stream.replace( 0, 6, "x" )
    end
  end
  
  example 'replace single middle then overlapping superset' do
    rewrite( "abcba", "fooa" ) do |stream|
      stream.replace( 2, 2, "xyz" )
      stream.replace( 0, 3, "foo" )
    end
  end
  
  example 'combine inserts' do
    rewrite( "abc", "yxabc" ) do |stream|
      stream.insert_before( 0, "x" )
      stream.insert_before( 0, "y" )
    end
  end
  
  example 'combine3 inserts' do
    rewrite( "abc", "yazxbc" ) do |stream|
      stream.insert_before( 1, "x" )
      stream.insert_before( 0, "y" )
      stream.insert_before( 1, "z" )
    end
  end
  
  example 'disjoint inserts' do
    rewrite( "abc", "zaxbyc" ) do |stream|
      stream.insert_before( 1, "x" )
      stream.insert_before( 2, "y" )
      stream.insert_before( 0, "z" )
    end
  end
  
  example 'leave alone disjoint insert' do
    rewrite( "abcc", "axbfoo" ) do |stream|
      stream.insert_before( 1, "x" )
      stream.replace( 2, 3, "foo" )
    end
  end
  
  example 'leave alone disjoint insert2' do
    rewrite( "abcc", "axbfoo" ) do |stream|
      stream.replace( 2, 3, "foo" )
      stream.insert_before( 1, "x" )
    end
  end
  
  example 'combine insert on left with delete' do
    rewrite( "abc", "z" ) do |stream|
      stream.delete( 0, 2 )
      stream.insert_before( 0, "z" )
    end
  end
  
  example 'overlapping replace' do
    rewrite( "abcc", "bar" ) do |stream|
      stream.replace( 1, 2, "foo" )
      stream.replace( 0, 3, "bar" )
    end
  end
  
  example 'overlapping replace3' do
    rewrite( "abcc", "barc" ) do |stream|
      stream.replace( 1, 2, "foo" )
      stream.replace( 0, 2, "bar" )
    end
  end
  
  example 'overlapping replace 4' do
    rewrite( "abcc", "abar" ) do |stream|
      stream.replace( 1, 2, "foo" )
      stream.replace( 1, 3, "bar" )
    end
  end

  example 'overlapping replace 2' do
    lexer = SimpleRewriting::Lexer.new( 'abcc' )
    stream = ANTLR3::TokenRewriteStream.new( lexer )
    stream.replace 0, 3, 'bar'
    stream.replace 1, 2, 'foo'
    
    lambda { stream.render }.
    should raise_error { |error|
      error.to_s.should == %q<operation (replace @ 1..2 : "foo") overlaps with previous operation (replace @ 0..3 : "bar")>
    }
  end
  
  example 'replace range then insert at right edge' do
    lexer = SimpleRewriting::Lexer.new( 'abcccba' )
    stream = ANTLR3::TokenRewriteStream.new( lexer )
    stream.replace 2, 4, 'x'
    stream.insert_before 4, 'y'
    lambda { stream.render }.
    should raise_error { |error|
      error.to_s.should == %q<operation (insert-before @ 4 : "y") overlaps with previous operation (replace @ 2..4 : "x")>
    }
  end
  
  example 'replace then replace superset' do
    lexer = SimpleRewriting::Lexer.new( 'abcccba' )
    stream = ANTLR3::TokenRewriteStream.new( lexer )
    stream.replace 2, 4, 'xyz'
    stream.replace 3, 5, 'foo'
    lambda { stream.render }.
    should raise_error { |error|
      error.to_s.should == %q<operation (replace @ 3..5 : "foo") overlaps with previous operation (replace @ 2..4 : "xyz")>
    }
  end
  
  example 'replace then replace lower indexed superset' do
    lexer = SimpleRewriting::Lexer.new( 'abcccba' )
    stream = ANTLR3::TokenRewriteStream.new( lexer )
    stream.replace 2, 4, 'xyz'
    stream.replace 1, 3, 'foo'
    lambda { stream.render }.
    should raise_error { |error|
      error.to_s.should == %q<operation (replace @ 1..3 : "foo") overlaps with previous operation (replace @ 2..4 : "xyz")>
    }
  end
  
end

class TestRewritingWithTokenStream2 < ANTLR3::Test::Functional
  inline_grammar( <<-END )
    lexer grammar SimpleRewriting2;
    options {
        language = Ruby;
    }
    
    ID : 'a'..'z'+;
    INT : '0'..'9'+;
    SEMI : ';';
    PLUS : '+';
    MUL : '*';
    ASSIGN : '=';
    WS : ' '+;
  END
  
  def rewrite( input )
    lexer = SimpleRewriting2::Lexer.new( input )
    ANTLR3::TokenRewriteStream.new( lexer )
  end
  
  example 'rendering over a range' do
    stream = rewrite 'x = 3 * 0;'
    stream.replace 4, 8, '0'
    stream.original_string.should == 'x = 3 * 0;'
    stream.render.should == 'x = 0;'
    stream.render( 0, 9 ).should == 'x = 0;'
    stream.render( 4, 8 ).should == '0'
  end
  
  example 'more rendering over a range' do
    stream = rewrite 'x = 3 * 0 + 2 * 0;'
    stream.original_string.should == 'x = 3 * 0 + 2 * 0;'
    stream.replace 4, 8, '0'
    stream.render.should == 'x = 0 + 2 * 0;'
    stream.render( 0, 17 ).should == 'x = 0 + 2 * 0;'
    stream.render( 4, 8 ).should  == '0'
    stream.render( 0, 8 ).should  == 'x = 0'
    stream.render( 12, 16 ).should == '2 * 0'
    stream.insert_after( 17, '// comment' )
    stream.render( 12, 17 ).should == '2 * 0;// comment'
    stream.render( 0, 8 ).should == 'x = 0'
  end

end
