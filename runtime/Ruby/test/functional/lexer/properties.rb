#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestLexerRuleReference < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    lexer grammar RuleProperty;
    options {
      language = Ruby;
    }
    
    @lexer::init {
      @properties = []
    }
    @lexer::members {
      attr_reader :properties
    }
    
    IDENTIFIER: 
            ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
            {
              @properties << [$text, $type, $line, $pos, $index, $channel, $start, $stop]
            }
        ;
    WS: (' ' | '\n')+;
  END

  example "referencing lexer rule properties" do
    lexer = RuleProperty::Lexer.new( "foobar _ab98 \n A12sdf" )
    tokens = lexer.map { |tk| tk }
    
    lexer.properties.should have( 3 ).things
    text, type, line, pos, index, channel, start, stop = lexer.properties[ 0 ]
    text.should == 'foobar'
    type.should == RuleProperty::TokenData::IDENTIFIER
    line.should == 1
    pos.should == 0
    index.should == -1
    channel.should == ANTLR3::DEFAULT_CHANNEL
    start.should == 0
    stop.should == 5
    
    text, type, line, pos, index, channel, start, stop = lexer.properties[ 1 ]
    text.should == '_ab98'
    type.should == RuleProperty::TokenData::IDENTIFIER
    line.should == 1
    pos.should == 7
    index.should == -1
    channel.should == ANTLR3::DEFAULT_CHANNEL
    start.should == 7
    stop.should == 11
    
    lexer.properties.should have( 3 ).things
    text, type, line, pos, index, channel, start, stop = lexer.properties[ 2 ]
    text.should == 'A12sdf'
    type.should == RuleProperty::TokenData::IDENTIFIER
    line.should == 2
    pos.should == 1
    index.should == -1
    channel.should == ANTLR3::DEFAULT_CHANNEL
    start.should == 15
    stop.should == 20
  end


end

class TestLexerRuleLabel < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    lexer grammar LexerRuleLabel;
    options {
      language = Ruby;
    }
    
    @members { attr_reader :token_text }
    
    A: 'a'..'z' WS '0'..'9'
            {
              @token_text = $WS.text
            }
        ;
    
    fragment WS  :
            (   ' '
            |   '\t'
            |  ( '\n'
                |	'\r\n'
                |	'\r'
                )
            )+
            { $channel = HIDDEN }
        ;
  END
  
  example "referencing other token rule values with labels" do
    lexer = LexerRuleLabel::Lexer.new 'a  2'
    lexer.next_token
    lexer.token_text.should == '  '
  end

end
