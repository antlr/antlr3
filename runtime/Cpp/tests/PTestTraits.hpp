#ifndef	_T_TEST_TRAITS_H
#define	_T_TEST_TRAITS_H

// First thing we always do is include the ANTLR3 generated files, which
// will automatically include the antlr3 runtime header files.
// The compiler must use -I (or set the project settings in VS2005)
// to locate the antlr3 runtime files and -I. to find this file
#include <antlr3.hpp>

#include <fstream>
#include <iostream>
#include <sstream>
#include <cctype>
#include <locale>
#include <cwchar>

// Forward declaration for Lexer&Parser class(es)
namespace Antlr3Test {
	class PLSQLLexer;
	class PLSQLParser;

	template<class ImplTraits>
	class UserTraits : public antlr3::CustomTraitsBase<ImplTraits>
	{
	public:
		struct ci_char_traits : public std::char_traits<char>
		// just inherit all the other functions
		//  that we don't need to override
		{			
			static bool eq( char c1, char c2 )
			{ return toupper(c1) == std::toupper(c2); }
			
			static bool ne( char c1, char c2 )
			{ return toupper(c1) != std::toupper(c2); }

			static bool lt( char c1, char c2 )
			{ return toupper(c1) <  std::toupper(c2); }

			static int compare( const char* s1, const char* s2, size_t n )
			{
				for (std::size_t i=0; i<n; ++i)
				{
					if (!eq(s1[i],s2[i]))
					{
						return lt(s1[i],s2[i])?-1:1;
					}
				}
				return 0;
			}

			static const char* find( const char* s, int n, char a )
			{
				a = toupper(a);				
				while( n-- > 0 && toupper(*s) != a )
				{
					++s;
				}
				return s;
			}

		private:
			static inline int toupper(int C)
			{
				//static const std::ctype<typename StringType::value_type>& f = std::use_facet<std::ctype<typename StringType::value_type>>(std::locale(std::locale::classic(), new codecvt_byname(".C")))
				//static std::locale loc(std::locale::classic(), new std::codecvt_byname<char, char, std::mbstate_t>(".C"));
				static std::locale loc(std::locale::classic());
				static const std::ctype<typename ImplTraits::StringType::value_type>& f = std::use_facet<std::ctype<typename ImplTraits::StringType::value_type>>(loc);
				int i = f.toupper((char)C);
				return i;
			}
		};

		typedef std::basic_string<char,ci_char_traits> StringType;
		typedef std:: basic_stringstream<char, ci_char_traits> StringStreamType;

		static void displayRecognitionError(const StringType& str)
		{
			printf("%s", str.c_str());
		}
		//static void displayRecognitionError(const std::string& str)
		//{
		//printf("%s", str.c_str());
		//}		
		//static const bool TOKENS_ACCESSED_FROM_OWNING_RULE = true;
		//static const int  TOKEN_FILL_BUFFER_INCREMENT = 2;
	};

	typedef antlr3::Traits<PLSQLLexer, PLSQLParser, UserTraits> PLSQLTraits;
	typedef PLSQLTraits PLSQLLexerTraits;
	typedef PLSQLTraits PLSQLParserTraits;
	typedef PLSQLTraits PLSQLParser_PLSQLKeysTraits;
	typedef PLSQLTraits PLSQLParser_PLSQLCommonsTraits;
	typedef PLSQLTraits PLSQLParser_PLSQL_DMLParserTraits;
	typedef PLSQLTraits PLSQLParser_SQLPLUSParserTraits;
	typedef PLSQLTraits PLSQLParser_PLSQL_DMLParser_PLSQLKeysTraits;
	typedef PLSQLTraits PLSQLParser_PLSQL_DMLParser_PLSQLCommonsTraits;
	
	/* define an output operator
	 * because the traits type is different than that for std::ostream
	 */
	inline
	std::ostream& operator << (std::ostream& strm, const PLSQLTraits::StringType& s)
	{
		// simply convert the icstring into a normal string
		return strm << std::string(s.data(),s.length());
	}

  	template<class CommonTokenType>
	inline bool isTableAlias(CommonTokenType *LT1, CommonTokenType *LT2) {
		static const char* wPARTITION("PARTITION");
		static const char* wBY("BY");
		static const char* wCROSS("CROSS");
		static const char* wNATURAL("NATURAL");
		static const char* wINNER("INNER");
		static const char* wJOIN("JOIN");
		static const char* wFULL("FULL");
		static const char* wLEFT("LEFT");
		static const char* wRIGHT("RIGHT");
		static const char* wOUTER("OUTER");

		PLSQLTraits::StringType const& lt1 = LT1->getText();
		PLSQLTraits::StringType lt2;
		
		if ( LT2 )
			lt2 = LT2->getText();

		
		if ( ( lt1 == wPARTITION && lt2 == wBY)
		     || lt1 == wCROSS
		     || lt1 == wNATURAL
		     || lt1 == wINNER
		     || lt1 == wJOIN
		     || ( ( lt1 == wFULL || lt1 == wLEFT || lt1 == wRIGHT ) && ( lt2 == wOUTER || lt2 == wJOIN ))
			)
		{
			return false;
		}
		return true;
	}

  	template<class StringType>
	inline bool isStandardPredictionFunction(StringType const& originalFunctionName) {
		static const char* wPREDICTION("PREDICTION");
		static const char* wPREDICTION_BOUNDS("PREDICTION_BOUNDS");
		static const char* wPREDICTION_COST("PREDICTION_COST");
		static const char* wPREDICTION_DETAILS("PREDICTION_DETAILS");
		static const char* wPREDICTION_PROBABILITY("PREDICTION_PROBABILITY");
		static const char* wPREDICTION_SET("PREDICTION_SET");		
		// StringType  functionName = originalFunctionName;
		// std::transform(functionName.begin(), functionName.end(), functionName.begin(), ::toupper);
		
		if ( (originalFunctionName == wPREDICTION)
		     || (originalFunctionName == wPREDICTION_BOUNDS)
		     || (originalFunctionName == wPREDICTION_COST)
		     || (originalFunctionName == wPREDICTION_DETAILS)
		     || (originalFunctionName == wPREDICTION_PROBABILITY)
		     || (originalFunctionName == wPREDICTION_SET)
			)
		{
			return true;
		}
		return false;
	}

	inline bool starts_with(PLSQLTraits::StringType const& A, const char*B)
	{
		return A.length() >= strlen(B) && A.compare(0, strlen(B), B) == 0;
	}
		
	template<class StringType>     
	inline bool enablesWithinOrOverClause(StringType const& originalFunctionName) {
		static const char* wCUME_DIST("CUME_DIST");
		static const char* wDENSE_RANK("DENSE_RANK");
		static const char* wLISTAGG("LISTAGG");
		static const char* wPERCENT_RANK("PERCENT_RANK");
		static const char* wPERCENTILE_CONT("PERCENTILE_CONT");
		static const char* wPERCENTILE_DISC("PERCENTILE_DISC");
		static const char* wRANK("RANK");		
		// StringType functionName = originalFunctionName;
		// std::transform(functionName.begin(), functionName.end(), functionName.begin(), ::toupper);
		
		if ( (originalFunctionName == wCUME_DIST)
		     || (originalFunctionName == wDENSE_RANK)
		     || (originalFunctionName == wLISTAGG)
		     || (originalFunctionName == wPERCENT_RANK)
		     || (originalFunctionName == wPERCENTILE_CONT)
		     || (originalFunctionName == wPERCENTILE_DISC)
		     || (originalFunctionName == wRANK)
			)
		{
			return true;
		}
		return false;
	}


	template<class StringType>          
	inline bool enablesUsingClause(StringType const& originalFunctionName) {
		static const char *wCLUSTER("CLUSTER_");
		static const char *wFEATURE("FEATURE_");
	
		if ( starts_with(originalFunctionName, wCLUSTER) || starts_with(originalFunctionName, wFEATURE) )
		{
			return true;
		}
		return false;
	}

	//template<class StringType>     
	inline bool enablesOverClause(PLSQLTraits::StringType const& originalFunctionName) {
		static const char* wREGR("REGR_");
		static const char* wSTDDEV("STDDEV");
		static const char* wVAR("VAR_");
		static const char* wCOVAR("COVAR_");		
		static const char* wAVG("AVG");
		static const char* wCORR("CORR");
		static const char* wLAG("LAG");
		static const char* wLEAD("LEAD");
		static const char* wMAX ("MAX");
		static const char* wMEDIAN("MEDIAN");
		static const char* wMIN("MIN");
		static const char* wNTILE("NTILE");
		static const char* wRATIO_TO_REPORT("RATIO_TO_REPORT");
		static const char* wROW_NUMBER("ROW_NUMBER");
		static const char* wSUM("SUM");
		static const char* wVARIANCE("VARIANCE");       
		// StringType functionName = originalFunctionName;
		// std::transform(functionName.begin(), functionName.end(), functionName.begin(), ::toupper);		
		
		if ( (originalFunctionName == wAVG)
		     || (originalFunctionName == wCORR)
		     || (originalFunctionName == wLAG)
		     || (originalFunctionName == wLEAD)
		     || (originalFunctionName == wMAX)
		     || (originalFunctionName == wMEDIAN)
		     || (originalFunctionName == wMIN)
		     || (originalFunctionName == wNTILE)
		     || (originalFunctionName == wRATIO_TO_REPORT)
		     || (originalFunctionName == wROW_NUMBER)
		     || (originalFunctionName == wSUM)
		     || (originalFunctionName == wVARIANCE)
		     || starts_with(originalFunctionName, wREGR)
		     || starts_with(originalFunctionName, wSTDDEV)
		     || starts_with(originalFunctionName, wVAR)
		     || starts_with(originalFunctionName, wCOVAR)
			)
		{
			return true;
		}
		return false;
	}

	inline std::string slurp(std::string const& fileName)
	{
		std::ifstream ifs(fileName.c_str(), std::ios::in | std::ios::binary | std::ios::ate);
		//std::ifstream::pos_type fileSize = ifs.tellg();
		ifs.seekg(0, std::ios::beg);
		std::stringstream sstr;
		sstr << ifs.rdbuf();
		return sstr.str();
	}
};
 
#endif
