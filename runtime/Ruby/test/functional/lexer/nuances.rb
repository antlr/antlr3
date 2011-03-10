#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestBug80 < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    lexer grammar Bug80;
    options { language = Ruby; }
     
    ID_LIKE
        : 'defined' 
        | {false}? Identifier 
        | Identifier 
        ; 
     
    fragment
    // with just 'a', output compiles
    Identifier: 'a'..'z'+ ;
  END
  
  example "um... something" do
    lexer = Bug80::Lexer.new( 'defined' )
    tokens = lexer.each { |tk| tk }
  end
end


class TestEOF < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    lexer grammar EndOfFile;
    
    options {
      language = Ruby;
    }
    
    KEND: EOF;
    SPACE: ' ';
  END
  
  example 'referencing EOF in a rule' do
    lexer = EndOfFile::Lexer.new( " " )
    tks = lexer.map { |tk| tk }
  end
end
