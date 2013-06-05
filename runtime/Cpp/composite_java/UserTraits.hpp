/** \file
 * This is the include file for the ANTLR3 sample project "dynamic-scope"
 * which shows how to use a C grammar and call it from C code.
 */
#ifndef	_T_TRAITS_H
#define	_T_TRAITS_H

// First thing we always do is include the ANTLR3 generated files, which
// will automatically include the antlr3 runtime header files.
// The compiler must use -I (or set the project settings in VS2005)
// to locate the antlr3 runtime files and -I. to find this file
//
#include    <antlr3.hpp>

namespace User {

class JavaLexer;
class JavaParser;

typedef antlr3::Traits<JavaLexer, JavaParser> JavaTraits;

/*
//code for overriding
template<class ImplTraits>
class UserTraits : public antlr3::CustomTraitsBase<ImplTraits>
{
public:
	//for using the token stream which deleted the tokens, once it is reduced to a rule
	//but it leaves the start and stop tokens. So they can be accessed as usual
	static const bool TOKENS_ACCESSED_FROM_OWNING_RULE = true;

	//Similarly, if you want to override the nextToken function. write a class that 
	//derives from antlr3::TokenSource and override the nextToken function. But name the class
	//as TokenSourceType
	class TokenSourceType : public antlr3::TokenSource<ImplTraits>
	{
		public:
			TokenType*  nextToken()
			{
			   ..your version...
			}
	};
};

typedef antlr3::Traits< JavaLexer, JavaParser, UserTraits > JavaTraits;
*/

typedef JavaTraits Java_JavaAnnotationsTraits;
typedef JavaTraits Java_JavaDeclTraits;
typedef JavaTraits Java_JavaExprTraits;
typedef JavaTraits Java_JavaLexerRulesTraits;
typedef JavaTraits Java_JavaStatTraits;
typedef JavaTraits JavaLexerTraits;
typedef JavaTraits JavaParserTraits;

}

#endif
