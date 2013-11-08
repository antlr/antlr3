#include "UserTestTraits.hpp"
#include "t039labelsLexer.hpp"
#include "t039labelsParser.hpp"

#include <sys/types.h>

#include <iostream>
#include <sstream>
#include <fstream>

using namespace Antlr3Test;
using namespace std;

int testValid(string const& data);
int testMalformedInput(string const& data);

static t039labelsLexer *lxr;


struct TokenData
{
	//t039labelsLexerTokens::Tokens type;
	//unsigned start;
	//unsigned stop;
	const char* text;
};

static TokenData ExpectedTokens[] =
{
  /*
        lexer = self.getLexer(cStream)
        tStream = antlr3.CommonTokenStream(lexer)
        parser = self.getParser(tStream)
        ids, w = parser.a()

        self.assertEqual(len(ids), 6, ids)
        self.assertEqual(ids[0].text, 'a', ids[0])
        self.assertEqual(ids[1].text, 'b', ids[1])
        self.assertEqual(ids[2].text, 'c', ids[2])
        self.assertEqual(ids[3].text, '1', ids[3])
        self.assertEqual(ids[4].text, '2', ids[4])
        self.assertEqual(ids[5].text, 'A', ids[5])

        self.assertEqual(w.text, 'GNU1', w)
  */
	// "a, b, c, 1, 2 A FOOBAR GNU1 A BLARZ"
	{ "a"},
	{ "b"},
	{ "c"},
	{ "1"},
	{ "2"},
	{ "A"},
};


int main (int argc, char *argv[])
{
	testValid("a, b, c, 1, 2 A FOOBAR GNU1 A BLARZ");
	return 0;
}

int testValid(string const& data)
{
	t039labelsLexerTraits::InputStreamType* input	= new t039labelsLexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t039");
	if (lxr == NULL)
		lxr = new t039labelsLexer(input);
	else
		lxr->setCharStream(input);

	std::cout << "testValid: \"" << data << '"' <<std::endl;

	t039labelsLexerTraits::TokenStreamType *tstream = new t039labelsLexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());
	t039labelsParser *psr = new t039labelsParser(tstream);
	t039labelsParser::TokenList r = psr->a();	
	
	for(unsigned i = 0; i < r.tokens.size() ; i++)
	{
		t039labelsLexerTraits::CommonTokenType *token = r.tokens.at(i);

		size_t startIndex = ((const char*)token->get_startIndex()) - data.c_str();
		size_t stopIndex = ((const char*)token->get_stopIndex()) - data.c_str();

		std::cout << token->getText()
			  << '\t' << (token->getText()       == ExpectedTokens[i].text ?  "OK" : "Fail")
			  << std::endl;
		
	}
	delete lxr; lxr = NULL;
	delete input; 
	return 0;
}

/*
    def testValid1(self):
        cStream = antlr3.StringStream(
            'a, b, c, 1, 2 A FOOBAR GNU1 A BLARZ'
            )

        lexer = self.getLexer(cStream)
        tStream = antlr3.CommonTokenStream(lexer)
        parser = self.getParser(tStream)
        ids, w = parser.a()

        self.assertEqual(len(ids), 6, ids)
        self.assertEqual(ids[0].text, 'a', ids[0])
        self.assertEqual(ids[1].text, 'b', ids[1])
        self.assertEqual(ids[2].text, 'c', ids[2])
        self.assertEqual(ids[3].text, '1', ids[3])
        self.assertEqual(ids[4].text, '2', ids[4])
        self.assertEqual(ids[5].text, 'A', ids[5])

        self.assertEqual(w.text, 'GNU1', w)


if __name__ == '__main__':
    unittest.main()


*/
