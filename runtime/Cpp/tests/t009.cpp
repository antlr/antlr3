#include "UserTestTraits.hpp"
#include "t009lexer.hpp"

#include <sys/types.h>

#include <iostream>
#include <sstream>
#include <fstream>

using namespace Antlr3Test;
using namespace std;

int testValid(string const& data);
int testMalformedInput(string const& data);

static t009lexer *lxr;

struct TokenData
{
	t009lexerTokens::Tokens type;
	unsigned start;
	unsigned stop;
	const char* text;
};

static TokenData ExpectedTokens[] =
{
	// "085"
	{ t009lexerTokens::DIGIT, 0, 0, "0"},
	{ t009lexerTokens::DIGIT, 1, 1, "8"},
	{ t009lexerTokens::DIGIT, 2, 2, "5"},
	{ t009lexerTokens::EOF_TOKEN, 3, 3, "<EOF>"}
};

int main (int argc, char *argv[])
{
	testValid("085"); 
	testMalformedInput("2a");
	return 0;
}

int testValid(string const& data)
{
	t009lexerTraits::InputStreamType* input	= new t009lexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t009");
	if (lxr == NULL)
		lxr = new t009lexer(input);
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
		t009lexerTraits::CommonTokenType *token = lxr->nextToken();

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
	t009lexerTraits::InputStreamType* input	= new t009lexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t009");
	if (lxr == NULL)
		lxr = new t009lexer(input);
	else
		lxr->setCharStream(input);

	std::cout << "testMalformedInput: \"" << data << '"' <<std::endl;
	
	t009lexerTraits::CommonTokenType *token;
	token = lxr->nextToken();
	std::cout << token->getText() << std::endl;
	token = lxr->nextToken();
	std::cout << token->getText() << std::endl;

	//except antlr3.MismatchedSetException as exc:
	//   # TODO: This should provide more useful information
	//   self.assertIsNone(exc.expecting)
	//   self.assertEqual(exc.unexpectedType, 'a')
	//   self.assertEqual(exc.charPositionInLine, 1)
	//   self.assertEqual(exc.line, 1)

	delete lxr; lxr = NULL;
	delete input; 
	return 0;
}
