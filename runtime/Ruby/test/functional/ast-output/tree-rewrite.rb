#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'


class TestASTRewritingTreeParsers < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
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
  
  inline_grammar( <<-'END' )
    tree grammar FlatListWalker;
    options {
      language=Ruby;
      output=AST;
      ASTLabelType=CommonTree;
      tokenVocab=FlatList;
    }
    
    a : ID INT -> INT ID;
  END

  inline_grammar( <<-'END' )
    grammar SimpleTree;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID INT -> ^(ID INT);
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar SimpleTreeWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=SimpleTree;
    }
    a : ^(ID INT) -> ^(INT ID);
  END

  inline_grammar( <<-END )
    grammar CombinedRewriteAndAuto;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID INT -> ^(ID INT) | INT ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-END )
    tree grammar CombinedRewriteAndAutoTree;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=CombinedRewriteAndAuto;
    }
    a : ^(ID INT) -> ^(INT ID) | INT;
  END

  inline_grammar( <<-'END' )
    grammar AvoidDup;
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
    tree grammar AvoidDupWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=AvoidDup;
    }
    a : ID -> ^(ID ID);
  END

  inline_grammar( <<-'END' )
    grammar Loop;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID+ INT+ -> (^(ID INT))+ ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar LoopWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=Loop;
    }
    a : (^(ID INT))+ -> INT+ ID+;
  END

  inline_grammar( <<-'END' )
    grammar AutoDup;
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
    tree grammar AutoDupWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=AutoDup;
    }
    a : ID;
  END

  inline_grammar( <<-'END' )
    grammar AutoDupRule;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID INT ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar AutoDupRuleWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=AutoDupRule;
    }
    a : b c ;
    b : ID ;
    c : INT ;
  END

  inline_grammar( <<-'END' )
    grammar AutoWildcard;
    options {language=Ruby;output=AST;}
    a : ID INT ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar AutoWildcardWalker;
    options {language=Ruby;output=AST; ASTLabelType=CommonTree; tokenVocab=AutoWildcard;}
    a : ID . 
      ;
  END
  
  inline_grammar( <<-'END' )
    grammar AutoWildcard2;
    options {language=Ruby;output=AST;}
    a : ID INT -> ^(ID INT);
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar AutoWildcard2Walker;
    options {language=Ruby;output=AST; ASTLabelType=CommonTree; tokenVocab=AutoWildcard2;}
    a : ^(ID .) 
      ;
  END

  inline_grammar( <<-'END' )
    grammar AutoWildcardWithLabel;
    options {language=Ruby;output=AST;}
    a : ID INT ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar AutoWildcardWithLabelWalker;
    options {language=Ruby;output=AST; ASTLabelType=CommonTree; tokenVocab=AutoWildcardWithLabel;}
    a : ID c=. 
      ;
  END

  inline_grammar( <<-'END' )
    grammar AutoWildcardWithListLabel;
    options {language=Ruby;output=AST;}
    a : ID INT ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END
  
  inline_grammar( <<-'END' )
    tree grammar AutoWildcardWithListLabelWalker;
    options {language=Ruby;output=AST; ASTLabelType=CommonTree; tokenVocab=AutoWildcardWithListLabel;}
    a : ID c+=. 
      ;
  END
  
  inline_grammar( <<-'END' )
    grammar AutoDupMultiple;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID ID INT;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar AutoDupMultipleWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=AutoDupMultiple;
    }
    a : ID ID INT
      ;
  END

  inline_grammar( <<-'END' )
    grammar AutoDupTree;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID INT -> ^(ID INT);
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar AutoDupTreeWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=AutoDupTree;
    }
    a : ^(ID INT)
      ;
  END

  inline_grammar( <<-'END' )
    grammar AutoDupTreeWithLabels;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID INT -> ^(ID INT);
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar AutoDupTreeWithLabelsWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=AutoDupTreeWithLabels;
    }
    a : ^(x=ID y=INT)
      ;
  END

  inline_grammar( <<-'END' )
    grammar AutoDupTreeWithListLabels;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID INT -> ^(ID INT);
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar AutoDupTreeWithListLabelsWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=AutoDupTreeWithListLabels;
    }
    a : ^(x+=ID y+=INT)
      ;
  END

  inline_grammar( <<-'END' )
    grammar AutoDupTreeWithRuleRoot;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID INT -> ^(ID INT);
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar AutoDupTreeWithRuleRootWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=AutoDupTreeWithRuleRoot;
    }
    a : ^(b INT) ;
    b : ID ;
  END

  inline_grammar( <<-'END' )
    grammar AutoDupTreeWithRuleRootAndLabels;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID INT -> ^(ID INT);
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar AutoDupTreeWithRuleRootAndLabelsWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=AutoDupTreeWithRuleRootAndLabels;
    }
    a : ^(x=b INT) ;
    b : ID ;
  END

  inline_grammar( <<-'END' )
    grammar AutoDupTreeWithRuleRootAndListLabels;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID INT -> ^(ID INT);
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar AutoDupTreeWithRuleRootAndListLabelsWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=AutoDupTreeWithRuleRootAndListLabels;
    }
    a : ^(x+=b y+=c) ;
    b : ID ;
    c : INT ;
  END

  inline_grammar( <<-'END' )
    grammar AutoDupNestedTree;
    options {
        language=Ruby;
        output=AST;
    }
    a : x=ID y=ID INT -> ^($x ^($y INT));
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar AutoDupNestedTreeWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=AutoDupNestedTree;
    }
    a : ^(ID ^(ID INT))
      ;
  END

  inline_grammar( <<-'END' )
    grammar Delete;
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
    tree grammar DeleteWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=Delete;
    }
    a : ID -> 
      ;
  END

  inline_grammar( <<-'END' )
    grammar SetMatchNoRewrite;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID INT ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar SetMatchNoRewriteWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=SetMatchNoRewrite;
    }
    a : b INT;
    b : ID | INT;
  END

  inline_grammar( <<-'END' )
    grammar SetOptionalMatchNoRewrite;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID INT ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar SetOptionalMatchNoRewriteWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=SetOptionalMatchNoRewrite;
    }
    a : (ID|INT)? INT ;
  END

  inline_grammar( <<-'END' )
    grammar SetMatchNoRewriteLevel2;
    options {
        language=Ruby;
        output=AST;
    }
    a : x=ID INT -> ^($x INT);
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar SetMatchNoRewriteLevel2Walker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=SetMatchNoRewriteLevel2;
    }
    a : ^(ID (ID | INT) ) ;
  END

  inline_grammar( <<-'END' )
    grammar SetMatchNoRewriteLevel2Root;
    options {
        language=Ruby;
        output=AST;
    }
    a : x=ID INT -> ^($x INT);
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar SetMatchNoRewriteLevel2RootWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=SetMatchNoRewriteLevel2Root;
    }
    a : ^((ID | INT) INT) ;
  END

  inline_grammar( <<-END )
    grammar RewriteModeCombinedRewriteAndAuto;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID INT -> ^(ID INT) | INT ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-END )
    tree grammar RewriteModeCombinedRewriteAndAutoTree;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=RewriteModeCombinedRewriteAndAuto;
        rewrite=true;
    }
    a : ^(ID INT) -> ^(ID["ick"] INT)
      | INT // leaves it alone, returning $a.start
      ;
  END

  inline_grammar( <<-'END' )
    grammar RewriteModeFlatTree;
    options {
      language=Ruby;
      output=AST;
    }
    a : ID INT -> ID INT | INT ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar RewriteModeFlatTreeWalker;
    options {
      language=Ruby;
      output=AST;
      ASTLabelType=CommonTree;
      tokenVocab=RewriteModeFlatTree;
      rewrite=true;
    }
    s : ID a ;
    a : INT -> INT["1"]
      ;
  END

  inline_grammar( <<-'END' )
    grammar RewriteModeChainRuleFlatTree;
    options {language=Ruby; output=AST;}
    a : ID INT -> ID INT | INT ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar RewriteModeChainRuleFlatTreeWalker;
    options {language=Ruby; output=AST; ASTLabelType=CommonTree; tokenVocab=RewriteModeChainRuleFlatTree; rewrite=true;}
    s : a ;
    a : b ;
    b : ID INT -> INT ID
      ;
  END

  inline_grammar( <<-'END' )
    grammar RewriteModeChainRuleTree;
    options {language=Ruby; output=AST;}
    a : ID INT -> ^(ID INT) ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar RewriteModeChainRuleTreeWalker;
    options {language=Ruby; output=AST; ASTLabelType=CommonTree; tokenVocab=RewriteModeChainRuleTree; rewrite=true;}
    s : a ;
    a : b ; // a.tree must become b.tree
    b : ^(ID INT) -> INT
      ;
  END

  inline_grammar( <<-'END' )
    grammar RewriteModeChainRuleTree2;
    options {language=Ruby; output=AST;}
    a : ID INT -> ^(ID INT) ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar RewriteModeChainRuleTree2Walker;
    options {language=Ruby; output=AST; ASTLabelType=CommonTree; tokenVocab=RewriteModeChainRuleTree2; rewrite=true;}
    tokens { X; }
    s : a* b ; // only b contributes to tree, but it's after a*; s.tree = b.tree
    a : X ;
    b : ^(ID INT) -> INT
      ;
  END

  inline_grammar( <<-'END' )
    grammar RewriteModeChainRuleTree3;
    options {language=Ruby; output=AST;}
    a : 'boo' ID INT -> 'boo' ^(ID INT) ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar RewriteModeChainRuleTree3Walker;
    options {language=Ruby; output=AST; ASTLabelType=CommonTree; tokenVocab=RewriteModeChainRuleTree3; rewrite=true;}
    tokens { X; }
    s : 'boo' a* b ; // don't reset s.tree to b.tree due to 'boo'
    a : X ;
    b : ^(ID INT) -> INT
      ;
  END

  inline_grammar( <<-'END' )
    grammar RewriteModeChainRuleTree4;
    options {language=Ruby; output=AST;}
    a : 'boo' ID INT -> ^('boo' ^(ID INT)) ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar RewriteModeChainRuleTree4Walker;
    options {language=Ruby; output=AST; ASTLabelType=CommonTree; tokenVocab=RewriteModeChainRuleTree4; rewrite=true;}
    tokens { X; }
    s : ^('boo' a* b) ; // don't reset s.tree to b.tree due to 'boo'
    a : X ;
    b : ^(ID INT) -> INT
      ;
  END

  inline_grammar( <<-'END' )
    grammar RewriteModeChainRuleTree5;
    options {language=Ruby; output=AST;}
    a : 'boo' ID INT -> ^('boo' ^(ID INT)) ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar RewriteModeChainRuleTree5Walker;
    options {language=Ruby; output=AST; ASTLabelType=CommonTree; tokenVocab=RewriteModeChainRuleTree5; rewrite=true;}
    tokens { X; }
    s : ^(a b) ; // s.tree is a.tree
    a : 'boo' ;
    b : ^(ID INT) -> INT
      ;
  END

  inline_grammar( <<-'END' )
    grammar RewriteOfRuleRef;
    options {language=Ruby; output=AST;}
    a : ID INT -> ID INT | INT ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar RewriteOfRuleRefWalker;
    options {language=Ruby; output=AST; ASTLabelType=CommonTree; tokenVocab=RewriteOfRuleRef; rewrite=true;}
    s : a -> a ;
    a : ID INT -> ID INT ;
  END

  inline_grammar( <<-'END' )
    grammar RewriteOfRuleRefRoot;
    options {language=Ruby; output=AST;}
    a : ID INT INT -> ^(INT ^(ID INT));
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar RewriteOfRuleRefRootWalker;
    options {language=Ruby; output=AST; ASTLabelType=CommonTree; tokenVocab=RewriteOfRuleRefRoot; rewrite=true;}
    s : ^(a ^(ID INT)) -> a ;
    a : INT ;
  END

  inline_grammar( <<-'END' )
    grammar RewriteOfRuleRefRootLabeled;
    options {language=Ruby; output=AST;}
    a : ID INT INT -> ^(INT ^(ID INT));
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar RewriteOfRuleRefRootLabeledWalker;
    options {language=Ruby; output=AST; ASTLabelType=CommonTree; tokenVocab=RewriteOfRuleRefRootLabeled; rewrite=true;}
    s : ^(label=a ^(ID INT)) -> a ;
    a : INT ;
  END

  inline_grammar( <<-'END' )
    grammar RewriteOfRuleRefRootListLabeled;
    options {language=Ruby; output=AST;}
    a : ID INT INT -> ^(INT ^(ID INT));
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar RewriteOfRuleRefRootListLabeledWalker;
    options {language=Ruby; output=AST; ASTLabelType=CommonTree; tokenVocab=RewriteOfRuleRefRootListLabeled; rewrite=true;}
    s : ^(label+=a ^(ID INT)) -> a ;
    a : INT ;
  END

  inline_grammar( <<-'END' )
    grammar RewriteOfRuleRefChild;
    options {language=Ruby; output=AST;}
    a : ID INT -> ^(ID ^(INT INT));
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar RewriteOfRuleRefChildWalker;
    options {language=Ruby; output=AST; ASTLabelType=CommonTree; tokenVocab=RewriteOfRuleRefChild; rewrite=true;}
    s : ^(ID a) -> a ;
    a : ^(INT INT) ;
  END

  inline_grammar( <<-'END' )
    grammar RewriteOfRuleRefLabel;
    options {language=Ruby; output=AST;}
    a : ID INT -> ^(ID ^(INT INT));
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar RewriteOfRuleRefLabelWalker;
    options {language=Ruby; output=AST; ASTLabelType=CommonTree; tokenVocab=RewriteOfRuleRefLabel; rewrite=true;}
    s : ^(ID label=a) -> a ;
    a : ^(INT INT) ;
  END

  inline_grammar( <<-'END' )
    grammar RewriteOfRuleRefListLabel;
    options {language=Ruby; output=AST;}
    a : ID INT -> ^(ID ^(INT INT));
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar RewriteOfRuleRefListLabelWalker;
    options {language=Ruby; output=AST; ASTLabelType=CommonTree; tokenVocab=RewriteOfRuleRefListLabel; rewrite=true;}
    s : ^(ID label+=a) -> a ;
    a : ^(INT INT) ;
  END

  inline_grammar( <<-'END' )
    grammar RewriteModeWithPredicatedRewrites;
    options {
      language=Ruby;
      output=AST;
    }
    a : ID INT -> ^(ID["root"] ^(ID INT)) | INT -> ^(ID["root"] INT) ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar RewriteModeWithPredicatedRewritesWalker;
    options {
      language=Ruby;
      output=AST;
      ASTLabelType=CommonTree;
      tokenVocab=RewriteModeWithPredicatedRewrites;
      rewrite=true;
    }
    s : ^(ID a) {
      # self.buf += $s.start.inspect
    };
    a : ^(ID INT) -> {true}? ^(ID["ick"] INT)
                  -> INT
      ;
  END

  inline_grammar( <<-'END' )
    grammar WildcardSingleNode;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID INT -> ^(ID["root"] INT);
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar WildcardSingleNodeWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=WildcardSingleNode;
    }
    s : ^(ID c=.) -> $c
    ;
  END

  inline_grammar( <<-'END' )
    grammar WildcardUnlabeledSingleNode;
    options {language=Ruby; output=AST;}
    a : ID INT -> ^(ID INT);
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar WildcardUnlabeledSingleNodeWalker;
    options {language=Ruby; output=AST; ASTLabelType=CommonTree; tokenVocab=WildcardUnlabeledSingleNode;}
    s : ^(ID .) -> ID
      ;
  END

  inline_grammar( <<-'END' )
    grammar WildcardListLabel;
    options {language=Ruby; output=AST;}
    a : INT INT INT ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END
  
  inline_grammar( <<-'END' )
    tree grammar WildcardListLabelWalker;
    options {language=Ruby; output=AST; ASTLabelType=CommonTree; tokenVocab=WildcardListLabel;}
    s : (c+=.)+ -> $c+
      ;
  END
  
  inline_grammar( <<-'END' )
    grammar WildcardListLabel2;
    options {language=Ruby; output=AST; ASTLabelType=CommonTree;}
    a  : x=INT y=INT z=INT -> ^($x ^($y $z) ^($y $z));
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END
  
  inline_grammar( <<-'END' )
    tree grammar WildcardListLabel2Walker;
    options {language=Ruby; output=AST; ASTLabelType=CommonTree; tokenVocab=WildcardListLabel2; rewrite=true;}
    s : ^(INT (c+=.)+) -> $c+
      ;
  END

  inline_grammar( <<-'END' )
    grammar WildcardGrabsSubtree;
    options {language=Ruby; output=AST;}
    a : ID x=INT y=INT z=INT -> ^(ID[\"root\"] ^($x $y $z));
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END

  inline_grammar( <<-'END' )
    tree grammar WildcardGrabsSubtreeWalker;
    options {language=Ruby; output=AST; ASTLabelType=CommonTree; tokenVocab=WildcardGrabsSubtree;}
    s : ^(ID c=.) -> $c
      ;
  END
  
  inline_grammar( <<-'END' )
    grammar WildcardGrabsSubtree2;
    options {language=Ruby; output=AST;}
    a : ID x=INT y=INT z=INT -> ID ^($x $y $z);
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\n') {$channel=HIDDEN;} ;
  END
  
  inline_grammar( <<-'END' )
    tree grammar WildcardGrabsSubtree2Walker;
    options {language=Ruby; output=AST; ASTLabelType=CommonTree; tokenVocab=WildcardGrabsSubtree2;}
    s : ID c=. -> $c
      ;
  END

  inline_grammar( <<-END )
    grammar CombinedRewriteAndAuto;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID INT -> ^(ID INT) | INT ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\\n') {$channel=HIDDEN;} ;
  END
  
  inline_grammar( <<-END )
    tree grammar CombinedRewriteAndAutoWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=CombinedRewriteAndAuto;
    }
    a : ^(ID INT) -> ^(INT ID) | INT;
  END

  inline_grammar( <<-END )
    grammar RewriteModeCombinedRewriteAndAuto;
    options {
        language=Ruby;
        output=AST;
    }
    a : ID INT -> ^(ID INT) | INT ;
    ID : 'a'..'z'+ ;
    INT : '0'..'9'+;
    WS : (' '|'\\n') {$channel=HIDDEN;} ;
  END
  
  inline_grammar( <<-END )
    tree grammar RewriteModeCombinedRewriteAndAutoWalker;
    options {
        language=Ruby;
        output=AST;
        ASTLabelType=CommonTree;
        tokenVocab=RewriteModeCombinedRewriteAndAuto;
        rewrite=true;
    }
    a : ^(ID INT) -> ^(ID["ick"] INT)
      | INT // leaves it alone, returning $a.start
      ;
  END
  
  example "flat list" do
    lexer  = FlatList::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = FlatList::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = FlatListWalker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "34 abc"
  end

  example "simple tree" do
    lexer  = SimpleTree::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = SimpleTree::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = SimpleTreeWalker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(34 abc)"
  end

  example "combined rewrite and auto" do
    lexer  = CombinedRewriteAndAuto::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = CombinedRewriteAndAuto::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = CombinedRewriteAndAutoWalker::TreeParser.new( nodes )
    result = walker.a.tree
    result.inspect.should == '(34 abc)'
    lexer  = CombinedRewriteAndAuto::Lexer.new( "34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = CombinedRewriteAndAuto::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = CombinedRewriteAndAutoWalker::TreeParser.new( nodes )
    result = walker.a.tree
    result.inspect.should == '34'
  end

  example "avoid dup" do
    lexer  = AvoidDup::Lexer.new( "abc" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = AvoidDup::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = AvoidDupWalker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(abc abc)"
  end
  
  example "loop" do
    lexer  = Loop::Lexer.new( "a b c 3 4 5" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = Loop::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = LoopWalker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "3 4 5 a b c"
  end
  
  example "auto dup" do
    lexer  = AutoDup::Lexer.new( "abc" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = AutoDup::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = AutoDupWalker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "abc"
  end

  example "auto dup rule" do
    lexer  = AutoDupRule::Lexer.new( "a 1" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = AutoDupRule::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = AutoDupRuleWalker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "a 1"
  end

  example "auto wildcard" do
    lexer  = AutoWildcard::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = AutoWildcard::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = AutoWildcardWalker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "abc 34"
  end

  example "auto wildcard2" do
    lexer  = AutoWildcard2::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = AutoWildcard2::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = AutoWildcard2Walker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(abc 34)"
  end

  example "auto wildcard with label" do
    lexer  = AutoWildcardWithLabel::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = AutoWildcardWithLabel::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = AutoWildcardWithLabelWalker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "abc 34"
  end

  example "auto wildcard with list label" do
    lexer  = AutoWildcardWithListLabel::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = AutoWildcardWithListLabel::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = AutoWildcardWithListLabelWalker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "abc 34"
  end

  example "auto dup multiple" do
    lexer  = AutoDupMultiple::Lexer.new( "a b 3" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = AutoDupMultiple::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = AutoDupMultipleWalker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "a b 3"
  end

  example "auto dup tree" do
    lexer  = AutoDupTree::Lexer.new( "a 3" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = AutoDupTree::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = AutoDupTreeWalker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(a 3)"
  end

  example "auto dup tree with labels" do
    lexer  = AutoDupTreeWithLabels::Lexer.new( "a 3" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = AutoDupTreeWithLabels::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = AutoDupTreeWithLabelsWalker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(a 3)"
  end

  example "auto dup tree with list labels" do
    lexer  = AutoDupTreeWithListLabels::Lexer.new( "a 3" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = AutoDupTreeWithListLabels::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = AutoDupTreeWithListLabelsWalker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(a 3)"
  end

  example "auto dup tree with rule root" do
    lexer  = AutoDupTreeWithRuleRoot::Lexer.new( "a 3" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = AutoDupTreeWithRuleRoot::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = AutoDupTreeWithRuleRootWalker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(a 3)"
  end

  example "auto dup tree with rule root and labels" do
    lexer  = AutoDupTreeWithRuleRootAndLabels::Lexer.new( "a 3" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = AutoDupTreeWithRuleRootAndLabels::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = AutoDupTreeWithRuleRootAndLabelsWalker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(a 3)"
  end

  example "auto dup tree with rule root and list labels" do
    lexer  = AutoDupTreeWithRuleRootAndListLabels::Lexer.new( "a 3" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = AutoDupTreeWithRuleRootAndListLabels::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = AutoDupTreeWithRuleRootAndListLabelsWalker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(a 3)"
  end

  example "auto dup nested tree" do
    lexer  = AutoDupNestedTree::Lexer.new( "a b 3" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = AutoDupNestedTree::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = AutoDupNestedTreeWalker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(a (b 3))"
  end

  example "delete" do
    lexer  = Delete::Lexer.new( "abc" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = Delete::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = DeleteWalker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == ""
  end

  example "set match no rewrite" do
    lexer  = SetMatchNoRewrite::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = SetMatchNoRewrite::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = SetMatchNoRewriteWalker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "abc 34"
  end

  example "set optional match no rewrite" do
    lexer  = SetOptionalMatchNoRewrite::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = SetOptionalMatchNoRewrite::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = SetOptionalMatchNoRewriteWalker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "abc 34"
  end

  example "set match no rewrite level2" do
    lexer  = SetMatchNoRewriteLevel2::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = SetMatchNoRewriteLevel2::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = SetMatchNoRewriteLevel2Walker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(abc 34)"
  end

  example "set match no rewrite level2 root" do
    lexer  = SetMatchNoRewriteLevel2Root::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = SetMatchNoRewriteLevel2Root::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = SetMatchNoRewriteLevel2RootWalker::TreeParser.new( nodes )
    result = walker.a
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(abc 34)"
  end

  example "rewrite mode combined rewrite and auto" do
    
    parser_test = proc do |input, expected_output|
      lexer = RewriteModeCombinedRewriteAndAuto::Lexer.new( input )
      tokens = ANTLR3::CommonTokenStream.new( lexer )
      parser = RewriteModeCombinedRewriteAndAuto::Parser.new( tokens )
      result = parser.a
      nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
      nodes.token_stream = tokens
      walker = RewriteModeCombinedRewriteAndAutoWalker::TreeParser.new( nodes )
      result = walker.a
      stree = result.tree.nil? ? '' : result.tree.inspect
      stree.should == expected_output
    end
    
    parser_test[ 'abc 34', '(ick 34)' ]
    parser_test[ '34', '34' ]
  end
  
  example "rewrite mode flat tree" do
    lexer  = RewriteModeFlatTree::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = RewriteModeFlatTree::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = RewriteModeFlatTreeWalker::TreeParser.new( nodes )
    result = walker.s
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "abc 1"
  end
  
  example "rewrite mode chain rule flat tree" do
    lexer  = RewriteModeChainRuleFlatTree::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = RewriteModeChainRuleFlatTree::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = RewriteModeChainRuleFlatTreeWalker::TreeParser.new( nodes )
    result = walker.s
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "34 abc"
  end

  example "rewrite mode chain rule tree" do
    lexer  = RewriteModeChainRuleTree::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = RewriteModeChainRuleTree::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = RewriteModeChainRuleTreeWalker::TreeParser.new( nodes )
    result = walker.s
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "34"
  end

  example "rewrite mode chain rule tree2" do
    lexer  = RewriteModeChainRuleTree2::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = RewriteModeChainRuleTree2::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = RewriteModeChainRuleTree2Walker::TreeParser.new( nodes )
    result = walker.s
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "34"
  end

  example "rewrite mode chain rule tree3" do
    lexer  = RewriteModeChainRuleTree3::Lexer.new( "boo abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = RewriteModeChainRuleTree3::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = RewriteModeChainRuleTree3Walker::TreeParser.new( nodes )
    result = walker.s
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "boo 34"
  end

  example "rewrite mode chain rule tree4" do
    lexer  = RewriteModeChainRuleTree4::Lexer.new( "boo abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = RewriteModeChainRuleTree4::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = RewriteModeChainRuleTree4Walker::TreeParser.new( nodes )
    result = walker.s
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(boo 34)"
  end

  example "rewrite mode chain rule tree5" do
    lexer  = RewriteModeChainRuleTree5::Lexer.new( "boo abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = RewriteModeChainRuleTree5::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = RewriteModeChainRuleTree5Walker::TreeParser.new( nodes )
    result = walker.s
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(boo 34)"
  end

  example "rewrite of rule ref" do
    lexer  = RewriteOfRuleRef::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = RewriteOfRuleRef::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = RewriteOfRuleRefWalker::TreeParser.new( nodes )
    result = walker.s
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "abc 34"
  end

  example "rewrite of rule ref root" do
    lexer  = RewriteOfRuleRefRoot::Lexer.new( "abc 12 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = RewriteOfRuleRefRoot::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = RewriteOfRuleRefRootWalker::TreeParser.new( nodes )
    result = walker.s
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(12 (abc 34))"
  end

  example "rewrite of rule ref root labeled" do
    lexer  = RewriteOfRuleRefRootLabeled::Lexer.new( "abc 12 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = RewriteOfRuleRefRootLabeled::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = RewriteOfRuleRefRootLabeledWalker::TreeParser.new( nodes )
    result = walker.s
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(12 (abc 34))"
  end

  example "rewrite of rule ref root list labeled" do
    lexer  = RewriteOfRuleRefRootListLabeled::Lexer.new( "abc 12 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = RewriteOfRuleRefRootListLabeled::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = RewriteOfRuleRefRootListLabeledWalker::TreeParser.new( nodes )
    result = walker.s
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(12 (abc 34))"
  end

  example "rewrite of rule ref child" do
    lexer  = RewriteOfRuleRefChild::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = RewriteOfRuleRefChild::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = RewriteOfRuleRefChildWalker::TreeParser.new( nodes )
    result = walker.s
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(34 34)"
  end

  example "rewrite of rule ref label" do
    lexer  = RewriteOfRuleRefLabel::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = RewriteOfRuleRefLabel::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = RewriteOfRuleRefLabelWalker::TreeParser.new( nodes )
    result = walker.s
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(34 34)"
  end

  example "rewrite of rule ref list label" do
    lexer  = RewriteOfRuleRefListLabel::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = RewriteOfRuleRefListLabel::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = RewriteOfRuleRefListLabelWalker::TreeParser.new( nodes )
    result = walker.s
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(34 34)"
  end
  
  example "rewrite mode with predicated rewrites" do
    lexer  = RewriteModeWithPredicatedRewrites::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = RewriteModeWithPredicatedRewrites::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = RewriteModeWithPredicatedRewritesWalker::TreeParser.new( nodes )
    result = walker.s
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(root (ick 34))"
  end
  
  example "wildcard single node" do
    lexer  = WildcardSingleNode::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = WildcardSingleNode::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = WildcardSingleNodeWalker::TreeParser.new( nodes )
    result = walker.s
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "34"
  end
  
  example "wildcard unlabeled single node" do
    lexer  = WildcardUnlabeledSingleNode::Lexer.new( "abc 34" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = WildcardUnlabeledSingleNode::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = WildcardUnlabeledSingleNodeWalker::TreeParser.new( nodes )
    result = walker.s
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "abc"
  end

  example "wildcard grabs subtree" do
    lexer  = WildcardGrabsSubtree::Lexer.new( "abc 1 2 3" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = WildcardGrabsSubtree::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = WildcardGrabsSubtreeWalker::TreeParser.new( nodes )
    result = walker.s
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(1 2 3)"
  end

  example "wildcard grabs subtree2" do
    lexer  = WildcardGrabsSubtree2::Lexer.new( "abc 1 2 3" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = WildcardGrabsSubtree2::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = WildcardGrabsSubtree2Walker::TreeParser.new( nodes )
    result = walker.s
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(1 2 3)"
  end

  example "wildcard list label" do
    lexer  = WildcardListLabel::Lexer.new( "1 2 3" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = WildcardListLabel::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = WildcardListLabelWalker::TreeParser.new( nodes )
    result = walker.s
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "1 2 3"
  end
  
  example "wildcard list label2" do
    lexer  = WildcardListLabel2::Lexer.new( "1 2 3" )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = WildcardListLabel2::Parser.new( tokens )
    
    result = parser.a
    nodes = ANTLR3::AST::CommonTreeNodeStream.new( result.tree )
    nodes.token_stream = tokens
    walker = WildcardListLabel2Walker::TreeParser.new( nodes )
    result = walker.s
    stree = result.tree.nil? ? '' : result.tree.inspect
    stree.should == "(2 3) (2 3)"
  end
  
end
