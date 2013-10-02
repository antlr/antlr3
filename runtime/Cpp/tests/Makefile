.PRECIOUS=.o

ANTLRGRAMMARS ?= $(wildcard t0[01]*.g)
HEADERS = $(wildcard *.hpp) $(wildcard *.inl)
RUNTIME_HEADERS = $(wildcard ../include/*.hpp) $(wildcard ../include/*.inl)
SOURCES = $(wildcard *.cpp)
POBJS = $(PSOURCES:.cpp=.o)
TOKENS = $(ANTLRGRAMMARS:.g=.tokens)

GRAMMAROPTIONS= #-report -Xconversiontimeout 1500000 -Xmultithreaded -Xwatchconversion
ANTLR = ../../../antlr-complete/target/antlr-complete-3.5.2-SNAPSHOT.jar
STGS  = $(wildcard ../../../tool/src/main/resources/org/antlr/codegen/templates/Cpp/*.stg)

.SUFFIXES:

INCLUDES= -I. -I../include/

CFLAGS=-ggdb3 -O0 -fno-inline -Wall -Wno-unused-variable
#CFLAGS=-ggdb3 -O3

TOBJS= utils.o

all: $(ANTLR) $(TOKENS) t001 t002 t003 t004 t005 t006 t006 t007 t008 t009 t010 t011 t012

# For devel only. This will replace .stg files in the tool in a fast way
#
$(ANTLR): $(STGS)
	jar uvf $(ANTLR) -C ../../../tool/src/main/resources \
	org/antlr/codegen/templates/Cpp/Cpp.stg

t001:	t001.cpp t001lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	g++ $(CFLAGS) -DUSESTL $(INCLUDES) $< $@?*.cpp -o $@

t002:	t002.cpp t002lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	g++ $(CFLAGS) -DUSESTL $(INCLUDES) $< $@?*.cpp -o $@

t003:	t003.cpp t003lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	g++ $(CFLAGS) -DUSESTL $(INCLUDES) $< $@?*.cpp -o $@

t004:	t004.cpp t004lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	g++ $(CFLAGS) -DUSESTL $(INCLUDES) $< $@?*.cpp -o $@

t005:	t005.cpp t005lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	g++ $(CFLAGS) -DUSESTL $(INCLUDES) $< $@?*.cpp -o $@

t006:	t006.cpp t006lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	g++ $(CFLAGS) -DUSESTL $(INCLUDES) $< $@?*.cpp -o $@

t007:	t007.cpp t007lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	g++ $(CFLAGS) -DUSESTL $(INCLUDES) $< $@?*.cpp -o $@

t008:	t008.cpp t008lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	g++ $(CFLAGS) -DUSESTL $(INCLUDES) $< $@?*.cpp -o $@

t009:	t009.cpp t009lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	g++ $(CFLAGS) -DUSESTL $(INCLUDES) $< $@?*.cpp -o $@

t010:	t010.cpp t010lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	g++ $(CFLAGS) -DUSESTL $(INCLUDES) $< $@?*.cpp -o $@

t011:	t011.cpp t011lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	g++ $(CFLAGS) -DUSESTL $(INCLUDES) $< $@?*.cpp -o $@

t012:	t012.cpp t012lexerXMLLexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	g++ $(CFLAGS) -DUSESTL $(INCLUDES) $< $@?*.cpp -o $@

t051:	t051.cpp t051lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
	g++ $(CFLAGS) -DUSESTL $(INCLUDES) $< $@?*.cpp -o $@

# AST commented out
# t039:	t039.cpp t039labels.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
# 	g++ $(CFLAGS) -DUSESTL $(INCLUDES) $< $@?*.cpp -o $@
#
# t042:	t042.cpp t005lexer.tokens UserTestTraits.hpp Makefile $(ANTLR) $(RUNTIME_HEADERS)
# 	g++ $(CFLAGS) -DUSESTL $(INCLUDES) $< $@?*.cpp -o $@

clean:
	rm -f *.o t0[0-9][0-9]??*.[ch]pp *.tokens t[0-9][0-9][0-9] t0[0-9][0-9].exe

# %.u: %.g
# 	@echo "Bulding dependencies for "$<
# 	java -jar $(ANTLR) -depend $< > $@
# 	@grep ":" $@ |awk 'BEGIN {printf "ANTLRGENLIST := " }{printf " " $$1}END {print ""}'  >> $@.tmp
# 	@cat $@.tmp >> $@
# 	$(RM) $@.tmp

%.tokens %.cpp %Lexer.c %Parser.c %Lexer.h %Parser.h %.hpp: %.g $(ANTLR)
	java -jar $(ANTLR) $(GRAMMAROPTIONS) $<

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(ANTLRGRAMMARS)),)
#-include $(ANTLRGRAMMARS:.g=.u)
endif
endif

%.o: %.cpp $(HEADERS) utils.hpp
	g++ $(CFLAGS) -DUSESTL $(INCLUDES) -c $< -o $@
