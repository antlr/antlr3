//
//  CommonTreeTest.m
//  ANTLR
//
//  Created by Ian Michell on 26/05/2010.
//  Copyright 2010 Ian Michell. All rights reserved.
//

#import <ANTLR/BaseTree.h>
#import "CommonTreeTest.h"
#import <ANTLR/ANTLRStringStream.h>
#import <ANTLR/CommonTree.h>
#import <ANTLR/CommonToken.h>
#import <ANTLR/ANTLRError.h>
#import <ANTLR/RuntimeException.h>

@implementation CommonTreeTest

-(void) test01InitAndRelease
{
	CommonTree *tree = [CommonTree newTree];
	STAssertNotNil(tree, @"Tree was nil");
	// FIXME: It doesn't do anything else, perhaps initWithTree should set something somewhere, java says no though...
    return;
}

-(void) test02InitWithTree
{
	CommonTree *tree = [CommonTree newTree];
	STAssertNotNil(tree, @"Tree was nil");
    if (tree != nil)
        STAssertEquals(tree.type, (NSInteger)TokenTypeInvalid, @"Tree should have an invalid token type, because it has no token");
    // [tree release];
    return;
}

-(void) test03WithToken
{
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	CommonToken *token = [CommonToken newToken:stream Type:555 Channel:TokenChannelDefault Start:4 Stop:5];
	token.line = 1;
	token.charPositionInLine = 4;
	CommonTree *tree = [CommonTree newTreeWithToken:token];
	STAssertNotNil(tree, @"Tree was nil");
    if (tree != nil)
        STAssertNotNil(tree.token, @"Tree with token was nil");
    if (tree != nil && tree.token != nil) {
        STAssertEquals((NSUInteger) tree.token.line, (NSUInteger)1, [NSString stringWithFormat:@"Tree should be at line 1, but was at %d", tree.token.line] );
        STAssertEquals((NSUInteger) tree.token.charPositionInLine, (NSUInteger)4, [NSString stringWithFormat:@"Char position should be 1, but was at %d", tree.token.charPositionInLine]);
        STAssertNotNil(((CommonToken *)tree.token).text, @"Tree with token with text was nil");
    }
    if (tree != nil && tree.token != nil && tree.token.text != nil)
        STAssertTrue([tree.token.text isEqualToString:@"||"], @"Text was not ||");
	//[tree release];
    return;
}

-(void) test04InvalidTreeNode
{
	CommonTree *tree = [CommonTree newTreeWithToken:[CommonToken invalidToken]];
	STAssertNotNil(tree, @"Tree was nil");
	STAssertEquals(tree.token.type, (NSInteger)TokenTypeInvalid, @"Tree Token type was not TokenTypeInvalid");
	//[tree release];
    return;
}

-(void) test05InitWithCommonTreeNode
{
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	CommonToken *token = [CommonToken newToken:stream Type:555 Channel:TokenChannelDefault Start:4 Stop:5];
	CommonTree *tree = [CommonTree newTreeWithToken:token];
	STAssertNotNil(tree, @"Tree was nil");
	STAssertNotNil(tree.token, @"Tree token was nil");
	CommonTree *newTree = [CommonTree newTreeWithTree:tree];
	STAssertNotNil(newTree, @"New tree was nil");
	STAssertNotNil(newTree.token, @"New tree token was nil");
	STAssertEquals(newTree.token, tree.token, @"Tokens did not match");
	STAssertEquals(newTree.startIndex, tree.startIndex, @"Token start index did not match %d:%d", newTree.startIndex, tree.startIndex);
	STAssertEquals(newTree.stopIndex, tree.stopIndex, @"Token stop index did not match %d:%d", newTree.stopIndex, tree.stopIndex);
	//[stream release];
	//[tree release];
	//[newTree release];
	//[token release];
    return;
}

-(void) test06CopyTree
{
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	CommonToken *token = [CommonToken newToken:stream Type:555 Channel:TokenChannelDefault Start:4 Stop:5];
	CommonTree *tree = [CommonTree newTreeWithToken:token];
	STAssertNotNil(tree, @"Tree was nil");
	CommonTree *newTree = (CommonTree *)[tree copyWithZone:nil];
	STAssertTrue([newTree isKindOfClass:[CommonTree class]], @"Copied tree was not an CommonTree");
	STAssertNotNil(newTree, @"New tree was nil");
	// STAssertEquals(newTree.token, tree.token, @"Tokens did not match");
	STAssertEquals(newTree.stopIndex, tree.stopIndex, @"Token stop index did not match");
	STAssertEquals(newTree.startIndex, tree.startIndex, @"Token start index did not match");
	//[stream release];
	//[tree release];
	//[newTree release];
	// [token release];
    return;
}

-(void) test07Description
{
    NSString *aString;
	CommonTree *errorTree = [CommonTree invalidNode];
	STAssertNotNil(errorTree, @"Error tree node is nil");
    if (errorTree != nil) {
        aString = [errorTree description];
        STAssertNotNil( aString, @"errorTree description returned nil");
        if (aString != nil)
            STAssertTrue([aString isEqualToString:@"<errornode>"], @"Not a valid error node description %@", aString);
    }
	//[errorTree release];
	
	CommonTree *tree = [CommonTree newTreeWithTokenType:TokenTypeUP];
	STAssertNotNil(tree, @"Tree is nil");
    if (tree != nil)
        STAssertNil([tree description], @"Tree description was not nil, was: %@", [tree description]);
	//[tree release];
	
	tree = [CommonTree newTree];
	STAssertNotNil(tree, @"Tree is nil");
    if (tree != nil) {
        aString = [tree description];
        STAssertNotNil(aString, @"tree description returned nil");
        if (aString != nil)
            STAssertTrue([aString isEqualToString:@"nil"], @"Tree description was not empty", [tree description]);
    }
	//[tree release];
	
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	CommonToken *token = [CommonToken newToken:stream Type:555 Channel:TokenChannelDefault Start:4 Stop:5];
	tree = [CommonTree newTreeWithToken:token];
	STAssertNotNil(tree, @"Tree node is nil");
    aString = [tree description];
    STAssertNotNil(aString, @"tree description returned nil");
    if (aString != nil)
        STAssertTrue([aString isEqualToString:@"||"], @"description was not || was instead %@", [tree description]);
	//[tree release];
    return;
}

-(void) test08Text
{
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	CommonToken *token = [CommonToken newToken:stream Type:555 Channel:TokenChannelDefault Start:4 Stop:5];
	CommonTree *tree = [CommonTree newTreeWithToken:token];
	STAssertNotNil(tree, @"Tree was nil");
	STAssertTrue([tree.token.text isEqualToString:@"||"], @"Tree text was not valid, should have been || was %@", tree.token.text);
	//[tree release];
	
	// test nil (for line coverage)
	tree = [CommonTree newTree];
	STAssertNotNil(tree, @"Tree was nil");
	STAssertNil(tree.token.text, @"Tree text was not nil: %@", tree.token.text);
    return;
}

-(void) test09AddChild
{
	// Create a new tree
	CommonTree *parent = [CommonTree newTreeWithTokenType:555];
    parent.token.line = 1;
	parent.token.charPositionInLine = 1;
	
	// Child tree
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	CommonToken *token = [CommonToken newToken:stream Type:555 Channel:TokenChannelDefault Start:4 Stop:5];
	token.line = 1;
	token.charPositionInLine = 4;
	CommonTree *tree = [CommonTree newTreeWithToken:token];
	
	// Add a child to the parent tree
	[parent addChild:tree];


	STAssertNotNil(parent, @"parent was nil");
    if (parent != nil)
        STAssertNotNil(parent.token, @"parent was nil");
	STAssertEquals((NSInteger)parent.token.line, (NSInteger)1, @"Tree should be at line 1 but is %d", parent.token.line);
	STAssertEquals((NSInteger)parent.token.charPositionInLine, (NSInteger)1, @"Char position should be 1 but is %d", parent.token.charPositionInLine);
	
	STAssertEquals((NSInteger)[parent getChildCount], (NSInteger)1, @"There should be 1 child but there were %d", [parent getChildCount]);
	STAssertEquals((NSInteger)[[parent getChild:0] getChildIndex], (NSInteger)0, @"Child index should be 0 was : %d", [[parent getChild:0] getChildIndex]);
	STAssertEquals([[parent getChild:0] getParent], parent, @"Parent not set for child");
	
	//[parent release];
    return;
}

-(void) test10AddChildren
{
	// Create a new tree
	CommonTree *parent = [CommonTree newTree];
	
	// Child tree
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	CommonToken *token = [CommonToken newToken:stream Type:555 Channel:TokenChannelDefault Start:4 Stop:5];
	token.line = 1;
	token.charPositionInLine = 4;
	CommonTree *tree = [CommonTree newTreeWithToken:token];
	
	// Add a child to the parent tree
	[parent addChild: tree];
	
	CommonTree *newParent = [CommonTree newTree];
	[newParent addChildren:parent.children];
	
	STAssertEquals([newParent getChild:0], [parent getChild:0], @"Children did not match");
    return;
}

-(void) test11AddSelfAsChild
{
	CommonTree *parent = [CommonTree newTree];
	@try 
	{
		[parent addChild:parent];
	}
	@catch (NSException *e) 
	{
		STAssertTrue([[e name] isEqualToString:@"IllegalArgumentException"], @"Got wrong kind of exception! %@", [e name]);
		//[parent release];
		return;
	}
	STFail(@"Did not get an exception when adding an empty child!");
    return;
}

-(void) test12AddEmptyChildWithNoChildren
{
	CommonTree *emptyChild = [CommonTree newTree];
	CommonTree *parent = [CommonTree newTree];
	[parent addChild:emptyChild];
	STAssertEquals((NSInteger)[parent getChildCount], (NSInteger)0, @"There were supposed to be no children!");
	//[parent release];
	//[emptyChild release];
    return;
}

-(void) test13AddEmptyChildWithChildren
{
	// Create a new tree
	CommonTree *parent = [CommonTree newTree];
	
	// Child tree
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	CommonToken *token = [CommonToken newToken:stream Type:555 Channel:TokenChannelDefault Start:4 Stop:5];
	token.line = 1;
	token.charPositionInLine = 4;
	CommonTree *tree = [CommonTree newTreeWithToken:token];
	
	// Add a child to the parent tree
	[parent addChild: tree];
	
	CommonTree *newParent = [CommonTree newTree];
	[newParent addChild:parent];
	
	STAssertEquals((NSInteger)[newParent getChildCount], (NSInteger)1, @"Parent should only have 1 child: %d", [newParent getChildCount]);
	STAssertEquals([newParent getChild:0], tree, @"Child was not the correct object.");
	//[parent release];
	//[newParent release];
	//[tree release];
    return;
}

-(void) test14ChildAtIndex
{
	// Create a new tree
	CommonTree *parent = [CommonTree newTree];
	
	// Child tree
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	CommonToken *token = [CommonToken newToken:stream Type:555 Channel:TokenChannelDefault Start:4 Stop:5];
	CommonTree *tree = [CommonTree newTreeWithToken:token];
	
	// Add a child to the parent tree
	[parent addChild: tree];
	
	STAssertEquals((NSInteger)[parent getChildCount], (NSInteger)1, @"There were either no children or more than 1: %d", [parent getChildCount]);
	
	CommonTree *child = [parent getChild:0];
	STAssertNotNil(child, @"Child at index 0 should not be nil");
	STAssertEquals(child, tree, @"Child and Original tree were not the same");
	//[parent release];
    return;
}

-(void) test15SetChildAtIndex
{
	CommonTree *parent = [CommonTree newTree];
	
	// Child tree
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	CommonToken *token = [CommonToken newToken:stream Type:555 Channel:TokenChannelDefault Start:4 Stop:5];
	CommonTree *tree = [CommonTree newTreeWithToken:token];
	
	
	tree = [CommonTree newTreeWithTokenType:TokenTypeUP];
	tree.token.text = @"<UP>";
	[parent addChild:tree];
	
	STAssertTrue([parent getChild:0] == tree, @"Trees don't match");
	[parent setChild:0 With:tree];
	
	CommonTree *child = [parent getChild:0];
	STAssertTrue([parent getChildCount] == 1, @"There were either no children or more than 1: %d", [parent getChildCount]);
	STAssertNotNil(child, @"Child at index 0 should not be nil");
	STAssertEquals(child, tree, @"Child and Original tree were not the same");
	//[parent release];
    return;
}

-(void) test16GetAncestor
{
	CommonTree *parent = [CommonTree newTreeWithTokenType:TokenTypeUP];
	parent.token.text = @"<UP>";
	
	CommonTree *down = [CommonTree newTreeWithTokenType:TokenTypeDOWN];
	down.token.text = @"<DOWN>";
	
	[parent addChild:down];
	
	// Child tree
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	CommonToken *token = [CommonToken newToken:stream Type:555 Channel:TokenChannelDefault Start:4 Stop:5];
	CommonTree *tree = [CommonTree newTreeWithToken:token];
	
	[down addChild:tree];
	STAssertTrue([tree hasAncestor:TokenTypeUP], @"Should have an ancestor of type TokenTypeUP");
	
	CommonTree *ancestor = [tree getAncestor:TokenTypeUP];
	STAssertNotNil(ancestor, @"Ancestor should not be nil");
	STAssertEquals(ancestor, parent, @"Acenstors do not match");
	//[parent release];
    return;
}

-(void) test17FirstChildWithType
{
	// Create a new tree
	CommonTree *parent = [CommonTree newTree];
	
	CommonTree *up = [CommonTree newTreeWithTokenType:TokenTypeUP];
	CommonTree *down = [CommonTree newTreeWithTokenType:TokenTypeDOWN];
	
	[parent addChild:up];
	[parent addChild:down];
	
	CommonTree *found = (CommonTree *)[parent getFirstChildWithType:TokenTypeDOWN];
	STAssertNotNil(found, @"Child with type DOWN should not be nil");
    if (found != nil) {
        STAssertNotNil(found.token, @"Child token with type DOWN should not be nil");
        if (found.token != nil)
            STAssertEquals((NSInteger)found.token.type, (NSInteger)TokenTypeDOWN, @"Token type was not correct, should be down!");
    }
	found = (CommonTree *)[parent getFirstChildWithType:TokenTypeUP];
	STAssertNotNil(found, @"Child with type UP should not be nil");
    if (found != nil) {
        STAssertNotNil(found.token, @"Child token with type UP should not be nil");
        if (found.token != nil)
            STAssertEquals((NSInteger)found.token.type, (NSInteger)TokenTypeUP, @"Token type was not correct, should be up!");
    }
	//[parent release];
    return;
}

-(void) test18SanityCheckParentAndChildIndexesForParentTree
{
	// Child tree
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	CommonToken *token = [CommonToken newToken:stream Type:555 Channel:TokenChannelDefault Start:4 Stop:5];
	CommonTree *tree = [CommonTree newTreeWithToken:token];
	
	CommonTree *parent = [CommonTree newTreeWithTokenType:555];
	STAssertNotNil(tree, @"tree should not be nil");
	@try 
	{
		[tree sanityCheckParentAndChildIndexes];
	}
	@catch (NSException * e) 
	{
		STFail(@"Exception was thrown and this is not what's right...");
	}
	
	BOOL passed = NO;
	@try 
	{
		[tree sanityCheckParentAndChildIndexes:parent At:0];
	}
	@catch (NSException * e) 
	{
		STAssertTrue([[e name] isEqualToString:@"IllegalStateException"], @"Exception was not an IllegalStateException but was %@", [e name]);
		passed = YES;
	}
	if (!passed)
	{
		STFail(@"An exception should have been thrown");
	}
	
	STAssertNotNil(parent, @"parent should not be nil");
	[parent addChild:tree];
	@try 
	{
		[tree sanityCheckParentAndChildIndexes:parent At:0];
	}
	@catch (NSException * e) 
	{
		STFail(@"No exception should have been thrown!");
	}
    return;
}

-(void) test19DeleteChild
{
	// Child tree
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	CommonToken *token = [CommonToken newToken:stream Type:555 Channel:TokenChannelDefault Start:4 Stop:5];
	CommonTree *tree = [CommonTree newTreeWithToken:token];
	
	CommonTree *parent = [CommonTree newTree];
	[parent addChild:tree];
	
	CommonTree *deletedChild = [parent deleteChild:0];
	STAssertEquals(deletedChild, tree, @"Children do not match!");
	STAssertEquals((NSInteger)[parent getChildCount], (NSInteger)0, @"Child count should be zero!");
    return;
}

-(void) test20TreeDescriptions
{
	// Child tree
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	CommonToken *token = [CommonToken newToken:stream Type:555 Channel:TokenChannelDefault Start:4 Stop:5];
	CommonTree *tree = [CommonTree newTreeWithToken:token];
	
	// Description for tree
	NSString *treeDesc = [tree treeDescription];
    STAssertNotNil(treeDesc, @"Tree description should not be nil");
    STAssertTrue([treeDesc isEqualToString:@"||"], @"Tree description was not || but rather %@", treeDesc);
	
	CommonTree *parent = [CommonTree newTree];
	STAssertTrue([[parent treeDescription] isEqualToString:@"nil"], @"Tree description was not nil was %@", [parent treeDescription]);
	[parent addChild:tree];
	treeDesc = [parent treeDescription];
	STAssertTrue([treeDesc isEqualToString:@"||"], @"Tree description was not || but was: %@", treeDesc);
	
	// Test non empty parent
	CommonTree *down = [CommonTree newTreeWithTokenType:TokenTypeDOWN];
	down.token.text = @"<DOWN>";
	
	[tree addChild:down];
	treeDesc = [parent treeDescription];
	STAssertTrue([treeDesc isEqualToString:@"(|| <DOWN>)"], @"Tree description was wrong expected (|| <DOWN>) but got: %@", treeDesc);
    return;
}

-(void) test21ReplaceChildrenAtIndexWithNoChildren
{
	CommonTree *parent = [CommonTree newTree];
	CommonTree *parent2 = [CommonTree newTree];
	CommonTree *child = [CommonTree newTreeWithTokenType:TokenTypeDOWN];
	child.token.text = @"<DOWN>";
	[parent2 addChild:child];
	@try 
	{
		[parent replaceChildrenFrom:1 To:2 With:parent2];
	}
	@catch (NSException *ex)
	{
		STAssertTrue([[ex name] isEqualToString:@"IllegalArgumentException"], @"Expected an illegal argument exception... Got instead: %@", [ex name]);
		return;
	}
	STFail(@"Exception was not thrown when I tried to replace a child on a parent with no children");
    return;
}

-(void) test22ReplaceChildrenAtIndex
{
	CommonTree *parent1 = [CommonTree newTree];
	CommonTree *child1 = [CommonTree newTreeWithTokenType:TokenTypeUP];
	[parent1 addChild:child1];
	CommonTree *parent2 = [CommonTree newTree];
	CommonTree *child2 = [CommonTree newTreeWithTokenType:TokenTypeDOWN];
	child2.token.text = @"<DOWN>";
	[parent2 addChild:child2];
	
	[parent2 replaceChildrenFrom:0 To:0 With:parent1];
	
	STAssertEquals([parent2 getChild:0], child1, @"Child for parent 2 should have been from parent 1");
    return;
}

-(void) test23ReplaceChildrenAtIndexWithChild
{
	CommonTree *replacement = [CommonTree newTreeWithTokenType:TokenTypeUP];
	replacement.token.text = @"<UP>";
	CommonTree *parent = [CommonTree newTree];
	CommonTree *child = [CommonTree newTreeWithTokenType:TokenTypeDOWN];
	child.token.text = @"<DOWN>";
	[parent addChild:child];
	
	[parent replaceChildrenFrom:0 To:0 With:replacement];
	
	STAssertTrue([parent getChild:0] == replacement, @"Children do not match");
    return;
}

-(void) test24ReplacechildrenAtIndexWithLessChildren
{
	CommonTree *parent1 = [CommonTree newTree];
	CommonTree *child1 = [CommonTree newTreeWithTokenType:TokenTypeUP];
	[parent1 addChild:child1];
	
	CommonTree *parent2 = [CommonTree newTree];
	
	CommonTree *child2 = [CommonTree newTreeWithTokenType:TokenTypeEOF];
	[parent2 addChild:child2];
	
	CommonTree *child3 = [CommonTree newTreeWithTokenType:TokenTypeDOWN];
	child2.token.text = @"<DOWN>";
	[parent2 addChild:child3];
	
	[parent2 replaceChildrenFrom:0 To:1 With:parent1];
	STAssertEquals((NSInteger)[parent2 getChildCount], (NSInteger)1, @"Should have one child but has %d", [parent2 getChildCount]);
	STAssertEquals([parent2 getChild:0], child1, @"Child for parent 2 should have been from parent 1");
    return;
}

-(void) test25ReplacechildrenAtIndexWithMoreChildren
{
	CommonTree *parent1 = [CommonTree newTree];
	CommonTree *child1 = [CommonTree newTreeWithTokenType:TokenTypeUP];
	[parent1 addChild:child1];
	CommonTree *child2 = [CommonTree newTreeWithTokenType:TokenTypeEOF];
	[parent1 addChild:child2];
	
	CommonTree *parent2 = [CommonTree newTree];
	
	CommonTree *child3 = [CommonTree newTreeWithTokenType:TokenTypeDOWN];
	child2.token.text = @"<DOWN>";
	[parent2 addChild:child3];
	
	[parent2 replaceChildrenFrom:0 To:0 With:parent1];
	STAssertEquals((NSInteger)[parent2 getChildCount], (NSInteger)2, @"Should have one child but has %d", [parent2 getChildCount]);
	STAssertEquals([parent2 getChild:0], child1, @"Child for parent 2 should have been from parent 1");
	STAssertEquals([parent2 getChild:1], child2, @"An extra child (child2) should be in the children collection");
    return;
}

@end
