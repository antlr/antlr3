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

public class JavaScriptTarget extends Target {
    /** Convert an int to a JavaScript Unicode character literal.
     *
     *  The current JavaScript spec (ECMA-262) doesn't provide for octal
     *  notation in String literals, although some implementations support it.
     *  This method overrides the parent class so that characters will always
     *  be encoded as Unicode literals (e.g. \u0011).
     */
    public String encodeIntAsCharEscape(int v) {
        String hex = Integer.toHexString(v|0x10000).substring(1,5);
        return "\\u"+hex;
    }

    /** Convert long to two 32-bit numbers separted by a comma.
     *  JavaScript does not support 64-bit numbers, so we need to break
     *  the number into two 32-bit literals to give to the Bit.  A number like
     *  0xHHHHHHHHLLLLLLLL is broken into the following string:
     *  "0xLLLLLLLL, 0xHHHHHHHH"
     *  Note that the low order bits are first, followed by the high order bits.
     *  This is to match how the BitSet constructor works, where the bits are
     *  passed in in 32-bit chunks with low-order bits coming first.
     *
     *  Note: stole the following two methods from the ActionScript target.
     */
    public String getTarget64BitStringFromValue(long word) {
        StringBuffer buf = new StringBuffer(22); // enough for the two "0x", "," and " "
        buf.append("0x");
        writeHexWithPadding(buf, Integer.toHexString((int)(word & 0x00000000ffffffffL)));
        buf.append(", 0x");
        writeHexWithPadding(buf, Integer.toHexString((int)(word >> 32)));

        return buf.toString();
    }

    private void writeHexWithPadding(StringBuffer buf, String digits) {
        digits = digits.toUpperCase();
        int padding = 8 - digits.length();
        // pad left with zeros
        for (int i=1; i<=padding; i++) {
            buf.append('0');
        }
        buf.append(digits);
    }
}
