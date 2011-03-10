#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestAutoAST < ANTLR3::Test::Functional
  
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
  
  
  example 'flat token list' do
    result = parse( <<-'END', :a, 'abc 34' )
      grammar TokenList;
      options {language=Ruby;output=AST;}
      a : ID INT ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;};
    END
    result.should == 'abc 34'
  end
  
  example 'token list in a single-alternative subrule' do
    result = parse( <<-'END', :a, 'abc 34' )
      grammar TokenListInSingleAltBlock;
      options {language=Ruby;output=AST;}
      a : (ID INT) ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    result.should == 'abc 34'
  end
  
  example "simple root at the outer level via the `^' operator" do
    result = parse( <<-'END', :a, 'abc 34' )
      grammar SimpleRootAtOuterLevel;
      options {language=Ruby;output=AST;}
      a : ID^ INT ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    result.should == '(abc 34)'
  end
  
  example "outer-level root changing token order from the `^' operator" do
    result = parse( <<-'END', :a, '34 abc' )
      grammar SimpleRootAtOuterLevelReverse;
      options {language=Ruby;output=AST;}
      a : INT ID^ ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    result.should == '(abc 34)'
  end
  
  example "leaving out tokens using the `!' operator" do
    result = parse( <<-'END', :a, 'abc 34 dag 4532' )
      grammar Bang;
      options {language=Ruby;output=AST;}
      a : ID INT! ID! INT ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    
    result.should == 'abc 4532'
  end
  
  example "tokens in `(...)?' optional subrule" do
    result = parse( <<-'END', :a, 'a 1 b' )
      grammar OptionalThenRoot;
      options {language=Ruby;output=AST;}
      a : ( ID INT )? ID^ ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    result.should == '(b a 1)'
  end
  
  example "labeled literal-string root token" do
    result = parse( <<-'END', :a, 'void foo;' )
      grammar LabeledStringRoot;
      options {language=Ruby;output=AST;}
      a : v='void'^ ID ';' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    result.should == '(void foo ;)'
  end
  
  example 'rule with token wildcard' do
    result = parse( <<-'END', :a, 'void foo;' )
      grammar Wildcard;
      options {language=Ruby;output=AST;}
      a : v='void'^ . ';' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    result.should == '(void foo ;)'
  end
  
  example "token wildcard as root via the `^' operator" do
    result = parse( <<-'END', :a, 'void foo;' )
      grammar WildcardRoot;
      options {language=Ruby;output=AST;}
      a : v='void' .^ ';' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    result.should == '(foo void ;)'
  end
  
  example "labeled token wildcard as root via the `^' operator" do
    result = parse( <<-'END', :a, 'void foo;' )
      grammar WildcardRootWithLabel;
      options {language=Ruby;output=AST;}
      a : v='void' x=.^ ';' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    result.should == '(foo void ;)'
  end
  
  
  example "token wildcard as root (with list label)" do
    result = parse( <<-'END', :a, 'void foo;' )
      grammar WildcardRootWithListLabel;
      options {language=Ruby;output=AST;}
      a : v='void' x=.^ ';' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(foo void ;)'
  end
  
  example "trashed token wildcard" do
    result = parse( <<-'END', :a, 'void foo;' )
      grammar WildcardBangWithListLabel;
      options {language=Ruby;output=AST;}
      a : v='void' x=.! ';' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'void ;'
  end
  
  example "multiple occurences of the `^' operator in a list of tokens" do
    result = parse( <<-'END', :a, 'a 34 c' )
      grammar RootRoot;
      options {language=Ruby;output=AST;}
      a : ID^ INT^ ID ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(34 a c)'
  end
  
  example "another case of multiple occurences of the `^' operator" do
    result = parse( <<-'END', :a, 'a 34 c' )
      grammar RootRoot2;
      options {language=Ruby;output=AST;}
      a : ID INT^ ID^ ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(c (34 a))'
  end
  
  example "root-hoist using `^' from within a (...)+ block" do
    result = parse( <<-'END', :a, 'a 34 * b 9 * c' )
      grammar RootThenRootInLoop;
      options {language=Ruby;output=AST;}
      a : ID^ (INT '*'^ ID)+ ;
      ID  : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(* (* (a 34) b 9) c)'
  end
  
  example "nested subrules without any AST ops resulting in a flat list" do
    result = parse( <<-'END', :a, 'void a b;' )
      grammar NestedSubrule;
      options {language=Ruby;output=AST;}
      a : 'void' (({
      #do nothing
      } ID|INT) ID | 'null' ) ';' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'void a b ;'
  end
  
  example "invoking another rule without any AST ops, resulting in a flat list" do
    result = parse( <<-'END', :a, 'int a' )
      grammar InvokeRule;
      options {language=Ruby;output=AST;}
      a  : type ID ;
      type : {
        # do nothing
      }'int' | 'float' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'int a'
  end
  
  example "hoisting the results of another rule as root using the `^' operator" do
    result = parse( <<-'END', :a, 'int a' )
      grammar InvokeRuleAsRoot;
      options {language=Ruby;output=AST;}
      a  : type^ ID ;
      type : {
        # do nothing
      }'int' | 'float' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(int a)'
  end
  
  example "hoisting another rule's true as root using the `^' operator (with a label)" do
    result = parse( <<-'END', :a, 'int a' )
      grammar InvokeRuleAsRootWithLabel;
      options {language=Ruby;output=AST;}
      a  : x=type^ ID ;
      type : {
        # do nothing
      }'int' | 'float' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(int a)'
  end
  
  example "hoisting another rule's result tree as root using the `^' operator (with a list += label)" do
    result = parse( <<-'END', :a, 'int a' )
      grammar InvokeRuleAsRootWithListLabel;
      options {language=Ruby;output=AST;}
      a  : x+=type^ ID ;
      type : {
        # do nothing
      }'int' | 'float' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(int a)'
  end
  
  example "root-hoist via `^' within a (...)* loop resulting in a deeply-nested tree" do
    result = parse( <<-'END', :a, 'a+b+c+d' )
      grammar RuleRootInLoop;
      options {language=Ruby;output=AST;}
      a : ID ('+'^ ID)* ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(+ (+ (+ a b) c) d)'
  end
  
  example "hoisting another rule's result tree as root from within a (...)* loop resulting in a deeply nested tree" do
    result = parse( <<-'END', :a, 'a+b+c-d' )
      grammar RuleInvocationRuleRootInLoop;
      options {language=Ruby;output=AST;}
      a : ID (op^ ID)* ;
      op : {
        # do nothing
      }'+' | '-' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(- (+ (+ a b) c) d)'
  end
  
  example "using tail recursion to build deeply-nested expression trees" do
    result = parse( <<-'END', :s, '3 exp 4 exp 5' )
      grammar TailRecursion;
      options {language=Ruby;output=AST;}
      s : a ;
      a : atom ('exp'^ a)? ;
      atom : INT ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(exp 3 (exp 4 5))'
  end
  
  example "simple token node from a token type set" do
    result = parse( <<-'END', :a, 'abc' )
      grammar TokenSet;
      options {language=Ruby; output=AST;}
      a : ID|INT ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    result.should == 'abc'
  end
  
  example "hoisting a token-type set token as root with `^'" do
    result = parse( <<-'END', :a, '+abc' )
      grammar SetRoot;
      options {language=Ruby;output=AST;}
      a : ('+' | '-')^ ID ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(+ abc)'
  end
  
  example "hoisting a token-type set token as root with `^' (with a label)" do
    result = parse( <<-'END', :a, '+abc' )
      grammar SetRootWithLabel;
      options {language=Ruby;output=AST;}
      a : (x=('+' | '-'))^ ID ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '+ abc'
  end
  
  example "hoisting a token-type set token as root from within a (...)* loop" do
    result = parse( <<-'END', :a, 'a+b-c' )
      grammar SetAsRuleRootInLoop;
      options {language=Ruby;output=AST;}
      a : ID (('+'|'-')^ ID)* ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(- (+ a b) c)'
  end
  
  example "an `~' inverted token-type set element" do
    result = parse( <<-'END', :a, '34+2' )
      grammar NotSet;
      options {language=Ruby;output=AST;}
      a : ~ID '+' INT ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '34 + 2'
  end
  
  example "a `~' inverted token-type set in a rule (with a label)" do
    result = parse( <<-'END', :a, '34+2' )
      grammar NotSetWithLabel;
      options {language=Ruby;output=AST;}
      a : x=~ID '+' INT ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '34 + 2'
  end
  
  example "a `~' inverted token-type set element in a rule (with a list += label)" do
    result = parse( <<-'END', :a, '34+2' )
      grammar NotSetWithListLabel;
      options {language=Ruby;output=AST;}
      a : x=~ID '+' INT ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '34 + 2'
  end
  
  example "a `~' inverted token-type set element hoisted to root via `^'" do
    result = parse( <<-'END', :a, '34 55' )
      grammar NotSetRoot;
      options {language=Ruby;output=AST;}
      a : ~'+'^ INT ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(34 55)'
  end
  
  example "hoisting a `~' inverted token-type set to root using `^' (with label)" do
    result = parse( <<-'END', :a, '34 55' )
      grammar NotSetRootWithLabel;
      options {language=Ruby;output=AST;}
      a   : x=~'+'^ INT ;
      ID  : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS  : (' '|'\n') {$channel=HIDDEN;} ;
    END
    result.should == '(34 55)'
  end
  
  example "hoisting a `~' inverted token-type set to root using `^' (with list += label)" do
    result = parse( <<-'END', :a, '34 55' )
      grammar NotSetRootWithListLabel;
      options {language=Ruby;output=AST;}
      a : x+=~'+'^ INT ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    result.should == '(34 55)'
  end
  
  example "hoisting a `~' inverted token-type set to root from within a (...)* loop" do
    result = parse( <<-'END', :a, '3+4+5' )
      grammar NotSetRuleRootInLoop;
      options {language=Ruby;output=AST;}
      a : INT (~INT^ INT)* ;
      blort : '+' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '(+ (+ 3 4) 5)'
  end
  
  example "multiple tokens with the same label in a rule" do
    result = parse( <<-'END', :a, 'a b' )
      grammar TokenLabelReuse;
      options {language=Ruby;output=AST;}
      a returns [result] : id=ID id=ID {
        $result = "2nd id=\%s," \% $id.text
      } ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '2nd id=b,a b'
  end
  
  example "multiple tokens with the same label in a rule (with a `^' root hoist)" do
    result = parse( <<-'END', :a, 'a b' )
      grammar TokenLabelReuse2;
      options {language=Ruby;output=AST;}
      a returns [result]: id=ID id=ID^ {$result = "2nd id=#{$id.text},"} ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '2nd id=b,(b a)'
  end
  
  example "extra token in a simple declaration" do
    result, errors = parse( <<-'END', :decl, 'int 34 x=1;', true )
      grammar ExtraTokenInSimpleDecl;
      options {language=Ruby;output=AST;}
      decl : type^ ID '='! INT ';'! ;
      type : 'int' | 'float' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    errors.should == [ "line 1:4 extraneous input \"34\" expecting ID" ]
    result.should == '(int x 1)'
  end
  
  example "missing ID in a simple declaration" do
    result, errors = parse( <<-'END', :decl, 'int =1;', true )
      grammar MissingIDInSimpleDecl;
      options {language=Ruby;output=AST;}
      tokens {EXPR;}
      decl : type^ ID '='! INT ';'! ;
      type : 'int' | 'float' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    errors.should == [ "line 1:4 missing ID at \"=\"" ]
    result.should == '(int <missing ID> 1)'
  end
  
  example "missing token of a token-type set in a simple declaration" do
    result, errors = parse( <<-'END', :decl, 'x=1;', true )
      grammar MissingSetInSimpleDecl;
      options {language=Ruby;output=AST;}
      tokens {EXPR;}
      decl : type^ ID '='! INT ';'! ;
      type : 'int' | 'float' ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    errors.should == [ "line 1:0 mismatched input \"x\" expecting set nil" ]
    result.should == '(<error: x> x 1)'
  end
  
  example "missing INT token simulated with a `<missing INT>' error node" do
    result, errors = parse( <<-'END', :a, 'abc', true )
      grammar MissingTokenGivesErrorNode;
      options {language=Ruby;output=AST;}
      a : ID INT ; // follow is EOF
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    errors.should == [ "line 0:-1 missing INT at \"<EOF>\"" ]
    result.should == 'abc <missing INT>'
  end
  
  example "missing token from invoked rule results in error node with a resync attribute" do
    result, errors = parse( <<-'END', :a, 'abc', true )
      grammar MissingTokenGivesErrorNodeInInvokedRule;
      options {language=Ruby;output=AST;}
      a : b ;
      b : ID INT ; // follow should see EOF
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    errors.should == [ "line 0:-1 mismatched input \"<EOF>\" expecting INT" ]
    result.should == '<mismatched token: <EOF>, resync = abc>'
  end
  
  example "extraneous ID token displays error and is ignored in AST output" do
    result, errors = parse( <<-'END', :a, 'abc ick 34', true )
      grammar ExtraTokenGivesErrorNode;
      options {language=Ruby;output=AST;}
      a : b c ;
      b : ID ;
      c : INT ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    errors.should == [ "line 1:4 extraneous input \"ick\" expecting INT" ]
    result.should == 'abc 34'
  end
  
  example "missing ID token simulated with a `<missing ID>' error node" do
    result, errors = parse( <<-'END', :a, '34', true )
      grammar MissingFirstTokenGivesErrorNode;
      options {language=Ruby;output=AST;}
      a : ID INT ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    errors.should == [ "line 1:0 missing ID at \"34\"" ]
    result.should == '<missing ID> 34'
  end
  
  example "another case where a missing ID token is simulated with a `<missing ID>' error node" do
    result, errors = parse( <<-'END', :a, '34', true )
      grammar MissingFirstTokenGivesErrorNode2;
      options {language=Ruby;output=AST;}
      a : b c ;
      b : ID ;
      c : INT ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    errors.should == [ "line 1:0 missing ID at \"34\"" ]
    result.should == '<missing ID> 34'
  end
  
  example "no viable alternative for rule is represented as a single `<unexpected: ...>' error node" do
    result, errors = parse( <<-'END', :a, '*', true )
      grammar NoViableAltGivesErrorNode;
      options {language=Ruby;output=AST;}
      a : b | c ;
      b : ID ;
      c : INT ;
      ID : 'a'..'z'+ ;
      S : '*' ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    errors.should == [ "line 1:0 no viable alternative at input \"*\"" ]
    result.should == "<unexpected: 0 S[\"*\"] @ line 1 col 0 (0..0), resync = *>"
  end
  
  example "token with a `+=' list label hoisted to root with `^'" do
    result = parse( <<-'END', :a, 'a' )
      grammar TokenListLabelRuleRoot;
      options {language=Ruby;output=AST;}
      a : id+=ID^ ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'a'
  end
  
  example "token with a list `+=' label trashed with `!'" do
    result = parse( <<-'END', :a, 'a' )
      grammar TokenListLabelBang;
      options {language=Ruby;output=AST;}
      a : id+=ID! ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == ''
  end
  
  example "using list `+=' labels to collect trees of invoked rules" do
    result = parse( <<-'END', :a, 'a b' )
      grammar RuleListLabel;
      options {language=Ruby;output=AST;}
      a returns [result]: x+=b x+=b {
      t = $x[1]
      $result = "2nd x=#{t.inspect},"
      };
      b : ID;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '2nd x=b,a b'
  end
  
  example "using a list `+=' label to collect the trees of invoked rules within a (...)+ block" do
    result = parse( <<-'END', :a, 'a b' )
      grammar RuleListLabelRuleRoot;
      options {language=Ruby;output=AST;}
      a returns [result] : ( x+=b^ )+ {
      $result = "x=\%s," \% $x[1].inspect
      } ;
      b : ID;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == 'x=(b a),(b a)'
  end
  
  example "trashing the tree of an invoked rule with `!' while collecting the tree with a list `+=' label" do
    result = parse( <<-'END', :a, 'a b' )
      grammar RuleListLabelBang;
      options {language=Ruby;output=AST;}
      a returns [result] : x+=b! x+=b {
      $result = "1st x=#{$x[0].inspect},"
      } ;
      b : ID;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == '1st x=a,b'
  end
  
  example "a whole bunch of different elements" do
    result = parse( <<-'END', :a, 'a b b c c d' )
      grammar ComplicatedMelange;
      options {language=Ruby;output=AST;}
      a : A b=B b=B c+=C c+=C D {s = $D.text} ;
      A : 'a' ;
      B : 'b' ;
      C : 'c' ;
      D : 'd' ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    result.should == 'a b b c c d'
  end
  
  example "rule return values in addition to AST output" do
    result = parse( <<-'END', :a, 'abc 34' )
      grammar ReturnValueWithAST;
      options {language=Ruby;output=AST;}
      a returns [result] : ID b { $result = $b.i.to_s + "\n" } ;
      b returns [i] : INT {$i=$INT.text.to_i};
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
  
    END
    result.should == "34\nabc 34"
  end
  
  example "a (...)+ loop containing a token-type set" do
    result = parse( <<-'END', :r, 'abc 34 d' )
      grammar SetLoop;
      options { language=Ruby;output=AST; }
      r : (INT|ID)+ ; 
      ID : 'a'..'z' + ;
      INT : '0'..'9' +;
      WS: (' ' | '\n' | '\t')+ {$channel = HIDDEN;};
    
    END
    result.should == 'abc 34 d'
  end
  
end
