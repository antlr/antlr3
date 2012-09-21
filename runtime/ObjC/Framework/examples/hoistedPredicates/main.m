#import <Foundation/Foundation.h>
#import <ANTLR/ANTLR.h>
#import "TLexer.h"
#import "TParser.h"

int main() {
    NSError *error;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *string = [NSString stringWithContentsOfFile:@"/Users/acondit/source/antlr/code/antlr3/runtime/ObjC/Framework/examples/hoistedPredicates/input" encoding:NSASCIIStringEncoding error:&error];
	NSLog(@"input is : %@", string);
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:string];
	TLexer *lexer = [TLexer newTLexerWithCharStream:stream];
	
	//	Token *currentToken;
	//	while ((currentToken = [lexer nextToken]) && [currentToken type] != TokenTypeEOF) {
	//		NSLog(@"%@", currentToken);
	//	}
	
	CommonTokenStream *tokenStream = [CommonTokenStream newCommonTokenStreamWithTokenSource:lexer];
	TParser *parser = [[TParser alloc] initWithTokenStream:tokenStream];
	[parser stat];
	[lexer release];
	[stream release];
	[tokenStream release];
	[parser release];
	
	[pool release];
	return 0;
}