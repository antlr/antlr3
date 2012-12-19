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

package org.antlr.tool;

import org.antlr.grammar.v3.ANTLRv3Lexer;
import org.antlr.grammar.v3.ANTLRv3Parser;
import org.antlr.runtime.*;
import org.antlr.runtime.tree.CommonTree;
import org.antlr.runtime.tree.TreeAdaptor;
import org.antlr.runtime.tree.TreeWizard;

import java.util.List;

/** A basic action stripper. */
public class Strip {
    protected String filename;
    protected TokenRewriteStream tokens;
    protected boolean tree_option = false;
    protected String args[];

    public static void main(String args[]) throws Exception {
        Strip s = new Strip(args);
        s.parseAndRewrite();
        System.out.println(s.tokens);
    }

    public Strip(String[] args) { this.args = args; }

    public TokenRewriteStream getTokenStream() { return tokens; }

    public void parseAndRewrite() throws Exception {
        processArgs(args);
        CharStream input;
        if ( filename!=null ) input = new ANTLRFileStream(filename);
        else input = new ANTLRInputStream(System.in);
        // BUILD AST
        ANTLRv3Lexer lex = new ANTLRv3Lexer(input);
        tokens = new TokenRewriteStream(lex);
        ANTLRv3Parser g = new ANTLRv3Parser(tokens);
        ANTLRv3Parser.grammarDef_return r = g.grammarDef();
        CommonTree t = r.getTree();
        if (tree_option) System.out.println(t.toStringTree());
        rewrite(g.getTreeAdaptor(),t,g.getTokenNames());
    }

    public void rewrite(TreeAdaptor adaptor, CommonTree t, String[] tokenNames) throws Exception {
        TreeWizard wiz = new TreeWizard(adaptor, tokenNames);

        // ACTIONS STUFF
        wiz.visit(t, ANTLRv3Parser.ACTION,
           new TreeWizard.Visitor() {
			@Override
               public void visit(Object t) { ACTION(tokens, (CommonTree)t); }
           });

        wiz.visit(t, ANTLRv3Parser.AT,  // ^('@' id ACTION) rule actions
            new TreeWizard.Visitor() {
			@Override
              public void visit(Object t) {
                  CommonTree a = (CommonTree)t;
                  CommonTree action = null;
                  if ( a.getChildCount()==2 ) action = (CommonTree)a.getChild(1);
                  else if ( a.getChildCount()==3 ) action = (CommonTree)a.getChild(2);
                  if ( action.getType()==ANTLRv3Parser.ACTION ) {
                      tokens.delete(a.getTokenStartIndex(),
                                    a.getTokenStopIndex());
                      killTrailingNewline(tokens, action.getTokenStopIndex());
                  }
              }
            });
        wiz.visit(t, ANTLRv3Parser.ARG, // wipe rule arguments
                  new TreeWizard.Visitor() {
			@Override
              public void visit(Object t) {
                  CommonTree a = (CommonTree)t;
                  a = (CommonTree)a.getChild(0);
                  tokens.delete(a.token.getTokenIndex());
                  killTrailingNewline(tokens, a.token.getTokenIndex());
              }
            });
        wiz.visit(t, ANTLRv3Parser.RET, // wipe rule return declarations
            new TreeWizard.Visitor() {
			@Override
                public void visit(Object t) {
                    CommonTree a = (CommonTree)t;
                    CommonTree ret = (CommonTree)a.getChild(0);
                    tokens.delete(a.token.getTokenIndex(),
                                  ret.token.getTokenIndex());
                }
            });
        wiz.visit(t, ANTLRv3Parser.SEMPRED, // comment out semantic predicates
            new TreeWizard.Visitor() {
			@Override
                public void visit(Object t) {
                    CommonTree a = (CommonTree)t;
                    tokens.replace(a.token.getTokenIndex(), "/*"+a.getText()+"*/");
                }
            });
        wiz.visit(t, ANTLRv3Parser.GATED_SEMPRED, // comment out semantic predicates
            new TreeWizard.Visitor() {
			@Override
                public void visit(Object t) {
                    CommonTree a = (CommonTree)t;
                    String text = tokens.toString(a.getTokenStartIndex(),
                                                  a.getTokenStopIndex());
                    tokens.replace(a.getTokenStartIndex(),
                                   a.getTokenStopIndex(),
                                   "/*"+text+"*/");
                }
            });
        wiz.visit(t, ANTLRv3Parser.SCOPE, // comment scope specs
            new TreeWizard.Visitor() {
			@Override
                public void visit(Object t) {
                    CommonTree a = (CommonTree)t;
                    tokens.delete(a.getTokenStartIndex(),
                                  a.getTokenStopIndex());
                    killTrailingNewline(tokens, a.getTokenStopIndex());
                }
            });        
        wiz.visit(t, ANTLRv3Parser.ARG_ACTION, // args r[x,y] -> ^(r [x,y])
            new TreeWizard.Visitor() {
			@Override
                public void visit(Object t) {
                    CommonTree a = (CommonTree)t;
                    if ( a.getParent().getType()==ANTLRv3Parser.RULE_REF ) {
                        tokens.delete(a.getTokenStartIndex(),
                                      a.getTokenStopIndex());
                    }
                }
            });
        wiz.visit(t, ANTLRv3Parser.LABEL_ASSIGN, // ^('=' id ^(RULE_REF [arg])), ...
            new TreeWizard.Visitor() {
			@Override
                public void visit(Object t) {
                    CommonTree a = (CommonTree)t;
                    if ( !a.hasAncestor(ANTLRv3Parser.OPTIONS) ) { // avoid options
                        CommonTree child = (CommonTree)a.getChild(0);
                        tokens.delete(a.token.getTokenIndex());     // kill "id="
                        tokens.delete(child.token.getTokenIndex());
                    }
                }
            });
        wiz.visit(t, ANTLRv3Parser.LIST_LABEL_ASSIGN, // ^('+=' id ^(RULE_REF [arg])), ...
            new TreeWizard.Visitor() {
			@Override
              public void visit(Object t) {
                  CommonTree a = (CommonTree)t;
                  CommonTree child = (CommonTree)a.getChild(0);
                  tokens.delete(a.token.getTokenIndex());     // kill "id+="
                  tokens.delete(child.token.getTokenIndex());
              }
            });


        // AST STUFF
        wiz.visit(t, ANTLRv3Parser.REWRITE,
            new TreeWizard.Visitor() {
			@Override
              public void visit(Object t) {
                  CommonTree a = (CommonTree)t;
                  CommonTree child = (CommonTree)a.getChild(0);
                  int stop = child.getTokenStopIndex();
                  if ( child.getType()==ANTLRv3Parser.SEMPRED ) {
                      CommonTree rew = (CommonTree)a.getChild(1);
                      stop = rew.getTokenStopIndex();
                  }
                  tokens.delete(a.token.getTokenIndex(), stop);
                  killTrailingNewline(tokens, stop);
              }
            });
        wiz.visit(t, ANTLRv3Parser.ROOT,
           new TreeWizard.Visitor() {
			@Override
               public void visit(Object t) {
                   tokens.delete(((CommonTree)t).token.getTokenIndex());
               }
           });
        wiz.visit(t, ANTLRv3Parser.BANG,
           new TreeWizard.Visitor() {
			@Override
               public void visit(Object t) {
                   tokens.delete(((CommonTree)t).token.getTokenIndex());
               }
           });
    }

    public static void ACTION(TokenRewriteStream tokens, CommonTree t) {
        CommonTree parent = (CommonTree)t.getParent();
        int ptype = parent.getType();
        if ( ptype==ANTLRv3Parser.SCOPE || // we have special rules for these
             ptype==ANTLRv3Parser.AT )
        {
            return;
        }
        //System.out.println("ACTION: "+t.getText());
        CommonTree root = (CommonTree)t.getAncestor(ANTLRv3Parser.RULE);
        if ( root!=null ) {
            CommonTree rule = (CommonTree)root.getChild(0);
            //System.out.println("rule: "+rule);
            if ( !Character.isUpperCase(rule.getText().charAt(0)) ) {
                tokens.delete(t.getTokenStartIndex(),t.getTokenStopIndex());
                killTrailingNewline(tokens, t.token.getTokenIndex());
            }
        }
    }

    private static void killTrailingNewline(TokenRewriteStream tokens, int index) {
        List<? extends Token> all = tokens.getTokens();
        Token tok = all.get(index);
        Token after = all.get(index+1);
        String ws = after.getText();
        if ( ws.startsWith("\n") ) {
            //System.out.println("killing WS after action");
            if ( ws.length()>1 ) {
                int space = ws.indexOf(' ');
                int tab = ws.indexOf('\t');
                if ( ws.startsWith("\n") &&
                     space>=0 || tab>=0 )
                {
                    return; // do nothing if \n + indent
                }
                // otherwise kill all \n
                ws = ws.replaceAll("\n", "");
                tokens.replace(after.getTokenIndex(), ws);
            }
            else {
                tokens.delete(after.getTokenIndex());
            }
        }
    }

    public void processArgs(String[] args) {
		if ( args==null || args.length==0 ) {
			help();
			return;
		}
		for (int i = 0; i < args.length; i++) {
			if (args[i].equals("-tree")) tree_option = true;
			else {
				if (args[i].charAt(0) != '-') {
					// Must be the grammar file
                    filename = args[i];
				}
			}
		}
	}

    private static void help() {
        System.err.println("usage: java org.antlr.tool.Strip [args] file.g");
        System.err.println("  -tree      print out ANTLR grammar AST");
    }

}
