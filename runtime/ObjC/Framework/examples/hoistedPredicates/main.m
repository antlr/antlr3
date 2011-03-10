#import <Cocoa/Cocoa.h>
#import <antlr3.h>
#import "TLexer.h"
#import "TParser.h"

int main() {
    NSError *error;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *string = [NSString stringWithContentsOfFile:@"../../examples/hoistedPredicates/input" encoding:NSASCIIStringEncoding error:&error];
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