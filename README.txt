ANTLR v3.5.3
April 9, 2022

Terence Parr
ANTLR project lead and supreme dictator for life
University of San Francisco

INTRODUCTION

Welcome to ANTLR v3!  ANTLR (ANother Tool for Language Recognition) is
a language tool that provides a framework for constructing
recognizers, interpreters, compilers, and translators from grammatical
descriptions containing actions in a variety of target
languages. ANTLR provides excellent support for tree construction,
tree walking, translation, error recovery, and error reporting. I've
been working on parser generators for 25 years and on this particular
version of ANTLR for 9 years.

You should use v3 in conjunction with ANTLRWorks:

    http://www.antlr3.org/works/

and gUnit (grammar unit testing tool included in distribution):

    http://theantlrguy.atlassian.net/wiki/display/ANTLR3/gUnit+-+Grammar+Unit+Testing

The book will also help you a great deal (printed May 15, 2007); you
can also buy the PDF:

    http://www.pragmaticprogrammer.com/titles/tpantlr/index.html

2nd book, Language Implementation Patterns:

    http://pragprog.com/titles/tpdsl/language-implementation-patterns

See the getting started document:

    http://theantlrguy.atlassian.net/wiki/display/ANTLR3/FAQ+-+Getting+Started

You also have the examples plus the source to guide you.

See the wiki FAQ:

    http://theantlrguy.atlassian.net/wiki/display/ANTLR3/ANTLR+v3+FAQ

and general doc root:

    http://theantlrguy.atlassian.net/wiki/display/ANTLR3/ANTLR+3+Wiki+Home

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

    https://github.com/antlr/examples-v3

Examples from Language Implementation Patterns:

    http://www.pragprog.com/titles/tpdsl/source_code

----------------------------------------------------------------------

What is ANTLR?

ANTLR stands for (AN)other (T)ool for (L)anguage (R)ecognition
and generates LL(*) recursive-descent parsers. ANTLR is a language tool
that provides a framework for constructing recognizers, compilers, and
translators from grammatical descriptions containing actions.
Target language list:

http://theantlrguy.atlassian.net/wiki/display/ANTLR3/Code+Generation+Targets

----------------------------------------------------------------------

How is ANTLR v3 different than ANTLR v2?

See "What is the difference between ANTLR v2 and v3?"

    http://theantlrguy.atlassian.net/wiki/pages/viewpage.action?pageId=2687279

See migration guide:

    http://theantlrguy.atlassian.net/wiki/display/ANTLR3/Migrating+from+ANTLR+2+to+ANTLR+3

----------------------------------------------------------------------

How do I install this damn thing?

You will have grabbed either of these:

    http://www.antlr3.org/download/antlr-3.5.3-complete-no-st3.jar
    http://www.antlr3.org/download/antlr-3.5.3-complete.jar

It has all of the jars you need combined into one. Then you need to
add antlr-3.5.3-complete.jar to your CLASSPATH or add to arg list; e.g., on unix:

$ java -cp "/usr/local/lib/antlr-3.5.3-complete.jar:$CLASSPATH" org.antlr.Tool Test.g

Source + java binaries: Just untar antlr-3.5.3.tar.gz and you'll get:

antlr-3.5.3/BUILD.txt
antlr-3.5.3/antlr3-maven-plugin
antlr-3.5.3/antlrjar.xml
antlr-3.5.3/antlrsources.xml
antlr-3.5.3/gunit
antlr-3.5.3/gunit-maven-plugin
antlr-3.5.3/pom.xml
antlr-3.5/runtime
antlr-3.5.3/tool
antlr-3.5.3/lib

Please see the FAQ

    http://theantlrguy.atlassian.net/wiki/display/ANTLR3/ANTLR+v3+FAQ

-------------------------

How can I contribute to ANTLR v3?

http://theantlrguy.atlassian.net/wiki/pages/viewpage.action?pageId=2687297
