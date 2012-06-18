
from io import StringIO
import os
import unittest
import antlr3


class TestStringStream(unittest.TestCase):
    """Test case for the StringStream class."""

    def testSize(self):
        """StringStream.size()"""

        stream = antlr3.StringStream('foo')

        self.assertEqual(stream.size(), 3)


    def testIndex(self):
        """StringStream.index()"""

        stream = antlr3.StringStream('foo')

        self.assertEqual(stream.index(), 0)


    def testConsume(self):
        """StringStream.consume()"""

        stream = antlr3.StringStream('foo\nbar')

        stream.consume() # f
        self.assertEqual(stream.index(), 1)
        self.assertEqual(stream.charPositionInLine, 1)
        self.assertEqual(stream.line, 1)

        stream.consume() # o
        self.assertEqual(stream.index(), 2)
        self.assertEqual(stream.charPositionInLine, 2)
        self.assertEqual(stream.line, 1)

        stream.consume() # o
        self.assertEqual(stream.index(), 3)
        self.assertEqual(stream.charPositionInLine, 3)
        self.assertEqual(stream.line, 1)

        stream.consume() # \n
        self.assertEqual(stream.index(), 4)
        self.assertEqual(stream.charPositionInLine, 0)
        self.assertEqual(stream.line, 2)

        stream.consume() # b
        self.assertEqual(stream.index(), 5)
        self.assertEqual(stream.charPositionInLine, 1)
        self.assertEqual(stream.line, 2)

        stream.consume() # a
        self.assertEqual(stream.index(), 6)
        self.assertEqual(stream.charPositionInLine, 2)
        self.assertEqual(stream.line, 2)

        stream.consume() # r
        self.assertEqual(stream.index(), 7)
        self.assertEqual(stream.charPositionInLine, 3)
        self.assertEqual(stream.line, 2)

        stream.consume() # EOF
        self.assertEqual(stream.index(), 7)
        self.assertEqual(stream.charPositionInLine, 3)
        self.assertEqual(stream.line, 2)

        stream.consume() # EOF
        self.assertEqual(stream.index(), 7)
        self.assertEqual(stream.charPositionInLine, 3)
        self.assertEqual(stream.line, 2)


    def testReset(self):
        """StringStream.reset()"""

        stream = antlr3.StringStream('foo')

        stream.consume()
        stream.consume()

        stream.reset()
        self.assertEqual(stream.index(), 0)
        self.assertEqual(stream.line, 1)
        self.assertEqual(stream.charPositionInLine, 0)
        self.assertEqual(stream.LT(1), 'f')


    def testLA(self):
        """StringStream.LA()"""

        stream = antlr3.StringStream('foo')

        self.assertEqual(stream.LT(1), 'f')
        self.assertEqual(stream.LT(2), 'o')
        self.assertEqual(stream.LT(3), 'o')

        stream.consume()
        stream.consume()

        self.assertEqual(stream.LT(1), 'o')
        self.assertEqual(stream.LT(2), antlr3.EOF)
        self.assertEqual(stream.LT(3), antlr3.EOF)


    def testSubstring(self):
        """StringStream.substring()"""

        stream = antlr3.StringStream('foobar')

        self.assertEqual(stream.substring(0, 0), 'f')
        self.assertEqual(stream.substring(0, 1), 'fo')
        self.assertEqual(stream.substring(0, 5), 'foobar')
        self.assertEqual(stream.substring(3, 5), 'bar')


    def testSeekForward(self):
        """StringStream.seek(): forward"""

        stream = antlr3.StringStream('foo\nbar')

        stream.seek(4)

        self.assertEqual(stream.index(), 4)
        self.assertEqual(stream.line, 2)
        self.assertEqual(stream.charPositionInLine, 0)
        self.assertEqual(stream.LT(1), 'b')


##     # not yet implemented
##     def testSeekBackward(self):
##         """StringStream.seek(): backward"""

##         stream = antlr3.StringStream('foo\nbar')

##         stream.seek(4)
##         stream.seek(1)

##         self.assertEqual(stream.index(), 1)
##         self.assertEqual(stream.line, 1)
##         self.assertEqual(stream.charPositionInLine, 1)
##         self.assertEqual(stream.LA(1), 'o')


    def testMark(self):
        """StringStream.mark()"""

        stream = antlr3.StringStream('foo\nbar')

        stream.seek(4)

        marker = stream.mark()
        self.assertEqual(marker, 1)
        self.assertEqual(stream.markDepth, 1)

        stream.consume()
        marker = stream.mark()
        self.assertEqual(marker, 2)
        self.assertEqual(stream.markDepth, 2)


    def testReleaseLast(self):
        """StringStream.release(): last marker"""

        stream = antlr3.StringStream('foo\nbar')

        stream.seek(4)
        marker1 = stream.mark()

        stream.consume()
        marker2 = stream.mark()

        stream.release()
        self.assertEqual(stream.markDepth, 1)

        # release same marker again, nothing has changed
        stream.release()
        self.assertEqual(stream.markDepth, 1)


    def testReleaseNested(self):
        """StringStream.release(): nested"""

        stream = antlr3.StringStream('foo\nbar')

        stream.seek(4)
        marker1 = stream.mark()

        stream.consume()
        marker2 = stream.mark()

        stream.consume()
        marker3 = stream.mark()

        stream.release(marker2)
        self.assertEqual(stream.markDepth, 1)


    def testRewindLast(self):
        """StringStream.rewind(): last marker"""

        stream = antlr3.StringStream('foo\nbar')

        stream.seek(4)

        marker = stream.mark()
        stream.consume()
        stream.consume()

        stream.rewind()
        self.assertEqual(stream.markDepth, 0)
        self.assertEqual(stream.index(), 4)
        self.assertEqual(stream.line, 2)
        self.assertEqual(stream.charPositionInLine, 0)
        self.assertEqual(stream.LT(1), 'b')


    def testRewindNested(self):
        """StringStream.rewind(): nested"""

        stream = antlr3.StringStream('foo\nbar')

        stream.seek(4)
        marker1 = stream.mark()

        stream.consume()
        marker2 = stream.mark()

        stream.consume()
        marker3 = stream.mark()

        stream.rewind(marker2)
        self.assertEqual(stream.markDepth, 1)
        self.assertEqual(stream.index(), 5)
        self.assertEqual(stream.line, 2)
        self.assertEqual(stream.charPositionInLine, 1)
        self.assertEqual(stream.LT(1), 'a')


class TestFileStream(unittest.TestCase):
    """Test case for the FileStream class."""


    def testNoEncoding(self):
        path = os.path.join(os.path.dirname(__file__), 'teststreams.input1')

        stream = antlr3.FileStream(path)

        stream.seek(4)
        marker1 = stream.mark()

        stream.consume()
        marker2 = stream.mark()

        stream.consume()
        marker3 = stream.mark()

        stream.rewind(marker2)
        self.assertEqual(stream.markDepth, 1)
        self.assertEqual(stream.index(), 5)
        self.assertEqual(stream.line, 2)
        self.assertEqual(stream.charPositionInLine, 1)
        self.assertEqual(stream.LT(1), 'a')
        self.assertEqual(stream.LA(1), ord('a'))


    def testEncoded(self):
        path = os.path.join(os.path.dirname(__file__), 'teststreams.input2')

        stream = antlr3.FileStream(path)

        stream.seek(4)
        marker1 = stream.mark()

        stream.consume()
        marker2 = stream.mark()

        stream.consume()
        marker3 = stream.mark()

        stream.rewind(marker2)
        self.assertEqual(stream.markDepth, 1)
        self.assertEqual(stream.index(), 5)
        self.assertEqual(stream.line, 2)
        self.assertEqual(stream.charPositionInLine, 1)
        self.assertEqual(stream.LT(1), 'ä')
        self.assertEqual(stream.LA(1), ord('ä'))



class TestInputStream(unittest.TestCase):
    """Test case for the InputStream class."""

    def testNoEncoding(self):
        file = StringIO('foo\nbar')

        stream = antlr3.InputStream(file)

        stream.seek(4)
        marker1 = stream.mark()

        stream.consume()
        marker2 = stream.mark()

        stream.consume()
        marker3 = stream.mark()

        stream.rewind(marker2)
        self.assertEqual(stream.markDepth, 1)
        self.assertEqual(stream.index(), 5)
        self.assertEqual(stream.line, 2)
        self.assertEqual(stream.charPositionInLine, 1)
        self.assertEqual(stream.LT(1), 'a')
        self.assertEqual(stream.LA(1), ord('a'))


    def testEncoded(self):
        file = StringIO('foo\nbär')

        stream = antlr3.InputStream(file)

        stream.seek(4)
        marker1 = stream.mark()

        stream.consume()
        marker2 = stream.mark()

        stream.consume()
        marker3 = stream.mark()

        stream.rewind(marker2)
        self.assertEqual(stream.markDepth, 1)
        self.assertEqual(stream.index(), 5)
        self.assertEqual(stream.line, 2)
        self.assertEqual(stream.charPositionInLine, 1)
        self.assertEqual(stream.LT(1), 'ä')
        self.assertEqual(stream.LA(1), ord('ä'))


class TestCommonTokenStream(unittest.TestCase):
    """Test case for the StringStream class."""

    def setUp(self):
        """Setup test fixure

        The constructor of CommonTokenStream needs a token source. This
        is a simple mock class providing just the nextToken() method.

        """

        class MockSource(object):
            def __init__(self):
                self.tokens = []

            def makeEOFToken(self):
                return antlr3.CommonToken(type=antlr3.EOF)

            def nextToken(self):
                if self.tokens:
                    return self.tokens.pop(0)
                return None

        self.source = MockSource()


    def testInit(self):
        """CommonTokenStream.__init__()"""

        stream = antlr3.CommonTokenStream(self.source)
        self.assertEqual(stream.index(), -1)


    def testSetTokenSource(self):
        """CommonTokenStream.setTokenSource()"""

        stream = antlr3.CommonTokenStream(None)
        stream.setTokenSource(self.source)
        self.assertEqual(stream.index(), -1)
        self.assertEqual(stream.channel, antlr3.DEFAULT_CHANNEL)


    def testLTEmptySource(self):
        """CommonTokenStream.LT(): EOF (empty source)"""

        stream = antlr3.CommonTokenStream(self.source)

        lt1 = stream.LT(1)
        self.assertEqual(lt1.type, antlr3.EOF)


    def testLT1(self):
        """CommonTokenStream.LT(1)"""

        self.source.tokens.append(
            antlr3.CommonToken(type=12)
            )

        stream = antlr3.CommonTokenStream(self.source)

        lt1 = stream.LT(1)
        self.assertEqual(lt1.type, 12)


    def testLT1WithHidden(self):
        """CommonTokenStream.LT(1): with hidden tokens"""

        self.source.tokens.append(
            antlr3.CommonToken(type=12, channel=antlr3.HIDDEN_CHANNEL)
            )

        self.source.tokens.append(
            antlr3.CommonToken(type=13)
            )

        stream = antlr3.CommonTokenStream(self.source)

        lt1 = stream.LT(1)
        self.assertEqual(lt1.type, 13)


    def testLT2BeyondEnd(self):
        """CommonTokenStream.LT(2): beyond end"""

        self.source.tokens.append(
            antlr3.CommonToken(type=12)
            )

        self.source.tokens.append(
            antlr3.CommonToken(type=13, channel=antlr3.HIDDEN_CHANNEL)
            )

        stream = antlr3.CommonTokenStream(self.source)

        lt1 = stream.LT(2)
        self.assertEqual(lt1.type, antlr3.EOF)


    # not yet implemented
    def testLTNegative(self):
        """CommonTokenStream.LT(-1): look back"""

        self.source.tokens.append(
            antlr3.CommonToken(type=12)
            )

        self.source.tokens.append(
            antlr3.CommonToken(type=13)
            )

        stream = antlr3.CommonTokenStream(self.source)
        stream.fillBuffer()
        stream.consume()

        lt1 = stream.LT(-1)
        self.assertEqual(lt1.type, 12)


    def testLB1(self):
        """CommonTokenStream.LB(1)"""

        self.source.tokens.append(
            antlr3.CommonToken(type=12)
            )

        self.source.tokens.append(
            antlr3.CommonToken(type=13)
            )

        stream = antlr3.CommonTokenStream(self.source)
        stream.fillBuffer()
        stream.consume()

        self.assertEqual(stream.LB(1).type, 12)


    def testLTZero(self):
        """CommonTokenStream.LT(0)"""

        self.source.tokens.append(
            antlr3.CommonToken(type=12)
            )

        self.source.tokens.append(
            antlr3.CommonToken(type=13)
            )

        stream = antlr3.CommonTokenStream(self.source)

        lt1 = stream.LT(0)
        self.assertIsNone(lt1)


    def testLBBeyondBegin(self):
        """CommonTokenStream.LB(-1): beyond begin"""

        self.source.tokens.append(
            antlr3.CommonToken(type=12)
            )

        self.source.tokens.append(
            antlr3.CommonToken(type=12, channel=antlr3.HIDDEN_CHANNEL)
            )

        self.source.tokens.append(
            antlr3.CommonToken(type=12, channel=antlr3.HIDDEN_CHANNEL)
            )

        self.source.tokens.append(
            antlr3.CommonToken(type=13)
            )

        stream = antlr3.CommonTokenStream(self.source)
        self.assertIsNone(stream.LB(1))

        stream.consume()
        stream.consume()
        self.assertIsNone(stream.LB(3))


    def testFillBuffer(self):
        """CommonTokenStream.fillBuffer()"""

        self.source.tokens.append(
            antlr3.CommonToken(type=12)
            )

        self.source.tokens.append(
            antlr3.CommonToken(type=13)
            )

        self.source.tokens.append(
            antlr3.CommonToken(type=14)
            )

        self.source.tokens.append(
            antlr3.CommonToken(type=antlr3.EOF)
            )

        stream = antlr3.CommonTokenStream(self.source)
        stream.fillBuffer()

        self.assertEqual(len(stream.tokens), 3)
        self.assertEqual(stream.tokens[0].type, 12)
        self.assertEqual(stream.tokens[1].type, 13)
        self.assertEqual(stream.tokens[2].type, 14)


    def testConsume(self):
        """CommonTokenStream.consume()"""

        self.source.tokens.append(
            antlr3.CommonToken(type=12)
            )

        self.source.tokens.append(
            antlr3.CommonToken(type=13)
            )

        self.source.tokens.append(
            antlr3.CommonToken(type=antlr3.EOF)
            )

        stream = antlr3.CommonTokenStream(self.source)
        self.assertEqual(stream.LA(1), 12)

        stream.consume()
        self.assertEqual(stream.LA(1), 13)

        stream.consume()
        self.assertEqual(stream.LA(1), antlr3.EOF)

        stream.consume()
        self.assertEqual(stream.LA(1), antlr3.EOF)


    def testSeek(self):
        """CommonTokenStream.seek()"""

        self.source.tokens.append(
            antlr3.CommonToken(type=12)
            )

        self.source.tokens.append(
            antlr3.CommonToken(type=13)
            )

        self.source.tokens.append(
            antlr3.CommonToken(type=antlr3.EOF)
            )

        stream = antlr3.CommonTokenStream(self.source)
        self.assertEqual(stream.LA(1), 12)

        stream.seek(2)
        self.assertEqual(stream.LA(1), antlr3.EOF)

        stream.seek(0)
        self.assertEqual(stream.LA(1), 12)


    def testMarkRewind(self):
        """CommonTokenStream.mark()/rewind()"""

        self.source.tokens.append(
            antlr3.CommonToken(type=12)
            )

        self.source.tokens.append(
            antlr3.CommonToken(type=13)
            )

        self.source.tokens.append(
            antlr3.CommonToken(type=antlr3.EOF)
            )

        stream = antlr3.CommonTokenStream(self.source)
        stream.fillBuffer()

        stream.consume()
        marker = stream.mark()

        stream.consume()
        stream.rewind(marker)

        self.assertEqual(stream.LA(1), 13)


    def testToString(self):
        """CommonTokenStream.toString()"""

        self.source.tokens.append(
            antlr3.CommonToken(type=12, text="foo")
            )

        self.source.tokens.append(
            antlr3.CommonToken(type=13, text="bar")
            )

        self.source.tokens.append(
            antlr3.CommonToken(type=14, text="gnurz")
            )

        self.source.tokens.append(
            antlr3.CommonToken(type=15, text="blarz")
            )

        stream = antlr3.CommonTokenStream(self.source)

        self.assertEqual(stream.toString(), "foobargnurzblarz")
        self.assertEqual(stream.toString(1, 2), "bargnurz")
        self.assertEqual(stream.toString(stream.tokens[1], stream.tokens[-2]), "bargnurz")


if __name__ == "__main__":
    unittest.main(testRunner=unittest.TextTestRunner(verbosity=2))
