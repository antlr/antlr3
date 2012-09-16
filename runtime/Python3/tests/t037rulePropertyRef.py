import antlr3
import testbase
import unittest


class t037rulePropertyRef(testbase.ANTLRTest):
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
        cStream = antlr3.StringStream('   a a a a  ')

        lexer = self.getLexer(cStream)
        tStream = antlr3.CommonTokenStream(lexer)
        parser = self.getParser(tStream)
        start, stop, text = parser.a().bla

        # first token of rule b is the 2nd token (counting hidden tokens)
        self.assertEqual(start.index, 1, start)
        
        # first token of rule b is the 7th token (counting hidden tokens)
        self.assertEqual(stop.index, 7, stop)

        self.assertEqual(text, "a a a a")


if __name__ == '__main__':
    unittest.main()
