//
//  ANTLRInputStream.h
//  ANTLR
//
//  Created by Alan Condit on 2/21/11.
//  Copyright 2011 Alan's MachineWorks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AntlrReaderStream.h"

@interface ANTLRInputStream : ANTLRReaderStream {
    NSStringEncoding encoding;
}

@property (assign) NSStringEncoding encoding;

+ (id) newANTLRInputStream;
+ (id) newANTLRInputStream:(NSFileHandle *)anInput;
+ (id) newANTLRInputStream:(NSFileHandle *)anInput size:(NSInteger)theSize;
+ (id) newANTLRInputStream:(NSFileHandle *)anInput encoding:(NSStringEncoding)theEncoding;
+ (id) newANTLRInputStream:(NSFileHandle *)anInput
                      size:(NSInteger)theSize
            readBufferSize:(NSInteger)theRBSize
                  encoding:(NSStringEncoding)theEncoding;
- (id) init;
- (id) initWithInput:(NSFileHandle *)anInput
                size:(NSInteger)theSize
      readBufferSize:(NSInteger)theRBSize
            encoding:(NSStringEncoding)theEncoding;
@end
