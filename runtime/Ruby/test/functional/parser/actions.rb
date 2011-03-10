#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestActions1 < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    grammar ParserActions;
    options { language = Ruby; }
    
    declaration returns [name]
        :   functionHeader ';'
            { $name = $functionHeader.name }
        ;
    
    functionHeader returns [name]
        : type id=ID
          { $name = $id.text }
        ;
    
    type
        :   'int'
        |   'char'
        |   'void'
        ;
    
    ID  :   ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
        ;
    
    WS  :   (   ' '
            |   '\t'
            |   '\r'
            |   '\n'
            )+
            {$channel=HIDDEN}
        ;    
  END
  
  example "parser action execution" do
    lexer = ParserActions::Lexer.new "int foo;"
    parser = ParserActions::Parser.new lexer
    
    parser.declaration.should == 'foo'
  end
  
end


class TestActions2 < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    grammar AllKindsOfActions;
    options { language = Ruby; }
    
    @parser::members {
      include ANTLR3::Test::CaptureOutput
    }
    
    @lexer::members {
      include ANTLR3::Test::CaptureOutput
    }
    @lexer::init { @foobar = 'attribute' }
    
    prog
    @init  { say('init')  }
    @after { say('after') }
      :   IDENTIFIER EOF
      ;
      catch [ RecognitionError => exc ] {
        say('catch')
        raise
      }
      finally { say('finally') }
    
    
    IDENTIFIER
        : ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
          {
            # a comment
            say('action')
            say('\%p \%p \%p \%p \%p \%p \%p \%p' \% [$text, $type, $line, $pos, $index, $channel, $start, $stop])
            say(@foobar)
          }
        ;
    
    WS: (' ' | '\n')+;
  END


  example "execution of special named actions" do
    lexer = AllKindsOfActions::Lexer.new( "foobar _Ab98 \n A12sdf" )
    parser = AllKindsOfActions::Parser.new lexer
    parser.prog
    
    parser.output.should == <<-END.fixed_indent( 0 )
      init
      after
      finally
    END
    
    lexer.output.should == <<-END.fixed_indent( 0 )
      action
      "foobar" 4 1 0 -1 :default 0 5
      attribute
      action
      "_Ab98" 4 1 7 -1 :default 7 11
      attribute
      action
      "A12sdf" 4 2 1 -1 :default 15 20
      attribute
    END
  end
end

class TestFinally < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    grammar Finally;
    
    options {
        language = Ruby;
    }
    
    prog returns [events]
    @init {events = []}
    @after {events << 'after'}
        :   ID {raise RuntimeError}
        ;
        catch [RuntimeError] {events << 'catch'}
        finally { events << 'finally'}
    
    ID  :   ('a'..'z')+
        ;
    
    WS  :   (' '|'\n'|'\r')+ {$channel=HIDDEN}
        ;
  END

  
  example "order of catch and ensure clauses" do
    lexer = Finally::Lexer.new( 'foobar' )
    parser = Finally::Parser.new lexer
    parser.prog.should == %w(catch finally)
  end

end


class TestActionScopes < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    grammar SpecialActionScopes;
    options { language=Ruby; }
    
    @all::header {
      \$all_header_files ||= []
      \$all_header_files << File.basename( __FILE__ )
    }
    
    @all::footer {
      \$all_footer_files ||= []
      \$all_footer_files << File.basename( __FILE__ )
    }
    
    @header {
      \$header_location = __LINE__
      \$header_context = self
    }
    
    @footer {
      \$footer_location = __LINE__
      \$footer_context = self
    }
    
    @module::head {
      \$module_head_location = __LINE__
      \$module_head_context = self
      
      class << self
        attr_accessor :head_var
      end
    }
    
    @module::foot {
      \$module_foot_location = __LINE__
      \$module_foot_context  = self
      
      FOOT_CONST = 1
    }
    
    @token::scheme {
      \$token_scheme_location = __LINE__
      \$token_scheme_context = self
      
      SCHEME_CONST = 1
    }
    
    @token::members {
      \$token_members_location = __LINE__
      \$token_members_context  = self
      
      def value
        text.to_i
      end
    }
    
    @members {
      \$members_location = __LINE__
    }
    
    nums returns [ds]: digs+=DIGIT+
                       { $ds = $digs.map { |t| t.value } };
    
    DIGIT: ('0'..'9')+;
    WS: (' ' | '\t' | '\n' | '\r' | '\f')+ { $channel=HIDDEN; };
  END
  
  example 'verifying action scope behavior' do
    lexer = SpecialActionScopes::Lexer.new( "10 20 30 40 50" )
    parser = SpecialActionScopes::Parser.new lexer
    parser.nums.should == [ 10, 20, 30, 40, 50 ]
  end
  
  example 'special action scope locations' do
    $all_header_files.should include "SpecialActionScopesLexer.rb"
    $all_header_files.should include "SpecialActionScopesParser.rb"
    $all_footer_files.should include "SpecialActionScopesLexer.rb"
    $all_footer_files.should include "SpecialActionScopesParser.rb"
    
    $header_location.should be < $module_head_location
    $module_head_location.should be < $token_scheme_location
    $token_scheme_location.should be < $token_members_location
    $token_members_location.should be < $members_location
    $members_location.should be < $module_foot_location
    $module_foot_location.should be < $footer_location
  end

end
