#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestASTConstructingParser < ANTLR3::Test::Functional

  compile inline_grammar( <<-'END' )
    grammar ASTBuilder;
    options {
      language = Ruby;
      output = AST;
    }
    
    tokens {
        VARDEF;
        FLOAT;
        EXPR;
        BLOCK;
        VARIABLE;
        FIELD;
        CALL;
        INDEX;
        FIELDACCESS;
    }
    
    @init {
      @flag = false
    }
    
    @members {
      attr_accessor :flag
      
      def report_error(e)
        # do nothing
      end
      
    }
    
    
    r1
        : INT ('+'^ INT)*
        ;
    
    r2
        : 'assert'^ x=expression (':'! y=expression)? ';'!
        ;
    
    r3
        : 'if'^ expression s1=statement ('else'! s2=statement)?
        ;
    
    r4
        : 'while'^ expression statement
        ;
    
    r5
        : 'return'^ expression? ';'!
        ;
    
    r6
        : (INT|ID)+
        ;
    
    r7
        : INT -> 
        ;
    
    r8
        : 'var' ID ':' type -> ^('var' type ID) 
        ;
    
    r9
        : type ID ';' -> ^(VARDEF type ID) 
        ;
    
    r10
        : INT -> { ANTLR3::AST::CommonTree.new(ANTLR3::CommonToken.create(:type => FLOAT, :text => ($INT.text + ".0")))}
        ;
    
    r11
        : expression -> ^(EXPR expression)
        | -> EXPR
        ;
    
    r12
        : ID (',' ID)* -> ID+
        ;
    
    r13
        : type ID (',' ID)* ';' -> ^(type ID+)
        ;
    
    r14
        :   expression? statement* type+
            -> ^(EXPR expression? statement* type+)
        ;
    
    r15
        : INT -> INT INT
        ;
    
    r16
        : 'int' ID (',' ID)* -> ^('int' ID)+
        ;
    
    r17
        : 'for' '(' start=statement ';' expression ';' next=statement ')' statement
            -> ^('for' $start expression $next statement)
        ;
    
    r18
        : t='for' -> ^(BLOCK)
        ;
    
    r19
        : t='for' -> ^(BLOCK[$t])
        ;
    
    r20
        : t='for' -> ^(BLOCK[$t,"FOR"])
        ;
    
    r21
        : t='for' -> BLOCK
        ;
    
    r22
        : t='for' -> BLOCK[$t]
        ;
    
    r23
        : t='for' -> BLOCK[$t,"FOR"]
        ;
    
    r24
        : r=statement expression -> ^($r expression)
        ;
    
    r25
        : r+=statement (',' r+=statement)+ expression -> ^($r expression)
        ;
    
    r26
        : r+=statement (',' r+=statement)+ -> ^(BLOCK $r+)
        ;
    
    r27
        : r=statement expression -> ^($r ^($r expression))
        ;
    
    r28
        : ('foo28a'|'foo28b') ->
        ;
    
    r29
        : (r+=statement)* -> ^(BLOCK $r+)
        ;
    
    r30
        : statement* -> ^(BLOCK statement?)
        ;
    
    r31
        : modifier type ID ('=' expression)? ';'
            -> {@flag == 0}? ^(VARDEF ID modifier* type expression?)
            -> {@flag == 1}? ^(VARIABLE ID modifier* type expression?)
            ->                   ^(FIELD ID modifier* type expression?)
        ;
    
    r32[which]
      : ID INT -> {which==1}? ID
               -> {which==2}? INT
               -> // yield nothing as else-clause
      ;
    
    r33
        :   modifiers! statement
        ;
    
    r34
        :   modifiers! r34a[$modifiers.tree]
        //|   modifiers! r33b[$modifiers.tree]
        ;
    
    r34a[mod]
        :   'class' ID ('extends' sup=type)?
            ( 'implements' i+=type (',' i+=type)*)?
            '{' statement* '}'
            -> ^('class' ID {$mod} ^('extends' $sup)? ^('implements' $i+)? statement* )
        ;
    
    r35
        : '{' 'extends' (sup=type)? '}'
            ->  ^('extends' $sup)?
        ;
    
    r36
        : 'if' '(' expression ')' s1=statement
            ( 'else' s2=statement -> ^('if' ^(EXPR expression) $s1 $s2)
            |                     -> ^('if' ^(EXPR expression) $s1)
            )
        ;
    
    r37
        : (INT -> INT) ('+' i=INT -> ^('+' $r37 $i) )* 
        ;
    
    r38
        : INT ('+'^ INT)*
        ;
    
    r39
        : (primary->primary) // set return tree to just primary
            ( '(' arg=expression ')'
                -> ^(CALL $r39 $arg)
            | '[' ie=expression ']'
                -> ^(INDEX $r39 $ie)
            | '.' p=primary
                -> ^(FIELDACCESS $r39 $p)
            )*
        ;
    
    r40
        : (INT -> INT) ( ('+' i+=INT)* -> ^('+' $r40 $i*) ) ';'
        ;
    
    r41
        : (INT -> INT) ( ('+' i=INT) -> ^($i $r41) )* ';'
        ;
    
    r42
        : ids+=ID (','! ids+=ID)*
        ;
    
    r43 returns [res]
        : ids+=ID! (','! ids+=ID!)* {$res = $ids.map { |id| id.text }}
        ;
    
    r44
        : ids+=ID^ (','! ids+=ID^)*
        ;
    
    r45
        : primary^
        ;
    
    r46 returns [res]
        : ids+=primary! (','! ids+=primary!)* {$res = $ids.map { |id| id.text }}
        ;
    
    r47
        : ids+=primary (','! ids+=primary)*
        ;
    
    r48
        : ids+=. (','! ids+=.)*
        ;
    
    r49
        : .^ ID
        ;
    
    r50
        : ID 
            -> ^({ANTLR3::AST::CommonTree.new(ANTLR3::CommonToken.create(:type => FLOAT, :text => "1.0"))} ID)
        ;
    
    /** templates tested:
        tokenLabelPropertyRef_tree
    */
    r51 returns [res]
        : ID t=ID ID
            { $res = $t.tree }
        ;
    
    /** templates tested:
        rulePropertyRef_tree
    */
    r52 returns [res]
    @after {
        $res = $tree
    }
        : ID
        ;
    
    /** templates tested:
        ruleLabelPropertyRef_tree
    */
    r53 returns [res]
        : t=primary
            { $res = $t.tree }
        ;
    
    /** templates tested:
        ruleSetPropertyRef_tree
    */
    r54 returns [res]
    @after {
        $tree = $t.tree;
    }
        : ID t=expression ID
        ;
    
    /** backtracking */
    r55
    options { backtrack=true; k=1; }
        : (modifier+ INT)=> modifier+ expression
        | modifier+ statement
        ;
    
    
    /** templates tested:
        rewriteTokenRef with len(args)>0
    */
    r56
        : t=ID* -> ID[$t,'foo']
        ;
    
    /** templates tested:
        rewriteTokenRefRoot with len(args)>0
    */
    r57
        : t=ID* -> ^(ID[$t,'foo'])
        ;
    
    /** templates tested:
        ???
    */
    r58
        : ({CommonTree.new(CommonToken.create(:type => FLOAT, :text => "2.0"))})^
        ;
    
    /** templates tested:
        rewriteTokenListLabelRefRoot
    */
    r59
        : (t+=ID)+ statement -> ^($t statement)+
        ;
    
    primary
        : ID
        ;
    
    expression
        : r1
        ;
    
    statement
        : 'fooze'
        | 'fooze2'
        ;
    
    modifiers
        : modifier+
        ;
    
    modifier
        : 'public'
        | 'private'
        ;
    
    type
        : 'int'
        | 'bool'
        ;
    
    ID : 'a'..'z' + ;
    INT : '0'..'9' +;
    WS: (' ' | '\n' | '\t')+ {$channel = HIDDEN;};
  END
  
  def self.ast_test( opts, &special_test )
    input = opts[ :input ]
    rule  = opts[ :rule ]
    expected_tree = opts[ :ast ]
    flag = opts[ :flag ]
    args = opts[ :arguments ] || []
    message = opts[ :message ] || rule.to_s #"should parse %p with rule %s and make tree %s" % [input, rule, expected_tree]
    
    example( message ) do
      lexer = ASTBuilder::Lexer.new( input )
      parser = ASTBuilder::Parser.new( lexer )
      parser.flag = flag unless flag.nil?
      result = parser.send( rule, *args )
      if special_test then instance_exec( result, &special_test )
      elsif expected_tree then
        result.tree.inspect.should == expected_tree
      else result.tree.should be_nil
      end
    end
  end
  
  ast_test :input => "1 + 2", :rule => :r1, :ast => "(+ 1 2)"
  
  ast_test :input => "assert 2+3", :rule => :r2, :ast => "(assert (+ 2 3))"
  
  ast_test :input => "assert 2+3 : 5", :rule => :r2, :ast => "(assert (+ 2 3) 5)"
  
  ast_test :input => "if 1 fooze", :rule => :r3, :ast => "(if 1 fooze)"
  
  ast_test :input => "if 1 fooze else fooze", :rule => :r3, :ast => "(if 1 fooze fooze)"
  
  ast_test :input => "while 2 fooze", :rule => :r4, :ast => "(while 2 fooze)"
  
  ast_test :input => "return;", :rule => :r5, :ast => "return"
  
  ast_test :input => "return 2+3;", :rule => :r5, :ast => "(return (+ 2 3))"
  
  ast_test :input => "3", :rule => :r6, :ast => "3"
  
  ast_test :input => "3 a", :rule => :r6, :ast => "3 a"
  
  ast_test :input => "3", :rule => :r7, :ast => nil
  
  ast_test :input => "var foo:bool", :rule => :r8, :ast => "(var bool foo)"
  
  ast_test :input => "int foo;", :rule => :r9, :ast => "(VARDEF int foo)"
  
  ast_test :input => "10", :rule => :r10, :ast => "10.0"
  
  ast_test :input => "1+2", :rule => :r11, :ast => "(EXPR (+ 1 2))"
  
  ast_test :input => "", :rule => :r11, :ast => "EXPR"
  
  ast_test :input => "foo", :rule => :r12, :ast => "foo"
  
  ast_test :input => "foo, bar, gnurz", :rule => :r12, :ast => "foo bar gnurz"
  
  ast_test :input => "int foo;", :rule => :r13, :ast => "(int foo)"
  
  ast_test :input => "bool foo, bar, gnurz;", :rule => :r13, :ast => "(bool foo bar gnurz)"
  
  ast_test :input => "1+2 int", :rule => :r14, :ast => "(EXPR (+ 1 2) int)"
  
  ast_test :input => "1+2 int bool", :rule => :r14, :ast => "(EXPR (+ 1 2) int bool)"
  
  ast_test :input => "int bool", :rule => :r14, :ast => "(EXPR int bool)"
  
  ast_test :input => "fooze fooze int bool", :rule => :r14, :ast => "(EXPR fooze fooze int bool)"
  
  ast_test :input => "7+9 fooze fooze int bool", :rule => :r14, :ast => "(EXPR (+ 7 9) fooze fooze int bool)"
  
  ast_test :input => "7", :rule => :r15, :ast => "7 7"
  
  ast_test :input => "int foo", :rule => :r16, :ast => "(int foo)"
  
  ast_test :input => "int foo, bar, gnurz", :rule => :r16, :ast => "(int foo) (int bar) (int gnurz)"
  
  ast_test :input => "for ( fooze ; 1 + 2 ; fooze ) fooze", :rule => :r17, :ast => "(for fooze (+ 1 2) fooze fooze)"
  
  ast_test :input => "for", :rule => :r18, :ast => "BLOCK"
  
  ast_test :input => "for", :rule => :r19, :ast => "for"
  
  ast_test :input => "for", :rule => :r20, :ast => "FOR"
  
  ast_test :input => "for", :rule => :r21, :ast => "BLOCK"
  
  ast_test :input => "for", :rule => :r22, :ast => "for"
  
  ast_test :input => "for", :rule => :r23, :ast => "FOR"
  
  ast_test :input => "fooze 1 + 2", :rule => :r24, :ast => "(fooze (+ 1 2))"
  
  ast_test :input => "fooze, fooze2 1 + 2", :rule => :r25, :ast => "(fooze (+ 1 2))"
  
  ast_test :input => "fooze, fooze2", :rule => :r26, :ast => "(BLOCK fooze fooze2)"
  
  ast_test :input => "fooze 1 + 2", :rule => :r27, :ast => "(fooze (fooze (+ 1 2)))"
  
  ast_test :input => "foo28a", :rule => :r28, :ast => nil
  
  ast_test :input => "public int gnurz = 1 + 2;", :rule => :r31, :ast => "(VARDEF gnurz public int (+ 1 2))", :flag => 0
  
  ast_test :input => "public int gnurz = 1 + 2;", :rule => :r31, :ast => "(VARIABLE gnurz public int (+ 1 2))", :flag => 1
  
  ast_test :input => "public int gnurz = 1 + 2;", :rule => :r31, :ast => "(FIELD gnurz public int (+ 1 2))", :flag => 2
  
  ast_test :input => 'gnurz 32', :rule => :r32, :arguments => [ 1 ], :flag => 2, :ast => 'gnurz'
  
  ast_test :input => 'gnurz 32', :rule => :r32, :arguments => [ 2 ], :flag => 2, :ast => '32'
  
  ast_test :input => 'gnurz', :rule => :r32, :arguments => [ 3 ], :flag => 2, :ast => nil
  
  ast_test :input => "public private fooze", :rule => :r33, :ast => "fooze"
  
  ast_test :input => "public class gnurz { fooze fooze2 }", :rule => :r34, :ast => "(class gnurz public fooze fooze2)"
  
  ast_test :input => "public class gnurz extends bool implements int, bool { fooze fooze2 }", :rule => :r34, :ast => "(class gnurz public (extends bool) (implements int bool) fooze fooze2)"
  
  ast_test :input => "if ( 1 + 2 ) fooze", :rule => :r36, :ast => "(if (EXPR (+ 1 2)) fooze)"
  
  ast_test :input => "1 + 2 + 3", :rule => :r37, :ast => "(+ (+ 1 2) 3)"
  
  ast_test :input => "1 + 2 + 3", :rule => :r38, :ast => "(+ (+ 1 2) 3)"
  
  ast_test :input => "gnurz[1]", :rule => :r39, :ast => "(INDEX gnurz 1)"
  
  ast_test :input => "gnurz(2)", :rule => :r39, :ast => "(CALL gnurz 2)"
  
  ast_test :input => "gnurz.gnarz", :rule => :r39, :ast => "(FIELDACCESS gnurz gnarz)"
  
  ast_test :input => "gnurz.gnarz.gnorz", :rule => :r39, :ast => "(FIELDACCESS (FIELDACCESS gnurz gnarz) gnorz)"
  
  ast_test :input => "1 + 2 + 3;", :rule => :r40, :ast => "(+ 1 2 3)"
  
  ast_test :input => "1 + 2 + 3;", :rule => :r41, :ast => "(3 (2 1))"
  
  ast_test :input => "gnurz, gnarz, gnorz", :rule => :r42, :ast => "gnurz gnarz gnorz"
  
  ast_test :input => "gnurz, gnarz, gnorz", :rule => :r43 do |result|
    result.tree.should be_nil
    result.res.should == %w(gnurz gnarz gnorz)
  end
  
  ast_test :input => 'gnurz, gnarz, gnorz', :rule => :r44, :ast => '(gnorz (gnarz gnurz))'
  
  ast_test :input => 'gnurz', :rule => :r45, :ast => 'gnurz'
  
  ast_test :input => 'gnurz, gnarz, gnorz', :rule => :r46 do |result|
    result.tree.should be_nil
    result.res.should == %w(gnurz gnarz gnorz)
  end
  
  ast_test :input => 'gnurz, gnarz, gnorz', :rule => :r47, :ast => 'gnurz gnarz gnorz'
  
  ast_test :input => 'gnurz, gnarz, gnorz', :rule => :r48, :ast => 'gnurz gnarz gnorz'
  
  ast_test :input => 'gnurz gnorz', :rule => :r49, :ast => '(gnurz gnorz)'
  
  ast_test :input => 'gnurz', :rule => :r50, :ast => '(1.0 gnurz)'
  
  ast_test :input => 'gnurza gnurzb gnurzc', :rule => :r51 do |result|
    result.res.inspect.should == 'gnurzb'
  end
  
  ast_test :input => 'gnurz', :rule => :r52, :ast => 'gnurz'
  
  ast_test :input => 'gnurz', :rule => :r53, :ast => 'gnurz'
  
  ast_test :input => 'gnurza 1 + 2 gnurzb', :rule => :r54, :ast => '(+ 1 2)'
  
  ast_test :input => 'public private 1 + 2', :rule => :r55, :ast => 'public private (+ 1 2)'
  
  ast_test :input => 'public fooze', :rule => :r55, :ast => 'public fooze'
  
  ast_test :input => 'a b c d', :rule => :r56, :ast => 'foo'
  
  ast_test :input => 'a b c d', :rule => :r57, :ast => 'foo'
  
  ast_test :input => 'a b c fooze', :rule => :r59, :ast => '(a fooze) (b fooze) (c fooze)'

end
