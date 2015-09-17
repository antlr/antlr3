#ifndef	_A007_TEST_TRAITS_H
#define	_A007_TEST_TRAITS_H

#include <antlr3.hpp>

#include <fstream>
#include <iostream>
#include <sstream>

// Forward declaration for Lexer&Parser class(es)
namespace Antlr3Test {
	//code for overriding
	template<class ImplTraits>
	class UserTraits : public antlr3::CustomTraitsBase<ImplTraits>
	{
	public:
		struct A007TokenUserDataType
		{
			A007TokenUserDataType() : identifierClass(-1), usageType(-1) {};
			int identifierClass, usageType;
		};

		class A007Token : public antlr3::CommonToken<ImplTraits>
		{
			typedef antlr3::CommonToken<ImplTraits> super;
			typedef typename antlr3::CommonToken<ImplTraits>::TOKEN_TYPE TOKEN_TYPE;
			typedef typename super::StringType StringType;
		public:
			// Override all possible constructors
			A007Token() : super() {};
			A007Token( ANTLR_UINT32 type) : super(type) {};
			A007Token( TOKEN_TYPE type) : super(type) {};
			A007Token( const A007Token& ctoken ) : super(ctoken) {};
			A007Token& operator=( const A007Token& other ) { super::operator=(other); return *this; };

			// Override toString method
			StringType toString() const
			{
				StringType m_txt;
				m_txt = super::getText();
				if (super::UserData.identifierClass > 0)
					m_txt += "[" + std::to_string(super::UserData.identifierClass) + "]";
				return m_txt;
			}
		};

		// Override default trait's types
		typedef A007Token CommonTokenType;
		typedef A007TokenUserDataType TokenUserDataType;
	};

  	class a007Lexer;	class a007Parser;

	// Instantiate the Traits class(will be used for Lexer/Parser template instantiations)
	typedef antlr3::Traits<a007Lexer, a007Parser, UserTraits> a007LexerTraits;
	typedef a007LexerTraits a007ParserTraits;
};

#endif
