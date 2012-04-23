#import <Foundation/Foundation.h>
#import <ANTLR/ANTLR.h>
#import "SimpleCLexer.h"
#import "SimpleCParser.h"

int main()
{
    NSError *error;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSString *string = [NSString stringWithContentsOfFile:@"/Users/acondit/source/antlr/code/antlr3/runtime/ObjC/Framework/examples/LL-star/input" encoding:NSASCIIStringEncoding error:&error];
	NSLog(@"input is: %@", string);
	ANTLRStringStream *stream = [[ANTLRStringStream alloc] initWithStringNoCopy:string];
	SimpleCLexer *lexer = [[SimpleCLexer alloc] initWithCharStream:stream];

//	CommonToken *currentToken;
//	while ((currentToken = [lexer nextToken]) && currentToken.type != TokenTypeEOF) {
//		NSLog(@"%@", [currentToken toString]);
//	}
	
	CommonTokenStream *tokens = [[CommonTokenStream alloc] initWithTokenSource:lexer];
	SimpleCParser *parser = [[SimpleCParser alloc] initWithTokenStream:tokens];
	[parser program];

	[lexer release];
	[stream release];
	[tokens release];
	[parser release];

	[pool release];
	return 0;
}