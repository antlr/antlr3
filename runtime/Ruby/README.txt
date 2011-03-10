ANTLR 3 for Ruby
    by Kyle Yetter (kcy5b@yahoo.com)
    http://antlr.ohboyohboyohboy.org
    http://github.com/ohboyohboyohboy/antlr3

== DESCRIPTION:

Fully-featured ANTLR 3 parser generation for Ruby.

ANTLR (ANother Tool for Language Recognition) is a tool that is used to generate
code for performing a variety of language recognition tasks: lexing, parsing,
abstract syntax tree construction and manipulation, tree structure recognition,
and input translation. The tool operates similarly to other parser generators,
taking in a grammar specification written in the special ANTLR metalanguage and
producing source code that implements the recognition functionality.

While the tool itself is implemented in Java, it has an extensible design that
allows for code generation in other programming languages. To implement an
ANTLR language target, a developer may supply a set of templates written in the
StringTemplate (http://www.stringtemplate.org) language.

ANTLR is currently distributed with a fairly limited Ruby target implementation.
While it does provide implementation for basic lexer and parser classes, the
target does not provide any implementation for abstract syntax tree
construction, tree parser class generation, input translation, or a number of
the other ANTLR features that give the program an edge over traditional code
generators.

This gem packages together a complete implementation of the majority of features
ANTLR provides for other language targets, such as Java and Python. It contains:

* A customized version of the latest ANTLR program, bundling all necessary
  java code and templates for producing fully featured language recognition
  in ruby code

* a ruby run-time library that collects classes used throughout the code that
  ANTLR generates
  
* a wrapper script, `antlr4ruby', which executes the ANTLR command line tool
  after ensuring the ANTLR jar is Java's class path

== FEATURES

1. generates ruby code capable of:
   * lexing text input
   * parsing lexical output and responding with arbitrary actions 
   * constructing Abstract Syntax Trees (ASTs)
   * parsing AST structure and responding with arbitrary actions
   * translating input source to some desired output format

2. This package can serve as a powerful assistant when performing tasks
   such as:
   * code compilation
   * source code highlighting and formatting
   * domain-specific language implementation
   * source code extraction and analysis

== USAGE

1. Write an ANTLR grammar specification for a language

   grammar SomeLanguage;
   
   options {
     language = Ruby;    // <- this option must be set to Ruby
     output   = AST;
   }
   
   top: expr ( ',' expr )*
      ;
    
   and so on...
   

2. Run the ANTLR tool with the antlr4ruby command to generate output:
   
   antlr4ruby SomeLanguage.g
   # creates:
   #   SomeLanguageParser.rb
   #   SomeLanguageLexer.rb
   #   SomeLanguage.g

3. Try out the results directly, if you like:

  # see how the lexer tokenizes some input
  ruby SomeLanguageLexer.rb < path/to/source-code.xyz
  
  # check whether the parser successfully matches some input
  ruby SomeLanguageParser.rb --rule=top < path/to/source-code.xyz

-> Read up on the package documentation for more specific details
   about loading the recognizers and using their class definitions

== ISSUES

* Currently, there are a few nuanced ways in which using the ruby output differs
  from the conventions and examples covered in the ANTLR standard documentation.
  I am still working on documenting these details.

* So far, this has only been tested on Linux with ruby 1.8.7 and ruby 1.9.1.
  I'm currently working on verifying behavior on other systems and with
  slightly older versions of ruby. 

== LICENSE

[The "BSD license"]
Copyright (c) 2009-2010 Kyle Yetter
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 3. The name of the author may not be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

