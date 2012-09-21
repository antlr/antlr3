ANTLR v3.4
July 18, 2011

Terence Parr, parrt at cs usfca edu
ANTLR project lead and supreme dictator for life
University of San Francisco

INTRODUCTION

Welcome to ANTLR v3!  ANTLR (ANother Tool for Language Recognition) is
a language tool that provides a framework for constructing
recognizers, interpreters, compilers, and translators from grammatical
descriptions containing actions in a variety of target
languages. ANTLR provides excellent support for tree construction,
tree walking, translation, error recovery, and error reporting. I've
been working on parser generators for 20 years and on this particular
version of ANTLR for 7 years.

You should use v3 in conjunction with ANTLRWorks:

    http://www.antlr.org/works/index.html

and gUnit (grammar unit testing tool included in distribution):

    http://www.antlr.org/wiki/display/ANTLR3/gUnit+-+Grammar+Unit+Testing

The book will also help you a great deal (printed May 15, 2007); you
can also buy the PDF:

    http://www.pragmaticprogrammer.com/titles/tpantlr/index.html

2nd book, Language Implementation Patterns:

    http://pragprog.com/titles/tpdsl/language-implementation-patterns

See the getting started document:

    http://www.antlr.org/wiki/display/ANTLR3/FAQ+-+Getting+Started

You also have the examples plus the source to guide you.

See the wiki FAQ:

    http://www.antlr.org/wiki/display/ANTLR3/ANTLR+v3+FAQ

and general doc root:

    http://www.antlr.org/wiki/display/ANTLR3/ANTLR+3+Wiki+Home

Please help add/update FAQ entries.

If all else fails, you can buy support or ask the antlr-interest list:

    http://www.antlr.org/support.html

Per the license in LICENSE.txt, this software is not guaranteed to
work and might even destroy all life on this planet:

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

----------------------------------------------------------------------

EXAMPLES

ANTLR v3 sample grammars:

    http://www.antlr.org/download/examples-v3.tar.gz

Examples from Language Implementation Patterns:

    http://www.pragprog.com/titles/tpdsl/source_code

Also check out Mantra Programming Language for a prototype (work in
progress) using v3:

    http://www.linguamantra.org/

----------------------------------------------------------------------

What is ANTLR?

ANTLR stands for (AN)other (T)ool for (L)anguage (R)ecognition
and generates LL(*) recursive-descent parsers. ANTLR is a language tool
that provides a framework for constructing recognizers, compilers, and
translators from grammatical descriptions containing actions.
Target language list:

http://www.antlr.org/wiki/display/ANTLR3/Code+Generation+Targets

----------------------------------------------------------------------

How is ANTLR v3 different than ANTLR v2?

See "What is the difference between ANTLR v2 and v3?"

    http://www.antlr.org/wiki/pages/viewpage.action?pageId=719

See migration guide:

    http://www.antlr.org/wiki/display/ANTLR3/Migrating+from+ANTLR+2+to+ANTLR+3

----------------------------------------------------------------------

How do I install this damn thing?

Just untar antlr-3.4.tar.gz and you'll get:

antlr-3.4/BUILD.txt
antlr-3.4/antlr3-maven-plugin
antlr-3.4/antlrjar.xml
antlr-3.4/antlrsources.xml
antlr-3.4/gunit
antlr-3.4/gunit-maven-plugin
antlr-3.4/pom.xml
antlr-3.4/runtime
antlr-3.4/tool
antlr-3.4/lib

This is the source and java binaries.  You could grab the
antlr-3.4-complete.jar file from the website, but it's in lib dir.
It has all of the jars you need combined into one. Then you need to
add antlr-3.4-complete.jar to your CLASSPATH or add
to arg list; e.g., on unix:

$ java -cp "/usr/local/lib/antlr-3.4-complete.jar:$CLASSPATH" org.antlr.Tool Test.g

Please see the FAQ

    http://www.antlr.org/wiki/display/ANTLR3/ANTLR+v3+FAQ
