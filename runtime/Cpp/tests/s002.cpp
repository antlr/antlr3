#include "utils.hpp"
#include "UserTestTraits.hpp"
#include "s002Lexer.hpp"
#include "s002Parser.hpp"

#include <sys/types.h>

#include <iostream>
#include <sstream>
#include <fstream>

using namespace Antlr3Test;
using namespace std;

int 
main	(int argc, char *argv[])
{
	if (argc < 2 || argv[1] == NULL)
	{
		Utils::processDir("./s002.input"); // Note in VS2005 debug, working directory must be configured
	}
	else
	{
		for (int i = 1; i < argc; i++)
		{
			Utils::processDir(argv[i]);
		}
	}

	printf("finished parsing OK\n");	// Finnish parking is pretty good - I think it is all the snow

	return 0;
}

void parseFile(const char* fName, int fd)
{
	s002LexerTraits::InputStreamType*    input;
	s002LexerTraits::TokenStreamType*	tstream;
	s002Parser*			psr;
	
#if defined __linux
	string data = Utils::slurp(fd);
#else
	string data = Utils::slurp(fName);
#endif
	input	= new s002LexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str()
						       , antlr3::ENC_8BIT
						       , data.length()
						       , (ANTLR_UINT8*)fName);

	input->setUcaseLA(true);

	// Our input stream is now open and all set to go, so we can create a new instance of our
	// lexer and set the lexer input to our input stream:
	//  (file | memory | ?) --> inputstream -> lexer --> tokenstream --> parser ( --> treeparser )?
	//
	s002Lexer* lxr = new s002Lexer(input);

	tstream = new s002LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());

	// Finally, now that we have our lexer constructed, we can create the parser
	//
	psr = new s002Parser(tstream);
	{
		s002Parser::start_rule_return r = psr->start_rule();
		std::cout << r.tree->toStringTree() << std::endl;
	}

	putc('L', stdout); fflush(stdout);
	{
		ANTLR_INT32 T = 0;
		while	(T != s002Lexer::EOF_TOKEN)
		{
			T = tstream->LA(1);
			s002LexerTraits::CommonTokenType const* token = tstream->LT(1);
			ANTLR_UINT8 const *name = lxr->getTokenName(T);
			  
			printf("%d %s\t\"%s\"\n",
			       T,
			       name,
			       tstream->LT(1)->getText().c_str()
			       );
			tstream->consume();
		}
	}

	tstream->LT(1);	// Don't do this mormally, just causes lexer to run for timings here

	delete psr;
	delete tstream; 
	delete lxr; lxr = NULL;
	delete input; 
}
