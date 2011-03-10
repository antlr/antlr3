#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3'
require 'fileutils'
require 'antlr3/test/functional'
#require 'antlr3/test/diff'

class ANTLRDebugger < Thread
  self.abort_on_exception = true
  attr_accessor :events, :success, :port
  include Timeout
  
  def initialize( port )
    @events = []
    @success = false
    @port = port
    
    super do
      timeout( 2 ) do
        begin
          @socket = TCPSocket.open( 'localhost', @port )
          #Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
          #@socket.connect( Socket.pack_sockaddr_in(@port, '127.0.0.1') )
        rescue Errno::ECONNREFUSED => error
          if $VERBOSE
            $stderr.printf( 
                "%s:%s received connection refuse error: %p\n",
                __FILE__, __LINE__, error
              )
            $stderr.puts( "sleeping for 0.1 seconds before retrying" )
          end
          sleep( 0.01 )
          retry
        end
      end
      
      @socket.readline.strip.should == 'ANTLR 2'
      @socket.readline.strip.start_with?( 'grammar "' ).should == true
      ack
      loop do
        event = @socket.readline.strip
        @events << event.split( "\t" )
        ack
        break if event == 'terminate'
      end
      
      @socket.close
      @success = true
    end
    
  end
  
  def ack
    @socket.write( "ACK\n" )
    @socket.flush
  end

end # ANTLRDebugger

class TestDebugGrammars < ANTLR3::Test::Functional
  compile_options :debug => true
  
  #include ANTLR3::Test::Diff
  
  def parse( grammar, rule, input, options = {} )
    @grammar = inline_grammar( grammar )
    @grammar.compile( self.class.compile_options )
    @grammar_path = File.expand_path( @grammar.path )
    for output_file in @grammar.target_files
      self.class.import( output_file )
    end
    grammar_module = self.class.const_get( @grammar.name )
    listener = options[ :listener ] or debugger = ANTLRDebugger.new( port = 49100 )
    
    begin
      lexer = grammar_module::Lexer.new( input )
      tokens = ANTLR3::CommonTokenStream.new( lexer )
      options[ :debug_listener ] = listener
      parser = grammar_module::Parser.new( tokens, options )
      parser.send( rule )
    ensure
      if listener.nil?
        debugger.join
        return( debugger )
      end
    end
  end
  
  example 'basic debug-mode parser using a RecordEventListener' do
    grammar = %q<
      grammar BasicParser;                      // line 1
      options {language=Ruby;}                  // line 2
      a : ID EOF;                               // line 3
      ID : 'a'..'z'+ ;                          // line 4
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    >
    listener = ANTLR3::Debug::RecordEventListener.new
    parse( grammar, :a, 'a', :listener => listener )
    lt_events, found = listener.events.partition { |event| event.start_with?( "(look): " ) }
    lt_events.should_not be_empty
    
    expected = [ "(enter_rule): rule=a",
                "(location): line=3 position=1",
                "(enter_alternative): number=1",
                "(location): line=3 position=5",
                "(location): line=3 position=8",
                "(location): line=3 position=11",
                "(exit_rule): rule=a" ]
    found.should == expected
  end
  
  example 'debug-mode parser using a socket proxy to transmit events' do
    grammar = %q<
      grammar SocketProxy;                   // line 1
      options {language=Ruby;}               // line 2
      a : ID EOF;                           // line 3
      ID : 'a'..'z'+ ;                       // line 4
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    >
    debugger = parse( grammar, :a, 'a' )
    debugger.success.should be_true
    expected = [ 
      [ 'enter_rule', @grammar_path, 'a' ],
      [ 'location', '3', '1' ],
      [ 'enter_alternative', '1' ],
      [ 'location', '3', '5' ],
      [ 'look', '1', '0', '4', 'default', '1', '0', '"a"' ],
      [ 'look', '1', '0', '4', 'default', '1', '0', '"a"' ],
      [ 'consume_token', '0', '4', 'default', '1', '0', '"a"' ],
      [ 'location', '3', '8' ],
      [ 'look', '1', '-1', '-1', 'default', '0', '-1', 'nil' ],
      [ 'look', '1', '-1', '-1', 'default', '0', '-1', 'nil' ],
      [ 'consume_token', '-1', '-1', 'default', '0', '-1', 'nil' ],
      [ 'location', '3', '11' ],
      [ 'exit_rule', @grammar_path, 'a' ],
      [ 'terminate' ]
    ]
    
    debugger.events.should == expected
  end
  
  example 'debug-mode parser events triggered by recognition errors' do
    grammar = %q<
      grammar RecognitionError;
      options { language=Ruby; }
      a : ID EOF;
      ID : 'a'..'z'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    >
    debugger = parse( grammar, :a, "a b" )
    debugger.success.should be_true
    
    expected = [ 
      [ "enter_rule", @grammar_path, "a" ],
      [ "location", "3", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "3", "5" ],
      [ "look", "1", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "look", "1", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "consume_token", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "consume_hidden_token", "1", "5", "hidden", "1", "1", '" "' ],
      [ "location", "3", "8" ],
      [ "look", "1", "2", "4", "default", "1", "2", "\"b\"" ],
      [ "look", "1", "2", "4", "default", "1", "2", "\"b\"" ],
      [ "look", "2", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "look", "1", "2", "4", "default", "1", "2", "\"b\"" ],
      [ "begin_resync" ],
      [ "consume_token", "2", "4", "default", "1", "2", "\"b\"" ],
      [ "end_resync" ],
      [ "recognition_exception", "ANTLR3::Error::UnwantedToken", "2", "1", "2" ],
      [ "consume_token", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "location", "3", "11" ],
      [ "exit_rule", @grammar_path, "a" ],
      [ "terminate" ]
    ]
    debugger.events.should == expected
  end
  
  example 'debug-mode parser events triggered by semantic predicate evaluation' do
    grammar = %q<
      grammar SemPred;
      options { language=Ruby; }
      a : {true}? ID EOF;
      ID : 'a'..'z'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    >
    
    debugger = parse( grammar, :a, "a" )
    debugger.success.should be_true
    
    expected = [ 
      [ "enter_rule", @grammar_path, "a" ],
      [ "location", "3", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "3", "5" ],
      [ "semantic_predicate", "true", '"true"' ],
      [ "location", "3", "13" ],
      [ "look", "1", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "look", "1", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "consume_token", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "location", "3", "16" ],
      [ "look", "1", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "look", "1", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "consume_token", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "location", "3", "19" ],
      [ "exit_rule", @grammar_path, "a" ],
      [ "terminate" ]
    ]
    debugger.events.should == expected
  end
  
  example 'debug-mode parser events triggered by recognizing a (...)+ block' do
    grammar = %q<
      grammar PositiveClosureBlock;
      options { language=Ruby; }
      a : ID ( ID | INT )+ EOF;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    >
    
    debugger = parse( grammar, :a, "a 1 b c 3" )
    debugger.success.should be_true
    
    expected = [ 
      [ "enter_rule", @grammar_path, "a" ],
      [ "location", "3", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "3", "5" ],
      [ "look", "1", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "look", "1", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "consume_token", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "consume_hidden_token", "1", "6", "hidden", "1", "1", '" "' ],
      [ "location", "3", "8" ],
      [ "enter_subrule", "1" ],
      [ "enter_decision", "1" ],
      [ "look", "1", "2", "5", "default", "1", "2", "\"1\"" ],
      [ "exit_decision", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "3", "8" ],
      [ "look", "1", "2", "5", "default", "1", "2", "\"1\"" ],
      [ "consume_token", "2", "5", "default", "1", "2", "\"1\"" ],
      [ "consume_hidden_token", "3", "6", "hidden", "1", "3", '" "' ],
      [ "enter_decision", "1" ],
      [ "look", "1", "4", "4", "default", "1", "4", "\"b\"" ],
      [ "exit_decision", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "3", "8" ],
      [ "look", "1", "4", "4", "default", "1", "4", "\"b\"" ],
      [ "consume_token", "4", "4", "default", "1", "4", "\"b\"" ],
      [ "consume_hidden_token", "5", "6", "hidden", "1", "5", '" "' ],
      [ "enter_decision", "1" ],
      [ "look", "1", "6", "4", "default", "1", "6", "\"c\"" ],
      [ "exit_decision", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "3", "8" ],
      [ "look", "1", "6", "4", "default", "1", "6", "\"c\"" ],
      [ "consume_token", "6", "4", "default", "1", "6", "\"c\"" ],
      [ "consume_hidden_token", "7", "6", "hidden", "1", "7", '" "' ],
      [ "enter_decision", "1" ],
      [ "look", "1", "8", "5", "default", "1", "8", "\"3\"" ],
      [ "exit_decision", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "3", "8" ],
      [ "look", "1", "8", "5", "default", "1", "8", "\"3\"" ],
      [ "consume_token", "8", "5", "default", "1", "8", "\"3\"" ],
      [ "enter_decision", "1" ],
      [ "look", "1", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "exit_decision", "1" ],
      [ "exit_subrule", "1" ],
      [ "location", "3", "22" ],
      [ "look", "1", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "look", "1", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "consume_token", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "location", "3", "25" ],
      [ "exit_rule", @grammar_path, "a" ],
      [ "terminate" ]
    ]
    
    debugger.events.should == expected
  end
  
  example 'debug-mode parser events triggered by recognizing a (...)* block' do
    grammar = %q<
      grammar ClosureBlock;
      options { language=Ruby; }
      a : ID ( ID | INT )* EOF;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    >
    
    debugger = parse( grammar, :a, "a 1 b c 3" )
    debugger.success.should be_true
    
    expected = [ 
      [ "enter_rule", @grammar_path, "a" ],
      [ "location", "3", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "3", "5" ],
      [ "look", "1", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "look", "1", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "consume_token", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "consume_hidden_token", "1", "6", "hidden", "1", "1", '" "' ],
      [ "location", "3", "8" ],
      [ "enter_subrule", "1" ],
      [ "enter_decision", "1" ],
      [ "look", "1", "2", "5", "default", "1", "2", "\"1\"" ],
      [ "exit_decision", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "3", "8" ],
      [ "look", "1", "2", "5", "default", "1", "2", "\"1\"" ],
      [ "consume_token", "2", "5", "default", "1", "2", "\"1\"" ],
      [ "consume_hidden_token", "3", "6", "hidden", "1", "3", '" "' ],
      [ "enter_decision", "1" ],
      [ "look", "1", "4", "4", "default", "1", "4", "\"b\"" ],
      [ "exit_decision", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "3", "8" ],
      [ "look", "1", "4", "4", "default", "1", "4", "\"b\"" ],
      [ "consume_token", "4", "4", "default", "1", "4", "\"b\"" ],
      [ "consume_hidden_token", "5", "6", "hidden", "1", "5", '" "' ],
      [ "enter_decision", "1" ],
      [ "look", "1", "6", "4", "default", "1", "6", "\"c\"" ],
      [ "exit_decision", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "3", "8" ],
      [ "look", "1", "6", "4", "default", "1", "6", "\"c\"" ],
      [ "consume_token", "6", "4", "default", "1", "6", "\"c\"" ],
      [ "consume_hidden_token", "7", "6", "hidden", "1", "7", '" "' ],
      [ "enter_decision", "1" ],
      [ "look", "1", "8", "5", "default", "1", "8", "\"3\"" ],
      [ "exit_decision", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "3", "8" ],
      [ "look", "1", "8", "5", "default", "1", "8", "\"3\"" ],
      [ "consume_token", "8", "5", "default", "1", "8", "\"3\"" ],
      [ "enter_decision", "1" ],
      [ "look", "1", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "exit_decision", "1" ],
      [ "exit_subrule", "1" ],
      [ "location", "3", "22" ],
      [ "look", "1", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "look", "1", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "consume_token", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "location", "3", "25" ],
      [ "exit_rule", @grammar_path, "a" ],
      [ "terminate" ]
    ]
    debugger.events.should == expected
  end
  
  example 'debug-mode parser events triggered by a mismatched set error' do
    grammar = %q<
      grammar MismatchedSetError;
      options { language=Ruby; }
      a : ID ( ID | INT ) EOF;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    >
    
    debugger = parse( grammar, :a, "a" )
    debugger.success.should be_true
    
    expected = [ 
      [ "enter_rule", @grammar_path, "a" ],
      [ "location", "3", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "3", "5" ],
      [ "look", "1", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "look", "1", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "consume_token", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "location", "3", "8" ],
      [ "look", "1", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "look", "1", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "recognition_exception", "ANTLR3::Error::MismatchedSet", "1", "0", "-1" ],
      [ "recognition_exception", "ANTLR3::Error::MismatchedSet", "1", "0", "-1" ],
      [ "begin_resync" ],
      [ "look", "1", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "end_resync" ],
      [ "location", "3", "24" ],
      [ "exit_rule", @grammar_path, "a" ],
      [ "terminate" ]
    ]
    
    debugger.events.should == expected
  end
  
  example 'debug-mode parser block-location events for subrules' do
    grammar = %q<
      grammar Block;
      options { language=Ruby; }
      a : ID ( b | c ) EOF;
      b : ID;
      c : INT;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    >
    
    debugger = parse( grammar, :a, "a 1" )
    debugger.success.should be_true
    
    expected = [ 
      [ "enter_rule", @grammar_path, "a" ],
      [ "location", "3", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "3", "5" ],
      [ "look", "1", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "look", "1", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "consume_token", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "consume_hidden_token", "1", "6", "hidden", "1", "1", '" "' ],
      [ "location", "3", "8" ],
      [ "enter_subrule", "1" ],
      [ "enter_decision", "1" ],
      [ "look", "1", "2", "5", "default", "1", "2", "\"1\"" ],
      [ "exit_decision", "1" ],
      [ "enter_alternative", "2" ],
      [ "location", "3", "14" ],
      [ "enter_rule", @grammar_path, "c" ],
      [ "location", "5", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "5", "5" ],
      [ "look", "1", "2", "5", "default", "1", "2", "\"1\"" ],
      [ "look", "1", "2", "5", "default", "1", "2", "\"1\"" ],
      [ "consume_token", "2", "5", "default", "1", "2", "\"1\"" ],
      [ "location", "5", "8" ],
      [ "exit_rule", @grammar_path, "c" ],
      [ "exit_subrule", "1" ],
      [ "location", "3", "18" ],
      [ "look", "1", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "look", "1", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "consume_token", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "location", "3", "21" ],
      [ "exit_rule", @grammar_path, "a" ],
      [ "terminate" ]
    ]
    debugger.events.should == expected
  end
  
  example 'debug-mode parser events triggered by a no viable alternative error' do
    grammar = %q<
      grammar NoViableAlt;
      options { language=Ruby; }
      a : ID ( b | c ) EOF;
      b : ID;
      c : INT;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+ ;
      BANG : '!' ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    >
    
    debugger = parse( grammar, :a, "a !" )
    debugger.success.should be_true
    
    expected = [ 
      [ "enter_rule", @grammar_path, "a" ],
      [ "location", "3", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "3", "5" ],
      [ "look", "1", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "look", "1", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "consume_token", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "consume_hidden_token", "1", "7", "hidden", "1", "1", '" "' ],
      [ "location", "3", "8" ],
      [ "enter_subrule", "1" ],
      [ "enter_decision", "1" ],
      [ "look", "1", "2", "6", "default", "1", "2", "\"!\"" ],
      [ "look", "1", "2", "6", "default", "1", "2", "\"!\"" ],
      [ "recognition_exception", "ANTLR3::Error::NoViableAlternative", "2", "1", "2" ],
      [ "exit_decision", "1" ],
      [ "exit_subrule", "1" ],
      [ "recognition_exception", "ANTLR3::Error::NoViableAlternative", "2", "1", "2" ],
      [ "begin_resync" ],
      [ "look", "1", "2", "6", "default", "1", "2", "\"!\"" ],
      [ "consume_token", "2", "6", "default", "1", "2", "\"!\"" ],
      [ "look", "1", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "end_resync" ],
      [ "location", "3", "21" ],
      [ "exit_rule", @grammar_path, "a" ],
      [ "terminate" ]
    ]
    debugger.events.should == expected
  end
  
  example 'debug-mode parser block-location events triggered by rules' do
    grammar = %q<
      grammar RuleBlock;
      options { language=Ruby; }
      a : b | c;
      b : ID;
      c : INT;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    >
    
    debugger = parse( grammar, :a, "1" )
    debugger.success.should be_true
    
    expected = [ 
      [ "enter_rule", @grammar_path, "a" ],
      [ "location", "3", "1" ],
      [ "enter_decision", "1" ],
      [ "look", "1", "0", "5", "default", "1", "0", "\"1\"" ],
      [ "exit_decision", "1" ],
      [ "enter_alternative", "2" ],
      [ "location", "3", "9" ],
      [ "enter_rule", @grammar_path, "c" ],
      [ "location", "5", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "5", "5" ],
      [ "look", "1", "0", "5", "default", "1", "0", "\"1\"" ],
      [ "look", "1", "0", "5", "default", "1", "0", "\"1\"" ],
      [ "consume_token", "0", "5", "default", "1", "0", "\"1\"" ],
      [ "location", "5", "8" ],
      [ "exit_rule", @grammar_path, "c" ],
      [ "location", "3", "10" ],
      [ "exit_rule", @grammar_path, "a" ],
      [ "terminate" ]
    ]
    
    debugger.events.should == expected
  end
  
  example 'debug-mode parser block-location events triggered by single-alternative rules' do
    grammar = %q<
      grammar RuleBlockSingleAlt;
      options { language=Ruby; }
      a : b;
      b : ID;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    >
    
    debugger = parse( grammar, :a, "a" )
    debugger.success.should be_true
    
    expected = [ 
      [ "enter_rule", @grammar_path, "a" ],
      [ "location", "3", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "3", "5" ],
      [ "enter_rule", @grammar_path, "b" ],
      [ "location", "4", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "4", "5" ],
      [ "look", "1", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "look", "1", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "consume_token", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "location", "4", "7" ],
      [ "exit_rule", @grammar_path, "b" ],
      [ "location", "3", "6" ],
      [ "exit_rule", @grammar_path, "a" ],
      [ "terminate" ]
    ]
    
    debugger.events.should == expected
  end
  
  example 'debug-mode parser block-location events triggered by single-alternative subrules' do
    grammar = %q<
      grammar BlockSingleAlt;
      options { language=Ruby; }
      a : ( b );
      b : ID;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+ ;
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    >
    
    debugger = parse( grammar, :a, "a" )
    debugger.success.should be_true
    
    expected = [ 
      [ "enter_rule", @grammar_path, "a" ],
      [ "location", "3", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "3", "5" ],
      [ "enter_alternative", "1" ],
      [ "location", "3", "7" ],
      [ "enter_rule", @grammar_path, "b" ],
      [ "location", "4", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "4", "5" ],
      [ "look", "1", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "look", "1", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "consume_token", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "location", "4", "7" ],
      [ "exit_rule", @grammar_path, "b" ],
      [ "location", "3", "10" ],
      [ "exit_rule", @grammar_path, "a" ],
      [ "terminate" ]
    ]
    debugger.events.should == expected
  end
  
  example 'debug-mode parser block-location events triggered by invoking a cyclic DFA for prediction' do
    grammar = %q<
      grammar DFA;
      options { language=Ruby; }
      a : ( b | c ) EOF;
      b : ID* INT;
      c : ID+ BANG;
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+ ;
      BANG : '!';
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    >
    
    debugger = parse( grammar, :a, "a!" )
    debugger.success.should be_true
    
    expected = [ 
      [ "enter_rule", @grammar_path, "a" ],
      [ "location", "3", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "3", "5" ],
      [ "enter_subrule", "1" ],
      [ "enter_decision", "1" ],
      [ "mark", "0" ],
      [ "look", "1", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "consume_token", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "look", "1", "1", "6", "default", "1", "1", "\"!\"" ],
      [ "consume_token", "1", "6", "default", "1", "1", "\"!\"" ],
      [ "rewind", "0" ],
      [ "exit_decision", "1" ],
      [ "enter_alternative", "2" ],
      [ "location", "3", "11" ],
      [ "enter_rule", @grammar_path, "c" ],
      [ "location", "5", "1" ],
      [ "enter_alternative", "1" ],
      [ "location", "5", "5" ],
      [ "enter_subrule", "3" ],
      [ "enter_decision", "3" ],
      [ "look", "1", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "exit_decision", "3" ],
      [ "enter_alternative", "1" ],
      [ "location", "5", "5" ],
      [ "look", "1", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "look", "1", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "consume_token", "0", "4", "default", "1", "0", "\"a\"" ],
      [ "enter_decision", "3" ],
      [ "look", "1", "1", "6", "default", "1", "1", "\"!\"" ],
      [ "exit_decision", "3" ],
      [ "exit_subrule", "3" ],
      [ "location", "5", "9" ],
      [ "look", "1", "1", "6", "default", "1", "1", "\"!\"" ],
      [ "look", "1", "1", "6", "default", "1", "1", "\"!\"" ],
      [ "consume_token", "1", "6", "default", "1", "1", "\"!\"" ],
      [ "location", "5", "13" ],
      [ "exit_rule", @grammar_path, "c" ],
      [ "exit_subrule", "1" ],
      [ "location", "3", "15" ],
      [ "look", "1", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "look", "1", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "consume_token", "-1", "-1", "default", "0", "-1", "nil" ],
      [ "location", "3", "18" ],
      [ "exit_rule", @grammar_path, "a" ],
      [ "terminate" ]
    ]
    debugger.events.should == expected
  end
  
  example 'debug-mode AST-building parser events' do
    grammar = %q/
      grammar BasicAST;
      options {
        language=Ruby;
        output=AST;
      }
      a : ( b | c ) EOF!;
      b : ID* INT -> ^(INT ID*);
      c : ID+ BANG -> ^(BANG ID+);
      ID : 'a'..'z'+ ;
      INT : '0'..'9'+ ;
      BANG : '!';
      WS : (' '|'\n') {$channel=HIDDEN;} ;
    /
    listener = ANTLR3::Debug::RecordEventListener.new
    parse( grammar, :a, "a!", :listener => listener )
  end

end
