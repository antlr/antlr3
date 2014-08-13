.PRECIOUS=.o

ANTLRGRAMMARS ?= $(wildcard [ast]*.g)
HEADERS = $(wildcard *.hpp) $(wildcard *.inl)
RUNTIME_HEADERS = $(wildcard ../include/*.hpp) $(wildcard ../include/*.inl)
SOURCES = $(wildcard *.cpp)
POBJS = $(PSOURCES:.cpp=.o)
TOKENS = $(ANTLRGRAMMARS:.g=.tokens)

GRAMMAROPTIONS= #-report -Xconversiontimeout 1500000 -Xmultithreaded -Xwatchconversion
ANTLR = ../../../antlr-complete/target/antlr-complete-3.5.3-SNAPSHOT.jar
STGS  = $(wildcard ../../../tool/src/main/resources/org/antlr/codegen/templates/Cpp/*.stg)

.SUFFIXES:

INCLUDES= -I. -I../include/

#-I/usr/lib/gcc/x86_64-pc-cygwin/4.8.3/include/c++/ -I/usr/lib/gcc/x86_64-pc-cygwin/4.8.3/include/c++/x86_64-pc-cygwin

#CXX=/usr/bin/clang++
CFLAGS=-ggdb3 -O0 -fno-inline -Wall -std=c++0x
#CFLAGS=-ggdb3 -O3 -std=c++0x

TOBJS= utils.o

all: $(ANTLR) $(TOKENS) t001 t002 t003 t004 t005 t006 t006 t007 t008 t009 t010 t011 t012 t020 t039 \
	s001 s002 s003 s004 a001 a002 a003 a004 a005

# For devel only. This will replace .stg files in the tool in a fast way
#
$(ANTLR): $(STGS)
	jar uvf $(ANTLR) \
	-C ../../../tool/src/main/resources org/antlr/codegen/templates/Cpp/Cpp.stg \
	-C ../../../tool/src/main/resources org/antlr/codegen/templates/Cpp/AST.stg \
	-C ../../../tool/src/main/resources org/antlr/codegen/templates/Cpp/ASTParser.stg

a001:	a001.cpp a001.tokens ATestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) -o $@

a002:	a002.cpp a002.tokens ATestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) -o $@

a003:	a003.cpp a003.tokens ATestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) -o $@

a004:	a004.cpp a004.tokens ATestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) -o $@

a005:	a005.cpp a005.tokens ATestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) -o $@

a006:	a006.cpp a006.tokens ATestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) -DUSESTL $(INCLUDES) $< $(wildcard $@?*.cpp) -o $@

s001:	s001.cpp s001.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) utils.cpp -o $@

s002:	s002.cpp s002.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) utils.cpp -o $@

s003:	s003.cpp s003.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) utils.cpp -o $@

t001:	t001.cpp t001lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) -o $@

t002:	t002.cpp t002lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) -o $@

t003:	t003.cpp t003lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) -o $@

t004:	t004.cpp t004lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) -o $@

t005:	t005.cpp t005lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) -o $@

t006:	t006.cpp t006lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) -o $@

t007:	t007.cpp t007lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) -o $@

t008:	t008.cpp t008lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) -o $@

t009:	t009.cpp t009lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) -o $@

t010:	t010.cpp t010lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) -o $@

t011:	t011.cpp t011lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) -o $@

t012:	t012.cpp t012lexerXMLLexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) -o $@

t020:	t020.cpp t020fuzzyLexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) -o $@

t039:	t039.cpp t039labels.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) -o $@

t051:	t051.cpp t051lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) -o $@

s004:   s004.cpp PLSQLLexer.tokens PLSQLParser.tokens PLSQL_DMLParser.g PTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< PLSQLLexer*.cpp PLSQLParser*.cpp utils.cpp -o $@

s005:   s005.cpp SQLMini.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< SQLMiniLexer.cpp SQLMiniParser.cpp utils.cpp -o $@

s006:   s006.cpp SQLMini2.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	$(CXX) $(CFLAGS) $(INCLUDES) $< SQLMiniLexer.cpp SQLMiniParser.cpp utils.cpp -o $@

# AST commented out
#
# t042:	t042.cpp t005lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
# 	$(CXX) $(CFLAGS) $(INCLUDES) $< $(wildcard $@?*.cpp) -o $@

clean:
	rm -f *.o [ast]0[0-9][0-9]??*.[ch]pp *.tokens [ast][0-9][0-9][0-9] [ast]0[0-9][0-9].exe
	rm -f PLSQLLexer.[ch]pp PLSQLParser*.[ch]pp

# %.u: %.g
# 	@echo "Bulding dependencies for "$<
# 	java -jar $(ANTLR) -depend $< > $@
# 	@grep ":" $@ |awk 'BEGIN {printf "ANTLRGENLIST := " }{printf " " $$1}END {print ""}'  >> $@.tmp
# 	@cat $@.tmp >> $@
# 	$(RM) $@.tmp

%.tokens %Lexer.cpp %Parser.cpp %Lexer.hpp %Parser.hpp: %.g $(ANTLR)
	java -Xmx512m -jar $(ANTLR) $(GRAMMAROPTIONS) $<

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(ANTLRGRAMMARS)),)
#-include $(ANTLRGRAMMARS:.g=.u)
endif
endif

%.o: %.cpp $(HEADERS) utils.hpp
	$(CXX) $(CFLAGS) $(INCLUDES) -c $< -o $@
