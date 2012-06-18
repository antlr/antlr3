import antlr3
import testbase
import unittest


class t024finally(testbase.ANTLRTest):
    def setUp(self):
        self.compileGrammar()
        

    def testValid1(self):
        cStream = antlr3.StringStream('foobar')
        lexer = self.getLexer(cStream)
        tStream = antlr3.CommonTokenStream(lexer)
        parser = self.getParser(tStream)
        events = parser.prog()

        self.assertEqual(events, ['catch', 'finally'])


if __name__ == '__main__':
    unittest.main()

