//
//  ACNumber.h
//  ST4
//
//  Created by Alan Condit on 3/19/12.
//  Copyright 2012 Alan Condit. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ACNumber : NSObject {
    
    union {
        BOOL b;
        char c;
        double d;
        NSInteger i;
    } u;
    
    BOOL fBOOL   :  1;
    BOOL fChar   :  1;
    BOOL fDouble :  1;
    BOOL fNSInt  :  1;
}

+ (ACNumber *)numberWithBool:(BOOL)aBool;
+ (ACNumber *)numberWithChar:(char)aChar;
+ (ACNumber *)numberWithDouble:(double)aDouble;
+ (ACNumber *)numberWithInt:(NSInteger)anInt;
+ (ACNumber *)numberWithInteger:(NSInteger)anInt;

- (ACNumber *)initWithBool:(BOOL)aBool;
- (ACNumber *)initWithChar:(char)aChar;
- (ACNumber *)initWithDouble:(double)aDouble;
- (ACNumber *)initWithInteger:(NSInteger)anInt;

- (BOOL)boolValue;
- (char)charValue;
- (double)doubleValue;
- (NSInteger)intValue;
- (NSInteger)integerValue;
- (NSInteger)inc;
- (NSInteger)add:(NSInteger)anInt;
- (NSString *)description;

@end
