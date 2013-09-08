#include "UserTestTraits.hpp"
#include "t010lexer.hpp"

#include <sys/types.h>

#include <iostream>
#include <sstream>
#include <fstream>

using namespace Antlr3Test;
using namespace std;

int testValid(string const& data);
int testMalformedInput(string const& data);

static t010lexer *lxr;

struct TokenData
{
	t010lexerTokens::Tokens type;
	unsigned start;
	unsigned stop;
	const char* text;
};

static TokenData ExpectedTokens[] =
{
	// "foobar _Ab98 \n A12sdf"
	{ t010lexerTokens::IDENTIFIER,  0,   5, "foobar"},
	{ t010lexerTokens::WS,          6,   6, " "},
	{ t010lexerTokens::IDENTIFIER,  7,  11, "_Ab98"},
	{ t010lexerTokens::WS,         12, 14, " \n "},
	{ t010lexerTokens::IDENTIFIER, 15, 20, "A12sdf"},
	{ t010lexerTokens::EOF_TOKEN,  21, 21, "<EOF>"}
};

int main (int argc, char *argv[])
{
	testValid("foobar _Ab98 \n A12sdf");
	testMalformedInput("a-b");
	return 0;
}

int testValid(string const& data)
{
	t010lexerTraits::InputStreamType* input	= new t010lexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t010");
	if (lxr == NULL)
		lxr = new t010lexer(input);
	else
		lxr->setCharStream(input);

	std::cout << "testValid: \"" << data << '"' <<std::endl;

	std::cout << "Text:"  << '\t'
		  << "Type:"  << '\t'
		  << "Start:" << '\t'
		  << "Stop:"  << '\t'
		  << "Text:"  << '\t' << std::endl;
	
	for(unsigned i = 0; i < sizeof(ExpectedTokens)/sizeof(TokenData) ; i++)
	{
		// nextToken does not allocate any new Token instance(the same instance is returned again and again)
		t010lexerTraits::CommonTokenType *token = lxr->nextToken();

		size_t startIndex = ((const char*)token->get_startIndex()) - data.c_str();
		size_t stopIndex = ((const char*)token->get_stopIndex()) - data.c_str();

		std::cout << token->getText()
			  << '\t' << (token->getType()       == ExpectedTokens[i].type ?  "OK" : "Fail")
			  << '\t' << (startIndex == ExpectedTokens[i].start ? "OK" : "Fail")
			  << '\t' << (stopIndex  == ExpectedTokens[i].stop ?  "OK" : "Fail")
			  << '\t' << (token->getText()       == ExpectedTokens[i].text ?  "OK" : "Fail")
			  << std::endl;
		
	}
	delete lxr; lxr = NULL;
	delete input; 
	return 0;
}

int testMalformedInput(string const& data)
{
	t010lexerTraits::InputStreamType* input	= new t010lexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t010");
	if (lxr == NULL)
		lxr = new t010lexer(input);
	else
		lxr->setCharStream(input);

	std::cout << "testMalformedInput: \"" << data << '"' <<std::endl;
	
	t010lexerTraits::CommonTokenType *token;
	token = lxr->nextToken();
	std::cout << token->getText() << std::endl;
	token = lxr->nextToken();
	std::cout << token->getText() << std::endl;

	//except antlr3.NoViableAltException as exc:
	//    self.assertEqual(exc.unexpectedType, '-')
	//    self.assertEqual(exc.charPositionInLine, 1)
	//    self.assertEqual(exc.line, 1)

	delete lxr; lxr = NULL;
	delete input; 
	return 0;
}
