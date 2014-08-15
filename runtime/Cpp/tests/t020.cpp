#include "UserTestTraits.hpp"
#include "t020fuzzyLexer.hpp"

#include <sys/types.h>

#include <iostream>
#include <sstream>
#include <fstream>

using namespace Antlr3Test;
using namespace std;

int testValid(string const& in, string const& out);

static t020fuzzyLexer *lxr;

int main (int argc, char *argv[])
{
	testValid("t020fuzzy.input", "t020fuzzy.output");
	return 0;
}

int testValid(string const& inFilename, string const& outFilename)
{
	string data = slurp(inFilename);
	t020fuzzyLexerTraits::InputStreamType* input	= new t020fuzzyLexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
												    antlr3::ENC_8BIT,
												    data.length(), //strlen(data.c_str()),
												    (ANTLR_UINT8*)inFilename.c_str());
	if (lxr == NULL)
		lxr = new t020fuzzyLexer(input);
	else
		lxr->setCharStream(input);

	std::cout << "testValid: \"" << inFilename << '"' <<std::endl;
	for(;;)
	{
		t020fuzzyLexerTraits::CommonTokenType *token = lxr->nextToken();
		if( token->getType() == t020fuzzyLexerTokens::EOF_TOKEN)
			break;
	}
	
	string expOutput = slurp(outFilename);
	string lxrOutput = lxr->outbuf.str();

	ofstream out("t012.lxr.output");
	out << lxrOutput;

	std::cout << inFilename << '\t' << (expOutput == lxrOutput ?  "OK" : "Fail") << std::endl;

	delete lxr; lxr = NULL;
	delete input; 
	return 0;
}

