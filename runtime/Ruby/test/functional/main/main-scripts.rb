#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3'
require 'antlr3/test/functional'

ENV.delete( 'RUBYOPT' )
ENV[ 'RUBYLIB' ] = ANTLR3.library_path

class TestMainUtility < ANTLR3::Test::Functional
  
  example 'overriding the built-in script action using the @main named-action' do
    grammar = inline_grammar( <<-'END' )
      lexer grammar MainOverride;
      options { language = Ruby; }
      
      @main {
        raise( "the main block ran" )
      }
      
      ID: ('a'..'z' | '\u00c0'..'\u00ff')+;
      WS: ' '+ { $channel = HIDDEN; };
    END
    
    # when this grammar is compiled and the resulting ruby files
    # are loaded as a library, the custom @main block
    # should not be executed
    proc { compile_and_load( grammar ) }.should_not raise_error
    
    # this assertion verifies that the main region is executed
    # when the parser script is run directly
    lexer_script = grammar.target_files.first
    out = `ruby #{ lexer_script } 2>&1`.chomp
    out.should =~ /the main block ran/
  end
  
  example 'using Lexer.main() to run the built-in lexer utility script on a source file' do
    input_path = local_path( 'input.txt' )
    open( input_path, 'w' ) { |f| f.write( "yada yada" ) }
    
    compile_and_load inline_grammar( <<-'END' )
      lexer grammar LexerMainWithSourceFile;
      options { language = Ruby; }
      
      ID: 'a'..'z'+;
      WS: ' '+ { $channel = HIDDEN; };
    END
    
    begin
      output = StringIO.new
      input = File.open( input_path )
      LexerMainWithSourceFile::Lexer.main( [], :input => input, :output => output )
      
      out_lines = output.string.split( /\n/ )
      out_lines.should have( 3 ).things
    ensure
      File.delete( input_path )
    end
  end

  example 'using Lexer.main to run the built-in lexer utility script on input from $stdin' do
    input = StringIO.new( "yada yada" )    # <- used to simulate $stdin
    output = StringIO.new
    
    compile_and_load inline_grammar( <<-'END' )
      lexer grammar LexerMainFromStdIO;
      options { language = Ruby; }
      
      ID: 'a'..'z'+;
      WS: ' '+ { $channel = HIDDEN; };
    END
    
    LexerMainFromStdIO::Lexer.main( [], :input => input, :output => output )
    lines = output.string.split( /\n/ )
    lines.should have( 3 ).things
  end

  example 'using Parser.main to run the built-in parser script utility with a combo grammar' do
    compile_and_load inline_grammar( <<-'END' )
      grammar MainForCombined;
      options { language = Ruby; }
      r returns [res]: (ID)+ EOF { $res = $text; };
      
      ID: 'a'..'z'+;
      WS: ' '+ { $channel = HIDDEN; };
    END
    
    output = StringIO.new
    input = StringIO.new( 'yada yada' )
    
    MainForCombined::Parser.main( 
        %w(--rule r --lexer-name MainForCombined::Lexer),
        :input => input, :output => output )
    lines = output.string.split( "\n" )
    lines.should have( 4 ).things
  end
  
  example 'using built-in main to inspect AST constructed by an AST-building parser' do
    compile_and_load inline_grammar( <<-'END' )
      grammar ASTParserMain;
      options {
        language = Ruby;
        output = AST;
      }
      r: ID OP^ ID EOF!;
      
      ID: 'a'..'z'+;
      OP: '+';
      WS: ' '+ { $channel = HIDDEN; };
    END
    
    output = StringIO.new
    input  = StringIO.new 'yada + yada'
    ASTParserMain::Parser.main( 
      %w(--rule r --lexer-name ASTParserMain::Lexer),
      :input => input, :output => output )
    output = output.string.strip
    output.should == "(+ yada yada)"
  end
  
  example "using a tree parser's built-in main" do
    compile_and_load inline_grammar( <<-'END' )
      grammar TreeMain;
      options {
        language = Ruby;
        output = AST;
      }
      
      r: ID OP^ ID EOF!;
      
      ID: 'a'..'z'+;
      OP: '+';
      WS: ' '+ { $channel = HIDDEN; };
    END
    compile_and_load inline_grammar( <<-'END' )
      tree grammar TreeMainWalker;
      options {
        language=Ruby;
        ASTLabelType=CommonTree;
        tokenVocab=TreeMain;
      }
      r returns [res]: ^(OP a=ID b=ID)
        { $res = "\%s \%s \%s" \% [$a.text, $OP.text, $b.text] }
        ;
    END
    
    output = StringIO.new
    input  = StringIO.new 'a+b'
    
    TreeMainWalker::TreeParser.main( 
      %w(--rule r --parser-name TreeMain::Parser
         --parser-rule r --lexer-name TreeMain::Lexer),
      :input => input, :output => output )
    output = output.string.strip
    output.should == '"a + b"'
  end
  
  example "using a tree parser's built-in main to inspect AST rewrite output" do
    compile_and_load inline_grammar( <<-'END' )
      grammar TreeRewriteMain;
      options {
        language = Ruby;
        output = AST;
      }
      
      r: ID OP^ ID EOF!;
      
      ID: 'a'..'z'+;
      OP: '+';
      WS: ' '+ { $channel = HIDDEN; };
    END
    compile_and_load inline_grammar( <<-'END' )
      tree grammar TreeRewriteMainWalker;
      options {
        language=Ruby;
        ASTLabelType=CommonTree;
        tokenVocab=TreeRewriteMain;
        output=AST;
      }
      tokens { ARG; }
      r: ^(OP a=ID b=ID) -> ^(OP ^(ARG ID) ^(ARG ID));
    END
    
    output = StringIO.new
    input  = StringIO.new 'a+b'
    TreeRewriteMainWalker::TreeParser.main( 
      %w(--rule r --parser-name TreeRewriteMain::Parser
         --parser-rule r --lexer-name TreeRewriteMain::Lexer),
      :input => input, :output => output
    )
    
    output = output.string.strip
    output.should == '(+ (ARG a) (ARG b))'
  end
  
  example 'using built-in main with a delegating grammar' do
    inline_grammar( <<-'END' )
      parser grammar MainSlave;
      options { language=Ruby; }
      a : B;
    END
    master = inline_grammar( <<-'END' )
      grammar MainMaster;
      options { language=Ruby; }
      import MainSlave;
      s returns [res]: a { $res = $a.text };
      B : 'b' ; // defines B from inherited token space
      WS : (' '|'\n') {skip} ;
    END
    master.compile
    for file in master.target_files
      require( file )
    end
    
    output = StringIO.new
    input = StringIO.new 'b'
    
    MainMaster::Parser.main( 
      %w(--rule s --lexer-name MainMaster::Lexer),
      :input => input, :output => output )
    output = output.string.strip
    output.should == 'b'.inspect
  end

  #test :LexerEncoding do
  #  broken!("Non-ASCII encodings have not been implemented yet")
  #  grammar = inline_grammar(<<-'END')
  #    lexer grammar T3;
  #    options {
  #      language = Ruby;
  #      }
  #
  #    ID: ('a'..'z' | '\u00c0'..'\u00ff')+;
  #    WS: ' '+ { $channel = HIDDEN; };
  #  END
  #  compile grammar
  #  input = StringIO.new("föö bär")
  #  output = StringIO.new('')
  #  lexer_class.main(%w(--encoding utf-8), :input => input, :output => output)
  #  puts output.string
  #  lines = output.string.split(/\n/)
  #  lines.should have(3).things
  #end

end
