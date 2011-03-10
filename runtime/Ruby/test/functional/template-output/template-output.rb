#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestTemplateOutput < ANTLR3::Test::Functional
  
  def parse( grammar, input, options = nil )
    @grammar = inline_grammar( grammar )
    compile_and_load( @grammar )
    grammar_module = self.class.const_get( @grammar.name )
    
    parser_options = {}
    if options
      rule = options.fetch( :rule ) { grammar_module::Parser.default_rule }
      group = options[ :templates ] and parser_options[ :templates ] = group
    else
      rule = grammar_module::Parser.default_rule
    end
    
    @lexer  = grammar_module::Lexer.new( input )
    @parser = grammar_module::Parser.new( @lexer, parser_options )
    
    out = @parser.send( rule ).template
    return( out ? out.to_s : out )
  end
  
  def parse_templates( source )
    ANTLR3::Template::Group.parse( source.fixed_indent( 0 ) )
  end
  
  
  example 'inline templates' do
    text = parse( <<-'END', "abc 34" )
      grammar InlineTemplates;
      options {
        language = Ruby;
        output = template;
      }
      
      a : ID INT
        -> template(id={$ID.text}, int={$INT.text})
           "id=<%= @id %>, int=<%= @int %>"
      ;
      
      ID : 'a'..'z'+;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    
    text.should == "id=abc, int=34"
  end
  
  example 'external template' do
    templates = ANTLR3::Template::Group.new do
      define_template( :expr, <<-'END'.strip )
        [<%= @args.join( @op.to_s ) %>]
      END
    end
    
    text = parse( <<-'END', 'a + b', :templates => templates )
      grammar ExternalTemplate;
      options {
        language = Ruby;
        output = template;
      }
      
      a : r+=arg OP r+=arg
        -> expr( op={$OP.text}, args={$r} )
      ;
      arg: ID -> template(t={$ID.text}) "<%= @t %>";
      
      ID : 'a'..'z'+;
      OP: '+';
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    
    text.should == '[a+b]'
  end

  example "empty template" do
    text = parse( <<-'END', 'abc 34' )
      grammar EmptyTemplate;
      options {
        language=Ruby;
        output=template;
      }
      a : ID INT
        -> 
      ;
      
      ID : 'a'..'z'+;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
      
    END
    text.should be_nil
  end
  
  example "list" do
    text = parse( <<-'END', "abc def ghi" )
      grammar List;
      options {
        language=Ruby;
        output=template;
      }
      a: (r+=b)* EOF
        -> template(r={$r}) "<%= @r.join(',') %>"
      ;
      
      b: ID
        -> template(t={$ID.text}) "<%= @t %>"
      ;
      
      ID : 'a'..'z'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    text.should == 'abc,def,ghi'
  end
  
  example 'action' do
    text = parse( <<-'END', "abc" )
      grammar Action;
      options {
        language=Ruby;
        output=template;
      }
      a: ID
        -> { create_template( "hello" ) }
      ;
      
      ID : 'a'..'z'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    
    text.should == 'hello'
  end
  
  example "template expression in action" do
    text = parse( <<-'END', 'abc' )
      grammar TemplateExpressionInAction;
      options {
        language=Ruby;
        output=template;
      }
      a: ID
        { $st = %{"hello"} }
      ;
      
      ID : 'a'..'z'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    text.should == 'hello'
  end
  
  #example "template expression in action2" do
  #  text = parse( <<-'END', 'abc' )
  #    grammar TemplateExpressionInAction2;
  #    options {
  #      language=Ruby;
  #      output=template;
  #    }
  #    a: ID
  #      {
  #        res = %{"hello <%= @foo %>"}
  #        %res.foo = "world";
  #      }
  #      -> { res }
  #    ;
  #    
  #    ID : 'a'..'z'+;
  #    WS : (' '|'\n') {$channel=HIDDEN;} ;
  #  END
  #  
  #  text.should == 'hello world'
  #end
  
  example "indirect template constructor" do
    templates = ANTLR3::Template::Group.new do
      define_template( :expr, <<-'END'.strip )
        [<%= @args.join( @op.to_s ) %>]
      END
    end
    
    text = parse( <<-'END', 'abc', :templates => templates )
      grammar IndirectTemplateConstructor;
      options {
        language=Ruby;
        output=template;
      }
      
      a: ID
        {
          $st = %({"expr"})(args={[1, 2, 3]}, op={"+"})
        }
      ;
      
      ID : 'a'..'z'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    
    text.should == '[1+2+3]'
  end
  
  example "predicates" do
    text = parse( <<-'END', 'b 34' )
      grammar Predicates;
      options {
        language=Ruby;
        output=template;
      }
      a : ID INT
        -> {$ID.text=='a'}? template(int={$INT.text})
                            "A: <%= @int %>"
        -> {$ID.text=='b'}? template(int={$INT.text})
                            "B: <%= @int %>"
        ->                  template(int={$INT.text})
                            "C: <%= @int %>"
      ;
      
      ID : 'a'..'z'+;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    
    text.should == 'B: 34'
  end
  
  example "backtracking mode" do
    text = parse( <<-'END', 'abc 34' )
      grammar BacktrackingMode;
      options {
        language=Ruby;
        output=template;
        backtrack=true;
      }
      a : (ID INT)=> ID INT
        -> template(id={$ID.text}, int={$INT.text})
           "id=<%= @id %>, int=<%= @int %>"
      ;
      
      ID : 'a'..'z'+;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    
    text.should == "id=abc, int=34"
  end
  
  example "rewrite" do
    input = <<-'END'.here_indent!
    | if ( foo ) {
    |   b = /* bla */ 2;
    |   return 1 /* foo */;
    | }
    | 
    | /* gnurz */
    | return 12;
    END
    expected = <<-'END'.here_indent!
    | if ( foo ) {
    |   b = /* bla */ 2;
    |   return boom(1) /* foo */;
    | }
    | 
    | /* gnurz */
    | return boom(12);
    END
    
    parse( <<-'END', input )
      grammar Rewrite;
      options {
        language=Ruby;
        output=template;
        rewrite=true;
      }
      
      prog: stat+;
      
      stat
          : 'if' '(' expr ')' stat
          | 'return' return_expr ';'
          | '{' stat* '}'
          | ID '=' expr ';'
          ;
      
      return_expr
          : expr
            -> template(t={$text}) <<boom(<%= @t %>)>>
          ;
          
      expr
          : ID
          | INT
          ;
          
      ID:  'a'..'z'+;
      INT: '0'..'9'+;
      WS: (' '|'\n')+ {$channel=HIDDEN;} ;
      COMMENT: '/*' (options {greedy=false;} : .)* '*/' {$channel = HIDDEN;} ;
    END
    
    @parser.input.render.should == expected
  end
  
  example "tree rewrite" do
    input = <<-'END'.here_indent!
    | if ( foo ) {
    |   b = /* bla */ 2;
    |   return 1 /* foo */;
    | }
    | 
    | /* gnurz */
    | return 12;
    END
    expected = <<-'END'.here_indent!
    | if ( foo ) {
    |   b = /* bla */ 2;
    |   return boom(1) /* foo */;
    | }
    | 
    | /* gnurz */
    | return boom(12);
    END
    
    compile_and_load( inline_grammar( <<-'END' ) )
      grammar TreeRewrite;
      options {
        language=Ruby;
        output=AST;
      }
      
      tokens {
        BLOCK;
        ASSIGN;
      }
      
      prog: stat+;
      
      stat
          : IF '(' e=expr ')' s=stat
            -> ^(IF $e $s)
          | RETURN expr ';'
            -> ^(RETURN expr)
          | '{' stat* '}'
            -> ^(BLOCK stat*)
          | ID '=' expr ';'
            -> ^(ASSIGN ID expr)
          ;
          
      expr
          : ID
          | INT
          ;
      
      IF: 'if';
      RETURN: 'return';
      ID:  'a'..'z'+;
      INT: '0'..'9'+;
      WS: (' '|'\n')+ {$channel=HIDDEN;} ;
      COMMENT: '/*' (options {greedy=false;} : .)* '*/' {$channel = HIDDEN;} ;
    END
    
    compile_and_load( inline_grammar( <<-'END' ) )
      tree grammar TreeRewriteTG;
      options {
        language=Ruby;
        tokenVocab=TreeRewrite;
        ASTLabelType=CommonTree;
        output=template;
        rewrite=true;
      }
      
      prog: stat+;
      
      stat
          : ^(IF expr stat)
          | ^(RETURN return_expr)                
          | ^(BLOCK stat*)                
          | ^(ASSIGN ID expr)
          ;
      
      return_expr
          : expr
            -> template(t={$text}) <<boom(<%= @t %>)>>
          ;
      
      expr
          : ID
          | INT
          ;
    END
    
    lexer = TreeRewrite::Lexer.new( input )
    tokens = ANTLR3::TokenRewriteStream.new( lexer )
    parser = TreeRewrite::Parser.new( tokens )
    tree = parser.prog.tree
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( tree )
    nodes.token_stream = tokens
    tree_parser = TreeRewriteTG::TreeParser.new( nodes )
    tree_parser.prog
    tokens.render.should == expected
  end
end
