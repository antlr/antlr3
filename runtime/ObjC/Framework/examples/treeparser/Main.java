import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;

public class Main {
	public static void main(String[] args) throws Exception {
		CharStream input = new ANTLRFileStream(args[0]);
		LangLexer lex = new LangLexer(input);
		CommonTokenStream tokens = new CommonTokenStream(lex);
		LangParser parser = new LangParser(tokens);
		//LangParser.decl_return r = parser.decl();
		LangParser.start_return r = parser.start();
		System.out.println("tree: "+((Tree)r.tree).toStringTree());
		CommonTree r0 = ((CommonTree)r.tree);

		CommonTreeNodeStream nodes = new CommonTreeNodeStream(r0);
		nodes.setTokenStream(tokens);
		LangDumpDecl walker = new LangDumpDecl(nodes);
		walker.decl();
	}
}
