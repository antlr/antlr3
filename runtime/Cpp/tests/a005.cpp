#include "utils.hpp"
#include "ATestTraits.hpp"
#include "a005Lexer.hpp"
#include "a005Parser.hpp"

#include <iostream>
#include <sstream>
#include <fstream>

using namespace Antlr3Test;
using namespace std;

void test1(const char* input);
void test2(const char* input);
void test3(const char* input);
void test4(const char* input);

int 
main	(int argc, char *argv[])
{
	test1("ABC");
	test2("AABBCC");
	test3("AABBCC");
	test4("ABC"); // NOTE: this one leaks memory

	printf("finished parsing OK\n");	// Finnish parking is pretty good - I think it is all the snow

	return 0;
}

void test1(const char* input)
{
	a005LexerTraits::InputStreamType* istream = new a005LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
											 , antlr3::ENC_8BIT
											 , strlen(input)
											 , (ANTLR_UINT8*)"test1");
	istream->setUcaseLA(true);
	
	a005Lexer* lxr = new a005Lexer(istream);
	a005LexerTraits::TokenStreamType* tstream = new a005LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	a005Parser* psr = new a005Parser(tstream);	
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
	a005LexerTraits::InputStreamType* istream = new a005LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
											 , antlr3::ENC_8BIT
											 , strlen(input)
											 , (ANTLR_UINT8*)"test2");
	istream->setUcaseLA(true);
	
	a005Lexer* lxr = new a005Lexer(istream);
	a005LexerTraits::TokenStreamType* tstream = new a005LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	a005Parser* psr = new a005Parser(tstream);	
	{
		auto r1 = psr->test2();
		std::cout << r1.tree->toStringTree() << std::endl;
	}
	
	delete psr;
	delete tstream; 
	delete lxr;
	delete istream;
}

void test3(const char* input)
{
	a005LexerTraits::InputStreamType* istream = new a005LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
											 , antlr3::ENC_8BIT
											 , strlen(input)
											 , (ANTLR_UINT8*)"test3");
	istream->setUcaseLA(true);
	
	a005Lexer* lxr = new a005Lexer(istream);
	a005LexerTraits::TokenStreamType* tstream = new a005LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	a005Parser* psr = new a005Parser(tstream);	
	{
		auto r1 = psr->test3();
		std::cout << r1.tree->toStringTree() << std::endl;
	}
	
	delete psr;
	delete tstream; 
	delete lxr;
	delete istream;
}

void test4(const char* input)
{
	a005LexerTraits::InputStreamType* istream = new a005LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
											 , antlr3::ENC_8BIT
											 , strlen(input)
											 , (ANTLR_UINT8*)"test4");
	istream->setUcaseLA(true);
	
	a005Lexer* lxr = new a005Lexer(istream);
	a005LexerTraits::TokenStreamType* tstream = new a005LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	a005Parser* psr = new a005Parser(tstream);	
	{
		auto r1 = psr->test4();
		std::cout << r1.tree->toStringTree() << std::endl;
	}
	
	delete psr;
	delete tstream; 
	delete lxr;
	delete istream;
}

void test5(const char* input)
{
	a005LexerTraits::InputStreamType* istream = new a005LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
											 , antlr3::ENC_8BIT
											 , strlen(input)
											 , (ANTLR_UINT8*)"test5");
	istream->setUcaseLA(true);
	
	a005Lexer* lxr = new a005Lexer(istream);
	a005LexerTraits::TokenStreamType* tstream = new a005LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	a005Parser* psr = new a005Parser(tstream);	
	{
		auto r1 = psr->test5();
		std::cout << r1.tree->toStringTree() << std::endl;
	}
	
	delete psr;
	delete tstream; 
	delete lxr;
	delete istream;
}

void test6(const char* input)
{
	a005LexerTraits::InputStreamType* istream = new a005LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
											 , antlr3::ENC_8BIT
											 , strlen(input)
											 , (ANTLR_UINT8*)"test6");
	istream->setUcaseLA(true);
	
	a005Lexer* lxr = new a005Lexer(istream);
	a005LexerTraits::TokenStreamType* tstream = new a005LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	a005Parser* psr = new a005Parser(tstream);	
	{
		auto r1 = psr->test6();
		std::cout << r1.tree->toStringTree() << std::endl;
	}
	
	delete psr;
	delete tstream; 
	delete lxr;
	delete istream;
}
