//
//  ANTLRCommonTreeTest.h
//  ANTLR
//
//  Created by Ian Michell on 26/05/2010.
//  Copyright 2010 Ian Michell and Alan Condit. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


@interface ANTLRCommonTreeTest : SenTestCase 
{
}

-(void) test01InitAndRelease;
-(void) test02InitWithTree;
-(void) test03WithToken;
-(void) test04InvalidTreeNode;
-(void) test05InitWithCommonTreeNode;
-(void) test06CopyTree;
-(void) test07Description;
-(void) test08Text;
-(void) test09AddChild;
-(void) test10AddChildren;
-(void) test11AddSelfAsChild;
-(void) test12AddEmptyChildWithNoChildren;
-(void) test13AddEmptyChildWithChildren;
-(void) test14ChildAtIndex;
-(void) test15SetChildAtIndex;
-(void) test16GetAncestor;
-(void) test17FirstChildWithType;
-(void) test18SanityCheckParentAndChildIndexesForParentTree;
-(void) test19DeleteChild;
-(void) test20TreeDescriptions;
-(void) test21ReplaceChildrenAtIndexWithNoChildren;
-(void) test22ReplaceChildrenAtIndex;
-(void) test23ReplaceChildrenAtIndexWithChild;
-(void) test24ReplacechildrenAtIndexWithLessChildren;
-(void) test25ReplacechildrenAtIndexWithMoreChildren;

@end
