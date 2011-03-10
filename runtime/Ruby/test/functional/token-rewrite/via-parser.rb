#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestRewritingWhileParsing < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    grammar TokenRewrites;
    options { language = Ruby; }
    
    program
    @after {
      @input.insert_before($start,"public class Wrapper {\n")
      @input.insert_after($stop, "\n}\n")
    }
        :   method+
        ;
    
    method
        :   m='method' ID '(' ')' body
            {@input.replace($m, "public void");}
        ; 
    
    body
    scope {
        decls
    }
    @init {
        $body::decls = []
    }
        :   lcurly='{' stat* '}'
            {
            $body::decls.uniq!
            for it in $body::decls
              @input.insert_after($lcurly, "\nint "+it+";")
            end
            }
        ;
    
    stat:   ID '=' expr ';' {$body::decls << $ID.text.to_s}
        ;
    
    expr:   mul ('+' mul)* 
        ;
    
    mul :   atom ('*' atom)*
        ;
    
    atom:   ID
        |   INT
        ;
    
    ID  :   ('a'..'z'|'A'..'Z')+ ;
    
    INT :   ('0'..'9')+ ;
    
    WS  :   (' '|'\t'|'\n')+ {$channel=HIDDEN;}
        ;
  END

  example 'using a TokenRewriteStream to rewrite input text while parsing' do
    input = <<-END.fixed_indent( 0 )
      method foo() {
        i = 3;
        k = i;
        i = k*4;
      }
      
      method bar() {
        j = i*2;
      }
    END
    expected_output = <<-END.fixed_indent( 0 ).strip!
      public class Wrapper {
      public void foo() {
      int k;
      int i;
        i = 3;
        k = i;
        i = k*4;
      }
      
      public void bar() {
      int j;
        j = i*2;
      }
      }
    END
    
    lexer = TokenRewrites::Lexer.new( input )
    tokens = ANTLR3::TokenRewriteStream.new( lexer )
    parser = TokenRewrites::Parser.new( tokens )
    parser.program
    
    tokens.render.strip.should == expected_output
  end

end
