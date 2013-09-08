grammar t039labels;
options {
  language =Cpp;
}

@lexer::includes
{
#include "UserTestTraits.hpp"
#include <iostream>
}
@lexer::namespace
{ Antlr3Test }

@parser::includes {
#include "UserTestTraits.hpp"
#include "t039labelsLexer.hpp"
}
@parser::namespace
{ Antlr3Test }
@parser::members {
	class TokenList {
	public:
        TokenList() : token() {}
        TokenList(TokenList const& other) : tokens(other.tokens), token(other.token) {}
        TokenList(ImplTraits::TokenPtrsListType const& lst, ImplTraits::CommonTokenType *t) : tokens(lst), token(t) {}
	//private:
        ImplTraits::TokenPtrsListType tokens;
        ImplTraits::CommonTokenType* token;
    };
}
a returns [t039labelsParser::TokenList retval]
    : ids+=A ( ',' ids+=(A|B) )* C D w=. ids+=. F EOF
        { retval = t039labelsParser::TokenList($ids, $w); }
    ;

A: 'a'..'z';
B: '0'..'9';
C: a='A'         { std::cout << $a << std::endl; };
D: a='FOOBAR'    { std::cout << $a << std::endl; };
E: 'GNU' a=.     { std::cout << $a << std::endl; };
F: 'BLARZ' a=EOF { std::cout << $a << std::endl; };

WS: ' '+  { $channel = HIDDEN; };
