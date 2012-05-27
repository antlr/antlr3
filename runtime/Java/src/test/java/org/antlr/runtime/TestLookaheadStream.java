package org.antlr.runtime;

import junit.framework.TestCase;

public class TestLookaheadStream extends TestCase {

  public void testSeek() {
    UnbufferedTokenStream stream = new UnbufferedTokenStream(createTokenSource());

    stream.consume();
    assertEquals(0, stream.LA(-1));
    assertEquals(1, stream.LA(1));

    stream.mark();

    stream.consume();
    assertEquals(1, stream.LA(-1));
    assertEquals(2, stream.LA(1));

    int index = stream.index();
    stream.rewind();
    assertEquals(0, stream.LA(-1));
    assertEquals(1, stream.LA(1));

    stream.seek(index);
    assertEquals(1, stream.LA(-1));
    assertEquals(2, stream.LA(1));
  }

  private TokenSource createTokenSource() {
    return new TokenSource() {
      int count = 0;

      @Override
      public Token nextToken() {
        return new CommonToken(count++);
      }

      @Override
      public String getSourceName() {
        return "test";
      }
    };

  }
}
