#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestProfileMode < ANTLR3::Test::Functional
  compile_options :profile => true
  
  inline_grammar( <<-'END' )
    grammar SimpleC;
    
    options { language = Ruby; }
    
    program
        :   declaration+
        ;
    
    /** In this rule, the functionHeader left prefix on the last two
     *  alternatives is not LL(k) for a fixed k.  However, it is
     *  LL(*).  The LL(*) algorithm simply scans ahead until it sees
     *  either the ';' or the '{' of the block and then it picks
     *  the appropriate alternative.  Lookhead can be arbitrarily
     *  long in theory, but is <=10 in most cases.  Works great.
     *  Use ANTLRWorks to see the lookahead use (step by Location)
     *  and look for blue tokens in the input window pane. :)
     */
    declaration
        :   variable
        |   functionHeader ';'
        |   functionHeader block
        ;
    
    variable
        :   type declarator ';'
        ;
    
    declarator
        :   ID 
        ;
    
    functionHeader
        :   type ID '(' ( formalParameter ( ',' formalParameter )* )? ')'
        ;
    
    formalParameter
        :   type declarator        
        ;
    
    type
        :   'int'   
        |   'char'  
        |   'void'
        |   ID        
        ;
    
    block
        :   '{'
                variable*
                stat*
            '}'
        ;
    
    stat: forStat
        | expr ';'      
        | block
        | assignStat ';'
        | ';'
        ;
    
    forStat
        :   'for' '(' assignStat ';' expr ';' assignStat ')' block        
        ;
    
    assignStat
        :   ID '=' expr        
        ;
    
    expr:   condExpr
        ;
    
    condExpr
        :   aexpr ( ('==' | '<') aexpr )?
        ;
    
    aexpr
        :   atom ( '+' atom )*
        ;
    
    atom
        : ID      
        | INT      
        | '(' expr ')'
        ; 
    
    ID  :   ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
        ;
    
    INT :	('0'..'9')+
        ;
    
    WS  :   (   ' '
            |   '\t'
            |   '\r'
            |   '\n'
            )+
            { $channel=HIDDEN; }
        ;
  END
  
  example 'profile mode output' do
    input = <<-END.fixed_indent( 0 )
      char c;
      int x;
      
      void bar(int x);
      
      int foo(int y, char d) {
        int i;
        for (i=0; i<3; i=i+1) {
          x=3;
          y=5;
        }
      }
    END
    
    lexer = SimpleC::Lexer.new( input )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = SimpleC::Parser.new( tokens )
    parser.program
    
    profile_data = parser.profile
    profile_data.rule_invocations.should == 60
    profile_data.guessing_rule_invocations.should == 0
    profile_data.rule_invocation_depth.should == 12
    
    profile_data.fixed_decisions.should == 40
    fixed_data = profile_data.fixed_looks
    fixed_data.min.should == 1
    fixed_data.max.should == 2
    fixed_data.average.should == 1.075
    fixed_data.standard_deviation.should == 0.26674678283691855
    
    profile_data.cyclic_decisions.should == 4
    cyclic_data = profile_data.cyclic_looks
    cyclic_data.min.should == 3
    cyclic_data.max.should == 10
    cyclic_data.average.should == 5.75
    cyclic_data.standard_deviation.should == 3.4034296427770228
    
    profile_data.syntactic_predicates.should == 0
    
    profile_data.memoization_cache_entries.should == 0
    profile_data.memoization_cache_hits.should == 0
    profile_data.memoization_cache_misses.should == 0
    
    profile_data.semantic_predicates.should == 0
    profile_data.tokens.should == 77
    profile_data.hidden_tokens.should == 24
    profile_data.characters_matched.should == 118
    profile_data.hidden_characters_matched.should == 40
    profile_data.reported_errors.should == 0
  end
  
  
end
