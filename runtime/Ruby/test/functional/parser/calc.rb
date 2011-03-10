#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestCalcParser < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    grammar TestCalc;
    options { language = Ruby; }
    
    @parser::init {
      @reported_errors = []
    }
    
    @parser::members {
      attr_reader :reported_errors
      
      def emit_error_message(msg)
        @reported_errors << msg
      end
    }
    
    evaluate returns [result]: r=expression { $result = $r.result };
    
    expression returns [result]:
               r=mult { $result = $r.result }
        (
          '+' r2=mult { $result += $r2.result }
        | '-' r2=mult { $result -= $r2.result }
        )*
        ;
    
    mult returns [result]:
               r=log { $result = $r.result }
        (
          '*' r2=log {$result *= $r2.result}
        | '/' r2=log {$result /= $r2.result}
        | '%' r2=log {$result \%= $r2.result}
        )*
        ;
    
    log returns [result]: 'ln' r=exp {$result = Math.log($r.result)}
        | r=exp {$result = $r.result}
        ;
    
    exp returns [result]: r=atom { $result = $r.result } ('^' r2=atom { $result **= $r2.result } )?
        ;
    
    atom returns [result]:
        n=INTEGER {$result = Integer($n.text)}
      | n=DECIMAL {$result = Float($n.text)} 
      | '(' r=expression {$result = $r.result} ')'
      | 'PI' {$result = Math::PI}
      | 'E' {$result = Math::E}
      ;
    
    INTEGER: DIGIT+;
    
    DECIMAL: DIGIT+ '.' DIGIT+;
    
    fragment
    DIGIT: '0'..'9';
    
    WS: (' ' | '\n' | '\t')+ {$channel = HIDDEN};
  END
  
  def evaluate( expression )
    lexer  = TestCalc::Lexer.new( expression )
    parser = TestCalc::Parser.new lexer
    value = parser.evaluate
    errors = parser.reported_errors
    return [ value, errors ]
  end
  
  tests = %[
    1 + 2            = 3
    1 + 2 * 3        = 7
    10 / 2           = 5
    6 + 2*(3+1) - 4  = 10
  ].strip!.split( /\n/ ).map { |line| 
    expr, val = line.strip.split( /\s+=\s+/, 2 )
    [ expr, Integer( val ) ]
  }
  
  tests.each do |expression, true_value|
    example "should parse '#{ expression }'" do
      parser_value, errors = evaluate( expression )
      parser_value.should == true_value
    end
  end
  
  example "badly formed input" do
    val, errors = evaluate "6 - (2*1"
    
    errors.should have( 1 ).thing
    errors.first.should =~ /mismatched/
  end
end
