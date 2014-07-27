#include "utils.hpp"
#include "ATestTraits.hpp"
#include "a001Lexer.hpp"
#include "a001Parser.hpp"

#include <iostream>
#include <sstream>
#include <fstream>

using namespace Antlr3Test;
using namespace std;

void test1(const char* input);
void test2(const char* input);
void test3(const char* input);

int 
main	(int argc, char *argv[])
{
	test1("ABCDEFG");
	test2("ABCDEFG");
	test3("ABCDEFGH");

	printf("finished parsing OK\n");	// Finnish parking is pretty good - I think it is all the snow

	return 0;
}

void test1(const char* input)
{
	a001LexerTraits::InputStreamType* istream = new a001LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
											 , ANTLR_ENC_8BIT
											 , strlen(input)
											 , (ANTLR_UINT8*)"test1");
	istream->setUcaseLA(true);
	
	a001Lexer* lxr = new a001Lexer(istream);
	a001LexerTraits::TokenStreamType* tstream = new a001LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	a001Parser* psr = new a001Parser(tstream);	
	{
		auto r1 = psr->test1();
		std::cout << r1.tree->toStringTree() << std::endl;
	}
	
	delete psr;
	delete tstream; 
	delete lxr;
	delete istream;
}

void test2(const char* input)
{
	auto istream = new a001LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
							    , ANTLR_ENC_8BIT
							    , strlen(input)
							    , (ANTLR_UINT8*)"test2");
	istream->setUcaseLA(true);
	
	auto lxr = new a001Lexer(istream);
	auto tstream = new a001LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	auto psr = new a001Parser(tstream);	
	{
		auto r2 = psr->test2();
		std::cout << r2.tree->toStringTree() << std::endl;
	}
	
	delete psr;
	delete tstream; 
	delete lxr;
	delete istream;
}

void test3(const char* input)
{
	auto istream = new a001LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
							    , ANTLR_ENC_8BIT
							    , strlen(input)
							    , (ANTLR_UINT8*)"test3");
	istream->setUcaseLA(true);
	
	auto lxr = new a001Lexer(istream);       
	auto tstream = new a001LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	auto psr = new a001Parser(tstream);
	{
		auto r3 = psr->test3();
		std::cout << r3.tree->toStringTree() << std::endl;
	}
	
	delete psr;
	delete tstream; 
	delete lxr;
	delete istream;
}
