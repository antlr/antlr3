#import <Cocoa/Cocoa.h>
#import <antlr3.h>
#import "SimpleCLexer.h"
#import "SimpleCParser.h"

int main() {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSString *string = [NSString stringWithContentsOfFile:@"/Users/acondit/source/antlr3/acondit_localhost/code/antlr/antlr3-main/runtime/ObjC/Framework/examples/LL-star/input"];
	NSLog(@"input is: %@", string);
	ANTLRStringStream *stream = [[ANTLRStringStream alloc] initWithStringNoCopy:string];
	SimpleCLexer *lexer = [[SimpleCLexer alloc] initWithCharStream:stream];

//	ANTLRCommonToken *currentToken;
//	while ((currentToken = [lexer nextToken]) && [currentToken getType] != ANTLRTokenTypeEOF) {
//		NSLog(@"%@", [currentToken toString]);
//	}
	
	ANTLRCommonTokenStream *tokens = [[ANTLRCommonTokenStream alloc] initWithTokenSource:lexer];
	SimpleCParser *parser = [[SimpleCParser alloc] initWithTokenStream:tokens];
	[parser program];

	[lexer release];
	[stream release];
	[tokens release];
	[parser release];

	[pool release];
	return 0;
}