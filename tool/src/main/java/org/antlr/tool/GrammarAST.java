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

import org.antlr.analysis.DFA;
import org.antlr.analysis.NFAState;
import org.antlr.grammar.v3.ANTLRParser;
import org.antlr.misc.IntSet;
import org.antlr.misc.Interval;
import org.antlr.runtime.CommonToken;
import org.antlr.runtime.Token;
import org.antlr.runtime.TokenSource;
import org.antlr.runtime.tree.CommonTree;
import org.antlr.runtime.tree.Tree;
import org.antlr.runtime.tree.TreeAdaptor;
import org.stringtemplate.v4.ST;
import org.omg.PortableInterceptor.ORBInitInfoPackage.DuplicateName;

import java.util.*;

/** Grammars are first converted to ASTs using this class and then are
 *  converted to NFAs via a tree walker.
 *
 *  The reader may notice that I have made a very non-OO decision in this
 *  class to track variables for many different kinds of nodes.  It wastes
 *  space for nodes that don't need the values and OO principles cry out
 *  for a new class type for each kind of node in my tree.  I am doing this
 *  on purpose for a variety of reasons.  I don't like using the type
 *  system for different node types; it yields too many damn class files
 *  which I hate.  Perhaps if I put them all in one file.  Most importantly
 *  though I hate all the type casting that would have to go on.  I would
 *  have all sorts of extra work to do.  Ick.  Anyway, I'm doing all this
 *  on purpose, not out of ignorance. ;)
 */
public class GrammarAST extends CommonTree {
	static int count = 0;

	public int ID = ++count;

	private String textOverride;

    public String enclosingRuleName;

    /** If this is a decision node, what is the lookahead DFA? */
    public DFA lookaheadDFA = null;

    /** What NFA start state was built from this node? */
    public NFAState NFAStartState = null;

	/** This is used for TREE_BEGIN nodes to point into
	 *  the NFA.  TREE_BEGINs point at left edge of DOWN for LOOK computation
     *  purposes (Nullable tree child list needs special code gen when matching).
	 */
	public NFAState NFATreeDownState = null;

	/** Rule ref nodes, token refs, set, and NOT set refs need to track their
	 *  location in the generated NFA so that local FOLLOW sets can be
	 *  computed during code gen for automatic error recovery.
	 */
	public NFAState followingNFAState = null;

	/** If this is a SET node, what are the elements? */
    protected IntSet setValue = null;

    /** If this is a BLOCK node, track options here */
    protected Map<String,Object> blockOptions;

	/** If this is a BLOCK node for a rewrite rule, track referenced
	 *  elements here.  Don't track elements in nested subrules.
	 */
	public Set<GrammarAST> rewriteRefsShallow;

	/*	If REWRITE node, track EVERY element and label ref to right of ->
	 *  for this rewrite rule.  There could be multiple of these per
	 *  rule:
	 *
	 *     a : ( ... -> ... | ... -> ... ) -> ... ;
	 *
	 *  We may need a list of all refs to do definitions for whole rewrite
	 *  later.
	 *
	 *  If BLOCK then tracks every element at that level and below.
	 */
	public Set<GrammarAST> rewriteRefsDeep;

	public Map<String,Object> terminalOptions;

	/** if this is an ACTION node, this is the outermost enclosing
	 *  alt num in rule.  For actions, define.g sets these (used to
	 *  be codegen.g).  We need these set so we can examine actions
	 *  early, before code gen, for refs to rule predefined properties
	 *  and rule labels.  For most part define.g sets outerAltNum, but
	 *  codegen.g does the ones for %foo(a={$ID.text}) type refs as
	 *  the {$ID...} is not seen as an action until code gen pulls apart.
	 */
	public int outerAltNum;

	/** if this is a TOKEN_REF or RULE_REF node, this is the code ST
	 *  generated for this node.  We need to update it later to add
	 *  a label if someone does $tokenref or $ruleref in an action.
	 */
	public ST code;

    /**
     *
     * @return
     */
    public Map<String, Object> getBlockOptions() {
        return blockOptions;
    }

    /**
     *
     * @param blockOptions
     */
    public void setBlockOptions(Map<String, Object> blockOptions) {
        this.blockOptions = blockOptions;
    }

	public GrammarAST() {;}

	public GrammarAST(int t, String txt) {
		initialize(t,txt);
	}

	public GrammarAST(Token token) {
		initialize(token);
	}

	public void initialize(int i, String s) {
        token = new CommonToken(i,s);
		token.setTokenIndex(-1);
    }

    public void initialize(Tree ast) {
		GrammarAST t = ((GrammarAST)ast);
		this.startIndex = t.startIndex;
		this.stopIndex = t.stopIndex;
		this.token = t.token;
		this.enclosingRuleName = t.enclosingRuleName;
		this.setValue = t.setValue;
		this.blockOptions = t.blockOptions;
		this.outerAltNum = t.outerAltNum;
	}

    public void initialize(Token token) {
        this.token = token;
		if ( token!=null ) {
			startIndex = token.getTokenIndex();
			stopIndex = startIndex;
		}
    }

    public DFA getLookaheadDFA() {
        return lookaheadDFA;
    }

    public void setLookaheadDFA(DFA lookaheadDFA) {
        this.lookaheadDFA = lookaheadDFA;
    }

    public NFAState getNFAStartState() {
        return NFAStartState;
    }

    public void setNFAStartState(NFAState nfaStartState) {
		this.NFAStartState = nfaStartState;
	}

	/** Save the option key/value pair and process it; return the key
	 *  or null if invalid option.
	 */
	public String setBlockOption(Grammar grammar, String key, Object value) {
		if ( blockOptions == null ) {
			blockOptions = new HashMap();
		}
		return setOption(blockOptions, Grammar.legalBlockOptions, grammar, key, value);
	}

	public String setTerminalOption(Grammar grammar, String key, Object value) {
		if ( terminalOptions == null ) {
			terminalOptions = new HashMap<String,Object>();
		}
		return setOption(terminalOptions, Grammar.legalTokenOptions, grammar, key, value);
	}

	public String setOption(Map options, Set legalOptions, Grammar grammar, String key, Object value) {
		if ( !legalOptions.contains(key) ) {
			ErrorManager.grammarError(ErrorManager.MSG_ILLEGAL_OPTION,
									  grammar,
									  token,
									  key);
			return null;
		}
		if ( value instanceof String ) {
			String vs = (String)value;
			if ( vs.charAt(0)=='"' ) {
				value = vs.substring(1,vs.length()-1); // strip quotes
            }
        }
		if ( key.equals("k") ) {
			grammar.numberOfManualLookaheadOptions++;
		}
        if ( key.equals("backtrack") && value.toString().equals("true") ) {
            grammar.composite.getRootGrammar().atLeastOneBacktrackOption = true;
        }
        options.put(key, value);
		return key;
    }

    public Object getBlockOption(String key) {
		Object value = null;
		if ( blockOptions != null ) {
			value = blockOptions.get(key);
		}
		return value;
	}

    public void setOptions(Grammar grammar, Map options) {
		if ( options==null ) {
			this.blockOptions = null;
			return;
		}
		String[] keys = (String[])options.keySet().toArray(new String[options.size()]);
		for (String optionName : keys) {
			String stored= setBlockOption(grammar, optionName, options.get(optionName));
			if ( stored==null ) {
				options.remove(optionName);
			}
		}
    }

    @Override
    public String getText() {
		if ( textOverride!=null ) return textOverride;
        if ( token!=null ) {
            return token.getText();
        }
        return "";
    }

	public void setType(int type) {
		token.setType(type);
	}

	public void setText(String text) {
		textOverride = text; // don't alt tokens as others might see
	}

    @Override
    public int getType() {
        if ( token!=null ) {
            return token.getType();
        }
        return -1;
    }

    @Override
    public int getLine() {
		int line=0;
        if ( token!=null ) {
            line = token.getLine();
        }
		if ( line==0 ) {
			Tree child = getChild(0);
			if ( child!=null ) {
				line = child.getLine();
			}
		}
        return line;
    }

    @Override
    public int getCharPositionInLine(){
		int col=0;
        if ( token!=null ) {
            col = token.getCharPositionInLine();
        }
		if ( col==0 ) {
			Tree child = getChild(0);
			if ( child!=null ) {
				col = child.getCharPositionInLine();
			}
		}
        return col;
    }

    public void setLine(int line) {
        token.setLine(line);
    }

    public void setCharPositionInLine(int value){
        token.setCharPositionInLine(value);
    }

 	public IntSet getSetValue() {
        return setValue;
    }

    public void setSetValue(IntSet setValue) {
        this.setValue = setValue;
    }

    public GrammarAST getLastChild() {
        if (getChildCount() == 0)
            return null;
        return (GrammarAST)getChild(getChildCount() - 1);
    }

    public GrammarAST getNextSibling() {
        return (GrammarAST)getParent().getChild(getChildIndex() + 1);
    }

    public GrammarAST getLastSibling() {
        Tree parent = getParent();
        if ( parent==null ) {
            return null;
        }
        return (GrammarAST)parent.getChild(parent.getChildCount() - 1);
    }


    public GrammarAST[] getChildrenAsArray() {
        return (GrammarAST[])getChildren().toArray(new GrammarAST[getChildCount()]);
    }

    private static final GrammarAST DescendantDownNode = new GrammarAST(Token.DOWN, "DOWN");
    private static final GrammarAST DescendantUpNode = new GrammarAST(Token.UP, "UP");

    public static List<Tree> descendants(Tree root){
        return descendants(root, false);
    }

    public static List<Tree> descendants(Tree root, boolean insertDownUpNodes){
        List<Tree> result = new ArrayList<Tree>();
        int count = root.getChildCount();

        if (insertDownUpNodes){
            result.add(root);
            result.add(DescendantDownNode);

            for (int i = 0 ; i < count ; i++){
                Tree child = root.getChild(i);
                for (Tree subchild : descendants(child, true))
                    result.add(subchild);
            }

            result.add(DescendantUpNode);
        }else{
            result.add(root);
            for (int i = 0 ; i < count ; i++){
                Tree child = root.getChild(i);
                for (Tree subchild : descendants(child, false))
                    result.add(subchild);
            }
        }

        return result;
    }

	public GrammarAST findFirstType(int ttype) {
		// check this node (the root) first
		if ( this.getType()==ttype ) {
			return this;
		}
		// else check children
		List<Tree> descendants = descendants(this);
		for (Tree child : descendants) {
			if ( child.getType()==ttype ) {
				return (GrammarAST)child;
			}
		}
		return null;
	}

	public List<GrammarAST> findAllType(int ttype) {
		List<GrammarAST> nodes = new ArrayList<GrammarAST>();
		_findAllType(ttype, nodes);
		return nodes;
	}

	public void _findAllType(int ttype, List<GrammarAST> nodes) {
		// check this node (the root) first
		if ( this.getType()==ttype ) nodes.add(this);
		// check children
		for (int i = 0; i < getChildCount(); i++){
			GrammarAST child = (GrammarAST)getChild(i);
			child._findAllType(ttype, nodes);
		}
	}

    /** Make nodes unique based upon Token so we can add them to a Set; if
	 *  not a GrammarAST, check type.
	 */
	@Override
	public boolean equals(Object ast) {
		if ( this == ast ) {
			return true;
		}
		if ( !(ast instanceof GrammarAST) ) {
			return this.getType() == ((Tree)ast).getType();
		}
		GrammarAST t = (GrammarAST)ast;
		return token.getLine() == t.getLine() &&
			   token.getCharPositionInLine() == t.getCharPositionInLine();
	}

    /** Make nodes unique based upon Token so we can add them to a Set; if
	 *  not a GrammarAST, check type.
	 */
    @Override
    public int hashCode(){
        if (token == null)
            return 0;

        return token.hashCode();
    }

	/** See if tree has exact token types and structure; no text */
	public boolean hasSameTreeStructure(Tree other) {
		// check roots first.
		if (this.getType() != other.getType()) return false;
		// if roots match, do full list match test on children.
		Iterator<Tree> thisDescendants = descendants(this, true).iterator();
		Iterator<Tree> otherDescendants = descendants(other, true).iterator();
		while (thisDescendants.hasNext()) {
			if (!otherDescendants.hasNext())
				return false;
			if (thisDescendants.next().getType() != otherDescendants.next().getType())
				return false;
		}
		return !otherDescendants.hasNext();
	}

	public static GrammarAST dup(Tree t) {
		if ( t==null ) {
			return null;
		}
		GrammarAST dup_t = new GrammarAST();
		dup_t.initialize(t);
		return dup_t;
	}

    @Override
    public Tree dupNode(){
        return dup(this);
    }

	/**Duplicate a tree, assuming this is a root node of a tree--
	 * duplicate that node and what's below; ignore siblings of root node.
	 */
	public static GrammarAST dupTreeNoActions(GrammarAST t, GrammarAST parent) {
		if ( t==null ) {
			return null;
		}
		GrammarAST result = (GrammarAST)t.dupNode();
		for (GrammarAST subchild : getChildrenForDupTree(t)) {
			result.addChild(dupTreeNoActions(subchild, result));
		}
		return result;
	}

	private static List<GrammarAST> getChildrenForDupTree(GrammarAST t) {
		List<GrammarAST> result = new ArrayList<GrammarAST>();
		for (int i = 0; i < t.getChildCount(); i++){
			GrammarAST child = (GrammarAST)t.getChild(i);
			int ttype = child.getType();
			if (ttype == ANTLRParser.REWRITES || ttype == ANTLRParser.REWRITE || ttype==ANTLRParser.ACTION) {
				continue;
			}

			if (ttype == ANTLRParser.BANG || ttype == ANTLRParser.ROOT) {
				for (GrammarAST subchild : getChildrenForDupTree(child))
					result.add(subchild);
			} else {
				result.add(child);
			}
		}
		if ( result.size()==1 && result.get(0).getType()==ANTLRParser.EOA &&
			 t.getType()==ANTLRParser.ALT )
		{
			// can't have an empty alt, insert epsilon
			result.add(0, new GrammarAST(ANTLRParser.EPSILON, "epsilon"));
		}

		return result;
	}

	public static GrammarAST dupTree(GrammarAST t) {
		if ( t==null ) {
			return null;
		}
		GrammarAST root = dup(t);		// make copy of root
		// copy all children of root.
		for (int i= 0; i < t.getChildCount(); i++) {
			GrammarAST child = (GrammarAST)t.getChild(i);
			root.addChild(dupTree(child));
		}
		return root;
	}

	public void setTreeEnclosingRuleNameDeeply(String rname) {
		enclosingRuleName = rname;
		if (getChildCount() == 0) return;
		for (Object child : getChildren()) {
			if (!(child instanceof GrammarAST)) {
				continue;
			}
			GrammarAST grammarAST = (GrammarAST)child;
			grammarAST.setTreeEnclosingRuleNameDeeply(rname);
		}
	}

	String toStringList() {
		return "";
	}

	/** Track start/stop token for subtree root created for a rule.
	 *  Only works with Tree nodes.  For rules that match nothing,
	 *  seems like this will yield start=i and stop=i-1 in a nil node.
	 *  Might be useful info so I'll not force to be i..i.
	 */
	public void setTokenBoundaries(Token startToken, Token stopToken) {
		if ( startToken!=null ) startIndex = startToken.getTokenIndex();
		if ( stopToken!=null ) stopIndex = stopToken.getTokenIndex();
	}

	public GrammarAST getBlockALT(int i) {
		if ( this.getType()!=ANTLRParser.BLOCK ) return null;
		int alts = 0;
		for (int j =0 ; j < getChildCount(); j++) {
			if (getChild(j).getType() == ANTLRParser.ALT) {
				alts++;
			}
			if (alts == i) {
				return (GrammarAST)getChild(j);
			}
		}
		return null;
	}
}
