import antlr3
import testbase
import unittest


class t036multipleReturnValues(testbase.ANTLRTest):
    def setUp(self):
        self.compileGrammar()
        

    def lexerClass(self, base):
        class TLexer(base):
            def recover(self, input, re):
                # no error recovery yet, just crash!
                raise

        return TLexer
    
        
    def parserClass(self, base):
        class TParser(base):
            def recover(self, input, re):
                # no error recovery yet, just crash!
                raise

        return TParser
    
        
    def testValid1(self):
        cStream = antlr3.StringStream('   a')

        lexer = self.getLexer(cStream)
        tStream = antlr3.CommonTokenStream(lexer)
        parser = self.getParser(tStream)
        ret = parser.a()
        self.assertEqual(ret.foo, 'foo')
        self.assertEqual(ret.bar, 'bar')


if __name__ == '__main__':
    unittest.main()


