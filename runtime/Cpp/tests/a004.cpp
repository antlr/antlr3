#include "utils.hpp"
#include "ATestTraits.hpp"
#include "a004Lexer.hpp"
#include "a004Parser.hpp"

#include <iostream>
#include <sstream>
#include <fstream>

using namespace Antlr3Test;
using namespace std;

void test1(const char* input);
void test2(const char* input);
void test3(const char* input);
void test4(const char* input);
void test5(const char* input);
void test6(const char* input);

int 
main	(int argc, char *argv[])
{
	test1("ABCDEFG");
	test2("ABCDEFG"); // NOTE this one leaks memory
	test3("ABCDEFG");
	test4("ABCDEFGH");
	test5("ABCDEFGH");
	test6("ABCDEFG");

	printf("finished parsing OK\n");	// Finnish parking is pretty good - I think it is all the snow

	return 0;
}

void test1(const char* input)
{
	a004LexerTraits::InputStreamType* istream = new a004LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
											 , ANTLR_ENC_8BIT
											 , strlen(input)
											 , (ANTLR_UINT8*)"test1");
	istream->setUcaseLA(true);
	
	a004Lexer* lxr = new a004Lexer(istream);
	a004LexerTraits::TokenStreamType* tstream = new a004LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	a004Parser* psr = new a004Parser(tstream);	
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
	auto istream = new a004LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
							    , ANTLR_ENC_8BIT
							    , strlen(input)
							    , (ANTLR_UINT8*)"test2");
	istream->setUcaseLA(true);
	
	auto lxr = new a004Lexer(istream);
	auto tstream = new a004LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	auto psr = new a004Parser(tstream);	
	{
		auto r = psr->test2();
		std::cout << r.tree->toStringTree() << std::endl;
	}
	
	delete psr;
	delete tstream; 
	delete lxr;
	delete istream;
}

void test3(const char* input)
{
	auto istream = new a004LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
							    , ANTLR_ENC_8BIT
							    , strlen(input)
							    , (ANTLR_UINT8*)"test2");
	istream->setUcaseLA(true);
	
	auto lxr = new a004Lexer(istream);
	auto tstream = new a004LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	auto psr = new a004Parser(tstream);	
	{
		auto r = psr->test3();
		std::cout << r.tree->toStringTree() << std::endl;
	}
	
	delete psr;
	delete tstream; 
	delete lxr;
	delete istream;
}

void test4(const char* input)
{
	auto istream = new a004LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
							    , ANTLR_ENC_8BIT
							    , strlen(input)
							    , (ANTLR_UINT8*)"test4");
	istream->setUcaseLA(true);
	
	auto lxr = new a004Lexer(istream);
	auto tstream = new a004LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	auto psr = new a004Parser(tstream);	
	{
		auto r = psr->test4();
		std::cout << r.tree->toStringTree() << std::endl;
	}
	
	delete psr;
	delete tstream; 
	delete lxr;
	delete istream;
}

void test5(const char* input)
{
	auto istream = new a004LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
							    , ANTLR_ENC_8BIT
							    , strlen(input)
							    , (ANTLR_UINT8*)"test5");
	istream->setUcaseLA(true);

	auto lxr = new a004Lexer(istream);
	auto tstream = new a004LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	auto psr = new a004Parser(tstream);
	{
		auto r = psr->test5();
		std::cout << r.tree->toStringTree() << std::endl;
	}

	delete psr;
	delete tstream;
	delete lxr;
	delete istream;
}

void test6(const char* input)
{
	auto istream = new a004LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
							    , ANTLR_ENC_8BIT
							    , strlen(input)
							    , (ANTLR_UINT8*)"test6");
	istream->setUcaseLA(true);

	auto lxr = new a004Lexer(istream);
	auto tstream = new a004LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	auto psr = new a004Parser(tstream);
	{
		auto r = psr->test6();
		std::cout << r.tree->toStringTree() << std::endl;
	}

	delete psr;
	delete tstream;
	delete lxr;
	delete istream;
}
