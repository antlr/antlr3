//
//  ANTLRInputStream.h
//  ANTLR
//
//  Created by Alan Condit on 2/21/11.
//  Copyright 2011 Alan's MachineWorks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AntlrReaderStream.h"

@interface ANTLRInputStream : ANTLRReaderStream {
    NSStringEncoding encoding;
}

@property (assign) NSStringEncoding encoding;

+ (id) newANTLRInputStream;
+ (id) newANTLRInputStream:(NSInputStream *)anInput;
+ (id) newANTLRInputStream:(NSInputStream *)anInput size:(NSInteger)theSize;
+ (id) newANTLRInputStream:(NSInputStream *)anInput encoding:(NSStringEncoding)theEncoding;
+ (id) newANTLRInputStream:(NSInputStream *)anInput
                      size:(NSInteger)theSize
            readBufferSize:(NSInteger)theRBSize
                  encoding:(NSStringEncoding)theEncoding;
- (id) init;
- (id) initWithInput:(NSInputStream *)anInput
                size:(NSInteger)theSize
      readBufferSize:(NSInteger)theRBSize
            encoding:(NSStringEncoding)theEncoding;
@end
