//
//  ACBtree.h
//  ST4
//
//  Created by Alan Condit on 4/18/11.
//  Copyright 2011 Alan Condit. All rights reserved.
//

typedef enum {
    BTNODE,
    LEAF
} NodeType;

#import <Foundation/Foundation.h>

@class AMutableDictionary;

#define BTNODESIZE 11
#define BTHNODESIZE ((BTNODESIZE-1)/2)
#define BTKeySize  38
#define FAILURE -1
#define SUCCESS 0

@interface ACBKey : NSObject {
    NSInteger recnum;               /*  record number                   */
    __strong NSString *key;         /*  key pointer id                  */
    char      kstr[BTKeySize];      /*  key entry                       */
}

@property (assign) NSInteger recnum;
@property (retain) NSString *key;

+ (ACBKey *)newKey;
+ (ACBKey *)newKeyWithKStr:(NSString *)aKey;
- (id) init;
- (id) initWithKStr:(NSString *)aKey;

@end

@interface ACBTree : NSObject {
    __strong AMutableDictionary *dict;  /* The dictionary that this node belongs to */
    __strong ACBTree *lnode;            /* pointer to left node            */
    __strong ACBTree *rnode;            /* pointer to right node           */
    __strong ACBKey  **keys;            /* pointer to keys                 */
    __strong ACBTree **btNodes;         /* pointers to btNodes             */
    __strong ACBKey  *keyArray[BTNODESIZE];
    __strong ACBTree *btNodeArray[BTNODESIZE];
    NSInteger lnodeid;                  /* nodeid of left node             */
    NSInteger rnodeid;                  /* nodeid of right node            */
    NSInteger nodeid;                   /* node id                         */
    NSInteger nodeType;                 /* 1 = node, 2 = leaf, -1 = unused */
    NSInteger numkeys;                  /* number of active entries        */
    NSInteger numrecs;                  /* number of records               */
    NSInteger updtd;                    /* modified since update flag      */
    NSInteger keylen;                   /* length of key                   */
    NSInteger kidx;
}

@property (retain) AMutableDictionary *dict;
@property (retain) ACBTree  *lnode;
@property (retain) ACBTree  *rnode;
@property (assign) ACBKey   **keys;
@property (assign) ACBTree  **btNodes;
@property (assign) NSInteger lnodeid;
@property (assign) NSInteger rnodeid;
@property (assign) NSInteger nodeid;
@property (assign) NSInteger nodeType;
@property (assign) NSInteger numkeys;
@property (assign) NSInteger numrecs;
@property (assign) NSInteger updtd;
@property (assign) NSInteger keylen;
@property (assign) NSInteger kidx;

+ (ACBTree *) newNodeWithDictionary:(AMutableDictionary *)theDict;

- (id)initWithDictionary:(AMutableDictionary *)theDict;

- (ACBTree *)createnode:(ACBKey *)kp0;
- (ACBTree *)deletekey:(NSString *)dkey;
- (ACBTree *)insertkey:(ACBKey *)ikp value:(id)value;
- (ACBKey *)internaldelete:(ACBKey *)dkp;
- (ACBTree *) internalinsert:(ACBKey *)key value:(id)value split:(NSInteger *)h;
- (ACBTree *) insert:(ACBKey *)key value:(id)value index:(NSInteger)hi split:(NSInteger *)h;
- (NSInteger)delfrmnode:(ACBKey *)ikp;
- (NSInteger)insinnode:(ACBKey *)key value:(id)value;
- (void)mergenode:(NSInteger)i;
- (ACBTree *)splitnode:(NSInteger)idx;
- (ACBTree *)search:(id)key;
- (NSInteger)searchnode:(id)key match:(BOOL)match;
- (void)borrowleft:(NSInteger)i;
- (void)borrowright:(NSInteger)i;
- (void)rotateleft:(NSInteger)j;
- (void)rotateright:(NSInteger)j;
- (NSInteger) keyWalkLeaves;
- (NSInteger) objectWalkLeaves;
- (void)dealloc;
@end
