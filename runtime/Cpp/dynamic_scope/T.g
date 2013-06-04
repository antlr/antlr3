grammar T;

options
{
    language = Cpp;
}

@parser::includes
{
   #include "TLexer.hpp"
}

@lexer::namespace {	User }
@parser::namespace{	User }

@lexer::traits 
{
	class TLexer; 
	class TParser; 

	template<class ImplTraits>
	class UserTraits : public antlr3::CustomTraitsBase<ImplTraits>
	{
	public:
	    //for using the token stream which deleted the tokens, once it is reduced to a rule
		//but it leaves the start and stop tokens. So they can be accessed as usual
		static const bool TOKENS_ACCESSED_FROM_OWNING_RULE = true;
	};

	typedef antlr3::Traits< TLexer, TParser, UserTraits > TLexerTraits;
	typedef TLexerTraits TParserTraits;

	/* If you don't want the override it is like this.
	   class TLexer;
	   class TParser;
	   typedef antlr3::Traits< TLexer, TParser > TLexerTraits;
	   typedef TLexerTraits TParserTraits;
	 */
}

program 
    : method ;

method
    scope 
    {
      /** name is visible to any rule called by method directly or indirectly.
       *  There is also a stack of these names, one slot for each nested
       *  invocation of method.  If you have a method nested within another
       *  method then you have name strings on the stack.  Referencing
       *  $method.name access the topmost always.  I have no way at the moment
       *  to access earlier elements on the stack.
       */
      std::string name; 
    }
    :   'method' ID '(' ')' {$method::name=$ID.text;} body
    ; 

body
    :   '{' bstat* '}'
    ;

// Cannot call this stat as it will clash with C runtime functions
//
bstat
    :   ID '=' expr ';'
    |   method // allow nested methods to demo stack nature of dynamic attributes
    ;

expr:   mul ('+' mul)* 
    ;

mul :   atom ('*' atom)*
    ;

/** Demonstrate that 'name' is a dynamically-scoped attribute defined
 *  within rule method.  With lexical-scoping (variables go away at
 *  the end of the '}'), you'd have to pass the current method name
 *  down through all rules as a parameter.  Ick.  This is much much better.
 */
atom
    :   ID  
    |   INT 
    ;

ID  :   ('a'..'z'|'A'..'Z')+ ;

INT :   '0'..'9'+ ;

WS  :   (' '|'\t'|'\n'|'\r')+ {$channel=HIDDEN;}
    ;
