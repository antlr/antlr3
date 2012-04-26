#import <Foundation/Foundation.h>
#import <ANTLR/ANTLR.h>
#import "TreeRewriteLexer.h"
#import "TreeRewriteParser.h"
//#import "stdio.h"
//#include <unistd.h>

int main() {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"23 42"];
	TreeRewriteLexer *lexer = [TreeRewriteLexer newTreeRewriteLexerWithCharStream:stream];
	
//    id<Token> currentToken;
//    while ((currentToken = [lexer nextToken]) && [currentToken type] != TokenTypeEOF) {
//        NSLog(@"%@", currentToken);
//    }
	
	CommonTokenStream *tokenStream = [CommonTokenStream newCommonTokenStreamWithTokenSource:lexer];
	TreeRewriteParser *parser = [[TreeRewriteParser alloc] initWithTokenStream:tokenStream];
	CommonTree *rule_tree = [[parser rule] getTree];
	NSLog(@"tree: %@", [rule_tree treeDescription]);
//	CommonTreeNodeStream *treeStream = [[CommonTreeNodeStream alloc] initWithTree:program_tree];
//	SimpleCTP *walker = [[SimpleCTP alloc] initWithTreeNodeStream:treeStream];
//	[walker program];

	[lexer release];
	[stream release];
	[tokenStream release];
	[parser release];
//	[treeStream release];
//	[walker release];

	[pool release];
    // sleep for objectalloc
    // while(1) sleep(60);
	return 0;
}