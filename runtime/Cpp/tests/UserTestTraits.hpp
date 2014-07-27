#ifndef	_T_TEST_TRAITS_H
#define	_T_TEST_TRAITS_H

// First thing we always do is include the ANTLR3 generated files, which
// will automatically include the antlr3 runtime header files.
// The compiler must use -I (or set the project settings in VS2005)
// to locate the antlr3 runtime files and -I. to find this file
#include <antlr3.hpp>

#include <fstream>
#include <iostream>
#include <sstream>

// Forward declaration for Lexer&Parser class(es)
namespace Antlr3Test {
	class s001Lexer;	class s001Parser;
	class s002Lexer;	class s002Parser;
	class s003Lexer;	class s003Parser;

	class t001lexer;
	class t002lexer;
	class t003lexer;
	class t004lexer;
	class t005lexer;
	class t006lexer;
	class t007lexer;
	class t008lexer;
	class t009lexer;
	class t010lexer;
	class t011lexer;
	class t012lexerXMLLexer;
	class t051lexer;

	class t020fuzzyLexer;

	class t039labelsLexer;
	class t039labelsParser;
};

namespace Antlr3Test {

	//code for overriding
	template<class ImplTraits>
	class UserTraits : public antlr3::CustomTraitsBase<ImplTraits>
	{
	public:
	};

	// Even Lexer only samples need some Parser class as a template parameter
	class NoParser {
	};
		
	// Instantiate the Traits class(will be used for Lexer/Parser template instantiations)
	typedef antlr3::Traits<s001Lexer, s001Parser, UserTraits> s001LexerTraits;
	typedef s001LexerTraits s001ParserTraits;
  	typedef antlr3::Traits<s002Lexer, s002Parser, UserTraits> s002LexerTraits;
	typedef s002LexerTraits s002ParserTraits;
  	typedef antlr3::Traits<s003Lexer, s003Parser, UserTraits> s003LexerTraits;
	typedef s003LexerTraits s003ParserTraits;
  
	typedef antlr3::Traits<t001lexer, NoParser, UserTraits> t001lexerTraits;
	typedef antlr3::Traits<t002lexer, NoParser, UserTraits> t002lexerTraits;
	typedef antlr3::Traits<t003lexer, NoParser, UserTraits> t003lexerTraits;
	typedef antlr3::Traits<t004lexer, NoParser, UserTraits> t004lexerTraits;
	typedef antlr3::Traits<t005lexer, NoParser, UserTraits> t005lexerTraits;
	typedef antlr3::Traits<t006lexer, NoParser, UserTraits> t006lexerTraits;
	typedef antlr3::Traits<t007lexer, NoParser, UserTraits> t007lexerTraits;
	typedef antlr3::Traits<t008lexer, NoParser, UserTraits> t008lexerTraits;
	typedef antlr3::Traits<t009lexer, NoParser, UserTraits> t009lexerTraits;
	typedef antlr3::Traits<t010lexer, NoParser, UserTraits> t010lexerTraits;
	typedef antlr3::Traits<t011lexer, NoParser, UserTraits> t011lexerTraits;
	typedef antlr3::Traits<t012lexerXMLLexer, NoParser, UserTraits> t012lexerXMLLexerTraits;
	typedef antlr3::Traits<t051lexer, NoParser, UserTraits> t051lexerTraits;

	typedef antlr3::Traits<t020fuzzyLexer, NoParser, UserTraits> t020fuzzyLexerTraits;

	typedef antlr3::Traits<t039labelsLexer, t039labelsParser, UserTraits> t039labelsLexerTraits;
	typedef t039labelsLexerTraits t039labelsParserTraits;

	inline std::string slurp(std::string const& fileName)
	{
		std::ifstream ifs(fileName.c_str(), std::ios::in | std::ios::binary | std::ios::ate);
		//std::ifstream::pos_type fileSize = ifs.tellg();
		ifs.seekg(0, std::ios::beg);
		std::stringstream sstr;
		sstr << ifs.rdbuf();
		return sstr.str();
	}

};

#endif
