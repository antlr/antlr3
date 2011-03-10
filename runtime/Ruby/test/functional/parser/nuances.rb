#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestEmptyAlternative < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    grammar EmptyAlt;
    options {
      language = Ruby;
    }
    
    r
      : NAME 
        ( WS+ NAME
        | 
        )
        EOF
      ;
    
    NAME: ('a'..'z') ('a'..'z' | '0'..'9')+;
    NUMBER: ('0'..'9')+;
    WS: ' '+;
  END
  
  example "rule with empty alternative" do
    lexer = EmptyAlt::Lexer.new( 'foo' )
    parser = EmptyAlt::Parser.new lexer
    events = parser.r
  end

end

class TestSubrulePrediction < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    grammar Subrule;
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
    
    a: 'BEGIN' b WS+ 'END';
    b: ( WS+ 'A' )+;
    WS: ' ';
  END
  
  example "make correct predictions involving subrules" do
    lexer = Subrule::Lexer.new( 'BEGIN A END' )
    parser = Subrule::Parser.new lexer
    events = parser.a
  end

end


class TestSpecialStates < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    grammar SpecialStates;
    options { language = Ruby; }
    
    @init { @cond = true }
    
    @members {
      attr_accessor :cond
      def recover(re)
        raise re
      end
    }
    
    r
      : ( { @cond }? NAME
        | {!@cond }? NAME WS+ NAME
        )
        ( WS+ NAME )?
        EOF
      ;
    
    NAME: ('a'..'z') ('a'..'z' | '0'..'9')+;
    NUMBER: ('0'..'9')+;
    WS: ' '+;
  END

  example "parsing 'foo'" do
    lexer  = SpecialStates::Lexer.new 'foo'
    parser = SpecialStates::Parser.new lexer
    parser.r
  end

  example "parsing 'foo name1'"  do
    lexer = SpecialStates::Lexer.new 'foo name1'
    parser = SpecialStates::Parser.new lexer
    parser.r
  end

  example "parsing 'bar name1'"  do
    lexer = SpecialStates::Lexer.new 'bar name1'
    parser = SpecialStates::Parser.new lexer
    parser.cond = false
    parser.r
  end

  example "parsing 'bar name1 name2'" do
    lexer = SpecialStates::Lexer.new 'bar name1 name2'
    parser = SpecialStates::Parser.new lexer
    parser.cond = false
    parser.r
  end
end


class TestDFABug < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    grammar DFABug;
    options {
        language = Ruby;
        output = AST;
    }
    
    
    // this rule used to generate an infinite loop in DFA.predict
    r
    options { backtrack=true; }
        : (modifier+ INT)=> modifier+ expression
        | modifier+ statement
        ;
    
    expression
        : INT '+' INT
        ;
    
    statement
        : 'fooze'
        | 'fooze2'
        ;
    
    modifier
        : 'public'
        | 'private'
        ;
    
    ID : 'a'..'z' + ;
    INT : '0'..'9' +;
    WS: (' ' | '\n' | '\t')+ {$channel = HIDDEN;};
  END

  example "testing for DFA-based decision bug" do
    lexer = DFABug::Lexer.new 'public fooze'
    parser = DFABug::Parser.new lexer
    parser.r
  end
  
end
