#!/usr/bin/ruby
# encoding: utf-8
require 'antlr3/test/functional'

class LexerTest001 < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    lexer grammar Zero;
    options {
      language = Ruby;
    }
    
    @members { include ANTLR3::Test::RaiseErrors }
    
    ZERO: '0';
  END
  
  example %(lexing '0') do
    lexer = Zero::Lexer.new( '0' )
    
    token = lexer.next_token
    token.name.should == 'ZERO'
    
    token = lexer.next_token
    token.name.should == '<EOF>'
  end
  
  example %(iterating over tokens) do
    lexer = Zero::Lexer.new( '0' )
    
    token_types = lexer.map { |token| token.name }
    token_types.should == %w(ZERO)
  end

  example "mismatched token" do
    lexer = Zero::Lexer.new( '1' )
    
    proc { 
      token = lexer.next_token
    }.should raise_error( ANTLR3::Error::MismatchedToken ) do |e|
      e.expecting.should == '0'
      e.unexpected_type.should == '1'
    end
  end
end

class LexerTest002 < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    lexer grammar Binary;
    options {
      language = Ruby;
    }
    
    @members { include ANTLR3::Test::RaiseErrors }
    
    ZERO: '0';
    ONE: '1';
  END
  
  example "lexing '01'" do
    lexer = Binary::Lexer.new( '01' )
    
    token = lexer.next_token
    token.name.should == 'ZERO'
    
    token = lexer.next_token
    token.name.should == 'ONE'
    
    token = lexer.next_token
    token.name.should == '<EOF>'
  end
  
  example "no matching token rule" do
    lexer = Binary::Lexer.new( '2' )
    
    b = lambda { token = lexer.next_token }
    b.should raise_error( ANTLR3::Error::NoViableAlternative ) do |exc|
      exc.unexpected_type.should == '2'
    end
  end
  
end

class LexerTest003 < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    lexer grammar BinaryFooze;
    options {
      language = Ruby;
    }
    
    @members { include ANTLR3::Test::RaiseErrors }
    
    ZERO: '0';
    ONE:  '1';
    FOOZE: 'fooze';
  END
  
  example "lexing '0fooze1'" do
    lexer = BinaryFooze::Lexer.new( '0fooze1' )
    
    token = lexer.next_token
    token.name.should == 'ZERO'
    
    token = lexer.next_token
    token.name.should == 'FOOZE'
    
    token = lexer.next_token
    token.name.should == 'ONE'
    
    token = lexer.next_token
    token.name.should == '<EOF>'
  end
  
  example "no token match" do
    lexer = BinaryFooze::Lexer.new( '2' )
    
    proc { lexer.next_token }.
    should raise_error( ANTLR3::Error::NoViableAlternative ) do |exc|
      exc.unexpected_type.should == '2'
    end
  end
end


class LexerTest004 < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    lexer grammar FooStar;
    options {
      language = Ruby;
    }
    
    @members { include ANTLR3::Test::RaiseErrors }
    
    FOO: 'f' 'o'*;
  END

  example "lexing 'ffofoofooo'" do
    lexer = FooStar::Lexer.new( 'ffofoofooo' )
    
    token = lexer.next_token
    token.name.should == 'FOO'
    token.start.should == 0
    token.stop.should == 0
    token.text.should == 'f'
    
    token = lexer.next_token
    token.name.should == 'FOO'
    token.text.should == 'fo'
    token.start.should == 1
    token.stop.should == 2
    
    token = lexer.next_token
    token.name.should == 'FOO'
    token.start.should == 3
    token.stop.should == 5
    token.text.should == 'foo'
    
    token = lexer.next_token
    token.name.should == 'FOO'
    token.start.should == 6
    token.stop.should == 9
    token.text.should == 'fooo'
    
    token = lexer.next_token
    token.name.should == '<EOF>'
  end
  
  example "mismatched token" do
    lexer = FooStar::Lexer.new( '2' )
    
    proc { lexer.next_token }.
    should raise_error( ANTLR3::Error::MismatchedToken ) do |exc|
      exc.expecting.should == 'f'
      exc.unexpected_type.should == '2'
    end
  end
end

class LexerTest005 < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    lexer grammar FooPlus;
    options {
      language = Ruby;
    }
    
    @members { include ANTLR3::Test::RaiseErrors }
    
    FOO: 'f' 'o'+;
  END
  
  example "lexing 'fofoofooo'" do
    lexer = FooPlus::Lexer.new( 'fofoofooo' )
    
    token = lexer.next_token
    token.name.should == 'FOO'
    token.start.should == 0
    token.stop.should == 1
    token.text.should == 'fo'
    
    token = lexer.next_token
    token.name.should == 'FOO'
    token.text.should == 'foo'
    token.start.should == 2
    token.stop.should == 4
    
    token = lexer.next_token
    token.name.should == 'FOO'
    token.start.should == 5
    token.stop.should == 8
    token.text.should == 'fooo'
    
    token = lexer.next_token
    token.name.should == '<EOF>'
  end
  
  example "mismatched token" do
    lexer = FooPlus::Lexer.new( '2' )
    
    proc { lexer.next_token }.
    should raise_error( ANTLR3::Error::MismatchedToken ) do |exc|
      exc.expecting.should == 'f'
      exc.unexpected_type.should == '2'
    end
  end
  
  example "early exit" do
    lexer = FooPlus::Lexer.new( 'f' )
    
    proc { token = lexer.next_token }.
    should raise_error( ANTLR3::Error::EarlyExit ) { |exc|
      exc.unexpected_type.should == ANTLR3::Constants::EOF
    }
  end
  
end

class LexerTest006 < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    lexer grammar FoaStar;
    options {
      language = Ruby;
    }
    
    @members { include ANTLR3::Test::RaiseErrors }
    
    FOO: 'f' ('o' | 'a')*;
  END
  
  example "lexing 'fofaaooa'" do
    lexer = FoaStar::Lexer.new( 'fofaaooa' )
    
    token = lexer.next_token
    token.name.should == 'FOO'
    token.start.should == 0
    token.stop.should == 1
    token.text.should == 'fo'
    
    token = lexer.next_token
    token.name.should == 'FOO'
    token.text.should == 'faaooa'
    token.start.should == 2
    token.stop.should == 7
    
    token = lexer.next_token
    token.name.should == '<EOF>'
  end
  
  example "mismatched token" do
    lexer = FoaStar::Lexer.new( 'fofoaooaoa2' )
    
    lexer.next_token
    lexer.next_token
    proc { lexer.next_token }.
    should raise_error( ANTLR3::Error::MismatchedToken ) do |exc|
      exc.expecting.should == 'f'
      exc.unexpected_type.should == '2'
      exc.column.should == 10
      exc.line.should == 1
    end
  end
end

class LexerTest007 < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    lexer grammar Foab;
    options {
      language = Ruby;
    }
    
    @members { include ANTLR3::Test::RaiseErrors }
    
    FOO: 'f' ('o' | 'a' 'b'+)*;
  END
  
  example "lexing 'fofababbooabb'" do
    lexer = Foab::Lexer.new( 'fofababbooabb' )
    
    token = lexer.next_token
    token.name.should == 'FOO'
    token.start.should == 0
    token.stop.should == 1
    token.text.should == 'fo'
    
    token = lexer.next_token
    token.name.should == 'FOO'
    token.start.should == 2
    token.stop.should == 12
    token.text.should == 'fababbooabb'
    
    token = lexer.next_token
    token.name.should == '<EOF>'
  end
  
  example "early exit" do
    lexer = Foab::Lexer.new( 'foaboao' )
    
    proc { lexer.next_token }.
    should raise_error( ANTLR3::Error::EarlyExit ) do |exc|
      exc.unexpected_type.should == 'o'
      exc.column.should == 6
      exc.line.should == 1
    end
  end
end

class LexerTest008 < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    lexer grammar Fa;
    options {
      language = Ruby;
    }
    
    @members { include ANTLR3::Test::RaiseErrors }
    
    FOO: 'f' 'a'?;
  END
  
  example "lexing 'ffaf'" do
    lexer = Fa::Lexer.new( 'ffaf' )
    
    token = lexer.next_token
    token.name.should == 'FOO'
    token.start.should == 0
    token.stop.should == 0
    token.text.should == 'f'
    
    token = lexer.next_token
    token.name.should == 'FOO'
    token.start.should == 1
    token.stop.should == 2
    token.text.should == 'fa'
    
    token = lexer.next_token
    token.name.should == 'FOO'
    token.start.should == 3
    token.stop.should == 3
    token.text.should == 'f'
    
    token = lexer.next_token
    token.name.should == '<EOF>'
  end
  
  example "mismatched token" do
    lexer = Fa::Lexer.new( 'fafb' )
    
    lexer.next_token
    lexer.next_token
    proc { lexer.next_token }.
    should raise_error( ANTLR3::Error::MismatchedToken ) do |exc|
      exc.unexpected_type.should == 'b'
      exc.column.should == 3
      exc.line.should == 1
    end
  end
end


class LexerTest009 < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    lexer grammar Digit;
    options {
      language = Ruby;
    }
    
    @members { include ANTLR3::Test::RaiseErrors }
    
    DIGIT: '0' .. '9';
  END
  
  example "lexing '085'" do
    lexer = Digit::Lexer.new( '085' )
    
    token = lexer.next_token
    token.name.should == 'DIGIT'
    token.start.should == 0
    token.stop.should == 0
    token.text.should == '0'
    
    token = lexer.next_token
    token.name.should == 'DIGIT'
    token.start.should == 1
    token.stop.should == 1
    token.text.should == '8'
    
    token = lexer.next_token
    token.name.should == 'DIGIT'
    token.start.should == 2
    token.stop.should == 2
    token.text.should == '5'
    
    token = lexer.next_token
    token.name.should == '<EOF>'
  end
  
  example "mismatched range" do
    lexer = Digit::Lexer.new( '2a' )
    
    lexer.next_token
    proc { lexer.next_token }.
    should raise_error( ANTLR3::Error::MismatchedRange ) do |exc|
      exc.min.should == '0'
      exc.max.should == '9'
      exc.unexpected_type.should == 'a'
      exc.column.should == 1
      exc.line.should == 1
    end
  end
end

class LexerTest010 < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    lexer grammar IDsAndSpaces;
    options {
      language = Ruby;
    }
        
    @members { include ANTLR3::Test::RaiseErrors }
    
    IDENTIFIER: ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;
    WS: (' ' | '\n')+;
  END

  example "lexing 'foobar _Ab98 \n A12sdf'" do
    lexer = IDsAndSpaces::Lexer.new( "foobar _Ab98 \n A12sdf" )
    
    token = lexer.next_token
    token.name.should == 'IDENTIFIER'
    token.start.should == 0
    token.stop.should == 5
    token.text.should == 'foobar'
    
    token = lexer.next_token
    token.name.should == 'WS'
    token.start.should == 6
    token.stop.should == 6
    token.text.should == ' '
    
    token = lexer.next_token
    token.name.should == 'IDENTIFIER'
    token.start.should == 7
    token.stop.should == 11
    token.text.should == '_Ab98'
    
    token = lexer.next_token
    token.name.should == 'WS'
    token.start.should == 12
    token.stop.should == 14
    token.text.should == " \n "
    
    token = lexer.next_token
    token.name.should == 'IDENTIFIER'
    token.start.should == 15
    token.stop.should == 20
    token.text.should == 'A12sdf'
    
    token = lexer.next_token
    token.name.should == '<EOF>'
  end
  
  example "contains characters without a matching token rule" do
    lexer = IDsAndSpaces::Lexer.new( 'a-b' )
    
    lexer.next_token
    proc { lexer.next_token }.
    should raise_error( ANTLR3::Error::NoViableAlternative ) do |exc|
      exc.unexpected_type.should == '-'
      exc.column.should == 1
      exc.line.should == 1
    end
  end
end

class LexerTest011 < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    lexer grammar IDsWithAction;
    options {language = Ruby;}
        
    @members { include ANTLR3::Test::RaiseErrors }
    
    IDENTIFIER: 
            ('a'..'z'|'A'..'Z'|'_') 
            ('a'..'z'
            |'A'..'Z'
            |'0'..'9'
            |'_' { \$action_var = '_' }
            )*
        ;
    
    WS: (' ' | '\n')+;
  END
  
  example "lexing 'foobar _Ab98 \n A12sdf'" do
    lexer = IDsWithAction::Lexer.new( "foobar _Ab98 \n A12sdf" )
    
    token = lexer.next_token
    token.name.should == 'IDENTIFIER'
    token.start.should == 0
    token.stop.should == 5
    token.text.should == 'foobar'
    
    token = lexer.next_token
    token.name.should == 'WS'
    token.start.should == 6
    token.stop.should == 6
    token.text.should == ' '
    
    token = lexer.next_token
    token.name.should == 'IDENTIFIER'
    token.start.should == 7
    token.stop.should == 11
    token.text.should == '_Ab98'
    
    token = lexer.next_token
    token.name.should == 'WS'
    token.start.should == 12
    token.stop.should == 14
    token.text.should == " \n "
    
    token = lexer.next_token
    token.name.should == 'IDENTIFIER'
    token.start.should == 15
    token.stop.should == 20
    token.text.should == 'A12sdf'
    
    token = lexer.next_token
    token.name.should == '<EOF>'
  end
  
  example "contains characters without a matching token" do
    lexer = IDsWithAction::Lexer.new( 'a-b' )
    
    lexer.next_token
    proc { lexer.next_token }.
    should raise_error( ANTLR3::Error::NoViableAlternative ) do |exc|
      exc.unexpected_type.should == '-'
      exc.column.should == 1
      exc.line.should == 1
    end
  end
end
