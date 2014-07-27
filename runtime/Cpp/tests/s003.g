grammar s003;

options {
	language=Cpp;
	//backtrack=true;
	//memoize=true;
	//output=AST;
}

tokens {
    BLOCK = 'block';
}

@lexer::includes 
{
#include "UserTestTraits.hpp"
}
@lexer::namespace 
{ Antlr3Test }

@parser::includes {
#include "UserTestTraits.hpp"
#include "s003Lexer.hpp"
}
@parser::namespace 
{ Antlr3Test }
@parser::context {
	class Evaluator {
        public:
        	Evaluator(const char*text) : m_text(text) {};
        	Evaluator(std::string text) : m_text(text) {};
        	std::string const& toString() { return m_text; };
        private:
            std::string m_text;
    };
}

start_rule returns[s003Parser::Evaluator *evaluator, std::string message]
	: r=parse
        {
            $evaluator = $r.evaluator;
            $message = $r.message;
        } 
	;

parse returns[s003Parser::Evaluator *evaluator, std::string message]
  :  r=receive
        {
            s003Parser::Evaluator *e = $r.evaluator;
            std::string m = $r.message;
            $evaluator   = $r.evaluator;
            $message = $r.message;
        }
  ;

receive returns[s003Parser::Evaluator *evaluator, std::string message]
  :  RECEIVE f=FILENAME
        {
            $evaluator = new s003Parser::Evaluator($f.text);
            $message = "Some message here...";
        }
  ;

RECEIVE: 'RECEIVE';
FILENAME: 'FILENAME';
		
