//
//  ACNumber.m
//  ST4
//
//  Created by Alan Condit on 3/19/12.
//  Copyright 2012 Alan Condit. All rights reserved.
//

#import "ACNumber.h"


@implementation ACNumber

+ (ACNumber *)numberWithBool:(BOOL)aBool
{
    return [[ACNumber alloc] initWithBool:aBool];
}

+ (ACNumber *)numberWithChar:(char)aChar
{
    return [[ACNumber alloc] initWithChar:aChar];
}

+ (ACNumber *)numberWithDouble:(double)aDouble
{
    return [[ACNumber alloc] initWithDouble:aDouble];
}

+ (ACNumber *)numberWithInt:(NSInteger)anInt
{
    return [[ACNumber alloc] initWithInteger:anInt];
}

+ (ACNumber *)numberWithInteger:(NSInteger)anInt
{
    return [[ACNumber alloc] initWithInteger:anInt];
}


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (ACNumber *)initWithBool:(BOOL)aBool
{
    self = [super init];
    if ( self != nil ) {
        fBOOL = YES;
        fChar = NO;
        fDouble = NO;
        fNSInt = NO;
        u.b = aBool;
    }
    return self;
}

- (ACNumber *)initWithChar:(char)aChar
{
    self = [super init];
    if ( self != nil ) {
        fBOOL = NO;
        fChar = YES;
        fDouble = NO;
        fNSInt = NO;
        u.c = aChar;
    }
    return self;
}

- (ACNumber *)initWithDouble:(double)aDouble
{
    self = [super init];
    if ( self != nil ) {
        fBOOL = NO;
        fChar = NO;
        fDouble = YES;
        fNSInt = NO;
        u.d = aDouble;
    }
    return self;
}

- (ACNumber *)initWithInteger:(NSInteger)anInt
{
    self = [super init];
    if ( self != nil ) {
        fBOOL = NO;
        fChar = NO;
        fDouble = NO;
        fNSInt = YES;
        u.i = anInt;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (BOOL)boolValue
{
    if (fBOOL)
        return u.b;
    else
        return NO;
}

- (char)charValue
{
    if (fChar)
        return u.c;
    else
        return (char)-1;
}

- (double)doubleValue
{
    if (fDouble)
        return u.d;
    else
        return 0.0;
}

- (NSInteger)intValue
{
    if (fNSInt)
        return u.i;
    else
        return -1;
}

- (NSInteger)integerValue
{
    if (fNSInt)
        return u.i;
    else
        return -1;
}

- (NSInteger)inc
{
    return (u.i+=1);
}

- (NSInteger)add:(NSInteger)anInt
{
    return (u.i+=anInt);
}

- (NSString *)description
{
    if (fBOOL)
        return (u.b == YES) ? @"true" : @"false"; 
    else if (fChar)
        return [NSString stringWithFormat:@"%c", u.c];
    else if (fNSInt)
        return [NSString stringWithFormat:@"%Ld", u.i];
    else if (fDouble)
        return [NSString stringWithFormat:@"%Lf", u.d];
    return @"ACNumber not valid";
}

@end
