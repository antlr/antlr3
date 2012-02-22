/*
 * [The "BSD license"]
 *  Copyright (c) 2010 Terence Parr
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *  1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *  3. The name of the author may not be used to endorse or promote products
 *      derived from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 *  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 *  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 *  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 *  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 *  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package org.antlr.codegen;

import org.antlr.Tool;
import org.antlr.analysis.Label;
import org.antlr.misc.Utils;
import org.stringtemplate.v4.ST;
import org.antlr.tool.Grammar;

public class DelphiTarget extends Target 
{
  public DelphiTarget() { 
    targetCharValueEscape['\n'] = "'#10'";    
    targetCharValueEscape['\r'] = "'#13'";    
    targetCharValueEscape['\t'] = "'#9'";   
    targetCharValueEscape['\b'] = "\\b";    
    targetCharValueEscape['\f'] = "\\f";    
    targetCharValueEscape['\\'] = "\\";   
    targetCharValueEscape['\''] = "''";   
    targetCharValueEscape['"'] = "'";
  } 

  protected ST chooseWhereCyclicDFAsGo(Tool tool,
                           CodeGenerator generator,
                           Grammar grammar,
                           ST recognizerST,
                           ST cyclicDFAST)
  {
    return recognizerST;
  }

	@Override
  public String encodeIntAsCharEscape(int v)
  {
    if (v <= 127)
    {
      String hex1 = Integer.toHexString(v | 0x10000).substring(3, 5);
      return "'#$" + hex1 + "'";
    }
    String hex = Integer.toHexString(v | 0x10000).substring(1, 5);
    return "'#$" + hex + "'";
  }
  
	@Override
  public String getTargetCharLiteralFromANTLRCharLiteral(
    CodeGenerator generator,
    String literal)
  {
    StringBuilder buf = new StringBuilder();
    int c = Grammar.getCharValueFromGrammarCharLiteral(literal);
    if ( c<Label.MIN_CHAR_VALUE ) {
      return "0";
    }
    // normal char
    buf.append(c);

    return buf.toString();
  } 

	@Override
  public String getTargetStringLiteralFromString(String s, boolean quoted) {
    if ( s==null ) {
      return null;
    }
    StringBuilder buf = new StringBuilder();
    if ( quoted ) {
      buf.append('\'');
    }
    for (int i=0; i<s.length(); i++) {
      int c = s.charAt(i);
      if ( c!='"' && // don't escape double quotes in strings for Delphi
         c<targetCharValueEscape.length &&
         targetCharValueEscape[c]!=null )
      {
        buf.append(targetCharValueEscape[c]);
      }
      else {
        buf.append((char)c);
      }
      if ((i & 127) == 127)
      {
        // Concatenate string literals because Delphi doesn't support literals over 255 characters,
        // and the code editor doesn't support lines over 1023 characters
        buf.append("\' + \r\n  \'");
      }
    }
    if ( quoted ) {
      buf.append('\'');
    }
    return buf.toString();
  }

	@Override
  public String getTargetStringLiteralFromANTLRStringLiteral(
    CodeGenerator generator,
    String literal)
  {
    literal = Utils.replace(literal,"\\\'","''"); // \' to ' to normalize
    literal = Utils.replace(literal,"\\r\\n","'#13#10'"); 
    literal = Utils.replace(literal,"\\r","'#13'"); 
    literal = Utils.replace(literal,"\\n","'#10'"); 
    StringBuilder buf = new StringBuilder(literal);
    buf.setCharAt(0,'\'');
    buf.setCharAt(literal.length()-1,'\'');
    return buf.toString();
  }
   
	@Override
  public String getTarget64BitStringFromValue(long word) {
    int numHexDigits = 8*2;
    StringBuilder buf = new StringBuilder(numHexDigits+2);
    buf.append("$");
    String digits = Long.toHexString(word);
    digits = digits.toUpperCase();
    int padding = numHexDigits - digits.length();
    // pad left with zeros
    for (int i=1; i<=padding; i++) {
      buf.append('0');
    }
    buf.append(digits);
    return buf.toString();
  }

}