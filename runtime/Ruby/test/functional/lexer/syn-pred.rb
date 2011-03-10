#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestSyntacticPredicate < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    lexer grammar SyntacticPredicateGate;
    options {
      language = Ruby;
    }
    
    FOO
      : ('ab')=> A
      | ('ac')=> B
      ;
    
    fragment
    A: 'a';
    
    fragment
    B: 'a';
  END

  example 'gating syntactic predicate rule' do
    lexer = SyntacticPredicateGate::Lexer.new( 'ac' )
    token = lexer.next_token
  end


end
