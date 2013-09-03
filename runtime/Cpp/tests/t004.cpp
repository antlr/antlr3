#include "UserTestTraits.hpp"
#include "t004lexer.hpp"

#include <sys/types.h>

#include <iostream>
#include <sstream>
#include <fstream>

using namespace Antlr3Test;
using namespace std;

int testValid(string const& data);
int testMalformedInput(string const& data);

static t004lexer *lxr;

struct TokenData
{
	t004lexerTokens::Tokens type;
	unsigned start;
	unsigned stop;
	const char* text;
};

static TokenData ExpectedTokens[] =
{
	{ t004lexerTokens::FOO, 0, 0, "f"},
	{ t004lexerTokens::FOO, 1, 2, "fo"},
	{ t004lexerTokens::FOO, 3, 5, "foo"},
	{ t004lexerTokens::FOO, 6, 9, "fooo"}
};

int main (int argc, char *argv[])
{
	testValid("ffofoofooo");
	testMalformedInput("2");
	return 0;
}

int testValid(string const& data)
{
	t004lexerTraits::InputStreamType* input	= new t004lexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t004");
	if (lxr == NULL)
		lxr = new t004lexer(input);
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
		t004lexerTraits::CommonTokenType *token = lxr->nextToken();

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
	t004lexerTraits::InputStreamType* input	= new t004lexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t004");
	if (lxr == NULL)
		lxr = new t004lexer(input);
	else
		lxr->setCharStream(input);

	std::cout << "testMalformedInput: \"" << data << '"' <<std::endl;
	
	t004lexerTraits::CommonTokenType *token0 = lxr->nextToken();
	std::cout << token0->getText() << std::endl;
	
	delete lxr; lxr = NULL;
	delete input;
	return 0;
}
