#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestTreeParser1 < ANTLR3::Test::Functional
  
  example "flat list" do
    compile_and_load inline_grammar( <<-'END' )
      grammar FlatList;
      options {
          language=Ruby;
          output=AST;
      }
      a : ID INT;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    compile_and_load inline_grammar( <<-'END' )
      tree grammar FlatListWalker;
      options {
          language=Ruby;
          ASTLabelType=CommonTree;
      }
      @members { include ANTLR3::Test::CaptureOutput }
      a : ID INT
          {self.capture("\%s, \%s" \% [$ID, $INT])}
        ;
    END
    
    lexer  = FlatList::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = FlatList::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = FlatListWalker::TreeParser.new( nodes )
    walker.a
    walker.output.should == "abc, 34"
  end
  
  example "simple tree" do
    compile_and_load inline_grammar( <<-'END' )
      grammar SimpleTree;
      options {
          language=Ruby;
          output=AST;
      }
      a : ID INT -> ^(ID INT);
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\\n') {$channel=HIDDEN;} ;
    END
    compile_and_load inline_grammar( <<-'END' )
      tree grammar SimpleTreeWalker;
      options {
          language=Ruby;
          ASTLabelType=CommonTree;
      }
      @members { include ANTLR3::Test::CaptureOutput }
      
      a : ^(ID INT)
          {capture('\%s, \%s' \% [$ID, $INT])}
        ;
    END
    lexer  = SimpleTree::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = SimpleTree::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = SimpleTreeWalker::TreeParser.new( nodes )
    walker.a
    walker.output.should == "abc, 34"
  end
  
  example "flat vs tree decision" do
    compile_and_load inline_grammar( <<-'END' )
      grammar FlatVsTreeDecision;
      options {
          language=Ruby;
          output=AST;
      }
      a : b c ;
      b : ID INT -> ^(ID INT);
      c : ID INT;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\\n') {$channel=HIDDEN;} ;
    END
    compile_and_load inline_grammar( <<-'END' )
      tree grammar FlatVsTreeDecisionWalker;
      options {
          language=Ruby;
          ASTLabelType=CommonTree;
      }
      @members { include ANTLR3::Test::CaptureOutput }
      
      a : b b ;
      b : ID INT    {capture("\%s \%s\n" \% [$ID, $INT])}
        | ^(ID INT) {capture("^(\%s \%s)" \% [$ID, $INT])}
        ;
    END
    lexer  = FlatVsTreeDecision::Lexer.new( "a 1 b 2" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = FlatVsTreeDecision::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = FlatVsTreeDecisionWalker::TreeParser.new( nodes )
    walker.a
    walker.output.should == "^(a 1)b 2\n"
  end
  
  example "flat vs tree decision2" do
    compile_and_load inline_grammar( <<-'END' )
      grammar FlatVsTreeDecision2;
      options {
          language=Ruby;
          output=AST;
      }
      a : b c ;
      b : ID INT+ -> ^(ID INT+);
      c : ID INT+;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    compile_and_load inline_grammar( <<-'END' )
      tree grammar FlatVsTreeDecision2Walker;
      options {
          language=Ruby;
          ASTLabelType=CommonTree;
      }
      @members { include ANTLR3::Test::CaptureOutput }
      a : b b ;
      b : ID INT+    {say("#{$ID} #{$INT}")}
        | ^(x=ID (y=INT)+) {capture("^(#{$x} #{$y})")}
        ;
    END
    lexer  = FlatVsTreeDecision2::Lexer.new( "a 1 2 3 b 4 5" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = FlatVsTreeDecision2::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = FlatVsTreeDecision2Walker::TreeParser.new( nodes )
    walker.a
    walker.output.should == "^(a 3)b 5\n"
  end
  
  example "cyclic dfa lookahead" do
    compile_and_load inline_grammar( <<-'END' )
      grammar CyclicDFALookahead;
      options {
          language=Ruby;
          output=AST;
      }
      a : ID INT+ PERIOD;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      SEMI : ';' ;
      PERIOD : '.' ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    compile_and_load inline_grammar( <<-'END' )
      tree grammar CyclicDFALookaheadWalker;
      options {
          language=Ruby;
          ASTLabelType=CommonTree;
      }
      @members { include ANTLR3::Test::CaptureOutput }
      a : ID INT+ PERIOD {capture("alt 1")}
        | ID INT+ SEMI   {capture("alt 2")}
        ;
    END
    lexer  = CyclicDFALookahead::Lexer.new( "a 1 2 3." )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = CyclicDFALookahead::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = CyclicDFALookaheadWalker::TreeParser.new( nodes )
    walker.a
    walker.output.should == "alt 1"
  end
  
  example "nullable child list" do
    compile_and_load inline_grammar( <<-'END' )
      grammar NullableChildList;
      options {
          language=Ruby;
          output=AST;
      }
      a : ID INT? -> ^(ID INT?);
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      WS : (' '|'\\n') {$channel=HIDDEN;} ;
    END
    compile_and_load inline_grammar( <<-'END' )
      tree grammar NullableChildListWalker;
      options {
          language=Ruby;
          ASTLabelType=CommonTree;
      }
      @members { include ANTLR3::Test::CaptureOutput }
      a : ^(ID INT?)
          {capture($ID.to_s)}
        ;
    END
    lexer  = NullableChildList::Lexer.new( "abc" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = NullableChildList::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = NullableChildListWalker::TreeParser.new( nodes )
    walker.a
    walker.output.should == "abc"
  end
  
  example "nullable child list2" do
    compile_and_load inline_grammar( <<-'END' )
      grammar NullableChildList2;
      options {
          language=Ruby;
          output=AST;
      }
      a : ID INT? SEMI -> ^(ID INT?) SEMI ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      SEMI : ';' ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    compile_and_load inline_grammar( <<-'END' )
      tree grammar NullableChildList2Walker;
      options {
          language=Ruby;
          ASTLabelType=CommonTree;
      }
      @members { include ANTLR3::Test::CaptureOutput }
      a : ^(ID INT?) SEMI
          {capture($ID.to_s)}
        ;
    END
    lexer  = NullableChildList2::Lexer.new( "abc;" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = NullableChildList2::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = NullableChildList2Walker::TreeParser.new( nodes )
    walker.a
    walker.output.should == "abc"
  end
  
  example "nullable child list3" do
    compile_and_load inline_grammar( <<-'END' )
      grammar NullableChildList3;
      options {
          language=Ruby;
          output=AST;
      }
      a : x=ID INT? (y=ID)? SEMI -> ^($x INT? $y?) SEMI ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      SEMI : ';' ;
      WS : (' '|'\\n') {$channel=HIDDEN;} ;
    END
    compile_and_load inline_grammar( <<-'END' )
      tree grammar NullableChildList3Walker;
      options {
          language=Ruby;
          ASTLabelType=CommonTree;
      }
      @members { include ANTLR3::Test::CaptureOutput }
      a : ^(ID INT? b) SEMI
          {self.capture($ID.to_s + ", " + $b.text.to_s)}
        ;
      b : ID? ;
    END
    lexer  = NullableChildList3::Lexer.new( "abc def;" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = NullableChildList3::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = NullableChildList3Walker::TreeParser.new( nodes )
    walker.a
    walker.output.should == "abc, def"
  end
  
  example "actions after root" do
    compile_and_load inline_grammar( <<-'END' )
      grammar ActionsAfterRoot;
      options {
          language=Ruby;
          output=AST;
      }
      a : x=ID INT? SEMI -> ^($x INT?) ;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      SEMI : ';' ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    compile_and_load inline_grammar( <<-'END' )
      tree grammar ActionsAfterRootWalker;
      options {
          language=Ruby;
          ASTLabelType=CommonTree;
      }
      @members { include ANTLR3::Test::CaptureOutput }
      a @init {x=0} : ^(ID {x=1} {x=2} INT?)
          {say( $ID.to_s + ", " + x.to_s )}
        ;
    END
    lexer  = ActionsAfterRoot::Lexer.new( "abc;" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = ActionsAfterRoot::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = ActionsAfterRootWalker::TreeParser.new( nodes )
    walker.a
    walker.output.should == "abc, 2\n"
  end
  
  example "wildcard lookahead" do
    compile_and_load inline_grammar( <<-'END' )
      grammar WildcardLookahead;
      options {language=Ruby; output=AST;}
      a : ID '+'^ INT;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      SEMI : ';' ;
      PERIOD : '.' ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    compile_and_load inline_grammar( <<-'END' )
      tree grammar WildcardLookaheadWalker;
      options {language=Ruby; tokenVocab=WildcardLookahead; ASTLabelType=CommonTree;}
      @members { include ANTLR3::Test::CaptureOutput }
      a : ^('+' . INT) { capture("alt 1") }
        ;
    END
    lexer  = WildcardLookahead::Lexer.new( "a + 2" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = WildcardLookahead::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = WildcardLookaheadWalker::TreeParser.new( nodes )
    walker.a
    walker.output.should == "alt 1"
  end
  
  example "wildcard lookahead2" do
    compile_and_load inline_grammar( <<-'END' )
      grammar WildcardLookahead2;
      options {language=Ruby; output=AST;}
      a : ID '+'^ INT;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      SEMI : ';' ;
      PERIOD : '.' ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    compile_and_load inline_grammar( <<-'END' )
      tree grammar WildcardLookahead2Walker;
      options {language=Ruby; tokenVocab=WildcardLookahead2; ASTLabelType=CommonTree;}
      @members { include ANTLR3::Test::CaptureOutput }
      a : ^('+' . INT) { capture("alt 1") }
        | ^('+' . .)   { capture("alt 2") }
        ;
    END
    lexer  = WildcardLookahead2::Lexer.new( "a + 2" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = WildcardLookahead2::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = WildcardLookahead2Walker::TreeParser.new( nodes )
    walker.a
    walker.output.should == "alt 1"
  end
  
  example "wildcard lookahead3" do
    compile_and_load inline_grammar( <<-'END' )
      grammar WildcardLookahead3;
      options {language=Ruby; output=AST;}
      a : ID '+'^ INT;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      SEMI : ';' ;
      PERIOD : '.' ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    compile_and_load inline_grammar( <<-'END' )
      tree grammar WildcardLookahead3Walker;
      options {language=Ruby; tokenVocab=WildcardLookahead3; ASTLabelType=CommonTree;}
      @members { include ANTLR3::Test::CaptureOutput }
      a : ^('+' ID INT) { capture("alt 1") }
        | ^('+' . .)   { capture("alt 2") }
        ;
    END
    lexer  = WildcardLookahead3::Lexer.new( "a + 2" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = WildcardLookahead3::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = WildcardLookahead3Walker::TreeParser.new( nodes )
    walker.a
    walker.output.should == "alt 1"
  end
  
  example "wildcard plus lookahead" do
    compile_and_load inline_grammar( <<-'END' )
      grammar WildcardPlusLookahead;
      options {language=Ruby; output=AST;}
      a : ID '+'^ INT;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+;
      SEMI : ';' ;
      PERIOD : '.' ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    END
    compile_and_load inline_grammar( <<-'END' )
      tree grammar WildcardPlusLookaheadWalker;
      options {language=Ruby; tokenVocab=WildcardPlusLookahead; ASTLabelType=CommonTree;}
      @members { include ANTLR3::Test::CaptureOutput }
      a : ^('+' INT INT ) { capture("alt 1") }
        | ^('+' .+)   { capture("alt 2") }
        ;
    END
    lexer  = WildcardPlusLookahead::Lexer.new( "a + 2" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = WildcardPlusLookahead::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = WildcardPlusLookaheadWalker::TreeParser.new( nodes )
    walker.a
    walker.output.should == "alt 2"
  end
  
end


class TestTreeParser2 < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    grammar GenericLanguage;
    options {
        language = Ruby;
        output=AST;
    }
    
    tokens {
        VAR_DEF;
        ARG_DEF;
        FUNC_HDR;
        FUNC_DECL;
        FUNC_DEF;
        BLOCK;
    }
    
    program
        :   declaration+
        ;
    
    declaration
        :   variable
        |   functionHeader ';' -> ^(FUNC_DECL functionHeader)
        |   functionHeader block -> ^(FUNC_DEF functionHeader block)
        ;
    
    variable
        :   type declarator ';' -> ^(VAR_DEF type declarator)
        ;
    
    declarator
        :   ID 
        ;
    
    functionHeader
        :   type ID '(' ( formalParameter ( ',' formalParameter )* )? ')'
            -> ^(FUNC_HDR type ID formalParameter+)
        ;
    
    formalParameter
        :   type declarator -> ^(ARG_DEF type declarator)
        ;
    
    type
        :   'int'   
        |   'char'  
        |   'void'
        |   ID        
        ;
    
    block
        :   lc='{'
                variable*
                stat*
            '}'
            -> ^(BLOCK[$lc,"BLOCK"] variable* stat*)
        ;
    
    stat: forStat
        | expr ';'!
        | block
        | assignStat ';'!
        | ';'!
        ;
    
    forStat
        :   'for' '(' start=assignStat ';' expr ';' next=assignStat ')' block
            -> ^('for' $start expr $next block)
        ;
    
    assignStat
        :   ID EQ expr -> ^(EQ ID expr)
        ;
    
    expr:   condExpr
        ;
    
    condExpr
        :   aexpr ( ('=='^ | '<'^) aexpr )?
        ;
    
    aexpr
        :   atom ( '+'^ atom )*
        ;
    
    atom
        : ID      
        | INT      
        | '(' expr ')' -> expr
        ; 
    
    FOR : 'for' ;
    INT_TYPE : 'int' ;
    CHAR: 'char';
    VOID: 'void';
    
    ID  :   ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
        ;
    
    INT :	('0'..'9')+
        ;
    
    EQ   : '=' ;
    EQEQ : '==' ;
    LT   : '<' ;
    PLUS : '+' ;
    
    WS  :   (   ' '
            |   '\t'
            |   '\r'
            |   '\n'
            )+
            { $channel=HIDDEN }
        ;
  END

  inline_grammar( <<-'END' )
    tree grammar GenericLanguageWalker;
    options {
        language = Ruby;
        tokenVocab = GenericLanguage;
        ASTLabelType = CommonTree;
    }
    
    @init { @traces = [] }
    @members {
      attr_reader :traces
      
      def trace_in(rule_name, rule_index)
        @traces << ">#{rule_name}"
      end
      
      def trace_out(rule_name, rule_index)
        @traces << "<#{rule_name}"
      end
    }
    
    program
        :   declaration+
        ;
    
    declaration
        :   variable
        |   ^(FUNC_DECL functionHeader)
        |   ^(FUNC_DEF functionHeader block)
        ;
    
    variable returns [res]
        :   ^(VAR_DEF type declarator)
            { 
                $res = $declarator.text; 
            }
        ;
    
    declarator
        :   ID 
        ;
    
    functionHeader
        :   ^(FUNC_HDR type ID formalParameter+)
        ;
    
    formalParameter
        :   ^(ARG_DEF type declarator)
        ;
    
    type
        :   'int'
        |   'char'
        |   'void'
        |   ID        
        ;
    
    block
        :   ^(BLOCK variable* stat*)
        ;
    
    stat: forStat
        | expr
        | block
        ;
    
    forStat
        :   ^('for' expr expr expr block)
        ;
    
    expr:   ^(EQEQ expr expr)
        |   ^(LT expr expr)
        |   ^(PLUS expr expr)
        |   ^(EQ ID expr)
        |   atom
        ;
    
    atom
        : ID      
        | INT      
        ;
  END
  
  compile_options :trace => true
  
  example "processing AST output from a parser with a tree parser" do
    input_source = <<-END.fixed_indent( 0 )
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
    
    lexer = GenericLanguage::Lexer.new( input_source )
    parser = GenericLanguage::Parser.new( lexer )
    
    expected_tree = <<-END.strip!.gsub!( /\s+/, ' ' )
      (VAR_DEF char c)
      (VAR_DEF int x)
      (FUNC_DECL (FUNC_HDR void bar (ARG_DEF int x)))
      (FUNC_DEF
        (FUNC_HDR int foo (ARG_DEF int y) (ARG_DEF char d))
        (BLOCK
          (VAR_DEF int i)
          (for (= i 0) (< i 3) (= i (+ i 1))
            (BLOCK (= x 3) (= y 5)))))
    END
    
    result = parser.program
    result.tree.inspect.should == expected_tree
    
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = parser.input
    tree_parser = GenericLanguageWalker::TreeParser.new( nodes )
    
    tree_parser.program
    tree_parser.traces.should == %w(
      >program          >declaration      >variable         >type           
      <type             >declarator       <declarator       <variable       
      <declaration      >declaration      >variable         >type           
      <type             >declarator       <declarator       <variable       
      <declaration      >declaration      >functionHeader   >type           
      <type             >formalParameter  >type             <type           
      >declarator       <declarator       <formalParameter  <functionHeader 
      <declaration      >declaration      >functionHeader   >type           
      <type             >formalParameter  >type             <type           
      >declarator       <declarator       <formalParameter  >formalParameter
      >type             <type             >declarator       <declarator     
      <formalParameter  <functionHeader   >block            >variable       
      >type             <type             >declarator       <declarator     
      <variable         >stat             >forStat          >expr           
      >expr             >atom             <atom             <expr           
      <expr             >expr             >expr             >atom           
      <atom             <expr             >expr             >atom           
      <atom             <expr             <expr             >expr           
      >expr             >expr             >atom             <atom           
      <expr             >expr             >atom             <atom           
      <expr             <expr             <expr             >block          
      >stat             >expr             >expr             >atom           
      <atom             <expr             <expr             <stat           
      >stat             >expr             >expr             >atom           
      <atom             <expr             <expr             <stat           
      <block            <forStat          <stat             <block          
      <declaration      <program        
    )
  end
  
  example 'tree parser rule label property references' do
    input = "char c;\n"
    lexer  = GenericLanguage::Lexer.new( "char c;\n" )
    parser = GenericLanguage::Parser.new( lexer )
    
    result = parser.variable
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = parser.input
    
    tree_parser = GenericLanguageWalker::TreeParser.new( nodes )
    tree_parser.variable.should == 'c'
  end
  
end
