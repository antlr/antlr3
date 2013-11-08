#include "UserTestTraits.hpp"
#include "t012lexerXMLLexer.hpp"

#include <sys/types.h>

#include <iostream>
#include <sstream>
#include <fstream>

using namespace Antlr3Test;
using namespace std;

int testValid(string const& in, string const& out);
int testMalformedInput1(string const& data);
int testMalformedInput2(string const& data);
int testMalformedInput3(string const& data);
string slurp(string const& fileName);

static t012lexerXMLLexer *lxr;

int main (int argc, char *argv[])
{
	testValid("t012lexerXML.input", "t012lexerXML.output");
	testMalformedInput1("<?xml version='1.0'?>\n<document d>\n</document>\n");
	testMalformedInput2("<?tml version='1.0'?>\n<document>\n</document>\n");
	testMalformedInput3("<?xml version='1.0'?>\n<docu ment attr=\"foo\">\n</document>\n");

	return 0;
}

int testValid(string const& inFilename, string const& outFilename)
{
	string data = slurp(inFilename);
	t012lexerXMLLexerTraits::InputStreamType* input	= new t012lexerXMLLexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
											   (ANTLR_UINT8*)inFilename.c_str());
	if (lxr == NULL)
		lxr = new t012lexerXMLLexer(input);
	else
		lxr->setCharStream(input);

	std::cout << "testValid: \"" << inFilename << '"' <<std::endl;
	for(;;)
	{
		t012lexerXMLLexerTraits::CommonTokenType *token = lxr->nextToken();
		if( token->getType() == t012lexerXMLLexerTokens::EOF_TOKEN)
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

int testMalformedInput1(string const& data)
{
	t012lexerXMLLexerTraits::InputStreamType* input	= new t012lexerXMLLexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t012");
	if (lxr == NULL)
		lxr = new t012lexerXMLLexer(input);
	else
		lxr->setCharStream(input);

	std::cout << "testMalformedInput1: \"" << data << '"' <<std::endl;
	
	t012lexerXMLLexerTraits::CommonTokenType *token;
	token = lxr->nextToken();
	std::cout << token->getText() << std::endl;
	token = lxr->nextToken();
	std::cout << token->getText() << std::endl;
	token = lxr->nextToken();
	std::cout << token->getText() << std::endl;

        // try:
        //     while True:
        //         token = lexer.nextToken()
        //         # Should raise NoViableAltException before hitting EOF
        //         if token.type == antlr3.EOF:
        //             self.fail()
	//
        // except antlr3.NoViableAltException as exc:
        //     self.assertEqual(exc.unexpectedType, '>')
        //     self.assertEqual(exc.charPositionInLine, 11)
        //     self.assertEqual(exc.line, 2)

	delete lxr; lxr = NULL;
	delete input; 
	return 0;
}

int testMalformedInput2(string const& data)
{
	t012lexerXMLLexerTraits::InputStreamType* input	= new t012lexerXMLLexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t012");
	if (lxr == NULL)
		lxr = new t012lexerXMLLexer(input);
	else
		lxr->setCharStream(input);

	std::cout << "testMalformedInput2: \"" << data << '"' <<std::endl;
	
	t012lexerXMLLexerTraits::CommonTokenType *token;
	token = lxr->nextToken();
	std::cout << token->getText() << std::endl;
	token = lxr->nextToken();
	std::cout << token->getText() << std::endl;
	token = lxr->nextToken();
	std::cout << token->getText() << std::endl;

        // try:
        //     while True:
        //         token = lexer.nextToken()
        //         # Should raise NoViableAltException before hitting EOF
        //         if token.type == antlr3.EOF:
        //             self.fail()
	//
        // except antlr3.MismatchedSetException as exc:
        //     self.assertEqual(exc.unexpectedType, 't')
        //     self.assertEqual(exc.charPositionInLine, 2)
        //     self.assertEqual(exc.line, 1)

	delete lxr; lxr = NULL;
	delete input; 
	return 0;
}

int testMalformedInput3(string const& data)
{
	t012lexerXMLLexerTraits::InputStreamType* input	= new t012lexerXMLLexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str(),
										       ANTLR_ENC_8BIT,
										       data.length(), //strlen(data.c_str()),
										       (ANTLR_UINT8*)"t012");
	if (lxr == NULL)
		lxr = new t012lexerXMLLexer(input);
	else
		lxr->setCharStream(input);

	std::cout << "testMalformedInput3: \"" << data << '"' <<std::endl;
	
	t012lexerXMLLexerTraits::CommonTokenType *token;
	token = lxr->nextToken();
	std::cout << token->getText() << std::endl;
	token = lxr->nextToken();
	std::cout << token->getText() << std::endl;
	token = lxr->nextToken();
	std::cout << token->getText() << std::endl;

        // try:
        //     while True:
        //         token = lexer.nextToken()
        //         # Should raise NoViableAltException before hitting EOF
        //         if token.type == antlr3.EOF:
        //             self.fail()
	//
        // except antlr3.NoViableAltException as exc:
        //     self.assertEqual(exc.unexpectedType, 'a')
        //     self.assertEqual(exc.charPositionInLine, 11)
        //     self.assertEqual(exc.line, 2)

	delete lxr; lxr = NULL;
	delete input; 
	return 0;
}
 
string slurp(string const& fileName)
{
	ifstream ifs(fileName.c_str(), ios::in | ios::binary | ios::ate);
	ifstream::pos_type fileSize = ifs.tellg();
	ifs.seekg(0, ios::beg);

	stringstream sstr;
	sstr << ifs.rdbuf();
	return sstr.str();
}
