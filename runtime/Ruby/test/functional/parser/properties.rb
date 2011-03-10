#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestRulePropertyReference < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    grammar RuleProperties;
    options { language = Ruby; }
    
    @parser::members {
      def emit_error_message(msg)
        # do nothing
      end
      def report_error(error)
        raise error
      end
    }
    
    @lexer::members {
      def emit_error_message(msg)
        # do nothing
      end
      def report_error(error)
        raise error
      end
    }
    
    a returns [bla]
    @after { $bla = [$start, $stop, $text] }
        : A+
        ;
    
    A: 'a'..'z';
    
    WS: ' '+  { $channel = HIDDEN };
  END
  
  example "accessing rule properties" do
    lexer = RuleProperties::Lexer.new( '   a a a a  ' )
    parser = RuleProperties::Parser.new lexer
    start, stop, text = parser.a.bla
    
    start.index.should == 1
    stop.index.should == 7
    text.should == 'a a a a'
  end


end

class TestLabels < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    grammar Labels;
    options { language = Ruby; }
    
    @parser::members {
      def recover(e)
        raise e
      end
    }
    
    @lexer::members {
      def recover(e)
        raise e
      end
    }
    
    a returns [l]
        : ids+=A ( ',' ids+=(A|B) )* C D w=. ids+=. F EOF
            { $l = [$ids, $w] }
        ;
    
    A: 'a'..'z';
    B: '0'..'9';
    C: a='A' { $a };
    D: a='FOOBAR' { $a };
    E: 'GNU' a=. { $a };
    F: 'BLARZ' a=EOF { $a };
    
    WS: ' '+  { $channel = HIDDEN };
  END
  
  example "parsing 'a, b, c, 1, 2 A FOOBAR GNU1 A BLARZ'" do
    lexer = Labels::Lexer.new 'a, b, c, 1, 2 A FOOBAR GNU1 A BLARZ'
    parser = Labels::Parser.new lexer
    ids, w = parser.a
    
    ids.should have( 6 ).things
    ids[ 0 ].text.should == 'a'
    ids[ 1 ].text.should == 'b'
    ids[ 2 ].text.should == 'c'
    ids[ 3 ].text.should == '1'
    ids[ 4 ].text.should == '2'
    ids[ 5 ].text.should == 'A'
    
    w.text.should == 'GNU1'
  end


end


class TestTokenLabelReference < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    grammar TokenLabels;
    options {
      language = Ruby;
    }
    
    @parser::members {
      def emit_error_message(msg)
        # do nothing
      end
      def report_error(error)
        raise error
      end
    }
    
    @lexer::members {
      def emit_error_message(msg)
        # do nothing
      end
      def report_error(error)
        raise error
      end
    }
    
    a returns [$tk]
      : t=A
          {
            $tk = [
              $t.text,
              $t.type,
              $t.name,
              $t.line,
              $t.pos,
              $t.index,
              $t.channel
            ]
          }
      ;
    
    A: 'a'..'z';
    
    WS  :
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
  
  example "accessing tokens with labels" do
    lexer = TokenLabels::Lexer.new( '   a' )
    parser = TokenLabels::Parser.new lexer
    tk = parser.a
    tk.should == [ 
      'a', TokenLabels::TokenData::A, 'A',
      1, 3, 1, :default
    ]
  end


end

class TestRuleLabelReference < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    grammar RuleLabelReference;
    options {language = Ruby;}
    
    @parser::members {
      def emit_error_message(msg)
        # do nothing
      end
      def report_error(error)
        raise error
      end
    }
    
    @lexer::members {
      def emit_error_message(msg)
        # do nothing
      end
      def report_error(error)
        raise error
      end
    }
    
    a returns [bla]: t=b
            {
                $bla = [$t.start, $t.stop, $t.text]
            }
        ;
    
    b: A+;
    
    A: 'a'..'z';
    
    WS: ' '+  { $channel = HIDDEN };
  END
  
  example "referencing rule properties using rule labels" do
    lexer = RuleLabelReference::Lexer.new( '   a a a a  ' )
    parser = RuleLabelReference::Parser.new lexer
    start, stop, text = parser.a
    
    start.index.should == 1
    stop.index.should == 7
    text.should == 'a a a a'
  end

end



class TestReferenceDoesntSetChannel < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    grammar ReferenceSetChannel;
    options {language=Ruby;}
    a returns [foo]: A EOF { $foo = '\%s, channel=\%p' \% [$A.text, $A.channel]; } ;
    A : '-' WS I ;
    I : '0'..'9'+ ;
    WS: ' ' | '\t';
  END

  example 'verifying that a token reference does not set its channel' do
    lexer = ReferenceSetChannel::Lexer.new( "- 34" )
    parser = ReferenceSetChannel::Parser.new lexer
    parser.a.should == "- 34, channel=:default"
  end

end
