import unittest
import re
import textwrap
import antlr3
import testbase


# Left-recursion resolution is not yet enabled in the tool.

# class TestLeftRecursion(testbase.ANTLRTest):
#     def parserClass(self, base):
#         class TParser(base):
#             def __init__(self, *args, **kwargs):
#                 base.__init__(self, *args, **kwargs)

#                 self._output = ""


#             def capture(self, t):
#                 self._output += str(t)


#             def recover(self, input, re):
#                 # no error recovery yet, just crash!
#                 raise

#         return TParser


#     def execParser(self, grammar, grammarEntry, input):
#         lexerCls, parserCls = self.compileInlineGrammar(grammar)

#         cStream = antlr3.StringStream(input)
#         lexer = lexerCls(cStream)
#         tStream = antlr3.CommonTokenStream(lexer)
#         parser = parserCls(tStream)
#         getattr(parser, grammarEntry)()
#         return parser._output


#     def runTests(self, grammar, tests, grammarEntry):
#         lexerCls, parserCls = self.compileInlineGrammar(grammar)

#         build_ast = re.search(r'output\s*=\s*AST', grammar)

#         for input, expecting in tests:
#             cStream = antlr3.StringStream(input)
#             lexer = lexerCls(cStream)
#             tStream = antlr3.CommonTokenStream(lexer)
#             parser = parserCls(tStream)
#             r = getattr(parser, grammarEntry)()
#             found = parser._output
#             if build_ast:
#               found += r.tree.toStringTree()

#             self.assertEquals(
#                 expecting, found,
#                 "%r != %r (for input %r)" % (expecting, found, input))


#     def testSimple(self):
#         grammar = textwrap.dedent(
#             r"""
#             grammar T;
#             options {
#                 language=Python;
#             }
#             s : a { self.capture($a.text) } ;
#             a : a ID
#               | ID
#               ;
#             ID : 'a'..'z'+ ;
#             WS : (' '|'\n') {self.skip()} ;
#             """)

#         found = self.execParser(grammar, 's', 'a b c')
#         expecting = "abc"
#         self.assertEquals(expecting, found)


#     def testSemPred(self):
#         grammar = textwrap.dedent(
#             r"""
#             grammar T;
#             options {
#                 language=Python;
#             }
#             s : a { self.capture($a.text) } ;
#             a : a {True}? ID
#               | ID
#               ;
#             ID : 'a'..'z'+ ;
#             WS : (' '|'\n') {self.skip()} ;
#             """)

#         found = self.execParser(grammar, "s", "a b c")
#         expecting = "abc"
#         self.assertEquals(expecting, found)

#     def testTernaryExpr(self):
#         grammar = textwrap.dedent(
#             r"""
#             grammar T;
#             options {
#                 language=Python;
#                 output=AST;
#             }
#             e : e '*'^ e
#               | e '+'^ e
#               | e '?'<assoc=right>^ e ':'! e
#               | e '='<assoc=right>^ e
#               | ID
#               ;
#             ID : 'a'..'z'+ ;
#             WS : (' '|'\n') {self.skip()} ;
#             """)

#         tests = [
#             ("a", "a"),
#             ("a+b", "(+ a b)"),
#             ("a*b", "(* a b)"),
#             ("a?b:c", "(? a b c)"),
#             ("a=b=c", "(= a (= b c))"),
#             ("a?b+c:d", "(? a (+ b c) d)"),
#             ("a?b=c:d", "(? a (= b c) d)"),
#             ("a? b?c:d : e", "(? a (? b c d) e)"),
#             ("a?b: c?d:e", "(? a b (? c d e))"),
#             ]
#         self.runTests(grammar, tests, "e")


#     def testDeclarationsUsingASTOperators(self):
#         grammar = textwrap.dedent(
#             r"""
#             grammar T;
#             options {
#                 language=Python;
#                 output=AST;
#             }
#             declarator
#                     : declarator '['^ e ']'!
#                     | declarator '['^ ']'!
#                     | declarator '('^ ')'!
#                     | '*'^ declarator // binds less tight than suffixes
#                     | '('! declarator ')'!
#                     | ID
#                     ;
#             e : INT ;
#             ID : 'a'..'z'+ ;
#             INT : '0'..'9'+ ;
#             WS : (' '|'\n') {self.skip()} ;
#             """)

#         tests = [
#             ("a", "a"),
#             ("*a", "(* a)"),
#             ("**a", "(* (* a))"),
#             ("a[3]", "([ a 3)"),
#             ("b[]", "([ b)"),
#             ("(a)", "a"),
#             ("a[]()", "(( ([ a))"),
#             ("a[][]", "([ ([ a))"),
#             ("*a[]", "(* ([ a))"),
#             ("(*a)[]", "([ (* a))"),
#             ]
#         self.runTests(grammar, tests, "declarator")


#     def testDeclarationsUsingRewriteOperators(self):
#         grammar = textwrap.dedent(
#             r"""
#             grammar T;
#             options {
#                 language=Python;
#                 output=AST;
#             }
#             declarator
#                     : declarator '[' e ']' -> ^('[' declarator e)
#                     | declarator '[' ']' -> ^('[' declarator)
#                     | declarator '(' ')' -> ^('(' declarator)
#                     | '*' declarator -> ^('*' declarator)  // binds less tight than suffixes
#                     | '(' declarator ')' -> declarator
#                     | ID -> ID
#                     ;
#             e : INT ;
#             ID : 'a'..'z'+ ;
#             INT : '0'..'9'+ ;
#             WS : (' '|'\n') {self.skip()} ;
#             """)

#         tests = [
#             ("a", "a"),
#             ("*a", "(* a)"),
#             ("**a", "(* (* a))"),
#             ("a[3]", "([ a 3)"),
#             ("b[]", "([ b)"),
#             ("(a)", "a"),
#             ("a[]()", "(( ([ a))"),
#             ("a[][]", "([ ([ a))"),
#             ("*a[]", "(* ([ a))"),
#             ("(*a)[]", "([ (* a))"),
#             ]
#         self.runTests(grammar, tests, "declarator")


#     def testExpressionsUsingASTOperators(self):
#         grammar = textwrap.dedent(
#             r"""
#             grammar T;
#             options {
#                 language=Python;
#                 output=AST;
#             }
#             e : e '.'^ ID
#               | e '.'^ 'this'
#               | '-'^ e
#               | e '*'^ e
#               | e ('+'^|'-'^) e
#               | INT
#               | ID
#               ;
#             ID : 'a'..'z'+ ;
#             INT : '0'..'9'+ ;
#             WS : (' '|'\n') {self.skip()} ;
#             """)

#         tests = [
#             ("a", "a"),
#             ("1", "1"),
#             ("a+1", "(+ a 1)"),
#             ("a*1", "(* a 1)"),
#             ("a.b", "(. a b)"),
#             ("a.this", "(. a this)"),
#             ("a-b+c", "(+ (- a b) c)"),
#             ("a+b*c", "(+ a (* b c))"),
#             ("a.b+1", "(+ (. a b) 1)"),
#             ("-a", "(- a)"),
#             ("-a+b", "(+ (- a) b)"),
#             ("-a.b", "(- (. a b))"),
#             ]
#         self.runTests(grammar, tests, "e")


#     @testbase.broken(
#         "Grammar compilation returns errors", testbase.GrammarCompileError)
#     def testExpressionsUsingRewriteOperators(self):
#         grammar = textwrap.dedent(
#             r"""
#             grammar T;
#             options {
#                 language=Python;
#                 output=AST;
#             }
#             e : e '.' ID                   -> ^('.' e ID)
#               | e '.' 'this'               -> ^('.' e 'this')
#               | '-' e                      -> ^('-' e)
#               | e '*' b=e                  -> ^('*' e $b)
#               | e (op='+'|op='-') b=e      -> ^($op e $b)
#               | INT                        -> INT
#               | ID                         -> ID
#               ;
#             ID : 'a'..'z'+ ;
#             INT : '0'..'9'+ ;
#             WS : (' '|'\n') {self.skip()} ;
#             """)

#         tests = [
#             ("a", "a"),
#             ("1", "1"),
#             ("a+1", "(+ a 1)"),
#             ("a*1", "(* a 1)"),
#             ("a.b", "(. a b)"),
#             ("a.this", "(. a this)"),
#             ("a+b*c", "(+ a (* b c))"),
#             ("a.b+1", "(+ (. a b) 1)"),
#             ("-a", "(- a)"),
#             ("-a+b", "(+ (- a) b)"),
#             ("-a.b", "(- (. a b))"),
#             ]
#         self.runTests(grammar, tests, "e")


#     def testExpressionAssociativity(self):
#         grammar = textwrap.dedent(
#             r"""
#             grammar T;
#             options {
#                 language=Python;
#                 output=AST;
#             }
#             e
#               : e '.'^ ID
#               | '-'^ e
#               | e '^'<assoc=right>^ e
#               | e '*'^ e
#               | e ('+'^|'-'^) e
#               | e ('='<assoc=right>^ |'+='<assoc=right>^) e
#               | INT
#               | ID
#               ;
#             ID : 'a'..'z'+ ;
#             INT : '0'..'9'+ ;
#             WS : (' '|'\n') {self.skip()} ;
#             """)

#         tests = [
#             ("a", "a"),
#             ("1", "1"),
#             ("a+1", "(+ a 1)"),
#             ("a*1", "(* a 1)"),
#             ("a.b", "(. a b)"),
#             ("a-b+c", "(+ (- a b) c)"),
#             ("a+b*c", "(+ a (* b c))"),
#             ("a.b+1", "(+ (. a b) 1)"),
#             ("-a", "(- a)"),
#             ("-a+b", "(+ (- a) b)"),
#             ("-a.b", "(- (. a b))"),
#             ("a^b^c", "(^ a (^ b c))"),
#             ("a=b=c", "(= a (= b c))"),
#             ("a=b=c+d.e", "(= a (= b (+ c (. d e))))"),
#             ]
#         self.runTests(grammar, tests, "e")


#     def testJavaExpressions(self):
#       grammar = textwrap.dedent(
#             r"""
#             grammar T;
#             options {
#                 language=Python;
#                 output=AST;
#             }
#             expressionList
#                 :   e (','! e)*
#                 ;
#             e   :   '('! e ')'!
#                 |   'this'
#                 |   'super'
#                 |   INT
#                 |   ID
#                 |   type '.'^ 'class'
#                 |   e '.'^ ID
#                 |   e '.'^ 'this'
#                 |   e '.'^ 'super' '('^ expressionList? ')'!
#                 |   e '.'^ 'new'^ ID '('! expressionList? ')'!
#                 |       'new'^ type ( '(' expressionList? ')'! | (options {k=1;}:'[' e ']'!)+) // ugly; simplified
#                 |   e '['^ e ']'!
#                 |   '('^ type ')'! e
#                 |   e ('++'^ | '--'^)
#                 |   e '('^ expressionList? ')'!
#                 |   ('+'^|'-'^|'++'^|'--'^) e
#                 |   ('~'^|'!'^) e
#                 |   e ('*'^|'/'^|'%'^) e
#                 |   e ('+'^|'-'^) e
#                 |   e ('<'^ '<' | '>'^ '>' '>' | '>'^ '>') e
#                 |   e ('<='^ | '>='^ | '>'^ | '<'^) e
#                 |   e 'instanceof'^ e
#                 |   e ('=='^ | '!='^) e
#                 |   e '&'^ e
#                 |   e '^'<assoc=right>^ e
#                 |   e '|'^ e
#                 |   e '&&'^ e
#                 |   e '||'^ e
#                 |   e '?' e ':' e
#                 |   e ('='<assoc=right>^
#                       |'+='<assoc=right>^
#                       |'-='<assoc=right>^
#                       |'*='<assoc=right>^
#                       |'/='<assoc=right>^
#                       |'&='<assoc=right>^
#                       |'|='<assoc=right>^
#                       |'^='<assoc=right>^
#                       |'>>='<assoc=right>^
#                       |'>>>='<assoc=right>^
#                       |'<<='<assoc=right>^
#                       |'%='<assoc=right>^) e
#                 ;
#             type: ID
#                 | ID '['^ ']'!
#                 | 'int'
#                 | 'int' '['^ ']'!
#                 ;
#             ID : ('a'..'z'|'A'..'Z'|'_'|'$')+;
#             INT : '0'..'9'+ ;
#             WS : (' '|'\n') {self.skip()} ;
#             """)

#       tests = [
#           ("a", "a"),
#           ("1", "1"),
#           ("a+1", "(+ a 1)"),
#           ("a*1", "(* a 1)"),
#           ("a.b", "(. a b)"),
#           ("a-b+c", "(+ (- a b) c)"),
#           ("a+b*c", "(+ a (* b c))"),
#           ("a.b+1", "(+ (. a b) 1)"),
#           ("-a", "(- a)"),
#           ("-a+b", "(+ (- a) b)"),
#           ("-a.b", "(- (. a b))"),
#           ("a^b^c", "(^ a (^ b c))"),
#           ("a=b=c", "(= a (= b c))"),
#           ("a=b=c+d.e", "(= a (= b (+ c (. d e))))"),
#           ("a|b&c", "(| a (& b c))"),
#           ("(a|b)&c", "(& (| a b) c)"),
#           ("a > b", "(> a b)"),
#           ("a >> b", "(> a b)"),  # text is from one token
#           ("a < b", "(< a b)"),
#           ("(T)x", "(( T x)"),
#           ("new A().b", "(. (new A () b)"),
#           ("(T)t.f()", "(( (( T (. t f)))"),
#           ("a.f(x)==T.c", "(== (( (. a f) x) (. T c))"),
#           ("a.f().g(x,1)", "(( (. (( (. a f)) g) x 1)"),
#           ("new T[((n-1) * x) + 1]", "(new T [ (+ (* (- n 1) x) 1))"),
#           ]
#       self.runTests(grammar, tests, "e")


#     def testReturnValueAndActions(self):
#         grammar = textwrap.dedent(
#             r"""
#             grammar T;
#             options {
#                 language=Python;
#             }
#             s : e { self.capture($e.v) } ;
#             e returns [v, ignored]
#               : e '*' b=e {$v *= $b.v;}
#               | e '+' b=e {$v += $b.v;}
#               | INT {$v = int($INT.text);}
#               ;
#             INT : '0'..'9'+ ;
#             WS : (' '|'\n') {self.skip()} ;
#             """)

#         tests = [
#             ("4", "4"),
#             ("1+2", "3")
#             ]
#         self.runTests(grammar, tests, "s")


#     def testReturnValueAndActionsAndASTs(self):
#         grammar = textwrap.dedent(
#             r"""
#             grammar T;
#             options {
#                 language=Python;
#                 output=AST;
#             }
#             s : e { self.capture("v=\%s, " \% $e.v) } ;
#             e returns [v, ignored]
#               : e '*'^ b=e {$v *= $b.v;}
#               | e '+'^ b=e {$v += $b.v;}
#               | INT {$v = int($INT.text);}
#               ;
#             INT : '0'..'9'+ ;
#             WS : (' '|'\n') {self.skip()} ;
#             """)

#         tests = [
#             ("4", "v=4, 4"),
#             ("1+2", "v=3, (+ 1 2)"),
#             ]
#         self.runTests(grammar, tests, "s")


if __name__ == '__main__':
    unittest.main()
