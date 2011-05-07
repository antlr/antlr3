//
//  ANTLRCommonTreeTest.m
//  ANTLR
//
//  Created by Ian Michell on 26/05/2010.
//  Copyright 2010 Ian Michell. All rights reserved.
//

#import "ANTLRBaseTree.h"
#import "ANTLRCommonTreeTest.h"
#import "ANTLRStringStream.h"
#import "ANTLRCommonTree.h"
#import "ANTLRCommonToken.h"
#import "ANTLRError.h"
#import "ANTLRRuntimeException.h"

@implementation ANTLRCommonTreeTest

-(void) test01InitAndRelease
{
	ANTLRCommonTree *tree = [ANTLRCommonTree newTree];
	STAssertNotNil(tree, @"Tree was nil");
	// FIXME: It doesn't do anything else, perhaps initWithTree should set something somewhere, java says no though...
    return;
}

-(void) test02InitWithTree
{
	ANTLRCommonTree *tree = [ANTLRCommonTree newTree];
	STAssertNotNil(tree, @"Tree was nil");
    if (tree != nil)
        STAssertEquals([tree getType], (NSInteger)ANTLRTokenTypeInvalid, @"Tree should have an invalid token type, because it has no token");
    // [tree release];
    return;
}

-(void) test03WithToken
{
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	ANTLRCommonToken *token = [ANTLRCommonToken newToken:stream Type:555 Channel:ANTLRTokenChannelDefault Start:4 Stop:5];
	token.line = 1;
	token.charPositionInLine = 4;
	ANTLRCommonTree *tree = [ANTLRCommonTree newTreeWithToken:token];
	STAssertNotNil(tree, @"Tree was nil");
    if (tree != nil)
        STAssertNotNil(tree.token, @"Tree with token was nil");
    if (tree != nil && tree.token != nil) {
        STAssertEquals((NSUInteger) tree.token.line, (NSUInteger)1, [NSString stringWithFormat:@"Tree should be at line 1, but was at %d", tree.token.line] );
        STAssertEquals((NSUInteger) tree.token.charPositionInLine, (NSUInteger)4, [NSString stringWithFormat:@"Char position should be 1, but was at %d", tree.token.charPositionInLine]);
        STAssertNotNil(((ANTLRCommonToken *)tree.token).text, @"Tree with token with text was nil");
    }
    if (tree != nil && tree.token != nil && tree.token.text != nil)
        STAssertTrue([tree.token.text isEqualToString:@"||"], @"Text was not ||");
	//[tree release];
    return;
}

-(void) test04InvalidTreeNode
{
	ANTLRCommonTree *tree = [ANTLRCommonTree newTreeWithToken:[ANTLRCommonToken invalidToken]];
	STAssertNotNil(tree, @"Tree was nil");
	STAssertEquals(tree.token.type, (NSInteger)ANTLRTokenTypeInvalid, @"Tree Token type was not ANTLRTokenTypeInvalid");
	//[tree release];
    return;
}

-(void) test05InitWithCommonTreeNode
{
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	ANTLRCommonToken *token = [ANTLRCommonToken newToken:stream Type:555 Channel:ANTLRTokenChannelDefault Start:4 Stop:5];
	ANTLRCommonTree *tree = [ANTLRCommonTree newTreeWithToken:token];
	STAssertNotNil(tree, @"Tree was nil");
	STAssertNotNil(tree.token, @"Tree token was nil");
	ANTLRCommonTree *newTree = [ANTLRCommonTree newTreeWithTree:tree];
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
	ANTLRCommonToken *token = [ANTLRCommonToken newToken:stream Type:555 Channel:ANTLRTokenChannelDefault Start:4 Stop:5];
	ANTLRCommonTree *tree = [ANTLRCommonTree newTreeWithToken:token];
	STAssertNotNil(tree, @"Tree was nil");
	ANTLRCommonTree *newTree = (ANTLRCommonTree *)[tree copyWithZone:nil];
	STAssertTrue([newTree isKindOfClass:[ANTLRCommonTree class]], @"Copied tree was not an ANTLRCommonTree");
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
	ANTLRCommonTree *errorTree = [ANTLRCommonTree invalidNode];
	STAssertNotNil(errorTree, @"Error tree node is nil");
    if (errorTree != nil) {
        aString = [errorTree description];
        STAssertNotNil( aString, @"errorTree description returned nil");
        if (aString != nil)
            STAssertTrue([aString isEqualToString:@"<errornode>"], @"Not a valid error node description %@", aString);
    }
	//[errorTree release];
	
	ANTLRCommonTree *tree = [ANTLRCommonTree newTreeWithTokenType:ANTLRTokenTypeUP];
	STAssertNotNil(tree, @"Tree is nil");
    if (tree != nil)
        STAssertNil([tree description], @"Tree description was not nil, was: %@", [tree description]);
	//[tree release];
	
	tree = [ANTLRCommonTree newTree];
	STAssertNotNil(tree, @"Tree is nil");
    if (tree != nil) {
        aString = [tree description];
        STAssertNotNil(aString, @"tree description returned nil");
        if (aString != nil)
            STAssertTrue([aString isEqualToString:@"nil"], @"Tree description was not empty", [tree description]);
    }
	//[tree release];
	
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	ANTLRCommonToken *token = [ANTLRCommonToken newToken:stream Type:555 Channel:ANTLRTokenChannelDefault Start:4 Stop:5];
	tree = [ANTLRCommonTree newTreeWithToken:token];
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
	ANTLRCommonToken *token = [ANTLRCommonToken newToken:stream Type:555 Channel:ANTLRTokenChannelDefault Start:4 Stop:5];
	ANTLRCommonTree *tree = [ANTLRCommonTree newTreeWithToken:token];
	STAssertNotNil(tree, @"Tree was nil");
	STAssertTrue([tree.token.text isEqualToString:@"||"], @"Tree text was not valid, should have been || was %@", tree.token.text);
	//[tree release];
	
	// test nil (for line coverage)
	tree = [ANTLRCommonTree newTree];
	STAssertNotNil(tree, @"Tree was nil");
	STAssertNil(tree.token.text, @"Tree text was not nil: %@", tree.token.text);
    return;
}

-(void) test09AddChild
{
	// Create a new tree
	ANTLRCommonTree *parent = [ANTLRCommonTree newTreeWithTokenType:555];
    parent.token.line = 1;
	parent.token.charPositionInLine = 1;
	
	// Child tree
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	ANTLRCommonToken *token = [ANTLRCommonToken newToken:stream Type:555 Channel:ANTLRTokenChannelDefault Start:4 Stop:5];
	token.line = 1;
	token.charPositionInLine = 4;
	ANTLRCommonTree *tree = [ANTLRCommonTree newTreeWithToken:token];
	
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
	ANTLRCommonTree *parent = [ANTLRCommonTree newTree];
	
	// Child tree
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	ANTLRCommonToken *token = [ANTLRCommonToken newToken:stream Type:555 Channel:ANTLRTokenChannelDefault Start:4 Stop:5];
	token.line = 1;
	token.charPositionInLine = 4;
	ANTLRCommonTree *tree = [ANTLRCommonTree newTreeWithToken:token];
	
	// Add a child to the parent tree
	[parent addChild: tree];
	
	ANTLRCommonTree *newParent = [ANTLRCommonTree newTree];
	[newParent addChildren:parent.children];
	
	STAssertEquals([newParent getChild:0], [parent getChild:0], @"Children did not match");
    return;
}

-(void) test11AddSelfAsChild
{
	ANTLRCommonTree *parent = [ANTLRCommonTree newTree];
	@try 
	{
		[parent addChild:parent];
	}
	@catch (NSException *e) 
	{
		STAssertTrue([[e name] isEqualToString:@"ANTLRIllegalArgumentException"], @"Got wrong kind of exception! %@", [e name]);
		//[parent release];
		return;
	}
	STFail(@"Did not get an exception when adding an empty child!");
    return;
}

-(void) test12AddEmptyChildWithNoChildren
{
	ANTLRCommonTree *emptyChild = [ANTLRCommonTree newTree];
	ANTLRCommonTree *parent = [ANTLRCommonTree newTree];
	[parent addChild:emptyChild];
	STAssertEquals((NSInteger)[parent getChildCount], (NSInteger)0, @"There were supposed to be no children!");
	//[parent release];
	//[emptyChild release];
    return;
}

-(void) test13AddEmptyChildWithChildren
{
	// Create a new tree
	ANTLRCommonTree *parent = [ANTLRCommonTree newTree];
	
	// Child tree
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	ANTLRCommonToken *token = [ANTLRCommonToken newToken:stream Type:555 Channel:ANTLRTokenChannelDefault Start:4 Stop:5];
	token.line = 1;
	token.charPositionInLine = 4;
	ANTLRCommonTree *tree = [ANTLRCommonTree newTreeWithToken:token];
	
	// Add a child to the parent tree
	[parent addChild: tree];
	
	ANTLRCommonTree *newParent = [ANTLRCommonTree newTree];
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
	ANTLRCommonTree *parent = [ANTLRCommonTree newTree];
	
	// Child tree
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	ANTLRCommonToken *token = [ANTLRCommonToken newToken:stream Type:555 Channel:ANTLRTokenChannelDefault Start:4 Stop:5];
	ANTLRCommonTree *tree = [ANTLRCommonTree newTreeWithToken:token];
	
	// Add a child to the parent tree
	[parent addChild: tree];
	
	STAssertEquals((NSInteger)[parent getChildCount], (NSInteger)1, @"There were either no children or more than 1: %d", [parent getChildCount]);
	
	ANTLRCommonTree *child = [parent getChild:0];
	STAssertNotNil(child, @"Child at index 0 should not be nil");
	STAssertEquals(child, tree, @"Child and Original tree were not the same");
	//[parent release];
    return;
}

-(void) test15SetChildAtIndex
{
	ANTLRCommonTree *parent = [ANTLRCommonTree newTree];
	
	// Child tree
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	ANTLRCommonToken *token = [ANTLRCommonToken newToken:stream Type:555 Channel:ANTLRTokenChannelDefault Start:4 Stop:5];
	ANTLRCommonTree *tree = [ANTLRCommonTree newTreeWithToken:token];
	
	
	tree = [ANTLRCommonTree newTreeWithTokenType:ANTLRTokenTypeUP];
	tree.token.text = @"<UP>";
	[parent addChild:tree];
	
	STAssertTrue([parent getChild:0] == tree, @"Trees don't match");
	[parent setChild:0 With:tree];
	
	ANTLRCommonTree *child = [parent getChild:0];
	STAssertTrue([parent getChildCount] == 1, @"There were either no children or more than 1: %d", [parent getChildCount]);
	STAssertNotNil(child, @"Child at index 0 should not be nil");
	STAssertEquals(child, tree, @"Child and Original tree were not the same");
	//[parent release];
    return;
}

-(void) test16GetAncestor
{
	ANTLRCommonTree *parent = [ANTLRCommonTree newTreeWithTokenType:ANTLRTokenTypeUP];
	parent.token.text = @"<UP>";
	
	ANTLRCommonTree *down = [ANTLRCommonTree newTreeWithTokenType:ANTLRTokenTypeDOWN];
	down.token.text = @"<DOWN>";
	
	[parent addChild:down];
	
	// Child tree
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	ANTLRCommonToken *token = [ANTLRCommonToken newToken:stream Type:555 Channel:ANTLRTokenChannelDefault Start:4 Stop:5];
	ANTLRCommonTree *tree = [ANTLRCommonTree newTreeWithToken:token];
	
	[down addChild:tree];
	STAssertTrue([tree hasAncestor:ANTLRTokenTypeUP], @"Should have an ancestor of type ANTLRTokenTypeUP");
	
	ANTLRCommonTree *ancestor = [tree getAncestor:ANTLRTokenTypeUP];
	STAssertNotNil(ancestor, @"Ancestor should not be nil");
	STAssertEquals(ancestor, parent, @"Acenstors do not match");
	//[parent release];
    return;
}

-(void) test17FirstChildWithType
{
	// Create a new tree
	ANTLRCommonTree *parent = [ANTLRCommonTree newTree];
	
	ANTLRCommonTree *up = [ANTLRCommonTree newTreeWithTokenType:ANTLRTokenTypeUP];
	ANTLRCommonTree *down = [ANTLRCommonTree newTreeWithTokenType:ANTLRTokenTypeDOWN];
	
	[parent addChild:up];
	[parent addChild:down];
	
	ANTLRCommonTree *found = (ANTLRCommonTree *)[parent getFirstChildWithType:ANTLRTokenTypeDOWN];
	STAssertNotNil(found, @"Child with type DOWN should not be nil");
    if (found != nil) {
        STAssertNotNil(found.token, @"Child token with type DOWN should not be nil");
        if (found.token != nil)
            STAssertEquals((NSInteger)found.token.type, (NSInteger)ANTLRTokenTypeDOWN, @"Token type was not correct, should be down!");
    }
	found = (ANTLRCommonTree *)[parent getFirstChildWithType:ANTLRTokenTypeUP];
	STAssertNotNil(found, @"Child with type UP should not be nil");
    if (found != nil) {
        STAssertNotNil(found.token, @"Child token with type UP should not be nil");
        if (found.token != nil)
            STAssertEquals((NSInteger)found.token.type, (NSInteger)ANTLRTokenTypeUP, @"Token type was not correct, should be up!");
    }
	//[parent release];
    return;
}

-(void) test18SanityCheckParentAndChildIndexesForParentTree
{
	// Child tree
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	ANTLRCommonToken *token = [ANTLRCommonToken newToken:stream Type:555 Channel:ANTLRTokenChannelDefault Start:4 Stop:5];
	ANTLRCommonTree *tree = [ANTLRCommonTree newTreeWithToken:token];
	
	ANTLRCommonTree *parent = [ANTLRCommonTree newTreeWithTokenType:555];
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
		STAssertTrue([[e name] isEqualToString:@"ANTLRIllegalStateException"], @"Exception was not an ANTLRIllegalStateException but was %@", [e name]);
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
	ANTLRCommonToken *token = [ANTLRCommonToken newToken:stream Type:555 Channel:ANTLRTokenChannelDefault Start:4 Stop:5];
	ANTLRCommonTree *tree = [ANTLRCommonTree newTreeWithToken:token];
	
	ANTLRCommonTree *parent = [ANTLRCommonTree newTree];
	[parent addChild:tree];
	
	ANTLRCommonTree *deletedChild = [parent deleteChild:0];
	STAssertEquals(deletedChild, tree, @"Children do not match!");
	STAssertEquals((NSInteger)[parent getChildCount], (NSInteger)0, @"Child count should be zero!");
    return;
}

-(void) test20TreeDescriptions
{
	// Child tree
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"this||is||a||double||piped||separated||csv"];
	ANTLRCommonToken *token = [ANTLRCommonToken newToken:stream Type:555 Channel:ANTLRTokenChannelDefault Start:4 Stop:5];
	ANTLRCommonTree *tree = [ANTLRCommonTree newTreeWithToken:token];
	
	// Description for tree
	NSString *treeDesc = [tree treeDescription];
    STAssertNotNil(treeDesc, @"Tree description should not be nil");
    STAssertTrue([treeDesc isEqualToString:@"||"], @"Tree description was not || but rather %@", treeDesc);
	
	ANTLRCommonTree *parent = [ANTLRCommonTree newTree];
	STAssertTrue([[parent treeDescription] isEqualToString:@"nil"], @"Tree description was not nil was %@", [parent treeDescription]);
	[parent addChild:tree];
	treeDesc = [parent treeDescription];
	STAssertTrue([treeDesc isEqualToString:@"||"], @"Tree description was not || but was: %@", treeDesc);
	
	// Test non empty parent
	ANTLRCommonTree *down = [ANTLRCommonTree newTreeWithTokenType:ANTLRTokenTypeDOWN];
	down.token.text = @"<DOWN>";
	
	[tree addChild:down];
	treeDesc = [parent treeDescription];
	STAssertTrue([treeDesc isEqualToString:@"(|| <DOWN>)"], @"Tree description was wrong expected (|| <DOWN>) but got: %@", treeDesc);
    return;
}

-(void) test21ReplaceChildrenAtIndexWithNoChildren
{
	ANTLRCommonTree *parent = [ANTLRCommonTree newTree];
	ANTLRCommonTree *parent2 = [ANTLRCommonTree newTree];
	ANTLRCommonTree *child = [ANTLRCommonTree newTreeWithTokenType:ANTLRTokenTypeDOWN];
	child.token.text = @"<DOWN>";
	[parent2 addChild:child];
	@try 
	{
		[parent replaceChildrenFrom:1 To:2 With:parent2];
	}
	@catch (NSException *ex)
	{
		STAssertTrue([[ex name] isEqualToString:@"ANTLRIllegalArgumentException"], @"Expected an illegal argument exception... Got instead: %@", [ex name]);
		return;
	}
	STFail(@"Exception was not thrown when I tried to replace a child on a parent with no children");
    return;
}

-(void) test22ReplaceChildrenAtIndex
{
	ANTLRCommonTree *parent1 = [ANTLRCommonTree newTree];
	ANTLRCommonTree *child1 = [ANTLRCommonTree newTreeWithTokenType:ANTLRTokenTypeUP];
	[parent1 addChild:child1];
	ANTLRCommonTree *parent2 = [ANTLRCommonTree newTree];
	ANTLRCommonTree *child2 = [ANTLRCommonTree newTreeWithTokenType:ANTLRTokenTypeDOWN];
	child2.token.text = @"<DOWN>";
	[parent2 addChild:child2];
	
	[parent2 replaceChildrenFrom:0 To:0 With:parent1];
	
	STAssertEquals([parent2 getChild:0], child1, @"Child for parent 2 should have been from parent 1");
    return;
}

-(void) test23ReplaceChildrenAtIndexWithChild
{
	ANTLRCommonTree *replacement = [ANTLRCommonTree newTreeWithTokenType:ANTLRTokenTypeUP];
	replacement.token.text = @"<UP>";
	ANTLRCommonTree *parent = [ANTLRCommonTree newTree];
	ANTLRCommonTree *child = [ANTLRCommonTree newTreeWithTokenType:ANTLRTokenTypeDOWN];
	child.token.text = @"<DOWN>";
	[parent addChild:child];
	
	[parent replaceChildrenFrom:0 To:0 With:replacement];
	
	STAssertTrue([parent getChild:0] == replacement, @"Children do not match");
    return;
}

-(void) test24ReplacechildrenAtIndexWithLessChildren
{
	ANTLRCommonTree *parent1 = [ANTLRCommonTree newTree];
	ANTLRCommonTree *child1 = [ANTLRCommonTree newTreeWithTokenType:ANTLRTokenTypeUP];
	[parent1 addChild:child1];
	
	ANTLRCommonTree *parent2 = [ANTLRCommonTree newTree];
	
	ANTLRCommonTree *child2 = [ANTLRCommonTree newTreeWithTokenType:ANTLRTokenTypeEOF];
	[parent2 addChild:child2];
	
	ANTLRCommonTree *child3 = [ANTLRCommonTree newTreeWithTokenType:ANTLRTokenTypeDOWN];
	child2.token.text = @"<DOWN>";
	[parent2 addChild:child3];
	
	[parent2 replaceChildrenFrom:0 To:1 With:parent1];
	STAssertEquals((NSInteger)[parent2 getChildCount], (NSInteger)1, @"Should have one child but has %d", [parent2 getChildCount]);
	STAssertEquals([parent2 getChild:0], child1, @"Child for parent 2 should have been from parent 1");
    return;
}

-(void) test25ReplacechildrenAtIndexWithMoreChildren
{
	ANTLRCommonTree *parent1 = [ANTLRCommonTree newTree];
	ANTLRCommonTree *child1 = [ANTLRCommonTree newTreeWithTokenType:ANTLRTokenTypeUP];
	[parent1 addChild:child1];
	ANTLRCommonTree *child2 = [ANTLRCommonTree newTreeWithTokenType:ANTLRTokenTypeEOF];
	[parent1 addChild:child2];
	
	ANTLRCommonTree *parent2 = [ANTLRCommonTree newTree];
	
	ANTLRCommonTree *child3 = [ANTLRCommonTree newTreeWithTokenType:ANTLRTokenTypeDOWN];
	child2.token.text = @"<DOWN>";
	[parent2 addChild:child3];
	
	[parent2 replaceChildrenFrom:0 To:0 With:parent1];
	STAssertEquals((NSInteger)[parent2 getChildCount], (NSInteger)2, @"Should have one child but has %d", [parent2 getChildCount]);
	STAssertEquals([parent2 getChild:0], child1, @"Child for parent 2 should have been from parent 1");
	STAssertEquals([parent2 getChild:1], child2, @"An extra child (child2) should be in the children collection");
    return;
}

@end
