//
//  TestDictionary.m
//  ST4
//
//  Created by Alan Condit on 4/20/11.
//  Copyright 2011 Alan Condit. All rights reserved.
//

#import "TestDictionary.h"
#import "AMutableDictionary.h"

@implementation TestDictionary

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void) test01add
{
    AMutableDictionary *testDict;
    NSString *key1 = @"a101";
    NSString *obj1 = @"obj101";
    
    testDict = [AMutableDictionary newDictionary];
    [testDict setObject:obj1 forKey:key1];
    NSString *expected = obj1;
    NSString *result = [testDict objectForKey:key1];
    STAssertTrue( [expected isEqualTo:result], @"Expected \"%@\" but got \"%@\"", expected, result );
}

- (void) test02add
{
    AMutableDictionary *testDict;
    NSString *key1 = @"a101";
    NSString *obj1 = @"obj101";
    NSString *key2 = @"a102";
    NSString *obj2 = @"obj102";
    
    testDict = [AMutableDictionary newDictionary];
    [testDict setObject:obj1 forKey:key1];
    [testDict setObject:obj2 forKey:key2];
    NSString *expected = obj1;
    NSString *result = [testDict objectForKey:key1];
    STAssertTrue( [expected isEqualTo:result], @"Expected \"%@\" but got \"%@\"", expected, result );
}

- (void) test03add
{
    AMutableDictionary *testDict;
    NSString *key1 = @"a101";
    NSString *obj1 = @"obj101";
    
    testDict = [AMutableDictionary newDictionary];
    [testDict setObject:obj1 forKey:key1];
    [testDict setObject:@"obj102"  forKey:@"a102"];
    [testDict setObject:@"obj103"  forKey:@"a103"];
    [testDict setObject:@"obj104"  forKey:@"a104"];
    [testDict setObject:@"obj105"  forKey:@"a105"];
    [testDict setObject:@"obj106"  forKey:@"a106"];
    [testDict setObject:@"obj107"  forKey:@"a107"];
    [testDict setObject:@"obj108"  forKey:@"a108"];
    [testDict setObject:@"obj109"  forKey:@"a109"];
    [testDict setObject:@"obj110" forKey:@"a110"];
    [testDict setObject:@"obj111" forKey:@"a111"];
    [testDict setObject:@"obj112" forKey:@"a112"];
    NSString *expected = @"obj106";
    NSString *result = [testDict objectForKey:@"a106"];
    STAssertTrue( [expected isEqualTo:result], @"Expected \"%@\" but got \"%@\"", expected, result );
}

- (void) test04removefromLo
{
    AMutableDictionary *testDict;
    NSString *key1 = @"a101";
    NSString *obj1 = @"obj101";
    
    testDict = [AMutableDictionary newDictionary];
    [testDict setObject:obj1 forKey:key1];
    [testDict setObject:@"obj107" forKey:@"a107"];
    [testDict setObject:@"obj108" forKey:@"a108"];
    [testDict setObject:@"obj109" forKey:@"a109"];
    [testDict setObject:@"obj110" forKey:@"a110"];
    [testDict setObject:@"obj111" forKey:@"a111"];
    [testDict setObject:@"obj112" forKey:@"a112"];
    [testDict setObject:@"obj102" forKey:@"a102"];
    [testDict setObject:@"obj103" forKey:@"a103"];
    [testDict setObject:@"obj104" forKey:@"a104"];
    [testDict setObject:@"obj105" forKey:@"a105"];
    [testDict setObject:@"obj106" forKey:@"a106"];
    NSString *expected = @"obj105";
    NSString *result = [testDict objectForKey:@"a105"];
    STAssertTrue( [expected isEqualTo:result], @"Expected \"%@\" but got \"%@\"", expected, result );
    [testDict removeObjectForKey:@"a104"];
    result = [testDict objectForKey:@"a106"];
    expected = @"obj106";
    STAssertTrue( [expected isEqualTo:result], @"Expected \"%@\" but got \"%@\"", expected, result );
}

- (void) test05removefromHi
{
    AMutableDictionary *testDict;
    NSString *key1 = @"a101";
    NSString *obj1 = @"obj101";
    
    testDict = [AMutableDictionary newDictionary];
    [testDict setObject:obj1 forKey:key1];
    [testDict setObject:@"obj107" forKey:@"a107"];
    [testDict setObject:@"obj108" forKey:@"a108"];
    [testDict setObject:@"obj109" forKey:@"a109"];
    [testDict setObject:@"obj110" forKey:@"a110"];
    [testDict setObject:@"obj111" forKey:@"a111"];
    [testDict setObject:@"obj112" forKey:@"a112"];
    [testDict setObject:@"obj102" forKey:@"a102"];
    [testDict setObject:@"obj103" forKey:@"a103"];
    [testDict setObject:@"obj104" forKey:@"a104"];
    [testDict setObject:@"obj105" forKey:@"a105"];
    [testDict setObject:@"obj106" forKey:@"a106"];
    NSString *expected = @"obj105";
    NSString *result = [testDict objectForKey:@"a105"];
    STAssertTrue( [expected isEqualTo:result], @"Expected \"%@\" but got \"%@\"", expected, result );
    [testDict removeObjectForKey:@"a108"];
    result = [testDict objectForKey:@"a110"];
    expected = @"obj110";
    STAssertTrue( [expected isEqualTo:result], @"Expected \"%@\" but got \"%@\"", expected, result );
}

@end
