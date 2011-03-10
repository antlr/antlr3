#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestImportedGrammars < ANTLR3::Test::Functional
  
  def load( grammar )
    grammar.compile
    $:.unshift( grammar.output_directory ) unless $:.include?( grammar.output_directory )
    for file in grammar.target_files( false )
      require File.basename( file, '.rb' )
    end
  end
  
  example 'delegator invokes delegate rule' do
    inline_grammar( <<-'END' )
      parser grammar DIDRSlave;
      options { language=Ruby; }
      @members {
        def capture(t)
          @didr_master.capture(t)
        end
      }
      a : B { capture("S.a") } ;
    END
    load inline_grammar( <<-'END' )
      grammar DIDRMaster;
      options { language=Ruby; }
      import DIDRSlave;
      
      @members { include ANTLR3::Test::CaptureOutput }
      
      s : a ;
      B : 'b' ;
      WS : (' '|'\n') { skip() } ;
    END
    
    lexer = DIDRMaster::Lexer.new( 'b' )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = DIDRMaster::Parser.new( tokens )
    parser.s
    parser.output.should == 'S.a'
  end
  
  example 'delegator invokes delegate rule with args' do
    inline_grammar( <<-'END' )
      parser grammar Slave2;
      options {
          language=Ruby;
      }
      @members {
        def capture(t)
          @master_2.capture(t)
        end
      }
      a[x] returns [y] : B {capture("S.a"); $y="1000";} ;
    END
    load inline_grammar( <<-'END' )
      grammar Master2;
      options {language=Ruby;}
      import Slave2;
      
      @members { include ANTLR3::Test::CaptureOutput }
      
      s : label=a[3] {capture($label.y)} ;
      B : 'b' ;
      WS : (' '|'\n') {skip} ;
    END
    lexer = Master2::Lexer.new( 'b' )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = Master2::Parser.new( tokens )
    parser.s
    parser.output.should == 'S.a1000'
  end
  
  example "delegator accesses delegate members" do
    inline_grammar( <<-'END' )
      parser grammar Slave3;
      options {
          language=Ruby;
      }
      @members {
        def capture(t)
          @master_3.capture(t)
        end
        
        def whatevs
          capture("whatevs")
        end
      }
      a : B ;
    END
    load inline_grammar( <<-'END' )
      grammar Master3;
      options {
        language=Ruby;
      }
      import Slave3;
      @members { include ANTLR3::Test::CaptureOutput }
      
      s : 'b' {@slave_3.whatevs} ;
      WS : (' '|'\n') {skip()} ;
    END
    
    parser = Master3::Parser.new( Master3::Lexer.new( 'b' ) )
    parser.s
    parser.output.should == 'whatevs'
  end
  
  example "delegator invokes first version of delegate rule" do
    inline_grammar( <<-'END' )
      parser grammar Slave4A;
      options {
          language=Ruby;
      }
      @members {
        def capture(t)
          @master_4.capture(t)
        end
      }
      a : b {capture("S.a")} ;
      b : B ;
    END
    inline_grammar( <<-'END' )
      parser grammar Slave4B;
      options {
        language=Ruby;
      }
      @members {
        def capture(t)
          @master_4.capture(t)
        end
      }
      a : B {capture("T.a")} ;
    END
    load inline_grammar( <<-'END' )
      grammar Master4;
      options {
        language=Ruby;
      }
      import Slave4A, Slave4B;
      @members { include ANTLR3::Test::CaptureOutput }
      s : a ;
      B : 'b' ;
      WS : (' '|'\n') {skip} ;
    END
    
    parser = Master4::Parser.new( Master4::Lexer.new( 'b' ) )
    parser.s
    parser.output.should == 'S.a'
  end
  
  example "delegates see same token type" do
    inline_grammar( <<-'END' )
      parser grammar Slave5A; // A, B, C token type order
      options {
        language=Ruby;
      }
      tokens { A; B; C; }
      @members {
        def capture(t)
          @master_5.capture(t)
        end
      }
      x : A {capture("S.x ")} ;
    END
    inline_grammar( <<-'END' )
      parser grammar Slave5B;
      options {
        language=Ruby;
      }
      tokens { C; B; A; } /// reverse order
      @members {
        def capture(t)
          @master_5.capture(t)
        end
      }
      y : A {capture("T.y")} ;
    END
    load inline_grammar( <<-'END' )
      grammar Master5;
      options {
          language=Ruby;
      }
      import Slave5A, Slave5B;
      @members { include ANTLR3::Test::CaptureOutput }
      s : x y ; // matches AA, which should be "aa"
      B : 'b' ; // another order: B, A, C
      A : 'a' ;
      C : 'c' ;
      WS : (' '|'\n') {skip} ;
    END
    
    lexer = Master5::Lexer.new( 'aa' )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = Master5::Parser.new( tokens )
    parser.s
    parser.output.should == 'S.x T.y'
  end
  
  example "delegator rule overrides delegate" do
    inline_grammar( <<-'END' )
      parser grammar Slave6;
      options {
          language=Ruby;
      }
      @members {
        def capture(t)
          @master_6.capture(t)
        end
      }
      a : b {capture("S.a")} ;
      b : B ;
    END
    load inline_grammar( <<-'END' )
      grammar Master6;
      options { language=Ruby; }
      import Slave6;
      @members { include ANTLR3::Test::CaptureOutput }
      b : 'b'|'c' ;
      WS : (' '|'\n') {skip} ;
    END
    
    parser = Master6::Parser.new( Master6::Lexer.new( 'c' ) )
    parser.a
    parser.output.should == 'S.a'
  end
  
  example "lexer delegator invokes delegate rule" do
    inline_grammar( <<-'END' )
      lexer grammar Slave7;
      options {
        language=Ruby;
      }                                                                       
      @members {
        def capture(t)
          @master_7.capture(t)
        end
      }
      A : 'a' {capture("S.A ")} ;
      C : 'c' ;
    END
    load inline_grammar( <<-'END' )
      lexer grammar Master7;
      options {
        language=Ruby;
      }
      import Slave7;
      @members { include ANTLR3::Test::CaptureOutput }
      B : 'b' ;
      WS : (' '|'\n') {skip} ;
    END
    
    lexer = Master7::Lexer.new( 'abc' )
    lexer.map { |tk| lexer.capture( tk.text ) }
    lexer.output.should == 'S.A abc'
  end
  
  example "lexer delegator rule overrides delegate" do
    inline_grammar( <<-'END' )
      lexer grammar Slave8;
      options {language=Ruby;}
      @members {
        def capture(t)
          @master_8.capture(t)
        end
      }
      A : 'a' {capture("S.A")} ;
    END
    load inline_grammar( <<-'END' )
      lexer grammar Master8;
      options {language=Ruby;}
      import Slave8;
      @members { include ANTLR3::Test::CaptureOutput }
      A : 'a' {capture("M.A ")} ;
      WS : (' '|'\n') {skip} ;
    END
    
    lexer = Master8::Lexer.new( 'a' )
    lexer.map { |tk| lexer.capture( tk.text ) }
    lexer.output.should == 'M.A a'
  end

  example "delegator rule with syntactic predicates" do
    inline_grammar( <<-'END' )
      parser grammar Slave9;
      options { language=Ruby; }
      @members {
        def capture(t)
          @master_9.capture(t)
        end
      }
      a : b c;
      c : ('c' 'b')=> 'c' 'b' { capture("(cb)") }
        | ('c' 'c')=> 'c'
        ;
    END
    load inline_grammar( <<-'END' )
      grammar Master9;
      options { language=Ruby; }
      import Slave9;
      @members { include ANTLR3::Test::CaptureOutput }
      b : ('b' 'b')=> 'b' 'b'
        | ('b' 'c')=> 'b' {capture("(bc)")}
        ;
      WS : (' '|'\n') {skip} ;
    END
    
    parser = Master9::Parser.new( Master9::Lexer.new( 'bcb' ) )
    parser.a
    parser.output.should == '(bc)(cb)'
  end
  
  example "lots of imported lexers" do
    inline_grammar( <<-'END' )
      lexer grammar SlaveOfSlaves;
      options { language=Ruby; }
      
      INTEGER: ('+'|'-')? DIGITS;
      FLOAT: INTEGER '.' DIGITS (('e'|'E') INTEGER)?;
      fragment DIGITS: ('0'..'9')+;
    END
    inline_grammar( <<-'END' )
      lexer grammar FirstSlave;
      options { language=Ruby; }
      
      import SlaveOfSlaves;
      
      ID: ('A'..'Z')+;
      OPS: '+' | '-' | '*' | '/';
    END
    inline_grammar( <<-'END' )
      lexer grammar SecondSlave;
      options { language=Ruby; }
      
      INT: ('0'..'9')+;
      ID: ('a'..'z'|'A'..'Z'|'_')+;
    END
    load inline_grammar( <<-'END' )
      lexer grammar MasterOfAll;
      options { language=Ruby; }
      
      import FirstSlave, SecondSlave;
      
      ID: ('a'..'z'|'A'..'Z'|'_')+;
      WS: ' '+ { $channel=HIDDEN };
    END
    
    MasterOfAll::Lexer.master_grammars.should == []
    MasterOfAll::Lexer.imported_grammars.should == Set[ :FirstSlave, :SecondSlave ]
    MasterOfAll::Lexer.master.should be_nil
    
    MasterOfAll::FirstSlave.master_grammars.should == [ :MasterOfAll ]
    MasterOfAll::FirstSlave.imported_grammars.should == Set[ :SlaveOfSlaves ]
    MasterOfAll::FirstSlave.master.should == :MasterOfAll
    
    MasterOfAll::SecondSlave.master_grammars.should == [ :MasterOfAll ]
    MasterOfAll::SecondSlave.imported_grammars.should == Set[ ]
    MasterOfAll::SecondSlave.master.should == :MasterOfAll
    
    MasterOfAll::FirstSlave::SlaveOfSlaves.master_grammars.should == [ :MasterOfAll, :FirstSlave ]
    MasterOfAll::FirstSlave::SlaveOfSlaves.imported_grammars.should == Set[ ]
    MasterOfAll::FirstSlave::SlaveOfSlaves.master.should == :FirstSlave
    
    master = MasterOfAll::Lexer.new( 'blah de blah' )
    master.should respond_to :first_slave
    master.should respond_to :second_slave
    master.first_slave.should respond_to :slave_of_slaves
    master.first_slave.should respond_to :master_of_all
    master.first_slave.slave_of_slaves.should respond_to :first_slave
    master.first_slave.slave_of_slaves.should respond_to :master_of_all
    dels = master.each_delegate.map { |d| d }
    dels.should have( 2 ).things
    dels.should include master.first_slave
    dels.should include master.second_slave
  end
  
end
