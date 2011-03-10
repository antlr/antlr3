#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class TestBacktracking < ANTLR3::Test::Functional

  inline_grammar( <<-'END' )
    grammar Backtrack;
    options {
			language = Ruby;
			backtrack=true;
			memoize=true;
			k=2;
    }
    
    scope Symbols {
    	types;
    }
    
    @members {
      def is_type_name?(name)
        @Symbols_stack.reverse_each do |scope|
          scope.types.include?(name) and return true
        end
        return false
      end
      
      def report_error(e)
        # do nothing
      end
      
    }
    
    translation_unit
    scope Symbols; // entire file is a scope
    @init {
      $Symbols::types = Set.new
    }
    	: external_declaration+
    	;
    
    /** Either a function definition or any other kind of C decl/def.
     *  The LL(*) analysis algorithm fails to deal with this due to
     *  recursion in the declarator rules.  I'm putting in a
     *  manual predicate here so that we don't backtrack over
     *  the entire function.  Further, you get a better error
     *  as errors within the function itself don't make it fail
     *  to predict that it's a function.  Weird errors previously.
     *  Remember: the goal is to avoid backtrack like the plague
     *  because it makes debugging, actions, and errors harder.
     *
     *  Note that k=1 results in a much smaller predictor for the 
     *  fixed look; k=2 made a few extra thousand lines. ;)
     *  I'll have to optimize that in the future.
     */
    external_declaration
    options {k=1;}
    	: ( declaration_specifiers? declarator declaration* '{' )=> function_definition
    	| declaration
    	;
    
    function_definition
    scope Symbols; // put parameters and locals into same scope for now
    @init {
      $Symbols::types = set()
    }
    	:	declaration_specifiers? declarator
    	;
    
    declaration
    scope {
      is_type_def;
    }
    @init {
      $declaration::is_type_def = false
    }
    	: 'typedef' declaration_specifiers? {$declaration::is_type_def = true}
    	  init_declarator_list ';' // special case, looking for typedef	
    	| declaration_specifiers init_declarator_list? ';'
    	;
    
    declaration_specifiers
    	:   (   storage_class_specifier
    		|   type_specifier
            |   type_qualifier
            )+
    	;
    
    init_declarator_list
    	: init_declarator (',' init_declarator)*
    	;
    
    init_declarator
    	: declarator //('=' initializer)?
    	;
    
    storage_class_specifier
    	: 'extern'
    	| 'static'
    	| 'auto'
    	| 'register'
    	;
    
    type_specifier
    	: 'void'
    	| 'char'
    	| 'short'
    	| 'int'
    	| 'long'
    	| 'float'
    	| 'double'
    	| 'signed'
    	| 'unsigned'
    	| type_id
    	;
    
    type_id
        :   { is_type_name?(@input.look(1).text)}? IDENTIFIER
        ;
    
    type_qualifier
    	: 'const'
    	| 'volatile'
    	;
    
    declarator
    	: pointer? direct_declarator
    	| pointer
    	;
    
    direct_declarator
    	:   (	IDENTIFIER
    			{
    			if $declaration.length > 0 && $declaration::is_type_def
						$Symbols::types.add($IDENTIFIER.text)
					end
    			}
    		|	'(' declarator ')'
    		)
            declarator_suffix*
    	;
    
    declarator_suffix
    	:   /*'[' constant_expression ']'
        |*/   '[' ']'
        |   '(' ')'
    	;
    
    pointer
    	: '*' type_qualifier+ pointer?
    	| '*' pointer
    	| '*'
    	;
    
    IDENTIFIER
    	:	LETTER (LETTER|'0'..'9')*
    	;
    	
    fragment
    LETTER
    	:	'$'
    	|	'A'..'Z'
    	|	'a'..'z'
    	|	'_'
    	;
    
    CHARACTER_LITERAL
        :   '\'' ( EscapeSequence | ~('\''|'\\') ) '\''
        ;
    
    STRING_LITERAL
        :  '"' ( EscapeSequence | ~('\\'|'"') )* '"'
        ;
    
    HEX_LITERAL : '0' ('x'|'X') HexDigit+ IntegerTypeSuffix? ;
    
    DECIMAL_LITERAL : ('0' | '1'..'9' '0'..'9'*) IntegerTypeSuffix? ;
    
    OCTAL_LITERAL : '0' ('0'..'7')+ IntegerTypeSuffix? ;
    
    fragment
    HexDigit : ('0'..'9'|'a'..'f'|'A'..'F') ;
    
    fragment
    IntegerTypeSuffix
    	:	('u'|'U')? ('l'|'L')
    	|	('u'|'U')  ('l'|'L')?
    	;
    
    FLOATING_POINT_LITERAL
        :   ('0'..'9')+ '.' ('0'..'9')* Exponent? FloatTypeSuffix?
        |   '.' ('0'..'9')+ Exponent? FloatTypeSuffix?
        |   ('0'..'9')+ Exponent FloatTypeSuffix?
        |   ('0'..'9')+ Exponent? FloatTypeSuffix
    	;
    
    fragment
    Exponent : ('e'|'E') ('+'|'-')? ('0'..'9')+ ;
    
    fragment
    FloatTypeSuffix : ('f'|'F'|'d'|'D') ;
    
    fragment
    EscapeSequence
        :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
        |   OctalEscape
        ;
    
    fragment
    OctalEscape
        :   '\\' ('0'..'3') ('0'..'7') ('0'..'7')
        |   '\\' ('0'..'7') ('0'..'7')
        |   '\\' ('0'..'7')
        ;
    
    fragment
    UnicodeEscape
        :   '\\' 'u' HexDigit HexDigit HexDigit HexDigit
        ;
    
    WS  :  (' '|'\r'|'\t'|'\u000C'|'\n') {$channel=HIDDEN;}
        ;
    
    COMMENT
        :   '/*' ( options {greedy=false;} : . )* '*/' {$channel=HIDDEN;}
        ;
    
    LINE_COMMENT
        : '//' ~('\n'|'\r')* '\r'? '\n' {$channel=HIDDEN;}
        ;
    LINE_COMMAND 
        : '#' ~('\n'|'\r')* '\r'? '\n' {$channel=HIDDEN;}
        ;
  END

  example "grammar with backtracking and memoization" do
    lexer = Backtrack::Lexer.new( 'int a;' )
    parser = Backtrack::Parser.new lexer
    events = parser.translation_unit
  end

end
