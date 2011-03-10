#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestPredicateHoist < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    grammar TestHoist;
    options {
        language = Ruby;
    }
    
    /* With this true, enum is seen as a keyword.  False, it's an identifier */
    @parser::init {
      @enable_enum = false
    }
    @members {
      attr_accessor :enable_enum
    }
    
    stat returns [enumIs]
        : identifier    {$enumIs = "ID"}
        | enumAsKeyword {$enumIs = "keyword"}
        ;
    
    identifier
        : ID
        | enumAsID
        ;
    
    enumAsKeyword : {@enable_enum}? 'enum' ;
    
    enumAsID : {!@enable_enum}? 'enum' ;
    
    ID  :   ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
        ;
    
    INT :	('0'..'9')+
        ;
    
    WS  :   (   ' '
            |   '\t'
            |   '\r'
            |   '\n'
            )+
            {$channel=HIDDEN}
        ;
  END
  
  
  example "'enum' is a keyword" do
    lexer = TestHoist::Lexer.new 'enum'
    parser = TestHoist::Parser.new lexer
    parser.enable_enum = true
    parser.stat.should == 'keyword'
  end
  
  example "'enum' is an ID" do
    lexer = TestHoist::Lexer.new 'enum'
    parser = TestHoist::Parser.new lexer
    parser.enable_enum = false
    parser.stat.should == 'ID'
  end
  
end


class TestSyntacticPredicate < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    grammar SyntacticPredicate;
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
    
    a: ((s+ P)=> s+ b)? E;
    b: P 'foo';
    
    s: S;
    
    
    S: ' ';
    P: '+';
    E: '>';
  END
  
  example "rule with syntactic predicate" do
    lexer = SyntacticPredicate::Lexer.new( '   +foo>' )
    parser = SyntacticPredicate::Parser.new lexer
    events = parser.a
  end
end
