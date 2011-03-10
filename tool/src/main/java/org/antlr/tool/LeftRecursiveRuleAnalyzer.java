package org.antlr.tool;

import antlr.Token;
import org.antlr.codegen.CodeGenerator;
import org.antlr.grammar.v2.*;
import org.antlr.stringtemplate.*;
import org.antlr.stringtemplate.language.AngleBracketTemplateLexer;

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

	public StringTemplateGroup recRuleTemplates;
	public String language;

	public Map<Integer, ASSOC> altAssociativity = new HashMap<Integer, ASSOC>();

	public LeftRecursiveRuleAnalyzer(Grammar g, String ruleName) {
		this.g = g;
		this.ruleName = ruleName;
		language = (String)g.getOption("language");
		generator = new CodeGenerator(g.tool, g, language);
		generator.loadTemplates(language);
		loadPrecRuleTemplates();
	}

	public void loadPrecRuleTemplates() {
		String templateDirs =
			CodeGenerator.classpathTemplateRootDirectoryName;
		StringTemplateGroupLoader loader =
			new CommonGroupLoader(templateDirs,
								  ErrorManager.getStringTemplateErrorListener());
		StringTemplateGroup.registerGroupLoader(loader);
		StringTemplateGroup.registerDefaultLexer(AngleBracketTemplateLexer.class);

		recRuleTemplates =	StringTemplateGroup.loadGroup("LeftRecursiveRules");
		if ( recRuleTemplates==null ) {
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
		StringTemplate refST = recRuleTemplates.getInstanceOf("recRuleRef");
		refST.setAttribute("ruleName", ruleName);
		refST.setAttribute("arg", nextPrec);
		altTree = replaceRuleRefs(altTree, refST.toString());

		String altText = text(altTree);
		altText = altText.trim();
		altText += "{}"; // add empty alt to prevent pred hoisting
		StringTemplate nameST = recRuleTemplates.getInstanceOf("recRuleName");
		nameST.setAttribute("ruleName", ruleName);
		rewriteTree = replaceRuleRefs(rewriteTree, "$" + nameST.toString());
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
		StringTemplate refST = recRuleTemplates.getInstanceOf("recRuleRef");
		refST.setAttribute("ruleName", ruleName);
		refST.setAttribute("arg", nextPrec);
		altTree = replaceLastRuleRef(altTree, refST.toString());

		String altText = text(altTree);
		altText = altText.trim();
		altText += "{}"; // add empty alt to prevent pred hoisting
		StringTemplate nameST = recRuleTemplates.getInstanceOf("recRuleName");
		nameST.setAttribute("ruleName", ruleName);
		rewriteTree = replaceRuleRefs(rewriteTree, "$" + nameST.toString());
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
		StringTemplate refST = recRuleTemplates.getInstanceOf("recRuleRef");
		refST.setAttribute("ruleName", ruleName);
		refST.setAttribute("arg", nextPrec);
		altTree = replaceRuleRefs(altTree, refST.toString());
		String altText = text(altTree);
		altText = altText.trim();
		altText += "{}"; // add empty alt to prevent pred hoisting

		StringTemplate nameST = recRuleTemplates.getInstanceOf("recRuleName");
		nameST.setAttribute("ruleName", ruleName);
		rewriteTree = replaceRuleRefs(rewriteTree, nameST.toString());
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
		StringTemplate nameST = recRuleTemplates.getInstanceOf("recRuleName");
		nameST.setAttribute("ruleName", ruleName);
		rewriteTree = replaceRuleRefs(rewriteTree, "$" + nameST.toString());
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
		StringTemplate ruleST = recRuleTemplates.getInstanceOf("recRuleStart");
		ruleST.setAttribute("ruleName", ruleName);
		ruleST.setAttribute("minPrec", 0);
		ruleST.setAttribute("userRetvals", retvals);
		fillRetValAssignments(ruleST, "recRuleName");

		System.out.println("start: " + ruleST);
		return ruleST.toString();
	}

	public String getArtificialOpPrecRule() {
		StringTemplate ruleST = recRuleTemplates.getInstanceOf("recRule");
		ruleST.setAttribute("ruleName", ruleName);
		ruleST.setAttribute("buildAST", grammar.buildAST());
		StringTemplate argDefST =
			generator.getTemplates().getInstanceOf("recRuleDefArg");
		ruleST.setAttribute("precArgDef", argDefST);
		StringTemplate ruleArgST =
			generator.getTemplates().getInstanceOf("recRuleArg");
		ruleST.setAttribute("argName", ruleArgST);
		StringTemplate setResultST =
			generator.getTemplates().getInstanceOf("recRuleSetResultAction");
		ruleST.setAttribute("setResultAction", setResultST);
		ruleST.setAttribute("userRetvals", retvals);
		fillRetValAssignments(ruleST, "recPrimaryName");

		LinkedHashMap<Integer, String> opPrecRuleAlts = new LinkedHashMap<Integer, String>();
		opPrecRuleAlts.putAll(binaryAlts);
		opPrecRuleAlts.putAll(ternaryAlts);
		opPrecRuleAlts.putAll(suffixAlts);
		for (int alt : opPrecRuleAlts.keySet()) {
			String altText = opPrecRuleAlts.get(alt);
			StringTemplate altST = recRuleTemplates.getInstanceOf("recRuleAlt");
			StringTemplate predST =
				generator.getTemplates().getInstanceOf("recRuleAltPredicate");
			predST.setAttribute("opPrec", precedence(alt));
			predST.setAttribute("ruleName", ruleName);
			altST.setAttribute("pred", predST);
			altST.setAttribute("alt", altText);
			ruleST.setAttribute("alts", altST);
		}

		System.out.println(ruleST);

		return ruleST.toString();
	}

	public String getArtificialPrimaryRule() {
		StringTemplate ruleST = recRuleTemplates.getInstanceOf("recPrimaryRule");
		ruleST.setAttribute("ruleName", ruleName);
		ruleST.setAttribute("alts", prefixAlts);
		ruleST.setAttribute("alts", otherAlts);
		ruleST.setAttribute("userRetvals", retvals);
		System.out.println(ruleST);
		return ruleST.toString();
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
		GrammarAST t = (GrammarAST)altAST.getFirstChild();
		if ( t.getType()==ANTLRParser.BACKTRACK_SEMPRED ||
			 t.getType()==ANTLRParser.SYNPRED ||
			 t.getType()==ANTLRParser.SYN_SEMPRED )
		{
			altAST.setFirstChild(t.getNextSibling()); // kill it
		}
	}

	public void stripLeftRecursion(GrammarAST altAST) {
		GrammarAST rref = (GrammarAST)altAST.getFirstChild();
		if ( rref.getType()== ANTLRParser.RULE_REF &&
			 rref.getText().equals(ruleName))
		{
			// remove rule ref
			altAST.setFirstChild(rref.getNextSibling());
			// reset index so it prints properly
			GrammarAST newFirstChild = (GrammarAST) altAST.getFirstChild();
			altAST.startIndex = newFirstChild.startIndex;
		}
	}

	public String text(GrammarAST t) {
		if ( t==null ) return null;
		try {
			return new ANTLRTreePrinter().toString(t, grammar, true);
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

	public void fillRetValAssignments(StringTemplate ruleST, String srcName) {
		if ( retvals==null ) return;

		// complicated since we must be target-independent
		for (String name : getNamesFromArgAction(retvals.token)) {
			StringTemplate setRetValST =
				generator.getTemplates().getInstanceOf("recRuleSetReturnAction");
			StringTemplate ruleNameST = recRuleTemplates.getInstanceOf(srcName);
			ruleNameST.setAttribute("ruleName", ruleName);
			setRetValST.setAttribute("src", ruleNameST);
			setRetValST.setAttribute("name", name);
			ruleST.setAttribute("userRetvalAssignments",setRetValST);
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
