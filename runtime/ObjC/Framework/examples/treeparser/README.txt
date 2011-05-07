Hi.  This is a simple demo of tree construction and tree parsing with ANTLR
v3.  Here's how to try it out.

$ java org.antlr.Tool LangParser.g LangTreeParser.g
$ javac *.java
$ java Main input

You should see out:

tree: (DECL int a)
int a
