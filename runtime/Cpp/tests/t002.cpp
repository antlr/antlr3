#include "UserTestTraits.hpp"
#include "t002lexer.hpp"

#include <sys/types.h>

#include <iostream>
#include <sstream>
#include <fstream>

using namespace Antlr3Test;
using namespace std;

int testValid(string const& data);
int testIteratorInterface(string const& data);
int testMalformedInput(string const& data);

static t002lexer *lxr;
static t002lexerTokens::Tokens ExpectedTokens[] =
  {
    t002lexerTokens::ZERO,
    t002lexerTokens::ONE,
    t002lexerTokens::EOF_TOKEN
  };

int main (int argc, char *argv[])
{
	testValid("01");
	testIteratorInterface("01");
	testMalformedInput("2");
	return 0;
}

int testValid(string const& data)
{
	t002lexerTraits::InputStreamType* input	= new t002lexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t002");
	if (lxr == NULL)
		lxr = new t002lexer(input);
	else
		lxr->setCharStream(input);

	std::cout << "testValid: \"" << data << '"' <<std::endl;

	for(unsigned i = 0; i <= 2 ; i++)
	{
		// nextToken does not allocate any new Token instance(the same instance is returned again and again)
		t002lexerTraits::CommonTokenType *token = lxr->nextToken();
		std::cout << token->getText() << '\t'
			  << (token->getType() == ExpectedTokens[i] ? "OK" : "Fail")
			  << std::endl;
		
	}
	delete lxr; lxr = NULL;
	delete input; 
	return 0;
}

int testIteratorInterface(string const& data)
{
	t002lexerTraits::InputStreamType* input	= new t002lexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t002");
	if (lxr == NULL)
		lxr = new t002lexer(input);
	else
		lxr->setCharStream(input);

	std::cout << "testIteratorInterface: \"" << data << '"' <<std::endl;
	
	t002lexerTraits::TokenStreamType *tstream = new t002lexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	t002lexerTraits::CommonTokenType const *token0 = tstream->_LT(1);
	t002lexerTraits::CommonTokenType const *token1 = tstream->_LT(2);
	t002lexerTraits::CommonTokenType const *token2 = tstream->_LT(3);

	std::cout << token0->getText() << std::endl;
	std::cout << token1->getText() << std::endl;
	std::cout << token2->getText() << std::endl;

	delete tstream;
	delete lxr; lxr = NULL;
	delete input;
	return 0;
}

int testMalformedInput(string const& data)
{
	t002lexerTraits::InputStreamType* input	= new t002lexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t002");
	if (lxr == NULL)
		lxr = new t002lexer(input);
	else
		lxr->setCharStream(input);

	std::cout << "testMalformedInput: \"" << data << '"' <<std::endl;
	
	t002lexerTraits::CommonTokenType *token0 = lxr->nextToken();
	std::cout << token0->getText() << std::endl;
	
	delete lxr; lxr = NULL;
	delete input;
	return 0;
}
