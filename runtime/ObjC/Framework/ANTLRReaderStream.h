//
//  AntlrReaderStream.h
//  ANTLR
//
//  Created by Alan Condit on 2/21/11.
//  Copyright 2011 Alan's MachineWorks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANTLRStringStream.h"

@interface ANTLRReaderStream : ANTLRStringStream {
    NSFileHandle *fh;
    NSInteger size;
    NSInteger rbSize;
    //NSData *data; /* ANTLRStringStream has NSString *data */
}

@property (retain) NSFileHandle *fh;
@property (assign) NSInteger size;
@property (assign) NSInteger rbSize;
//@property (retain) NSData *data;

+ (NSInteger) READ_BUFFER_SIZE;
+ (NSInteger) INITIAL_BUFFER_SIZE;

+ (id) newANTLRReaderStream;
+ (id) newANTLRReaderStream:(NSFileHandle *)r;
+ (id) newANTLRReaderStream:(NSFileHandle *)r size:(NSInteger)aSize;
+ (id) newANTLRReaderStream:(NSFileHandle *)r size:(NSInteger)aSize readBufferSize:(NSInteger)aReadChunkSize;
- (id) initWithReader:(NSFileHandle *)r size:(NSInteger)aSize readBufferSize:(NSInteger)aReadChunkSize;
- (void) load:(NSInteger)aSize readBufferSize:(NSInteger)aReadChunkSize;
- (void) close;

@end
