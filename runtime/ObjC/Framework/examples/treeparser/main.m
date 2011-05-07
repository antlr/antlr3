#import <Cocoa/Cocoa.h>
#import "antlr3.h"
#import "LangLexer.h"
#import "LangParser.h"
#import "LangDumpDecl.h"
#import "stdio.h"
#include <unistd.h>

/*
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
*/

int main(int argc, const char * argv[])
{
    NSError *error;
    NSLog(@"starting treeparser\n");
    NSString *dir = @"/Users/acondit/source/antlr3/acondit_localhost/code/antlr/main/runtime/ObjC/Framework/examples/treeparser/input";
	NSString *string = [NSString stringWithContentsOfFile:dir  encoding:NSASCIIStringEncoding error:&error];
	NSLog(@"input = %@", string);
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:string];
	LangLexer *lex = [LangLexer newLangLexerWithCharStream:stream];
    ANTLRCommonTokenStream *tokens = [ANTLRCommonTokenStream newANTLRCommonTokenStreamWithTokenSource:lex];
    LangParser *parser = [LangParser newLangParser:tokens];
//    LangParser_decl_return *r = [parser decl];
    LangParser_start_return *r = [parser start];
    NSLog( @"tree: %@", [r.tree toStringTree]);
    ANTLRCommonTree *r0 = [r getTree];
    
    ANTLRCommonTreeNodeStream *nodes = [ANTLRCommonTreeNodeStream newANTLRCommonTreeNodeStream:r0];
    [nodes setTokenStream:tokens];
    LangDumpDecl *walker = [LangDumpDecl newLangDumpDecl:nodes];
    [walker decl];

    NSLog(@"exiting treeparser\n");
	return 0;
}