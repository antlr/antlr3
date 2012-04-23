#import <Foundation/Foundation.h>
#import "Fuzzy.h"
#import <ANTLR/ANTLR.h>

int main(int argc, const char * argv[])
{
    NSError *error;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *input = [NSString stringWithContentsOfFile:@"/Users/acondit/source/antlr/code/antlr3/runtime/ObjC/Framework/examples/fuzzy/input"  encoding:NSASCIIStringEncoding error:&error];
	NSLog(@"%@", input);
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:input];
	Fuzzy *lex = [Fuzzy newFuzzyWithCharStream:stream];
	CommonTokenStream *tokens = [CommonTokenStream newCommonTokenStreamWithTokenSource:lex];
	NSLog( [tokens toString] );

	id<Token> currentToken;
	while ((currentToken = [lex nextToken]) && currentToken.type != TokenTypeEOF) {
		NSLog(@"### %@", [currentToken toString]);
	}

	[lex release];
	[stream release];
	
	[pool release];
	return 0;
}