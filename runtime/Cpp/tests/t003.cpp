#include "UserTestTraits.hpp"
#include "t003lexer.hpp"

#include <sys/types.h>

#include <iostream>
#include <sstream>
#include <fstream>

using namespace Antlr3Test;
using namespace std;

int testValid(string const& data);
int testIteratorInterface(string const& data);
int testMalformedInput(string const& data);

static t003lexer *lxr;

struct TokenData
{
	t003lexerTokens::Tokens type;
	//unsigned start;
	//unsigned stop;
	//const char* text;
};

static TokenData ExpectedTokens[] =
{
	{ t003lexerTokens::ZERO      },
	{ t003lexerTokens::FOOZE     },
	{ t003lexerTokens::ONE       },
	{ t003lexerTokens::EOF_TOKEN }
};

int main (int argc, char *argv[])
{
	testValid("0fooze1");
	testIteratorInterface("0fooze1");
	testMalformedInput("2");
	return 0;
}

int testValid(string const& data)
{
	t003lexerTraits::InputStreamType* input	= new t003lexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t003");
	if (lxr == NULL)
		lxr = new t003lexer(input);
	else
		lxr->setCharStream(input);

	std::cout << "testValid: \"" << data << '"' <<std::endl;

	for(unsigned i = 0; i < sizeof(ExpectedTokens)/sizeof(TokenData) ; i++)
	{
		// nextToken does not allocate any new Token instance(the same instance is returned again and again)
		t003lexerTraits::CommonTokenType *token = lxr->nextToken();
		std::cout << token->getText() << '\t'
			  << (token->getType() == ExpectedTokens[i].type ? "OK" : "Fail")
			  << std::endl;
		
	}
	delete lxr; lxr = NULL;
	delete input; 
	return 0;
}

int testIteratorInterface(string const& data)
{
	t003lexerTraits::InputStreamType* input	= new t003lexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t003");
	if (lxr == NULL)
		lxr = new t003lexer(input);
	else
		lxr->setCharStream(input);

	std::cout << "testIteratorInterface: \"" << data << '"' <<std::endl;
		
	t003lexerTraits::TokenStreamType *tstream = new t003lexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	t003lexerTraits::CommonTokenType const *token0 = tstream->_LT(1);
	t003lexerTraits::CommonTokenType const *token1 = tstream->_LT(2);
	t003lexerTraits::CommonTokenType const *token2 = tstream->_LT(3);
	t003lexerTraits::CommonTokenType const *token3 = tstream->_LT(4);

	std::cout << token0->getText() << std::endl;
	std::cout << token1->getText() << std::endl;
	std::cout << token2->getText() << std::endl;
	std::cout << token3->getText() << std::endl;

	delete tstream;
	delete lxr; lxr = NULL;
	delete input;
	return 0;
}

int testMalformedInput(string const& data)
{
	t003lexerTraits::InputStreamType* input	= new t003lexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t003");
	if (lxr == NULL)
		lxr = new t003lexer(input);
	else
		lxr->setCharStream(input);

	std::cout << "testMalformedInput: \"" << data << '"' <<std::endl;
	
	t003lexerTraits::CommonTokenType *token0 = lxr->nextToken();
	std::cout << token0->getText() << std::endl;
	
	delete lxr; lxr = NULL;
	delete input;
	return 0;
}
