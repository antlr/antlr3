//
//  PtrStack.h
//  ANTLR
//
//  Created by Alan Condit on 6/9/10.
//  Copyright 2010 Alan's MachineWorks. All rights reserved.
//ptrBuffer

#import <Foundation/Foundation.h>
#import "ACNumber.h"
#import "BaseStack.h"
#import "RuleMemo.h"

//#define GLOBAL_SCOPE       0
//#define LOCAL_SCOPE        1
#define HASHSIZE         101
#define HBUFSIZE      0x2000

@interface PtrStack : BaseStack {
	//PtrStack *fNext;
    // TStringPool *fPool;
}

//@property (copy) PtrStack *fNext;
//@property (copy) TStringPool *fPool;

// Contruction/Destruction
+ (PtrStack *)newPtrStack;
+ (PtrStack *)newPtrStack:(NSInteger)cnt;
- (id)init;
- (id)initWithLen:(NSInteger)aLen;
- (void)dealloc;

// Instance Methods
- (id) copyWithZone:(NSZone *)aZone;
/* clear -- reinitialize the maplist array */

#ifdef DONTUSENOMO
/* form hash value for string s */
- (NSInteger)hash:(NSString *)s;
/*   look for s in ptrBuffer  */
- (id)lookup:(NSString *)s;
/* look for s in ptrBuffer  */
- (id)install:(id)sym;
#endif

#ifdef DONTUSENOMO
- (id)getTType:(NSString *)name;
- (id)getName:(NSInteger)ttype;
#endif

@end
