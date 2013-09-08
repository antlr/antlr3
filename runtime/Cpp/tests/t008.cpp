#include "UserTestTraits.hpp"
#include "t008lexer.hpp"

#include <sys/types.h>

#include <iostream>
#include <sstream>
#include <fstream>

using namespace Antlr3Test;
using namespace std;

int testValid(string const& data);
int testMalformedInput(string const& data);

static t008lexer *lxr;

struct TokenData
{
	t008lexerTokens::Tokens type;
	unsigned start;
	unsigned stop;
	const char* text;
};

static TokenData ExpectedTokens[] =
{
	// "ffaf"
	{ t008lexerTokens::FOO, 0, 0, "f"},
	{ t008lexerTokens::FOO, 1, 2, "fa"},
	{ t008lexerTokens::FOO, 3, 3, "f"},
	{ t008lexerTokens::EOF_TOKEN, 4, 4, "<EOF>"}
};

int main (int argc, char *argv[])
{
	testValid("ffaf");
	testMalformedInput("fafb");
	return 0;
}

int testValid(string const& data)
{
	t008lexerTraits::InputStreamType* input	= new t008lexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t008");
	if (lxr == NULL)
		lxr = new t008lexer(input);
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
		t008lexerTraits::CommonTokenType *token = lxr->nextToken();

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
	t008lexerTraits::InputStreamType* input	= new t008lexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t008");
	if (lxr == NULL)
		lxr = new t008lexer(input);
	else
		lxr->setCharStream(input);

	std::cout << "testMalformedInput: \"" << data << '"' <<std::endl;
	
	t008lexerTraits::CommonTokenType *token;
	token = lxr->nextToken();
	std::cout << token->getText() << std::endl;
	token = lxr->nextToken();
	std::cout << token->getText() << std::endl;
	token = lxr->nextToken();
	std::cout << token->getText() << std::endl;

	//except antlr3.MismatchedTokenException as exc:
    //   self.assertEqual(exc.unexpectedType, 'b')
    //   self.assertEqual(exc.charPositionInLine, 3)
    //   self.assertEqual(exc.line, 1)

	delete lxr; lxr = NULL;
	delete input; 
	return 0;
}
