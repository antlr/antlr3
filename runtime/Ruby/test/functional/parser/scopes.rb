#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestScopes1 < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    grammar SimpleScope;
    
    options {
        language = Ruby;
    }
    
    prog
    scope {
    name
    }
        :   ID {$prog::name=$ID.text;}
        ;
    
    ID  :   ('a'..'z')+
        ;
    
    WS  :   (' '|'\n'|'\r')+ {$channel=HIDDEN}
        ;
  END
  
  example "parsing 'foobar'" do
    lexer = SimpleScope::Lexer.new( 'foobar' )
    parser = SimpleScope::Parser.new lexer
    parser.prog
  end
end

class TestScopes2 < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    grammar LotsaScopes;
    
    options {
        language = Ruby;
    }
    
    /* global scopes */
    
    scope aScope {
      names;
    }
    
    @members {
      def emit_error_message(msg)
        # do nothing
      end
      
      def report_error(error)
        raise error
      end
    }
    
    a
    scope aScope;
        :   {$aScope::names = []} ID*
        ;
    
    
    /* rule scopes, from the book, final beta, p.147 */
    
    b[v]
    scope {x}
        : {$b::x = v;} b2
        ;
    
    b2
        : b3
        ;
    
    b3 
        : {$b::x}?=> ID // only visible, if b was called with True
        | NUM
        ;
    
    
    /* rule scopes, from the book, final beta, p.148 */
    
    c returns [res]
    scope {
        symbols
    }
    @init {
        $c::symbols = Set.new;
    }
        : '{' c1* c2+ '}'
            { $res = $c::symbols; }
        ;
    
    c1
        : 'int' ID {$c::symbols.add($ID.text)} ';'
        ;
    
    c2
        : ID '=' NUM ';'
            {
                $c::symbols.include?($ID.text) or raise RuntimeError, $ID.text
             }
        ;
    
    /* recursive rule scopes, from the book, final beta, p.150 */
    
    d returns [res]
    scope {
        symbols
    }
    @init {
        $d::symbols = Set.new
    }
        : '{' d1* d2* '}'
            { $res = $d::symbols; }
        ;
    
    d1
        : 'int' ID {$d::symbols.add($ID.text)} ';'
        ;
    
    d2
        : ID '=' NUM ';'
            {
              catch(:found) do
                level = ($d.length - 1).downto(0) do |s|
                  $d[s].symbols.include?($ID.text) and throw(:found)
                end
                raise $ID.text
              end
            }
        | d
        ;
    
    /* recursive rule scopes, access bottom-most scope */
    
    e returns [res]
    scope {
        a
    }
    @after {
        $res = $e::a;
    }
        : NUM { $e[0]::a = Integer($NUM.text); }
        | '{' e '}'
        ;
    
    
    /* recursive rule scopes, access with negative index */
    
    f returns [res]
    scope {
        a
    }
    @after {
        $res = $f::a;
    }
        : NUM { $f[-2]::a = Integer($NUM.text); }
        | '{' f '}'
        ;
    
    
    /* tokens */
    
    ID  :   ('a'..'z')+
        ;
    
    NUM :   ('0'..'9')+
        ;
    
    WS  :   (' '|'\n'|'\r')+ {$channel=HIDDEN}
        ;
  END

  example "parsing 'foobar' with rule a" do
    lexer = LotsaScopes::Lexer.new( "foobar" )
    parser = LotsaScopes::Parser.new lexer
    parser.a
  end
  
  example "failing to parse 'foobar' with rule b[false]" do
    lexer = LotsaScopes::Lexer.new( "foobar" )
    parser = LotsaScopes::Parser.new lexer
    proc { parser.b( false ) }.should raise_error( ANTLR3::RecognitionError )
  end
  
  example "parsing 'foobar' with rule b[true]" do
    lexer = LotsaScopes::Lexer.new( "foobar" )
    parser = LotsaScopes::Parser.new lexer
    parser.b( true )
  end
  
  example "parsing a decl block with rule c" do
    lexer = LotsaScopes::Lexer.new( <<-END.here_indent! )
    | {
    |     int i;
    |     int j;
    |     i = 0;
    | }
    END
    parser = LotsaScopes::Parser.new lexer

    symbols = parser.c
    symbols.should have( 2 ).things
    symbols.should include 'i'
    symbols.should include 'j'
  end
  
  example "failing to parse undeclared symbols with rule c" do
    lexer = LotsaScopes::Lexer.new( <<-END.here_indent! )
    | {
    |     int i;
    |     int j;
    |     i = 0;
    |     x = 4;
    | }
    END
    parser = LotsaScopes::Parser.new lexer

    proc { parser.c }.should raise_error RuntimeError, 'x'
  end
  
  example "parsing nested declaration blocks" do
    lexer = LotsaScopes::Lexer.new( <<-END.here_indent! )
    | {
    |     int i;
    |     int j;
    |     i = 0;
    |     {
    |        int i;
    |        int x;
    |        x = 5;
    |     }
    | }
    END
    parser = LotsaScopes::Parser.new lexer

    symbols = parser.d 
    symbols.should have( 2 ).things
    symbols.should include 'i'
    symbols.should include 'j'
  end
  
  example "parsing a deeply nested set of blocks with rule e" do
    lexer = LotsaScopes::Lexer.new( <<-END.here_indent! )
    | { { { { 12 } } } }
    END

    parser = LotsaScopes::Parser.new lexer
    parser.e.should == 12
  end
  
  example "parsing a deeply nested set of blocks with rule f" do
    lexer = LotsaScopes::Lexer.new( <<-END.here_indent! )
    | { { { { 12 } } } }
    END

    parser = LotsaScopes::Parser.new lexer
    parser.f.should == nil
  end
  
  example "parsing a 2-level nested set of blocks with rule f" do
    lexer = LotsaScopes::Lexer.new( <<-END.here_indent! )
    | { { 12 } }
    END
    parser = LotsaScopes::Parser.new lexer

    parser.f.should == nil
  end

end
