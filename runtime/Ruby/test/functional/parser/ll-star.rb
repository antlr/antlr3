#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestLLStarParser < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    grammar LLStar;
    
    options { language = Ruby; }
    @header {  require 'stringio' }
    @init { @output = StringIO.new() }
    @members {
      def output
        @output.string
      end
    }
    
    program
        :   declaration+
        ;
    
    /** In this rule, the functionHeader left prefix on the last two
     *  alternatives is not LL(k) for a fixed k.  However, it is
     *  LL(*).  The LL(*) algorithm simply scans ahead until it sees
     *  either the ';' or the '{' of the block and then it picks
     *  the appropriate alternative.  Lookhead can be arbitrarily
     *  long in theory, but is <=10 in most cases.  Works great.
     *  Use ANTLRWorks to see the look use (step by Location)
     *  and look for blue tokens in the input window pane. :)
     */
    declaration
        :   variable
        |   functionHeader ';'
      { @output.puts( $functionHeader.name + " is a declaration") }
        |   functionHeader block
      { @output.puts( $functionHeader.name + " is a definition") }
        ;
    
    variable
        :   type declarator ';'
        ;
    
    declarator
        :   ID 
        ;
    
    functionHeader returns [name]
        :   type ID '(' ( formalParameter ( ',' formalParameter )* )? ')'
      {$name = $ID.text}
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
            {$channel=HIDDEN}
        ;
  END
  
  
  example "parsing with a LL(*) grammar" do
    lexer = LLStar::Lexer.new( <<-'END'.fixed_indent( 0 ) )
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
    parser = LLStar::Parser.new lexer
    
    parser.program
    parser.output.should == <<-'END'.fixed_indent( 0 )
      bar is a declaration
      foo is a definition
    END
  end
  
end
