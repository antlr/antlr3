#include "UserTestTraits.hpp"
#include "t005lexer.hpp"

#include <sys/types.h>

#include <iostream>
#include <sstream>
#include <fstream>

using namespace Antlr3Test;
using namespace std;

int testValid(string const& data);
int testMalformedInput1(string const& data);
int testMalformedInput2(string const& data);

static t005lexer *lxr;

struct TokenData
{
	t005lexerTokens::Tokens type;
	unsigned start;
	unsigned stop;
	const char* text;
};

static TokenData ExpectedTokens[] =
{
	// "fofoofooo"
	{ t005lexerTokens::FOO, 0, 1, "fo"},
	{ t005lexerTokens::FOO, 2, 4, "foo"},
	{ t005lexerTokens::FOO, 5, 8, "fooo"},
	{ t005lexerTokens::EOF_TOKEN, 9, 9, "<EOF>"}
};

int main (int argc, char *argv[])
{
	testValid("fofoofooo");
	testMalformedInput1("2");
	testMalformedInput2("f");
	return 0;
}

int testValid(string const& data)
{
	t005lexerTraits::InputStreamType* input	= new t005lexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t005");
	if (lxr == NULL)
		lxr = new t005lexer(input);
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
		t005lexerTraits::CommonTokenType *token = lxr->nextToken();

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

int testMalformedInput1(string const& data)
{
	t005lexerTraits::InputStreamType* input	= new t005lexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t005");
	if (lxr == NULL)
		lxr = new t005lexer(input);
	else
		lxr->setCharStream(input);

	std::cout << "testMalformedInput1: \"" << data << '"' <<std::endl;
	
	t005lexerTraits::CommonTokenType *token0 = lxr->nextToken();
	std::cout << token0->getText() << std::endl;

	//except antlr3.MismatchedTokenException as exc:
	//self.assertEqual(exc.expecting, 'f')
	//self.assertEqual(exc.unexpectedType, '2')

	delete lxr; lxr = NULL;
	delete input; 
	return 0;
}

int testMalformedInput2(string const& data)
{
	t005lexerTraits::InputStreamType* input	= new t005lexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t005");
	if (lxr == NULL)
		lxr = new t005lexer(input);
	else
		lxr->setCharStream(input);

	std::cout << "testMalformedInput2: \"" << data << '"' <<std::endl;
	
	t005lexerTraits::CommonTokenType *token0 = lxr->nextToken();
	std::cout << token0->getText() << std::endl;

	//except antlr3.EarlyExitException as exc:
	//self.assertEqual(exc.unexpectedType, antlr3.EOF)

	delete lxr; lxr = NULL;
	delete input; 
	return 0;
}
