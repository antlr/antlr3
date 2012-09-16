import antlr3
import testbase
import unittest

class t014parser(testbase.ANTLRTest):
    def setUp(self):
        self.compileGrammar()
        
        
    def testValid(self):
        cStream = antlr3.StringStream('var foobar; gnarz(); var blupp; flupp ( ) ;')
        lexer = self.getLexer(cStream)
        tStream = antlr3.CommonTokenStream(lexer)
        parser = self.getParser(tStream)
        parser.document()

        self.assertEqual(parser.reportedErrors, [])
        self.assertEqual(parser.events,
                         [('decl', 'foobar'), ('call', 'gnarz'),
                          ('decl', 'blupp'), ('call', 'flupp')])


    def testMalformedInput1(self):
        cStream = antlr3.StringStream('var; foo();')
        lexer = self.getLexer(cStream)
        tStream = antlr3.CommonTokenStream(lexer)
        parser = self.getParser(tStream)

        parser.document()

        # FIXME: currently strings with formatted errors are collected
        # can't check error locations yet
        self.assertEqual(len(parser.reportedErrors), 1, parser.reportedErrors)
        self.assertEqual(parser.events, [])


    def testMalformedInput2(self):
        cStream = antlr3.StringStream('var foobar(); gnarz();')
        lexer = self.getLexer(cStream)
        tStream = antlr3.CommonTokenStream(lexer)
        parser = self.getParser(tStream)

        parser.document()

        # FIXME: currently strings with formatted errors are collected
        # can't check error locations yet
        self.assertEqual(len(parser.reportedErrors), 1, parser.reportedErrors)
        self.assertEqual(parser.events, [('call', 'gnarz')])


    def testMalformedInput3(self):
        cStream = antlr3.StringStream('gnarz(; flupp();')
        lexer = self.getLexer(cStream)
        tStream = antlr3.CommonTokenStream(lexer)
        parser = self.getParser(tStream)

        parser.document()

        # FIXME: currently strings with formatted errors are collected
        # can't check error locations yet
        self.assertEqual(len(parser.reportedErrors), 1, parser.reportedErrors)
        self.assertEqual(parser.events, [('call', 'gnarz'), ('call', 'flupp')])
            

if __name__ == '__main__':
    unittest.main()
