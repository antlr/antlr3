#include "utils.hpp"
#include "A009TestTraits.hpp"
#include "a009Lexer.hpp"
#include "a009Parser.hpp"

#include <iostream>
#include <ostream>
#include <sstream>
#include <fstream>
#include <iomanip>

using namespace Antlr3Test;
using namespace std;

void test1(const char* input);
void test2(const char* input);
void test3(const char* input);

void treeWalk(a009Traits::TreeTypePtr const& root, unsigned depth = 0);
	
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
	a009Traits::InputStreamType* istream = new a009Traits::InputStreamType((const ANTLR_UINT8 *)input
											 , antlr3::ENC_8BIT
											 , strlen(input)
											 , (ANTLR_UINT8*)"test1");
	istream->setUcaseLA(true);
	
	a009Lexer* lxr = new a009Lexer(istream);
	a009Traits::TokenStreamType* tstream = new a009Traits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	a009Parser* psr = new a009Parser(tstream);	
	{
		auto r1 = psr->test1();
		std::cout << r1.tree->toStringTree() << std::endl;
		treeWalk(r1.tree);
	}
	
	delete psr;
	delete tstream; 
	delete lxr;
	delete istream;
}

void test2(const char* input)
{
	a009Traits::InputStreamType* istream = new a009Traits::InputStreamType((const ANTLR_UINT8 *)input
											 , antlr3::ENC_8BIT
											 , strlen(input)
											 , (ANTLR_UINT8*)"test2");
	istream->setUcaseLA(true);
	
	a009Lexer* lxr = new a009Lexer(istream);
	a009Traits::TokenStreamType* tstream = new a009Traits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	a009Parser* psr = new a009Parser(tstream);	
	{
		auto r1 = psr->test2();
		std::cout << r1.tree->toStringTree() << std::endl;
		treeWalk(r1.tree);		
	}
	
	delete psr;
	delete tstream; 
	delete lxr;
	delete istream;
}

void test3(const char* input)
{
	a009Traits::InputStreamType* istream = new a009Traits::InputStreamType((const ANTLR_UINT8 *)input
											 , antlr3::ENC_8BIT
											 , strlen(input)
											 , (ANTLR_UINT8*)"test3");
	istream->setUcaseLA(true);
	
	a009Lexer* lxr = new a009Lexer(istream);
	a009Traits::TokenStreamType* tstream = new a009Traits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	a009Parser* psr = new a009Parser(tstream);	
	{
		auto r1 = psr->test3();
		std::cout << r1.tree->toStringTree() << std::endl;
		treeWalk(r1.tree);
	}
	
	delete psr;
	delete tstream; 
	delete lxr;
	delete istream;
}


void treeWalk(a009Traits::TreeTypePtr const& root, unsigned depth)
{
	auto &children = root->get_children();

	if (root->UserData.usageType == 101)			
		cout << "column:" << setw(4 * depth + 3) << root->toStringTree() << endl;

	if (root->UserData.identifierClass)
		cout << "node:" << setw(4 * depth + 3) << root->toString() << '[' << root->UserData.identifierClass << ']' << endl;
	if (root->get_token() && root->get_token()->UserData.identifierClass)
		cout << "token:" << setw(4 * depth + 3) << root->toString() << '[' << root->get_token()->UserData.identifierClass << ']' << endl;
		
	for (auto i = children.begin(); i != children.end(); ++i)
	{
		treeWalk(*i, depth+1);
	}
}
