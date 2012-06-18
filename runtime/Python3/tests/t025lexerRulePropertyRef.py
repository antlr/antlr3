import antlr3
import testbase
import unittest


class t025lexerRulePropertyRef(testbase.ANTLRTest):
    def setUp(self):
        self.compileGrammar()
        

    def testValid1(self):
        stream = antlr3.StringStream('foobar _Ab98 \n A12sdf')
        lexer = self.getLexer(stream)

        while True:
            token = lexer.nextToken()
            if token.type == antlr3.EOF:
                break

        self.assertEqual(len(lexer.properties), 3, lexer.properties)

        text, type, line, pos, index, channel, start, stop = lexer.properties[0]
        self.assertEqual(text, 'foobar', lexer.properties[0])
        self.assertEqual(type, self.lexerModule.IDENTIFIER, lexer.properties[0])
        self.assertEqual(line, 1, lexer.properties[0])
        self.assertEqual(pos, 0, lexer.properties[0])
        self.assertEqual(index, -1, lexer.properties[0])
        self.assertEqual(channel, antlr3.DEFAULT_CHANNEL, lexer.properties[0])
        self.assertEqual(start, 0, lexer.properties[0])
        self.assertEqual(stop, 5, lexer.properties[0])

        text, type, line, pos, index, channel, start, stop = lexer.properties[1]
        self.assertEqual(text, '_Ab98', lexer.properties[1])
        self.assertEqual(type, self.lexerModule.IDENTIFIER, lexer.properties[1])
        self.assertEqual(line, 1, lexer.properties[1])
        self.assertEqual(pos, 7, lexer.properties[1])
        self.assertEqual(index, -1, lexer.properties[1])
        self.assertEqual(channel, antlr3.DEFAULT_CHANNEL, lexer.properties[1])
        self.assertEqual(start, 7, lexer.properties[1])
        self.assertEqual(stop, 11, lexer.properties[1])

        text, type, line, pos, index, channel, start, stop = lexer.properties[2]
        self.assertEqual(text, 'A12sdf', lexer.properties[2])
        self.assertEqual(type, self.lexerModule.IDENTIFIER, lexer.properties[2])
        self.assertEqual(line, 2, lexer.properties[2])
        self.assertEqual(pos, 1, lexer.properties[2])
        self.assertEqual(index, -1, lexer.properties[2])
        self.assertEqual(channel, antlr3.DEFAULT_CHANNEL, lexer.properties[2])
        self.assertEqual(start, 15, lexer.properties[2])
        self.assertEqual(stop, 20, lexer.properties[2])


if __name__ == '__main__':
    unittest.main()
