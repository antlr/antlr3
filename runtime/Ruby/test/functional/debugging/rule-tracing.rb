#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestRuleTracing < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    grammar Traced;
    options {
      language = Ruby;
    }
    
    @parser::init {
      @stack = nil
      @traces = []
    }
    
    @parser::members {
      attr_accessor :stack, :traces
      
      def trace_in(rule_name, rule_index)
        @traces << ">#{rule_name}"
      end
      
      def trace_out(rule_name, rule_index)
        @traces << "<#{rule_name}"
      end
    }
    
    @lexer::init {
      @stack = nil
      @traces = []
    }
    
    @lexer::members {
      attr_accessor :stack, :traces
      
      def trace_in(rule_name, rule_index)
        @traces << ">#{rule_name}"
      end
      
      def trace_out(rule_name, rule_index)
        @traces << "<#{rule_name}"
      end
    }
    
    a: '<' ((INT '+')=>b|c) '>';
    b: c ('+' c)*;
    c: INT ;
    
    INT: ('0'..'9')+;
    WS: (' ' | '\n' | '\t')+ {$channel = HIDDEN;};
  END

  compile_options :trace => true
  
  example "setting up rule tracing" do
    lexer = Traced::Lexer.new( '< 1 + 2 + 3 >' )
    parser = Traced::Parser.new lexer
    parser.a
    lexer.traces.should == [ 
            '>t__6!', '<t__6!', '>ws!', '<ws!', '>int!', '<int!', '>ws!', '<ws!',
            '>t__8!', '<t__8!', '>ws!', '<ws!', '>int!', '<int!', '>ws!', '<ws!',
            '>t__8!', '<t__8!', '>ws!', '<ws!', '>int!', '<int!', '>ws!', '<ws!',
            '>t__7!', '<t__7!'
    ]
    parser.traces.should == [ 
      '>a', '>synpred1_Traced', '<synpred1_Traced',
      '>b', '>c', '<c', '>c', '<c', '>c', '<c', '<b', '<a'
    ]
  end
end
