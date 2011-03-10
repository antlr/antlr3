#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestASTViaRewriteRules < ANTLR3::Test::Functional

  def parse( grammar, rule, input, expect_errors = false )
    @grammar = inline_grammar( grammar )
    compile_and_load @grammar
    grammar_module = self.class.const_get( @grammar.name )
    
    grammar_module::Lexer.send( :include, ANTLR3::Test::CollectErrors )
    grammar_module::Lexer.send( :include, ANTLR3::Test::CaptureOutput )
    grammar_module::Parser.send( :include, ANTLR3::Test::CollectErrors )
    grammar_module::Parser.send( :include, ANTLR3::Test::CaptureOutput )
    
    lexer  = grammar_module::Lexer.new( input )
    parser = grammar_module::Parser.new( lexer )
    
    r = parser.send( rule )
    parser.reported_errors.should be_empty unless expect_errors
    result = ''
    
    unless r.nil?
      result += r.result if r.respond_to?( :result )
      result += r.tree.inspect if r.tree
    end
    return( expect_errors ? [ result, parser.reported_errors ] : result )
  end
  
  def tree_parse( grammar, tree_grammar, rule, tree_rule, input )
    @grammar = inline_grammar( grammar )
    @tree_grammar = inline_grammar( tree_grammar )
    compile_and_load @grammar
    compile_and_load @tree_grammar
    
    grammar_module = self.class.const_get( @grammar.name )
    tree_grammar_module = self.class.const_get( @tree_grammar.name )
    
    grammar_module::Lexer.send( :include, ANTLR3::Test::CollectErrors )
    grammar_module::Lexer.send( :include, ANTLR3::Test::CaptureOutput )
    grammar_module::Parser.send( :include, ANTLR3::Test::CollectErrors )
    grammar_module::Parser.send( :include, ANTLR3::Test::CaptureOutput )
    tree_grammar_module::TreeParser.send( :include, ANTLR3::Test::CollectErrors )
    tree_grammar_module::TreeParser.send( :include, ANTLR3::Test::CaptureOutput )
    
    lexer  = grammar_module::Lexer.new( input )
    parser = grammar.module::Parser.new( lexer )
    r = parser.send( rule )
    nodes = ANTLR3::CommonTreeNodeStream( r.tree )
    nodes.token_stream = parser.input
    walker = tree_grammar_module::TreeParser.new( nodes )
    r = walker.send( tree_rule )
    
    return( r ? r.tree.inspect : '' )
  end
  
  example "delete" do
    result = parse( <<-'END', :a, 'abc 34' )
      grammar Delete;
      options {language=Ruby;output=AST;}
      a : ID INT -> ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    result.should == ''
  end
  
  
  example "single token" do
    result = parse( <<-'END', :a, 'abc' )
      grammar SingleToken;
      options {language=Ruby;output=AST;}
      a : ID -> ID;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'abc'
  end
  
  
  example "single token to new node" do
    result = parse( <<-'END', :a, 'abc' )
      grammar SingleTokenToNewNode;
      options {language=Ruby;output=AST;}
      a : ID -> ID["x"];
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'x'
  end
  
  
  example "single token to new node root" do
    result = parse( <<-'END', :a, 'abc' )
      grammar SingleTokenToNewNodeRoot;
      options {language=Ruby;output=AST;}
      a : ID -> ^(ID["x"] INT);
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(x INT)'
  end
  
  
  example "single token to new node2" do
    result = parse( <<-'END', :a, 'abc' )
      grammar SingleTokenToNewNode2;
      options {language=Ruby;output=AST;}
      a : ID -> ID[ ];
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    result.should == 'ID'
  end
  
  
  example "single char literal" do
    result = parse( <<-'END', :a, 'c' )
      grammar SingleCharLiteral;
      options {language=Ruby;output=AST;}
      a : 'c' -> 'c';
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'c'
  end
  
  
  example "single string literal" do
    result = parse( <<-'END', :a, 'ick' )
      grammar SingleStringLiteral;
      options {language=Ruby;output=AST;}
      a : 'ick' -> 'ick';
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'ick'
  end
  
  
  example "single rule" do
    result = parse( <<-'END', :a, 'abc' )
      grammar SingleRule;
      options {language=Ruby;output=AST;}
      a : b -> b;
      b : ID ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'abc'
  end
  
  
  example "reorder tokens" do
    result = parse( <<-'END', :a, 'abc 34' )
      grammar ReorderTokens;
      options {language=Ruby;output=AST;}
      a : ID INT -> INT ID;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '34 abc'
  end
  
  
  example "reorder token and rule" do
    result = parse( <<-'END', :a, 'abc 34' )
      grammar ReorderTokenAndRule;
      options {language=Ruby;output=AST;}
      a : b INT -> INT b;
      b : ID ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '34 abc'
  end
  
  
  example "token tree" do
    result = parse( <<-'END', :a, 'abc 34' )
      grammar TokenTree;
      options {language=Ruby;output=AST;}
      a : ID INT -> ^(INT ID);
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(34 abc)'
  end
  
  
  example "token tree after other stuff" do
    result = parse( <<-'END', :a, 'void abc 34' )
      grammar TokenTreeAfterOtherStuff;
      options {language=Ruby;output=AST;}
      a : 'void' ID INT -> 'void' ^(INT ID);
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'void (34 abc)'
  end
  
  
  example "nested token tree with outer loop" do
    result = parse( <<-'END', :a, 'a 1 b 2' )
      grammar NestedTokenTreeWithOuterLoop;
      options {language=Ruby;output=AST;}
      tokens {DUH;}
      a : ID INT ID INT -> ^( DUH ID ^( DUH INT) )+ ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(DUH a (DUH 1)) (DUH b (DUH 2))'
  end
  
  
  example "optional single token" do
    result = parse( <<-'END', :a, 'abc' )
      grammar OptionalSingleToken;
      options {language=Ruby;output=AST;}
      a : ID -> ID? ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'abc'
  end
  
  
  example "closure single token" do
    result = parse( <<-'END', :a, 'a b' )
      grammar ClosureSingleToken;
      options {language=Ruby;output=AST;}
      a : ID ID -> ID* ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'a b'
  end
  
  
  example "positive closure single token" do
    result = parse( <<-'END', :a, 'a b' )
      grammar PositiveClosureSingleToken;
      options {language=Ruby;output=AST;}
      a : ID ID -> ID+ ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'a b'
  end
  
  
  example "optional single rule" do
    result = parse( <<-'END', :a, 'abc' )
      grammar OptionalSingleRule;
      options {language=Ruby;output=AST;}
      a : b -> b?;
      b : ID ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'abc'
  end
  
  
  example "closure single rule" do
    result = parse( <<-'END', :a, 'a b' )
      grammar ClosureSingleRule;
      options {language=Ruby;output=AST;}
      a : b b -> b*;
      b : ID ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'a b'
  end
  
  
  example "closure of label" do
    result = parse( <<-'END', :a, 'a b' )
      grammar ClosureOfLabel;
      options {language=Ruby;output=AST;}
      a : x+=b x+=b -> $x*;
      b : ID ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'a b'
  end
  
  
  example "optional label no list label" do
    result = parse( <<-'END', :a, 'a' )
      grammar OptionalLabelNoListLabel;
      options {language=Ruby;output=AST;}
      a : (x=ID)? -> $x?;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'a'
  end
  
  
  example "positive closure single rule" do
    result = parse( <<-'END', :a, 'a b' )
      grammar PositiveClosureSingleRule;
      options {language=Ruby;output=AST;}
      a : b b -> b+;
      b : ID ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'a b'
  end
  
  
  example "single predicate t" do
    result = parse( <<-'END', :a, 'abc' )
      grammar SinglePredicateT;
      options {language=Ruby;output=AST;}
      a : ID -> {true}? ID -> ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'abc'
  end
  
  
  example "single predicate f" do
    result = parse( <<-'END', :a, 'abc' )
      grammar SinglePredicateF;
      options {language=Ruby;output=AST;}
      a : ID -> {false}? ID -> ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == ''
  end
  
  
  example "multiple predicate" do
    result = parse( <<-'END', :a, 'a 2' )
      grammar MultiplePredicate;
      options {language=Ruby;output=AST;}
      a : ID INT -> {false}? ID
                 -> {true}? INT
                 -> 
        ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '2'
  end
  
  
  example "multiple predicate trees" do
    result = parse( <<-'END', :a, 'a 2' )
      grammar MultiplePredicateTrees;
      options {language=Ruby;output=AST;}
      a : ID INT -> {false}? ^(ID INT)
                 -> {true}? ^(INT ID)
                 -> ID
        ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(2 a)'
  end
  
  
  example "simple tree" do
    result = parse( <<-'END', :a, '-34' )
      grammar SimpleTree;
      options {language=Ruby;output=AST;}
      a : op INT -> ^(op INT);
      op : '+'|'-' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(- 34)'
  end
  
  
  example "simple tree2" do
    result = parse( <<-'END', :a, '+ 34' )
      grammar SimpleTree2;
      options {language=Ruby;output=AST;}
      a : op INT -> ^(INT op);
      op : '+'|'-' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(34 +)'
  end
  
  
  example "nested trees" do
    result = parse( <<-'END', :a, 'var a:int; b:float;' )
      grammar NestedTrees;
      options {language=Ruby;output=AST;}
      a : 'var' (ID ':' type ';')+ -> ^('var' ^(':' ID type)+) ;
      type : 'int' | 'float' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(var (: a int) (: b float))'
  end
  
  
  example "imaginary token copy" do
    result = parse( <<-'END', :a, 'a,b,c' )
      grammar ImaginaryTokenCopy;
      options {language=Ruby;output=AST;}
      tokens {VAR;}
      a : ID (',' ID)*-> ^(VAR ID)+ ;
      type : 'int' | 'float' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(VAR a) (VAR b) (VAR c)'
  end
  
  
  example "token unreferenced on left but defined" do
    result = parse( <<-'END', :a, 'a' )
      grammar TokenUnreferencedOnLeftButDefined;
      options {language=Ruby;output=AST;}
      tokens {VAR;}
      a : b -> ID ;
      b : ID ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'ID'
  end
  
  
  example "imaginary token copy set text" do
    result = parse( <<-'END', :a, 'a,b,c' )
      grammar ImaginaryTokenCopySetText;
      options {language=Ruby;output=AST;}
      tokens {VAR;}
      a : ID (',' ID)*-> ^(VAR["var"] ID)+ ;
      type : 'int' | 'float' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(var a) (var b) (var c)'
  end
  
  
  example "imaginary token no copy from token" do
    result = parse( <<-'END', :a, '{a b c}' )
      grammar ImaginaryTokenNoCopyFromToken;
      options {language=Ruby;output=AST;}
      tokens {BLOCK;}
      a : lc='{' ID+ '}' -> ^(BLOCK[$lc] ID+) ;
      type : 'int' | 'float' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '({ a b c)'
  end
  
  
  example "imaginary token no copy from token set text" do
    result = parse( <<-'END', :a, '{a b c}' )
      grammar ImaginaryTokenNoCopyFromTokenSetText;
      options {language=Ruby;output=AST;}
      tokens {BLOCK;}
      a : lc='{' ID+ '}' -> ^(BLOCK[$lc,"block"] ID+) ;
      type : 'int' | 'float' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(block a b c)'
  end
  
  
  example "mixed rewrite and auto ast" do
    result = parse( <<-'END', :a, 'a 1 2' )
      grammar MixedRewriteAndAutoAST;
      options {language=Ruby;output=AST;}
      tokens {BLOCK;}
      a : b b^ ; // 2nd b matches only an INT; can make it root
      b : ID INT -> INT ID
        | INT
        ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    result.should == '(2 1 a)'
  end
  
  
  example "subrule with rewrite" do
    result = parse( <<-'END', :a, 'a 1 2 3' )
      grammar SubruleWithRewrite;
      options {language=Ruby;output=AST;}
      tokens {BLOCK;}
      a : b b ;
      b : (ID INT -> INT ID | INT INT -> INT+ )
        ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '1 a 2 3'
  end
  
  
  example "subrule with rewrite2" do
    result = parse( <<-'END', :a, 'int a; int b=3;' )
      grammar SubruleWithRewrite2;
      options {language=Ruby;output=AST;}
      tokens {TYPE;}
      a : b b ;
      b : 'int'
          ( ID -> ^(TYPE 'int' ID)
          | ID '=' INT -> ^(TYPE 'int' ID INT)
          )
          ';'
        ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(TYPE int a) (TYPE int b 3)'
  end
  
  
  example "nested rewrite shuts off auto ast" do
    result = parse( <<-'END', :a, 'a b c d; 42' )
      grammar NestedRewriteShutsOffAutoAST;
      options {language=Ruby;output=AST;}
      tokens {BLOCK;}
      a : b b ;
      b : ID ( ID (last=ID -> $last)+ ) ';' // get last ID
        | INT // should still get auto AST construction
        ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'd 42'
  end
  
  
  example "rewrite actions" do
    result = parse( <<-'END', :a, '3' )
      grammar RewriteActions;
      options {language=Ruby;output=AST;}
      a : atom -> ^({ @adaptor.create( INT, "9" ) } atom) ;
      atom : INT ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(9 3)'
  end
  
  
  example "rewrite actions2" do
    result = parse( <<-'END', :a, '3' )
      grammar RewriteActions2;
      options {language=Ruby;output=AST;}
      a : atom -> { @adaptor.create( INT, "9" ) } atom ;
      atom : INT ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') { $channel = HIDDEN } ;
  
    END
    result.should == '9 3'
  end
  
  
  example "ref to old value" do
    result = parse( <<-'END', :a, '3+4+5' )
      grammar RefToOldValue;
      options {language=Ruby;output=AST;}
      tokens {BLOCK;}
      a : (atom -> atom) (op='+' r=atom -> ^($op $a $r) )* ;
      atom : INT ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(+ (+ 3 4) 5)'
  end
  
  
  example "copy semantics for rules" do
    result = parse( <<-'END', :a, '3' )
      grammar CopySemanticsForRules;
      options {language=Ruby;output=AST;}
      tokens {BLOCK;}
      a : atom -> ^(atom atom) ; // NOT CYCLE! (dup atom)
      atom : INT ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(3 3)'
  end
  
  
  example "copy semantics for rules2" do
    result = parse( <<-'END', :a, 'int a,b,c;' )
      grammar CopySemanticsForRules2;
      options {language=Ruby;output=AST;}
      a : type ID (',' ID)* ';' -> ^(type ID)+ ;
      type : 'int' ;
      ID : 'a'..'z'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(int a) (int b) (int c)'
  end
  
  
  example "copy semantics for rules3" do
    result = parse( <<-'END', :a, 'public int a,b,c;' )
      grammar CopySemanticsForRules3;
      options {language=Ruby;output=AST;}
      a : modifier? type ID (',' ID)* ';' -> ^(type modifier? ID)+ ;
      type : 'int' ;
      modifier : 'public' ;
      ID : 'a'..'z'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(int public a) (int public b) (int public c)'
  end
  
  
  example "copy semantics for rules3 double" do
    result = parse( <<-'END', :a, 'public int a,b,c;' )
      grammar CopySemanticsForRules3Double;
      options {language=Ruby;output=AST;}
      a : modifier? type ID (',' ID)* ';' -> ^(type modifier? ID)+ ^(type modifier? ID)+ ;
      type : 'int' ;
      modifier : 'public' ;
      ID : 'a'..'z'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(int public a) (int public b) (int public c) (int public a) (int public b) (int public c)'
  end
  
  
  example "copy semantics for rules4" do
    result = parse( <<-'END', :a, 'public int a,b,c;' )
      grammar CopySemanticsForRules4;
      options {language=Ruby;output=AST;}
      tokens {MOD;}
      a : modifier? type ID (',' ID)* ';' -> ^(type ^(MOD modifier)? ID)+ ;
      type : 'int' ;
      modifier : 'public' ;
      ID : 'a'..'z'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(int (MOD public) a) (int (MOD public) b) (int (MOD public) c)'
  end
  
  
  example "copy semantics lists" do
    result = parse( <<-'END', :a, 'a,b,c;' )
      grammar CopySemanticsLists;
      options {language=Ruby;output=AST;}
      tokens {MOD;}
      a : ID (',' ID)* ';' -> ID+ ID+ ;
      ID : 'a'..'z'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'a b c a b c'
  end
  
  
  example "copy rule label" do
    result = parse( <<-'END', :a, 'a' )
      grammar CopyRuleLabel;
      options {language=Ruby;output=AST;}
      tokens {BLOCK;}
      a : x=b -> $x $x;
      b : ID ;
      ID : 'a'..'z'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'a a'
  end
  
  
  example "copy rule label2" do
    result = parse( <<-'END', :a, 'a' )
      grammar CopyRuleLabel2;
      options {language=Ruby;output=AST;}
      tokens {BLOCK;}
      a : x=b -> ^($x $x);
      b : ID ;
      ID : 'a'..'z'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(a a)'
  end
  
  
  example "queueing of tokens" do
    result = parse( <<-'END', :a, 'int a,b,c;' )
      grammar QueueingOfTokens;
      options {language=Ruby;output=AST;}
      a : 'int' ID (',' ID)* ';' -> ^('int' ID+) ;
      op : '+'|'-' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(int a b c)'
  end
  
  
  example "copy of tokens" do
    result = parse( <<-'END', :a, 'int a;' )
      grammar CopyOfTokens;
      options {language=Ruby;output=AST;}
      a : 'int' ID ';' -> 'int' ID 'int' ID ;
      op : '+'|'-' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'int a int a'
  end
  
  
  example "token copy in loop" do
    result = parse( <<-'END', :a, 'int a,b,c;' )
      grammar TokenCopyInLoop;
      options {language=Ruby;output=AST;}
      a : 'int' ID (',' ID)* ';' -> ^('int' ID)+ ;
      op : '+'|'-' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(int a) (int b) (int c)'
  end
  
  
  example "token copy in loop against two others" do
    result = parse( <<-'END', :a, 'int a:1,b:2,c:3;' )
      grammar TokenCopyInLoopAgainstTwoOthers;
      options {language=Ruby;output=AST;}
      a : 'int' ID ':' INT (',' ID ':' INT)* ';' -> ^('int' ID INT)+ ;
      op : '+'|'-' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(int a 1) (int b 2) (int c 3)'
  end
  
  
  example "list refd one at a time" do
    result = parse( <<-'END', :a, 'a b c' )
      grammar ListRefdOneAtATime;
      options {language=Ruby;output=AST;}
      a : ID+ -> ID ID ID ; // works if 3 input IDs
      op : '+'|'-' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'a b c'
  end
  
  
  example "split list with labels" do
    result = parse( <<-'END', :a, 'a b c' )
      grammar SplitListWithLabels;
      options {language=Ruby;output=AST;}
      tokens {VAR;}
      a : first=ID others+=ID* -> $first VAR $others+ ;
      op : '+'|'-' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'a VAR b c'
  end
  
  
  example "complicated melange" do
    result = parse( <<-'END', :a, 'a a b b b c c c d' )
      grammar ComplicatedMelange;
      options {language=Ruby;output=AST;}
      tokens {BLOCK;}
      a : A A b=B B b=B c+=C C c+=C D {s=$D.text} -> A+ B+ C+ D ;
      type : 'int' | 'float' ;
      A : 'a' ;
      B : 'b' ;
      C : 'c' ;
      D : 'd' ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'a a b b b c c c d'
  end
  
  
  example "rule label" do
    result = parse( <<-'END', :a, 'a' )
      grammar RuleLabel;
      options {language=Ruby;output=AST;}
      tokens {BLOCK;}
      a : x=b -> $x;
      b : ID ;
      ID : 'a'..'z'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'a'
  end
  
  
  example "ambiguous rule" do
    result = parse( <<-'END', :a, 'abc 34' )
      grammar AmbiguousRule;
      options {language=Ruby;output=AST;}
      a : ID a -> a | INT ;
      ID : 'a'..'z'+ ;
      INT: '0'..'9'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '34'
  end
  
  
  example "rule list label" do
    result = parse( <<-'END', :a, 'a b' )
      grammar RuleListLabel;
      options {language=Ruby;output=AST;}
      tokens {BLOCK;}
      a : x+=b x+=b -> $x+;
      b : ID ;
      ID : 'a'..'z'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'a b'
  end
  
  
  example "rule list label2" do
    result = parse( <<-'END', :a, 'a b' )
      grammar RuleListLabel2;
      options {language=Ruby;output=AST;}
      tokens {BLOCK;}
      a : x+=b x+=b -> $x $x*;
      b : ID ;
      ID : 'a'..'z'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'a b'
  end
  
  
  example "optional" do
    result = parse( <<-'END', :a, 'a' )
      grammar Optional;
      options {language=Ruby;output=AST;}
      tokens {BLOCK;}
      a : x=b (y=b)? -> $x $y?;
      b : ID ;
      ID : 'a'..'z'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'a'
  end
  
  
  example "optional2" do
    result = parse( <<-'END', :a, 'a b' )
      grammar Optional2;
      options {language=Ruby;output=AST;}
      tokens {BLOCK;}
      a : x=ID (y=b)? -> $x $y?;
      b : ID ;
      ID : 'a'..'z'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'a b'
  end
  
  
  example "optional3" do
    result = parse( <<-'END', :a, 'a b' )
      grammar Optional3;
      options {language=Ruby;output=AST;}
      tokens {BLOCK;}
      a : x=ID (y=b)? -> ($x $y)?;
      b : ID ;
      ID : 'a'..'z'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'a b'
  end
  
  
  example "optional4" do
    result = parse( <<-'END', :a, 'a b' )
      grammar Optional4;
      options {language=Ruby;output=AST;}
      tokens {BLOCK;}
      a : x+=ID (y=b)? -> ($x $y)?;
      b : ID ;
      ID : 'a'..'z'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    result.should == 'a b'
  end
  
  
  example "optional5" do
    result = parse( <<-'END', :a, 'a' )
      grammar Optional5;
      options {language=Ruby;output=AST;}
      tokens {BLOCK;}
      a : ID -> ID? ; // match an ID to optional ID
      b : ID ;
      ID : 'a'..'z'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'a'
  end
  
  
  example "arbitrary expr type" do
    result = parse( <<-'END', :a, 'a b' )
      grammar ArbitraryExprType;
      options {language=Ruby;output=AST;}
      tokens {BLOCK;}
      a : x+=b x+=b -> {ANTLR3::CommonTree.new(nil)};
      b : ID ;
      ID : 'a'..'z'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == ''
  end
  
  
  example "set" do
    result = parse( <<-'END', :a, '2 a 34 de' )
      grammar SetT;
      options {language=Ruby;output=AST;} 
      a: (INT|ID)+ -> INT+ ID+ ;
      INT: '0'..'9'+;
      ID : 'a'..'z'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '2 34 a de'
  end
  
  
  example "set2" do
    result = parse( <<-'END', :a, '2' )
      grammar Set2;
      options {language=Ruby;output=AST;} 
      a: (INT|ID) -> INT? ID? ;
      INT: '0'..'9'+;
      ID : 'a'..'z'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '2'
  end
  
  
  example "set with label" do
    warn( 'test SetWithLabel officially broken' )
    #result = parse(<<-'END', :a, '2')
    #  grammar SetWithLabel;
    #  options {language=Ruby;output=AST;} 
    #  a : x=(INT|ID) -> $x ;
    #  INT: '0'..'9'+;
    #  ID : 'a'..'z'+;
    #  WS : (' '|'\n') {$channel=HIDDEN;} ;
    #
    #END
    #result.should == '2'
  end
  
  
  example "rewrite action" do
    result = parse( <<-'END', :r, '25' )
      grammar RewriteAction; 
      options {language=Ruby;output=AST;}
      tokens { FLOAT; }
      r
          : INT -> { ANTLR3::CommonTree.new( create_token( FLOAT, nil, "#{$INT.text}.0" ) ) }
          ; 
      INT : '0'..'9'+; 
      WS: (' ' | '\n' | '\t')+ {$channel = HIDDEN;};
  
    END
    result.should == '25.0'
  end
  
  
  example "optional subrule without real elements" do
    result = parse( <<-'END', :modulo, 'modulo abc (x y #)' )
      grammar OptionalSubruleWithoutRealElements;
      options {language=Ruby;output=AST;} 
      tokens {PARMS;} 
      
      modulo 
       : 'modulo' ID ('(' parms+ ')')? -> ^('modulo' ID ^(PARMS parms+)?) 
       ; 
      parms : '#'|ID; 
      ID : ('a'..'z' | 'A'..'Z')+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(modulo abc (PARMS x y #))'
  end
  
  
  example "wildcard" do
    result = parse( <<-'END', :a, 'abc 34' )
      grammar Wildcard;
      options {language=Ruby;output=AST;}
      a : ID c=. -> $c;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '34'
  end
  
  
  example "extra token in simple decl" do
    result, errors = parse( <<-'END', :decl, 'int 34 x=1;', true )
      grammar ExtraTokenInSimpleDecl;
      options {language=Ruby;output=AST;}
      tokens {EXPR;}
      decl : type ID '=' INT ';' -> ^(EXPR type ID INT) ;
      type : 'int' | 'float' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    errors.should == [ 'line 1:4 extraneous input "34" expecting ID' ]
    result.should == '(EXPR int x 1)'
  end
  
  
  example "missing id in simple decl" do
    result, errors = parse( <<-'END', :decl, 'int =1;', true )
      grammar MissingIDInSimpleDecl;
      options {language=Ruby;output=AST;}
      tokens {EXPR;}
      decl : type ID '=' INT ';' -> ^(EXPR type ID INT) ;
      type : 'int' | 'float' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    errors.should == [ 'line 1:4 missing ID at "="' ]
    result.should == '(EXPR int <missing ID> 1)'
  end
  
  
  example "missing set in simple decl" do
    result, errors = parse( <<-'END', :decl, 'x=1;', true )
      grammar MissingSetInSimpleDecl;
      options {language=Ruby;output=AST;}
      tokens {EXPR;}
      decl : type ID '=' INT ';' -> ^(EXPR type ID INT) ;
      type : 'int' | 'float' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    errors.should == [ 'line 1:0 mismatched input "x" expecting set nil' ]
    result.should == '(EXPR <error: x> x 1)'
  end
  
  
  example "missing token gives error node" do
    result, errors = parse( <<-'END', :a, 'abc', true )
      grammar MissingTokenGivesErrorNode;
      options {language=Ruby;output=AST;}
      a : ID INT -> ID INT ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    errors.should == [ "line 0:-1 missing INT at \"<EOF>\"" ]
    result.should == 'abc <missing INT>'
    #end
  end
  
  
  example "extra token gives error node" do
    result, errors = parse( <<-'END', :a, 'abc ick 34', true )
      grammar ExtraTokenGivesErrorNode;
      options {language=Ruby;output=AST;}
      a : b c -> b c;
      b : ID -> ID ;
      c : INT -> INT ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    errors.should == [ 'line 1:4 extraneous input "ick" expecting INT' ]
    result.should == 'abc 34'
  end
  
  
  example "missing first token gives error node" do
    result, errors = parse( <<-'END', :a, '34', true )
      grammar MissingFirstTokenGivesErrorNode;
      options {language=Ruby;output=AST;}
      a : ID INT -> ID INT ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    errors.should == [ 'line 1:0 missing ID at "34"' ]
    result.should == '<missing ID> 34'
  end
  
  
  example "missing first token gives error node2" do
    result, errors = parse( <<-'END', :a, '34', true )
      grammar MissingFirstTokenGivesErrorNode2;
      options {language=Ruby;output=AST;}
      a : b c -> b c;
      b : ID -> ID ;
      c : INT -> INT ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    errors.should == [ 'line 1:0 missing ID at "34"' ]
    result.should == '<missing ID> 34'
  end
  
  
  example "no viable alt gives error node" do
    result, errors = parse( <<-'END', :a, '*', true )
      grammar NoViableAltGivesErrorNode;
      options {language=Ruby;output=AST;}
      a : b -> b | c -> c;
      b : ID -> ID ;
      c : INT -> INT ;
      ID : 'a'..'z'+ ;
      S : '*' ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    errors.should == [ 'line 1:0 no viable alternative at input "*"' ]
    result.should == '<unexpected: 0 S["*"] @ line 1 col 0 (0..0), resync = *>'
  end
  
  
  example "cardinality" do
    lambda do
      parse( <<-'END', :a, "a b 3 4 5" )
        grammar Cardinality;
        options {language=Ruby;output=AST;}
        tokens {BLOCK;}
        a : ID ID INT INT INT -> (ID INT)+;
        ID : 'a'..'z'+ ;
        INT : '0'..'9'+; 
        WS : (' '|'\n') {$channel=HIDDEN;} ;
      END
    end.should raise_error( ANTLR3::Error::RewriteCardinalityError )
  end
  
  example "cardinality2" do
    lambda do
      parse( <<-'END', :a, "a b" )
        grammar Cardinality2;
        options {language=Ruby;output=AST;}
        tokens {BLOCK;}
        a : ID+ -> ID ID ID ; // only 2 input IDs
        op : '+'|'-' ;
        ID : 'a'..'z'+ ;
        INT : '0'..'9'+;
        WS : (' '|'\n') {$channel=HIDDEN;} ;
      END
    end.should raise_error( ANTLR3::Error::RewriteCardinalityError )
  end
  
  example "cardinality3" do
    lambda do
      parse( <<-'END', :a, "3" )
        grammar Cardinality3;
        options {language=Ruby;output=AST;}
        tokens {BLOCK;}
        a : ID? INT -> ID INT ;
        op : '+'|'-' ;
        ID : 'a'..'z'+ ;
        INT : '0'..'9'+;
        WS : (' '|'\n') {$channel=HIDDEN;} ;
      END
    end.should raise_error( ANTLR3::Error::RewriteEmptyStream )
  end
  
  example "loop cardinality" do
    lambda do
      parse( <<-'END', :a, "3" )
        grammar LoopCardinality;
        options {language=Ruby;output=AST;}
        a : ID? INT -> ID+ INT ;
        op : '+'|'-' ;
        ID : 'a'..'z'+ ;
        INT : '0'..'9'+;
        WS : (' '|'\n') {$channel=HIDDEN;} ;
      END
    end.should raise_error( ANTLR3::Error::RewriteEarlyExit )
  end



end
