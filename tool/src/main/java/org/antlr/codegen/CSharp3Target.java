/*
 * [The "BSD license"]
 * Copyright (c) 2005-2008 Terence Parr
 * All rights reserved.
 *
 * Conversion to C#:
 * Copyright (c) 2008-2010 Sam Harwell, Pixel Mine, Inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package org.antlr.codegen;

import org.antlr.Tool;
import org.antlr.tool.Grammar;
import org.stringtemplate.v4.AttributeRenderer;
import org.stringtemplate.v4.ST;

import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Locale;
import java.util.Map;

public class CSharp3Target extends Target {
    private static final HashSet<String> _languageKeywords = new HashSet<String>()
        {{
            add("abstract"); add("event"); add("new"); add("struct");
            add("as"); add("explicit"); add("null"); add("switch");
            add("base"); add("extern"); add("object"); add("this");
            add("bool"); add("false"); add("operator"); add("throw");
            add("break"); add("finally"); add("out"); add("true");
            add("byte"); add("fixed"); add("override"); add("try");
            add("case"); add("float"); add("params"); add("typeof");
            add("catch"); add("for"); add("private"); add("uint");
            add("char"); add("foreach"); add("protected"); add("ulong");
            add("checked"); add("goto"); add("public"); add("unchecked");
            add("class"); add("if"); add("readonly"); add("unsafe");
            add("const"); add("implicit"); add("ref"); add("ushort");
            add("continue"); add("in"); add("return"); add("using");
            add("decimal"); add("int"); add("sbyte"); add("virtual");
            add("default"); add("interface"); add("sealed"); add("volatile");
            add("delegate"); add("internal"); add("short"); add("void");
            add("do"); add("is"); add("sizeof"); add("while");
            add("double"); add("lock"); add("stackalloc");
            add("else"); add("long"); add("static");
            add("enum"); add("namespace"); add("string");
        }};

    @Override
    public String encodeIntAsCharEscape(int v) {
        return "\\x" + Integer.toHexString(v).toUpperCase();
    }

    @Override
    public String getTarget64BitStringFromValue(long word) {
        return "0x" + Long.toHexString(word).toUpperCase();
    }

    @Override
    protected void genRecognizerFile(Tool tool, CodeGenerator generator, Grammar grammar, ST outputFileST) throws IOException
    {
        if (!grammar.getGrammarIsRoot())
        {
            Grammar rootGrammar = grammar.composite.getRootGrammar();
            String actionScope = grammar.getDefaultActionScope(grammar.type);
            Map<String, Object> actions = rootGrammar.getActions().get(actionScope);
            Object rootNamespace = actions != null ? actions.get("namespace") : null;
            if (actions != null && rootNamespace != null)
            {
                actions = grammar.getActions().get(actionScope);
                if (actions == null)
                {
                    actions = new HashMap<String, Object>();
                    grammar.getActions().put(actionScope, actions);
                }

                actions.put("namespace", rootNamespace);
            }
        }

        generator.getTemplates().registerRenderer(String.class, new StringRenderer(generator, this));
        super.genRecognizerFile(tool, generator, grammar, outputFileST);
    }

    public static class StringRenderer implements AttributeRenderer
    {
        private final CodeGenerator _generator;
        private final CSharp3Target _target;

        public StringRenderer(CodeGenerator generator, CSharp3Target target)
        {
            _generator = generator;
            _target = target;
        }

        public String toString(Object obj, String formatName, Locale locale)
        {
            String value = (String)obj;
            if (value == null || formatName == null)
                return value;

            if (formatName.equals("id")) {
                if (_languageKeywords.contains(value))
                    return "@" + value;

                return value;
            } else if (formatName.equals("cap")) {
                return Character.toUpperCase(value.charAt(0)) + value.substring(1);
            } else if (formatName.equals("string")) {
                return _target.getTargetStringLiteralFromString(value, true);
            } else {
                throw new IllegalArgumentException("Unsupported format name: '" + formatName + "'");
            }
        }
    }
}

