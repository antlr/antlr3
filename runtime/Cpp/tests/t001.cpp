#include "UserTestTraits.hpp"
#include "t001lexer.hpp"

#include <sys/types.h>

#include <iostream>
#include <sstream>
#include <fstream>

using namespace Antlr3Test;
using namespace std;

int testValid(string const& data);
int testIteratorInterface(string const& data);
int testMalformedInput(string const& data);

static    t001lexer*		    lxr;

int main (int argc, char *argv[])
{
	testValid("0");
	testIteratorInterface("0");
	testMalformedInput("1");
	return 0;
}

int testValid(string const& data)
{
	t001lexerTraits::InputStreamType* input	= new t001lexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t001");
	if (lxr == NULL)
		lxr = new t001lexer(input);
	else
		lxr->setCharStream(input);

	std::cout << "testValid: \"" << data << '"' <<std::endl;

	t001lexerTraits::CommonTokenType *token0 = lxr->nextToken();
	t001lexerTraits::CommonTokenType *token1 = lxr->nextToken();

	std::cout << token0->getText() << std::endl;
	std::cout << token1->getText() << std::endl;
	
	delete lxr; lxr = NULL;
	delete input;
	return 0;
}

int testIteratorInterface(string const& data)
{
	t001lexerTraits::InputStreamType* input	= new t001lexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t001");
	if (lxr == NULL)
		lxr = new t001lexer(input);
	else
		lxr->setCharStream(input);

	std::cout << "testIteratorInterface: \"" << data << '"' <<std::endl;

	t001lexerTraits::TokenStreamType *tstream = new t001lexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	t001lexerTraits::CommonTokenType const *token0 = tstream->_LT(1);
	t001lexerTraits::CommonTokenType const *token1 = tstream->_LT(2);

	std::cout << token0->getText() << std::endl;
	std::cout << token1->getText() << std::endl;

	delete tstream;
	delete lxr; lxr = NULL;
	delete input;
	return 0;
}

int testMalformedInput(string const& data)
{
	t001lexerTraits::InputStreamType* input	= new t001lexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t001");
	if (lxr == NULL)
		lxr = new t001lexer(input);
	else
		lxr->setCharStream(input);

	std::cout << "testMalformedInput: \"" << data << '"' <<std::endl;

	t001lexerTraits::CommonTokenType *token0 = lxr->nextToken();
	std::cout << token0->getText() << std::endl;
	
	delete lxr; lxr = NULL;
	delete input; 
	return 0;
}
