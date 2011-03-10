#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'


class TestHeterogeneousNodeTypes < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    grammar VToken;
    options {
        language=Ruby;
        output=AST;
    }
    @members {
      class V < ANTLR3::CommonTree
        def to_s
          return @token.text + "<V>"
        end
      end
    }
    a : ID<V> ;
    ID : 'a'..'z'+ ;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END


  inline_grammar( <<-'END' )
    grammar TokenWithQualifiedType;
    options {
        language=Ruby;
        output=AST;
    }
    @members {
      class V < ANTLR3::CommonTree
        def to_s
          return @token.text + "<V>"
        end
      end
    }
    a : ID<TokenWithQualifiedType.Parser.V> ;
    ID : 'a'..'z'+ ;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END


  inline_grammar( <<-'END' )
    grammar TokenWithLabel;
    options {
        language=Ruby;
        output=AST;
    }
    @members {
    class V < ANTLR3::CommonTree
      def to_s
        return @token.text + "<V>"
      end
    end
    }
    a : x=ID<V> ;
    ID : 'a'..'z'+ ;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END


  inline_grammar( <<-'END' )
    grammar TokenWithListLabel;
    options {
        language=Ruby;
        output=AST;
    }
    @members {
      class V < ANTLR3::CommonTree
        def to_s
          return @token.text + "<V>"
        end
      end
    }
    a : x+=ID<V> ;
    ID : 'a'..'z'+ ;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END


  inline_grammar( <<-'END' )
    grammar TokenRoot;
    options {
        language=Ruby;
        output=AST;
    }
    @members {
      class V < ANTLR3::CommonTree
        def to_s
          return @token.text + "<V>"
        end
      end
    
    }
    a : ID<V>^ ;
    ID : 'a'..'z'+ ;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END


  inline_grammar( <<-'END' )
    grammar TokenRootWithListLabel;
    options {
        language=Ruby;
        output=AST;
    }
    @members {
      class V < ANTLR3::CommonTree
        def to_s
          return @token.text + "<V>"
        end
      end
    
    }
    a : x+=ID<V>^ ;
    ID : 'a'..'z'+ ;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END


  inline_grammar( <<-'END' )
    grammar FromString;
    options {
        language=Ruby;
        output=AST;
    }
    @members {
      class V < ANTLR3::CommonTree
        def to_s
          return @token.text + "<V>"
        end
      end
    
    }
    a : 'begin'<V> ;
    ID : 'a'..'z'+ ;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END


  inline_grammar( <<-'END' )
    grammar StringRoot;
    options {
        language=Ruby;
        output=AST;
    }
    @members {
      class V < ANTLR3::CommonTree
        def to_s
          return @token.text + "<V>"
        end
      end
    
    }
    a : 'begin'<V>^ ;
    ID : 'a'..'z'+ ;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END


  inline_grammar( <<-'END' )
    grammar RewriteToken;
    options {
        language=Ruby;
        output=AST;
    }
    @members {
      class V < ANTLR3::CommonTree
        def to_s
          return @token.text + "<V>"
        end
      end
    
    }
    a : ID -> ID<V> ;
    ID : 'a'..'z'+ ;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END


  inline_grammar( <<-'END' )
    grammar RewriteTokenWithArgs;
    options {
        language=Ruby;
        output=AST;
    }
    @members {
      class V < ANTLR3::CommonTree
        def initialize(*args)
          case args.length
          when 4
            ttype, @x, @y, @z = args
            token = ANTLR3::CommonToken.new(ttype, nil, '')
          when 3
            ttype, token, @x = args
            @y = @z = 0
          else raise ArgumentError, "invalid number of arguments: #{args.length} for 3-4"
          end
          super(token)
        end
        
        def to_s
          (@token.text.to_s rescue '') << "<V>;\%d\%d\%d" \% [@x, @y, @z]
        end
      end
    
    }
    a : ID -> ID<V>[42,19,30] ID<V>[$ID,99];
    ID : 'a'..'z'+ ;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END


  inline_grammar( <<-'END' )
    grammar RewriteTokenRoot;
    options {
        language=Ruby;
        output=AST;
    }
    @members {
      class V < ANTLR3::CommonTree
        def to_s
          return @token.text + "<V>"
        end
      end
    
    }
    a : ID INT -> ^(ID<V> INT) ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+ ;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END


  inline_grammar( <<-'END' )
    grammar RewriteString;
    options {
        language=Ruby;
        output=AST;
    }
    @members {
      class V < ANTLR3::CommonTree
        def to_s
          return @token.text + "<V>"
        end
      end
    
    }
    a : 'begin' -> 'begin'<V> ;
    ID : 'a'..'z'+ ;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END


  inline_grammar( <<-'END' )
    grammar RewriteStringRoot;
    options {
        language=Ruby;
        output=AST;
    }
    @members {
      class V < ANTLR3::CommonTree
        def to_s
          return @token.text + "<V>"
        end
      end
    
    }
    a : 'begin' INT -> ^('begin'<V> INT) ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+ ;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END


  inline_grammar( <<-'END' )
    grammar RewriteRuleResults;
    options {
        language=Ruby;
        output=AST;
    }
    tokens {LIST;}
    @members {
      class V < ANTLR3::CommonTree
        def to_s
          return @token.text + "<V>"
        end
      end
      class W < ANTLR3::CommonTree
        def initialize(tok, text)
          tok.text = text
          super(tok)
        end
        def to_s
          return @token.text + "<W>"
        end
      end
    
    }
    a : id (',' id)* -> ^(LIST<W>["LIST"] id+);
    id : ID -> ID<V>;
    ID : 'a'..'z'+ ;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END


  inline_grammar( <<-'END' )
    grammar CopySemanticsWithHetero;
    options {
        language=Ruby;
        output=AST;
    }
    @members {
      class V < ANTLR3::CommonTree
        def dup_node
          return V.new(self)
        end
        def to_s
          return @token.text + "<V>"
        end
      end
    }
    a : type ID (',' ID)* ';' -> ^(type ID)+;
    type : 'int'<V> ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\\n') {$channel=HIDDEN;} ;
  END


  inline_grammar( <<-'END' )
    grammar TreeParserRewriteFlatList;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID INT;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END


  inline_grammar( <<-'END' )
    tree grammar TreeParserRewriteFlatListWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=TreeParserRewriteFlatList;
    }
    @members {
      class V < ANTLR3::CommonTree
        def to_s
          return @token.text + "<V>"
        end
      end
      class W < ANTLR3::CommonTree
        def to_s
          return @token.text + "<W>"
        end
      end
    }
    a : ID INT -> INT<V> ID<W>
      ;
  END


  inline_grammar( <<-'END' )
    grammar TreeParserRewriteTree;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID INT;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END


  inline_grammar( <<-'END' )
    tree grammar TreeParserRewriteTreeWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=TreeParserRewriteTree;
    }
    @members {
      class V < ANTLR3::CommonTree
        def to_s
          return @token.text + "<V>"
        end
      end
    
      class W < ANTLR3::CommonTree
        def to_s
          return @token.text + "<W>"
        end
      end      
    }
    a : ID INT -> ^(INT<V> ID<W>)
      ;
  END


  inline_grammar( <<-'END' )
    grammar TreeParserRewriteImaginary;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END


  inline_grammar( <<-'END' )
    tree grammar TreeParserRewriteImaginaryWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=TreeParserRewriteImaginary;
    }
    tokens { ROOT; }
    @members {
      class V < ANTLR3::CommonTree
        def to_s
          return @token.name + "<V>"
        end
      end
    }
    a : ID -> ROOT<V> ID
      ;
  END


  inline_grammar( <<-'END' )
    grammar TreeParserRewriteImaginaryWithArgs;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END


  inline_grammar( <<-'END' )
    tree grammar TreeParserRewriteImaginaryWithArgsWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=TreeParserRewriteImaginaryWithArgs;
    }
    tokens { ROOT; }
    @members {
      class V < ANTLR3::CommonTree
        def initialize(token_type, x)
          super(token_type)
          @x = x
        end
        def to_s
          return @token.name + "<V>;#@x"
        end
      end
    }
    a : ID -> ROOT<V>[42] ID
      ;
  END


  inline_grammar( <<-'END' )
    grammar TreeParserRewriteImaginaryRoot;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END


  inline_grammar( <<-'END' )
    tree grammar TreeParserRewriteImaginaryRootWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=TreeParserRewriteImaginaryRoot;
    }
    tokens { ROOT; }
    @members {
      class V < ANTLR3::CommonTree
        def to_s
          return @token.name + "<V>"
        end
      end
    }
    a : ID -> ^(ROOT<V> ID)
      ;
  END


  inline_grammar( <<-'END' )
    grammar TreeParserRewriteImaginaryFromReal;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END


  inline_grammar( <<-'END' )
    tree grammar TreeParserRewriteImaginaryFromRealWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=TreeParserRewriteImaginaryFromReal;
    }
    tokens { ROOT; }
    @members {
      class V < ANTLR3::CommonTree
        def initialize(token, tree = nil)
          if tree.nil? then super(token)
          else
            super(tree)
            @token = TokenData::Token.from_token(@token)
            @token.type = token.type
          end
        end
        def to_s
          return @token.name + "<V>@" + @token.line.to_s
        end
      end
    }
    a : ID -> ROOT<V>[$ID]
      ;
  END


  inline_grammar( <<-'END' )
    grammar TreeParserAutoHeteroAST;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID ';' ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END


  inline_grammar( <<-'END' )
    tree grammar TreeParserAutoHeteroASTWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=TreeParserAutoHeteroAST;
    }
    tokens { ROOT; }
    @members {
      class V < ANTLR3::CommonTree
        def to_s
          return @token.text + "<V>"
        end
      end
    }
    
    a : ID<V> ';'<V>;
  END

  def parse( grammar_name, grammar_rule, input )
    grammar_module = self.class.const_get( grammar_name.to_s )
    lexer  = grammar_module::Lexer.new( input )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = grammar_module::Parser.new( tokens )
    r = parser.send( grammar_rule )
    
    return( r.tree.inspect rescue '' )
  end
  
  def tree_parse( grammar_name, grammar_rule, tree_grammar_rule, input )
    grammar_module = self.class.const_get( grammar_name.to_s )
    tree_grammar_module = self.class.const_get( grammar_name.to_s + 'Walker' )
    
    lexer  = grammar_module::Lexer.new( input )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = grammar_module::Parser.new( tokens )
    r = parser.send( grammar_rule )
    
    nodes = ANTLR3::CommonTreeNodeStream.new( r.tree )
    nodes.token_stream = tokens
    tree_parser = tree_grammar_module::TreeParser.new( nodes )
    r = tree_parser.send( tree_grammar_rule )
    
    return( r.tree.inspect rescue '' )
  end

  example "v token" do
    result = parse( :VToken, :a, 'a' )
    result.should == 'a<V>'
  end


  example "token with qualified type" do
    result = parse( :TokenWithQualifiedType, :a, 'a' )
    result.should == 'a<V>'
  end


  example "token with label" do
    result = parse( :TokenWithLabel, :a, 'a' )
    result.should == 'a<V>'
  end


  example "token with list label" do
    result = parse( :TokenWithListLabel, :a, 'a' )
    result.should == 'a<V>'
  end


  example "token root" do
    result = parse( :TokenRoot, :a, 'a' )
    result.should == 'a<V>'
  end


  example "token root with list label" do
    result = parse( :TokenRootWithListLabel, :a, 'a' )
    result.should == 'a<V>'
  end


  example "string" do
    result = parse( :FromString, :a, 'begin' )
    result.should == 'begin<V>'
  end


  example "string root" do
    result = parse( :StringRoot, :a, 'begin' )
    result.should == 'begin<V>'
  end


  example "rewrite token" do
    result = parse( :RewriteToken, :a, 'a' )
    result.should == 'a<V>'
  end


  example "rewrite token with args" do
    result = parse( :RewriteTokenWithArgs, :a, 'a' )
    result.should == '<V>;421930 a<V>;9900'
  end


  example "rewrite token root" do
    result = parse( :RewriteTokenRoot, :a, 'a 2' )
    result.should == '(a<V> 2)'
  end


  example "rewrite string" do
    result = parse( :RewriteString, :a, 'begin' )
    result.should == 'begin<V>'
  end


  example "rewrite string root" do
    result = parse( :RewriteStringRoot, :a, 'begin 2' )
    result.should == '(begin<V> 2)'
  end


  example "rewrite rule results" do
    result = parse( :RewriteRuleResults, :a, 'a,b,c' )
    result.should == '(LIST<W> a<V> b<V> c<V>)'
  end


  example "copy semantics with hetero" do
    result = parse( :CopySemanticsWithHetero, :a, 'int a, b, c;' )
    result.should == '(int<V> a) (int<V> b) (int<V> c)'
  end


  example "tree parser rewrite flat list" do
    result = tree_parse( :TreeParserRewriteFlatList, :a, :a, 'abc 34' )
    result.should == '34<V> abc<W>'
  end


  example "tree parser rewrite tree" do
    result = tree_parse( :TreeParserRewriteTree, :a, :a, 'abc 34' )
    result.should == '(34<V> abc<W>)'
  end


  example "tree parser rewrite imaginary" do
    result = tree_parse( :TreeParserRewriteImaginary, :a, :a, 'abc' )
    result.should == 'ROOT<V> abc'
  end


  example "tree parser rewrite imaginary with args" do
    result = tree_parse( :TreeParserRewriteImaginaryWithArgs, :a, :a, 'abc' )
    result.should == 'ROOT<V>;42 abc'
  end


  example "tree parser rewrite imaginary root" do
    result = tree_parse( :TreeParserRewriteImaginaryRoot, :a, :a, 'abc' )
    result.should == '(ROOT<V> abc)'
  end


  example "tree parser rewrite imaginary from real" do
    result = tree_parse( :TreeParserRewriteImaginaryFromReal, :a, :a, 'abc' )
    result.should == 'ROOT<V>@1'
  end


  example "tree parser auto hetero ast" do
    result = tree_parse( :TreeParserAutoHeteroAST, :a, :a, 'abc;' )
    result.should == 'abc<V> ;<V>'
  end

end
