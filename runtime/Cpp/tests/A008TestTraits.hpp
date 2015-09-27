#ifndef	_A008_TEST_TRAITS_H
#define	_A008_TEST_TRAITS_H

#include <antlr3.hpp>

#include <fstream>
#include <iostream>
#include <sstream>

namespace Antlr3Test {
	//code for overriding
	template<class ImplTraits>
	class UserTraits : public antlr3::CustomTraitsBase<ImplTraits>
	{
	public:
		struct A008TreeUserDataType
		{
			A008TreeUserDataType() : identifierClass(-1), usageType(-1) {};
			int identifierClass, usageType;
		};

		class A008Token : public antlr3::CommonToken<ImplTraits>
		{
			typedef antlr3::CommonToken<ImplTraits> super;
			typedef typename antlr3::CommonToken<ImplTraits>::TOKEN_TYPE TOKEN_TYPE;
			typedef typename super::StringType StringType;
		public:
			// Override all possible constructors
			A008Token() : super() {};
			A008Token( ANTLR_UINT32 type) : super(type) {};
			A008Token( TOKEN_TYPE type) : super(type) {};
			A008Token( const A008Token& ctoken ) : super(ctoken) {};
			A008Token& operator=( const A008Token& other ) { super::operator=(other); return *this; };

			// Override toString method
			StringType toString() const
			{
				return super::getText();
			}
		};
		
		// Override default trait's types
		typedef A008Token CommonTokenType;
		typedef A008TreeUserDataType TreeUserDataType;
	};

	// Forward declaration for Lexer&Parser class(es)
  	class a008Lexer;
	class a008Parser;

	// Instantiate the Traits class(will be used for Lexer/Parser template instantiations)
	typedef antlr3::Traits<a008Lexer, a008Parser, UserTraits> a008Traits;
	typedef a008Traits a008LexerTraits;
	typedef a008Traits a008ParserTraits;
};

#endif
