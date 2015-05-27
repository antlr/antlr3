#include "utils.hpp"
#include "ATestTraits.hpp"
#include "a003Lexer.hpp"
#include "a003Parser.hpp"

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

int 
main	(int argc, char *argv[])
{
	test1("ABCDEFG");
	test1("BCDEFG");
	test2("ABCDEFG");
	test2("BCDEFG");
	test3("ABCDEFG");
	test3("BCDEFG");
	test4("ABCDEFGH");
	test4("BCDEFGH");
	test5("ABCDEFGH");
	test5("BCDEFGH");

	printf("finished parsing OK\n");	// Finnish parking is pretty good - I think it is all the snow

	return 0;
}

void test1(const char* input)
{
	a003LexerTraits::InputStreamType* istream = new a003LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
											 , antlr3::ENC_8BIT
											 , strlen(input)
											 , (ANTLR_UINT8*)"test1");
	istream->setUcaseLA(true);
	
	a003Lexer* lxr = new a003Lexer(istream);
	a003LexerTraits::TokenStreamType* tstream = new a003LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	a003Parser* psr = new a003Parser(tstream);	
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
	auto istream = new a003LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
							    , antlr3::ENC_8BIT
							    , strlen(input)
							    , (ANTLR_UINT8*)"test2");
	istream->setUcaseLA(true);
	
	auto lxr = new a003Lexer(istream);
	auto tstream = new a003LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	auto psr = new a003Parser(tstream);	
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
	auto istream = new a003LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
							    , antlr3::ENC_8BIT
							    , strlen(input)
							    , (ANTLR_UINT8*)"test2");
	istream->setUcaseLA(true);
	
	auto lxr = new a003Lexer(istream);
	auto tstream = new a003LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	auto psr = new a003Parser(tstream);	
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
	auto istream = new a003LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
							    , antlr3::ENC_8BIT
							    , strlen(input)
							    , (ANTLR_UINT8*)"test2");
	istream->setUcaseLA(true);
	
	auto lxr = new a003Lexer(istream);
	auto tstream = new a003LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	auto psr = new a003Parser(tstream);	
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
	auto istream = new a003LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
							    , antlr3::ENC_8BIT
							    , strlen(input)
							    , (ANTLR_UINT8*)"test2");
	istream->setUcaseLA(true);

	auto lxr = new a003Lexer(istream);
	auto tstream = new a003LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	auto psr = new a003Parser(tstream);
	{
		auto r = psr->test5();
		std::cout << r.tree->toStringTree() << std::endl;
	}

	delete psr;
	delete tstream;
	delete lxr;
	delete istream;
}
