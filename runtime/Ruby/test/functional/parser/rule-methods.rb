#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestParameters < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    grammar Parameters;
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
    
    a[arg1, arg2] returns [l]
        : A+ EOF
            { 
                l = [$arg1, $arg2]
                $arg1 = "gnarz"
            }
        ;
    
    A: 'a'..'z';
    
    WS: ' '+  { $channel = HIDDEN };
  END
  
  example "rules with method parameters" do
    lexer = Parameters::Lexer.new( 'a a a' )
    parser = Parameters::Parser.new lexer
    r = parser.a( 'foo', 'bar' )
    r.should == %w(foo bar)
  end

end


class TestMultipleReturnValues < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    grammar MultipleReturnValues;
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
    
    a returns [foo, bar]: A
            {
                $foo = "foo";
                $bar = "bar";
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
  
  example "multi-valued rule return structures" do
    lexer = MultipleReturnValues::Lexer.new( '   a' )
    parser = MultipleReturnValues::Parser.new lexer
    ret = parser.a
    
    ret.foo.should == 'foo'
    ret.bar.should == 'bar'
  end
  
end


class TestRuleVisibility < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    grammar RuleVisibility;
    options { language=Ruby; }
    
    public a: ID;
    private b: DIGIT;
    protected c: ID DIGIT;
    
    DIGIT: ('0'..'9')+;
    ID: ('a'..'z' | 'A'..'Z')+;
    WS: (' ' | '\t' | '\n' | '\r' | '\f')+ { $channel=HIDDEN; };
  END
  
  example 'using visibility modifiers on rules' do
    mname = RUBY_VERSION =~ /^1\.9/ ? proc { | n | n.to_sym } : proc { | n | n.to_s }
    
    RuleVisibility::Parser.public_instance_methods.should include( mname[ 'a' ] )
    RuleVisibility::Parser.protected_instance_methods.should include( mname[ 'c' ] )
    RuleVisibility::Parser.private_instance_methods.should include( mname[ 'b' ] )
  end

end
