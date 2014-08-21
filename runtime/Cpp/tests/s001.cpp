#include "utils.hpp"
#include "UserTestTraits.hpp"
#include "s001Lexer.hpp"
#include "s001Parser.hpp"

#include <sys/types.h>

#include <iostream>
#include <sstream>
#include <fstream>

using namespace Antlr3Test;
using namespace std;

int 
main	(int argc, char *argv[])
{
	// Create the input stream based upon the argument supplied to us on the command line
	// for this example, the input will always default to ./input if there is no explicit
	// argument, otherwise we are expecting potentially a whole list of 'em.
	//
	if (argc < 2 || argv[1] == NULL)
	{
		Utils::processDir("./s002.input"); // Note in VS2005 debug, working directory must be configured
	}
	else
	{
		int i;

		for (i = 1; i < argc; i++)
		{
			Utils::processDir(argv[i]);
		}
	}

	printf("finished parsing OK\n");	// Finnish parking is pretty good - I think it is all the snow

	return 0;
}

void parseFile(const char* fName, int fd)
{
	s001LexerTraits::InputStreamType*    input;
	s001LexerTraits::TokenStreamType*	tstream;
	s001Parser*			psr;
	
#if defined __linux
	string data = Utils::slurp(fd);
#else
	string data = Utils::slurp(fName);
#endif
	input	= new s001LexerTraits::InputStreamType((const ANTLR_UINT8 *)data.c_str()
						       , antlr3::ENC_8BIT
						       , data.length()
						       , (ANTLR_UINT8*)fName);
	input->setUcaseLA(true);

	//  (file | memory | ?) --> inputstream -> lexer --> tokenstream --> parser ( --> treeparser )?
	//
	s001Lexer* lxr	    = new s001Lexer(input); 

	tstream = new s001LexerTraits::TokenStreamType(ANTLR_SIZE_HINT, lxr->get_tokSource());

	// Finally, now that we have our lexer constructed, we can create the parser
	//
	psr = new s001Parser(tstream);
	
	putc('L', stdout); fflush(stdout);
	{
		ANTLR_INT32 T = 0;
		while	(T != s001Lexer::EOF_TOKEN)
		{
			T = tstream->LA(1);
			s001LexerTraits::CommonTokenType const* token = tstream->LT(1);
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
