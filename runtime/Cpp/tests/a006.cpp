#include "utils.hpp"
#include "ATestTraits.hpp"
#include "a006Lexer.hpp"
#include "a006Parser.hpp"

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
	test1("ABC");
 	test1("(ABC)");
	test1("ABC AS 5");
	test1("ABC AS(1,2,3,4,5,6)");
	test1("(ABC,ABD,ABE,ABF)AS(1,2,3,4,5,6)");

	test2("ABC");
	test2("(ABC)");
	test2("ABC AS 5");
	test2("ABC AS(1,2,3,4,5,6)");
	test2("(ABC,ABD,ABE,ABF)AS(1,2,3,4,5,6)");

	test3("SAMPLE (4)");
	test3("SAMPLE BLOCK(4,5)");
	
	printf("finished parsing OK\n");	// Finnish parking is pretty good - I think it is all the snow

	return 0;
}

void test1(const char* input)
{
	a006LexerTraits::InputStreamType* istream = new a006LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
											 , ANTLR_ENC_8BIT
											 , strlen(input)
											 , (ANTLR_UINT8*)"test1");
	istream->setUcaseLA(true);
	
	a006Lexer* lxr = new a006Lexer(istream);
	a006LexerTraits::TokenStreamType* tstream = new a006LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	a006Parser* psr = new a006Parser(tstream);	
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
	a006LexerTraits::InputStreamType* istream = new a006LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
											 , ANTLR_ENC_8BIT
											 , strlen(input)
											 , (ANTLR_UINT8*)"test2");
	istream->setUcaseLA(true);
	
	a006Lexer* lxr = new a006Lexer(istream);
	a006LexerTraits::TokenStreamType* tstream = new a006LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	a006Parser* psr = new a006Parser(tstream);	
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
	a006LexerTraits::InputStreamType* istream = new a006LexerTraits::InputStreamType((const ANTLR_UINT8 *)input
											 , ANTLR_ENC_8BIT
											 , strlen(input)
											 , (ANTLR_UINT8*)"test3");
	istream->setUcaseLA(true);
	
	a006Lexer* lxr = new a006Lexer(istream);
	a006LexerTraits::TokenStreamType* tstream = new a006LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	a006Parser* psr = new a006Parser(tstream);	
	{
		auto r1 = psr->test3();
		std::cout << r1.tree->toStringTree() << std::endl;
	}
	
	delete psr;
	delete tstream; 
	delete lxr;
	delete istream;
}
