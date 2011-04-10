package org.antlr.tool;

import org.antlr.codegen.CodeGenerator;
import org.antlr.grammar.v3.*;
import org.antlr.runtime.Token;
import org.antlr.runtime.tree.CommonTreeNodeStream;
import org.antlr.runtime.tree.TreeNodeStream;
import org.stringtemplate.v4.*;

import java.util.*;

/** */
public class LeftRecursiveRuleAnalyzer extends LeftRecursiveRuleWalker {
	public static enum ASSOC { left, right };

	public Grammar g;
	public CodeGenerator generator;
	public String ruleName;
	Map<Integer, Integer> tokenToPrec = new HashMap<Integer, Integer>();
	public LinkedHashMap<Integer, String> binaryAlts = new LinkedHashMap<Integer, String>();
	public LinkedHashMap<Integer, String> ternaryAlts = new LinkedHashMap<Integer, String>();
	public LinkedHashMap<Integer, String> suffixAlts = new LinkedHashMap<Integer, String>();
	public List<String> prefixAlts = new ArrayList<String>();
	public List<String> otherAlts = new ArrayList<String>();

	public GrammarAST retvals;

	public STGroup recRuleTemplates;
	public String language;

	public Map<Integer, ASSOC> altAssociativity = new HashMap<Integer, ASSOC>();

	public LeftRecursiveRuleAnalyzer(TreeNodeStream input, Grammar g, String ruleName) {
		super(input);
		this.g = g;
		this.ruleName = ruleName;
		language = (String)g.getOption("language");
		generator = new CodeGenerator(g.tool, g, language);
		generator.loadTemplates(language);
		loadPrecRuleTemplates();
	}

	public void loadPrecRuleTemplates() {
		recRuleTemplates =
			new STGroupFile(CodeGenerator.classpathTemplateRootDirectoryName+
							"/LeftRecursiveRules.stg");
		if ( !recRuleTemplates.isDefined("recRuleName") ) {
			ErrorManager.error(ErrorManager.MSG_MISSING_CODE_GEN_TEMPLATES,
							   "PrecRules");
			return;
		}
	}

	@Override
	public void setReturnValues(GrammarAST t) {
		System.out.println(t);
		retvals = t;
	}

	@Override
	public void setTokenPrec(GrammarAST t, int alt) {
		int ttype = g.getTokenType(t.getText());
		tokenToPrec.put(ttype, alt);
		ASSOC assoc = ASSOC.left;
		if ( t.terminalOptions!=null ) {
			String a = (String)t.terminalOptions.get("assoc");
			if ( a!=null ) {
				if ( a.equals(ASSOC.right.toString()) ) {
					assoc = ASSOC.right;
				}
				else {
					ErrorManager.error(ErrorManager.MSG_ILLEGAL_OPTION_VALUE, "assoc", assoc);
				}
			}
		}

		if ( altAssociativity.get(alt)!=null && altAssociativity.get(alt)!=assoc ) {
			ErrorManager.error(ErrorManager.MSG_ALL_OPS_NEED_SAME_ASSOC, alt);
		}
		altAssociativity.put(alt, assoc);

		//System.out.println("op " + alt + ": " + t.getText()+", assoc="+assoc);
	}

	@Override
	public void binaryAlt(GrammarAST altTree, GrammarAST rewriteTree, int alt) {
		altTree = GrammarAST.dupTree(altTree);
		rewriteTree = GrammarAST.dupTree(rewriteTree);

		stripSynPred(altTree);
		stripLeftRecursion(altTree);

		// rewrite e to be e_[rec_arg]
		int nextPrec = nextPrecedence(alt);
		ST refST = recRuleTemplates.getInstanceOf("recRuleRef");
		refST.add("ruleName", ruleName);
		refST.add("arg", nextPrec);
		altTree = replaceRuleRefs(altTree, refST.render());

		String altText = text(altTree);
		altText = altText.trim();
		altText += "{}"; // add empty alt to prevent pred hoisting
		ST nameST = recRuleTemplates.getInstanceOf("recRuleName");
		nameST.add("ruleName", ruleName);
		rewriteTree = replaceRuleRefs(rewriteTree, "$" + nameST.render());
		String rewriteText = text(rewriteTree);
		binaryAlts.put(alt, altText + (rewriteText != null ? " " + rewriteText : ""));
		//System.out.println("binaryAlt " + alt + ": " + altText + ", rewrite=" + rewriteText);
	}

	/** Convert e ? e : e  ->  ? e : e_[nextPrec] */
	@Override
	public void ternaryAlt(GrammarAST altTree, GrammarAST rewriteTree, int alt) {
		altTree = GrammarAST.dupTree(altTree);
		rewriteTree = GrammarAST.dupTree(rewriteTree);

		stripSynPred(altTree);
		stripLeftRecursion(altTree);

		int nextPrec = nextPrecedence(alt);
		ST refST = recRuleTemplates.getInstanceOf("recRuleRef");
		refST.add("ruleName", ruleName);
		refST.add("arg", nextPrec);
		altTree = replaceLastRuleRef(altTree, refST.render());

		String altText = text(altTree);
		altText = altText.trim();
		altText += "{}"; // add empty alt to prevent pred hoisting
		ST nameST = recRuleTemplates.getInstanceOf("recRuleName");
		nameST.add("ruleName", ruleName);
		rewriteTree = replaceRuleRefs(rewriteTree, "$" + nameST.render());
		String rewriteText = text(rewriteTree);
		ternaryAlts.put(alt, altText + (rewriteText != null ? " " + rewriteText : ""));
		//System.out.println("ternaryAlt " + alt + ": " + altText + ", rewrite=" + rewriteText);
	}

	@Override
	public void prefixAlt(GrammarAST altTree, GrammarAST rewriteTree, int alt) {
		altTree = GrammarAST.dupTree(altTree);
		rewriteTree = GrammarAST.dupTree(rewriteTree);

		stripSynPred(altTree);

		int nextPrec = precedence(alt);
		// rewrite e to be e_[rec_arg]
		ST refST = recRuleTemplates.getInstanceOf("recRuleRef");
		refST.add("ruleName", ruleName);
		refST.add("arg", nextPrec);
		altTree = replaceRuleRefs(altTree, refST.render());
		String altText = text(altTree);
		altText = altText.trim();
		altText += "{}"; // add empty alt to prevent pred hoisting

		ST nameST = recRuleTemplates.getInstanceOf("recRuleName");
		nameST.add("ruleName", ruleName);
		rewriteTree = replaceRuleRefs(rewriteTree, nameST.render());
		String rewriteText = text(rewriteTree);

		prefixAlts.add(altText + (rewriteText != null ? " " + rewriteText : ""));
		//System.out.println("prefixAlt " + alt + ": " + altText + ", rewrite=" + rewriteText);
	}

	@Override
	public void suffixAlt(GrammarAST altTree, GrammarAST rewriteTree, int alt) {
		altTree = GrammarAST.dupTree(altTree);
		rewriteTree = GrammarAST.dupTree(rewriteTree);
		stripSynPred(altTree);
		stripLeftRecursion(altTree);
		ST nameST = recRuleTemplates.getInstanceOf("recRuleName");
		nameST.add("ruleName", ruleName);
		rewriteTree = replaceRuleRefs(rewriteTree, "$" + nameST.render());
		String rewriteText = text(rewriteTree);
		String altText = text(altTree);
		altText = altText.trim();
		suffixAlts.put(alt, altText + (rewriteText != null ? " " + rewriteText : ""));
//		System.out.println("suffixAlt " + alt + ": " + altText + ", rewrite=" + rewriteText);
	}

	@Override
	public void otherAlt(GrammarAST altTree, GrammarAST rewriteTree, int alt) {
		altTree = GrammarAST.dupTree(altTree);
		rewriteTree = GrammarAST.dupTree(rewriteTree);
		stripSynPred(altTree);
		stripLeftRecursion(altTree);
		String altText = text(altTree);

		String rewriteText = text(rewriteTree);
		otherAlts.add(altText + (rewriteText != null ? " " + rewriteText : ""));
		//System.out.println("otherAlt " + alt + ": " + altText + ", rewrite=" + rewriteText);
	}

	// --------- get transformed rules ----------------

	public String getArtificialPrecStartRule() {
		ST ruleST = recRuleTemplates.getInstanceOf("recRuleStart");
		ruleST.add("ruleName", ruleName);
		ruleST.add("minPrec", 0);
		ruleST.add("userRetvals", retvals);
		fillRetValAssignments(ruleST, "recRuleName");

		System.out.println("start: " + ruleST);
		return ruleST.render();
	}

	public String getArtificialOpPrecRule() {
		ST ruleST = recRuleTemplates.getInstanceOf("recRule");
		ruleST.add("ruleName", ruleName);
		ruleST.add("buildAST", grammar.buildAST());
		ST argDefST =
			generator.getTemplates().getInstanceOf("recRuleDefArg");
		ruleST.add("precArgDef", argDefST);
		ST ruleArgST =
			generator.getTemplates().getInstanceOf("recRuleArg");
		ruleST.add("argName", ruleArgST);
		ST setResultST =
			generator.getTemplates().getInstanceOf("recRuleSetResultAction");
		ruleST.add("setResultAction", setResultST);
		ruleST.add("userRetvals", retvals);
		fillRetValAssignments(ruleST, "recPrimaryName");

		LinkedHashMap<Integer, String> opPrecRuleAlts = new LinkedHashMap<Integer, String>();
		opPrecRuleAlts.putAll(binaryAlts);
		opPrecRuleAlts.putAll(ternaryAlts);
		opPrecRuleAlts.putAll(suffixAlts);
		for (int alt : opPrecRuleAlts.keySet()) {
			String altText = opPrecRuleAlts.get(alt);
			ST altST = recRuleTemplates.getInstanceOf("recRuleAlt");
			ST predST =
				generator.getTemplates().getInstanceOf("recRuleAltPredicate");
			predST.add("opPrec", precedence(alt));
			predST.add("ruleName", ruleName);
			altST.add("pred", predST);
			altST.add("alt", altText);
			ruleST.add("alts", altST);
		}

		System.out.println(ruleST);

		return ruleST.render();
	}

	public String getArtificialPrimaryRule() {
		ST ruleST = recRuleTemplates.getInstanceOf("recPrimaryRule");
		ruleST.add("ruleName", ruleName);
		ruleST.add("alts", prefixAlts);
		ruleST.add("alts", otherAlts);
		ruleST.add("userRetvals", retvals);
		System.out.println(ruleST);
		return ruleST.render();
	}

	public GrammarAST replaceRuleRefs(GrammarAST t, String name) {
		if ( t==null ) return null;
		for (GrammarAST rref : t.findAllType(RULE_REF)) {
			if ( rref.getText().equals(ruleName) ) rref.setText(name);
		}
		return t;
	}

	public static boolean hasImmediateRecursiveRuleRefs(GrammarAST t, String ruleName) {
		if ( t==null ) return false;
		for (GrammarAST rref : t.findAllType(RULE_REF)) {
			if ( rref.getText().equals(ruleName) ) return true;
		}
		return false;
	}

	public GrammarAST replaceLastRuleRef(GrammarAST t, String name) {
		if ( t==null ) return null;
		GrammarAST last = null;
		for (GrammarAST rref : t.findAllType(RULE_REF)) { last = rref; }
		if ( last !=null && last.getText().equals(ruleName) ) last.setText(name);
		return t;
	}

	public void stripSynPred(GrammarAST altAST) {
		GrammarAST t = (GrammarAST)altAST.getChild(0);
		if ( t.getType()==ANTLRParser.BACKTRACK_SEMPRED ||
			 t.getType()==ANTLRParser.SYNPRED ||
			 t.getType()==ANTLRParser.SYN_SEMPRED )
		{
			altAST.deleteChild(0); // kill it
		}
	}

	public void stripLeftRecursion(GrammarAST altAST) {
		GrammarAST rref = (GrammarAST)altAST.getChild(0);
		if ( rref.getType()== ANTLRParser.RULE_REF &&
			 rref.getText().equals(ruleName))
		{
			// remove rule ref
			altAST.deleteChild(0);
			// reset index so it prints properly
			GrammarAST newFirstChild = (GrammarAST) altAST.getChild(0);
			altAST.setTokenStartIndex(newFirstChild.getTokenStartIndex());
		}
	}

	public String text(GrammarAST t) {
		if ( t==null ) return null;
		try {
			return new ANTLRTreePrinter(new CommonTreeNodeStream(t)).toString(grammar, true);
		}
		catch (Exception e) {
			ErrorManager.error(ErrorManager.MSG_BAD_AST_STRUCTURE, e);
		}
		return null;
	}

	public int precedence(int alt) {
		return numAlts-alt+1;
	}

	public int nextPrecedence(int alt) {
		int p = precedence(alt);
		if ( altAssociativity.get(alt)==ASSOC.left ) p++;
		return p;
	}

	public void fillRetValAssignments(ST ruleST, String srcName) {
		if ( retvals==null ) return;

		// complicated since we must be target-independent
		for (String name : getNamesFromArgAction(retvals.token)) {
			ST setRetValST =
				generator.getTemplates().getInstanceOf("recRuleSetReturnAction");
			ST ruleNameST = recRuleTemplates.getInstanceOf(srcName);
			ruleNameST.add("ruleName", ruleName);
			setRetValST.add("src", ruleNameST);
			setRetValST.add("name", name);
			ruleST.add("userRetvalAssignments",setRetValST);
		}
	}

	public Collection<String> getNamesFromArgAction(Token t) {
		AttributeScope returnScope = grammar.createReturnScope("",t);
		returnScope.addAttributes(t.getText(), ',');
		return returnScope.attributes.keySet();
	}

	@Override
	public String toString() {
		return "PrecRuleOperatorCollector{" +
			   "binaryAlts=" + binaryAlts +
			   ", rec=" + tokenToPrec +
			   ", ternaryAlts=" + ternaryAlts +
			   ", suffixAlts=" + suffixAlts +
			   ", prefixAlts=" + prefixAlts +
			   ", otherAlts=" + otherAlts +
			   '}';
	}
}
