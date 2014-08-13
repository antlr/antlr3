#ifndef	_A_TEST_TRAITS_H
#define	_A_TEST_TRAITS_H

#include <antlr3.hpp>

#include <fstream>
#include <iostream>
#include <sstream>

// Forward declaration for Lexer&Parser class(es)
namespace Antlr3Test {
	//code for overriding
	template<class ImplTraits>
	class UserTraits : public antlr3::CustomTraitsBase<ImplTraits>
	{
	public:
		//static const bool TOKENS_ACCESSED_FROM_OWNING_RULE = true;
		//static const int  TOKEN_FILL_BUFFER_INCREMENT = 2;
	};

	class a001Lexer;	class a001Parser;
	class a002Lexer;	class a002Parser;
	class a003Lexer;	class a003Parser;
	class a004Lexer;	class a004Parser;
	class a005Lexer;	class a005Parser;
  	class a006Lexer;	class a006Parser;

	// Instantiate the Traits class(will be used for Lexer/Parser template instantiations)
	typedef antlr3::Traits<a001Lexer, a001Parser, UserTraits> a001LexerTraits;	typedef a001LexerTraits a001ParserTraits;
	typedef antlr3::Traits<a002Lexer, a002Parser, UserTraits> a002LexerTraits;	typedef a002LexerTraits a002ParserTraits;
	typedef antlr3::Traits<a003Lexer, a003Parser, UserTraits> a003LexerTraits;	typedef a003LexerTraits a003ParserTraits;
	typedef antlr3::Traits<a004Lexer, a004Parser, UserTraits> a004LexerTraits;	typedef a004LexerTraits a004ParserTraits;
	typedef antlr3::Traits<a005Lexer, a005Parser, UserTraits> a005LexerTraits;	typedef a005LexerTraits a005ParserTraits;
  	typedef antlr3::Traits<a006Lexer, a006Parser, UserTraits> a006LexerTraits;	typedef a006LexerTraits a006ParserTraits;
};

#endif
