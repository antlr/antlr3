#import <Cocoa/Cocoa.h>
#import <ANTLR/ANTLR.h>
#import "TLexer.h"
#import "TParser.h"

int main() {
    NSError *error;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *string = [NSString stringWithContentsOfFile:@"/Users/acondit/source/antlr3/acondit_localhost/code/antlr/antlr3-main/runtime/ObjC/Framework/examples/hoistedPredicates/input" encoding:NSASCIIStringEncoding error:&error];
	NSLog(@"input is : %@", string);
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:string];
	TLexer *lexer = [TLexer newTLexerWithCharStream:stream];
	
	//	ANTLRToken *currentToken;
	//	while ((currentToken = [lexer nextToken]) && [currentToken type] != ANTLRTokenTypeEOF) {
	//		NSLog(@"%@", currentToken);
	//	}
	
	ANTLRCommonTokenStream *tokenStream = [ANTLRCommonTokenStream newANTLRCommonTokenStreamWithTokenSource:lexer];
	TParser *parser = [[TParser alloc] initWithTokenStream:tokenStream];
	[parser stat];
	[lexer release];
	[stream release];
	[tokenStream release];
	[parser release];
	
	[pool release];
	return 0;
}