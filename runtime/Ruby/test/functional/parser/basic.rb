#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestParser001 < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    grammar Identifiers;
    options { language = Ruby; }
    
    @parser::init {
      @identifiers = []
      @reported_errors = []
    }
    
    @parser::members {
      attr_reader :reported_errors, :identifiers
      
      def found_identifier(name)
          @identifiers << name
      end
      
      def emit_error_message(msg)
        @reported_errors << msg
      end
    }
    
    document:
            t=IDENTIFIER {found_identifier($t.text)}
            ;
    
    IDENTIFIER: ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;
  END
  
  example "parsing 'blah_de_blah'" do
    # to build a parser, this is the standard chain of calls to prepare the input
    input = ANTLR3::StringStream.new( 'blah_de_blah', :file => 'blah.txt' )
    lexer  = Identifiers::Lexer.new( input )
    tokens = ANTLR3::CommonTokenStream.new( lexer )
    parser = Identifiers::Parser.new( tokens )
    
    parser.document
    
    parser.reported_errors.should be_empty
    parser.identifiers.should == %w(blah_de_blah)
  end
  
  example "error from empty input" do
    # if you don't need to use a customized stream, lexers and parsers will
    # automatically wrap input in the standard stream classes
    lexer = Identifiers::Lexer.new( '' )
    parser = Identifiers::Parser.new( lexer )
    parser.document
    
    parser.reported_errors.should have( 1 ).thing
  end
  
  example 'automatic input wrapping' do
    # if the parser is able to figure out what lexer class
    # to use (typically when it comes from a combined grammar),
    # and you don't need to do any special token processing
    # before making a parser, this is an extra shortcut for
    # parser construction
    parser = Identifiers::Parser.new( 'blah_de_blah', :file => 'blah.txt' )
    
    parser.document
    
    parser.reported_errors.should be_empty
    parser.identifiers.should == %w(blah_de_blah)
  end
end

class TestParser002 < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    grammar SimpleLanguage;
    options {
      language = Ruby;
    }
    
    @parser::init {
      @events = []
      @reported_errors = []
    }
    
    @parser::members {
      attr_reader :reported_errors, :events
      
      def emit_error_message(msg)
        @reported_errors << msg
      end
    }
    
    document:
            ( declaration
            | call
            )*
            EOF
        ;
    
    declaration:
            'var' t=IDENTIFIER ';'
            {@events << ['decl', $t.text]}
        ;
    
    call:
            t=IDENTIFIER '(' ')' ';'
            {@events << ['call', $t.text]}
        ;
    
    IDENTIFIER: ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;
    WS:  (' '|'\r'|'\t'|'\n') {$channel=HIDDEN;};
  END
  
  
  example "parsing decls and calls" do
    lexer  = SimpleLanguage::Lexer.new( "var foobar; gnarz(); var blupp; flupp ( ) ;" )
    parser = SimpleLanguage::Parser.new( lexer )
    
    parser.document
    
    parser.reported_errors.should be_empty
    parser.events.should == [ 
      %w(decl foobar),
      %w(call gnarz),
      %w(decl blupp),
      %w(call flupp)
    ]
  end
  
  example "bad declaration" do
    lexer  = SimpleLanguage::Lexer.new( 'var; foo()' )
    parser = SimpleLanguage::Parser.new( lexer )
    
    parser.document
    
    parser.reported_errors.should have( 1 ).thing
    parser.events.should be_empty
  end
  
  example "error recovery via token insertion" do
    lexer  = SimpleLanguage::Lexer.new( 'gnarz(; flupp();' )
    parser = SimpleLanguage::Parser.new( lexer )
    
    parser.document
    
    parser.reported_errors.should have( 1 ).thing
    parser.events.should == [ 
      %w(call gnarz),
      %w(call flupp)
    ]
  end
  
end

class TestParser003 < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    grammar MoreComplicated;
    
    options { language = Ruby; }
    
    @init {
      @reported_errors = []
    }
    
    @members {
      attr_reader :reported_errors
      
      def emit_error_message(msg)
        @reported_errors << msg
      end
    }
    
    program
        :   declaration+
        ;
    
    declaration
        :   variable
        |   functionHeader ';'
        |   functionHeader block
        ;
    
    variable
        :   type declarator ';'
        ;
    
    declarator
        :   ID 
        ;
    
    functionHeader
        :   type ID '(' ( formalParameter ( ',' formalParameter )* )? ')'
        ;
    
    formalParameter
        :   type declarator        
        ;
    
    type
        :   'int'   
        |   'char'  
        |   'void'
        |   ID        
        ;
    
    block
        :   '{'
                variable*
                stat*
            '}'
        ;
    
    stat: forStat
        | expr ';'      
        | block
        | assignStat ';'
        | ';'
        ;
    
    forStat
        :   'for' '(' assignStat ';' expr ';' assignStat ')' block        
        ;
    
    assignStat
        :   ID '=' expr        
        ;
    
    expr:   condExpr
        ;
    
    condExpr
        :   aexpr ( ('==' | '<') aexpr )?
        ;
    
    aexpr
        :   atom ( '+' atom )*
        ;
    
    atom
        : ID      
        | INT      
        | '(' expr ')'
        ; 
    
    ID  :   ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
        ;
    
    INT :	('0'..'9')+
        ;
    
    WS  :   (   ' '
            |   '\t'
            |   '\r'
            |   '\n'
            )+
            {$channel=HIDDEN}
        ;    
  END
  
  example "parsing 'int foo;'" do
    lexer = MoreComplicated::Lexer.new "int foo;"
    parser = MoreComplicated::Parser.new lexer
    parser.program
    parser.reported_errors.should be_empty
  end
  
  
  example "catching badly formed input" do
    lexer = MoreComplicated::Lexer.new "int foo() { 1+2 }"
    parser = MoreComplicated::Parser.new lexer
    parser.program
    parser.reported_errors.should have( 1 ).thing
  end
  
  example "two instances of badly formed input" do
    lexer = MoreComplicated::Lexer.new "int foo() { 1+; 1+2 }"
    parser = MoreComplicated::Parser.new lexer
    parser.program
    parser.reported_errors.should have( 2 ).things
  end
  
end
