//
//  ACBTree.m
//  ST4
//
//  Created by Alan Condit on 4/18/11.
//  Copyright 2011 Alan Condit. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ACBTree.h"
#import "AMutableDictionary.h"
#import "ANTLRRuntimeException.h"

@class AMutableDictionary;

@implementation ACBKey

static NSInteger RECNUM = 0;

@synthesize recnum;
@synthesize key;

+ (ACBKey *)newKey
{
    return [[ACBKey alloc] init];
}

+ (ACBKey *)newKeyWithKStr:(NSString *)aKey
{
    return [[ACBKey alloc] initWithKStr:(NSString *)aKey];
}

- (id) init
{
    self =[super init];
    if ( self != nil ) {
        recnum = RECNUM++;
    }
    return self;
}

- (id) initWithKStr:(NSString *)aKey
{
    self =[super init];
    if ( self != nil ) {
        NSInteger len;
        recnum = RECNUM++;
        key = aKey;
        len = [aKey length];
        if ( len >= BTKeySize ) {
            len = BTKeySize - 1;
        }
        strncpy( kstr, [aKey cStringUsingEncoding:NSASCIIStringEncoding], len);
        kstr[len] = '\0';
    }
    return self;
}

@end

@implementation ACBTree

@synthesize dict;
@synthesize lnode;
@synthesize rnode;
@synthesize keys;
@synthesize btNodes;
@synthesize lnodeid;
@synthesize rnodeid;
@synthesize nodeid;
@synthesize nodeType;
@synthesize numkeys;
@synthesize numrecs;
@synthesize updtd;
@synthesize keylen;
@synthesize kidx;

+ (ACBTree *) newNodeWithDictionary:(AMutableDictionary *)theDict
{
    return [[ACBTree alloc] initWithDictionary:theDict];
}

- (id)initWithDictionary:(AMutableDictionary *)theDict
{
    self = [super init];
    if (self) {
        // Initialization code here.
        dict = theDict;
        nodeid = theDict.nxt_nodeid++;
        keys = keyArray;
        btNodes = btNodeArray;
        if ( nodeid == 0 ) {
            numkeys = 0;
        }
    }
    
    return self;
}

- (ACBTree *)createnode:(ACBKey *)kp
{
    ACBTree *tmp;
    
    tmp = [ACBTree newNodeWithDictionary:dict];
    tmp.nodeType = nodeType;
    tmp.lnode = self;
    tmp.rnode = self.rnode;
    self.rnode = tmp;
    //tmp.btNodes[0] = self;
    //tmp.keys[0] = kp;
    tmp.updtd = YES;
    tmp.numrecs = ((nodeType == LEAF)?1:numrecs);
    updtd = YES;
    tmp.numkeys = 1;
    [tmp retain];
    return(tmp);
}

- (ACBTree *)deletekey:(NSString *)dkey
{
    ACBKey /* *del, */ *dkp;
    ACBTree *told, *sNode;
    BOOL mustRelease = NO;

    if ( [dkey isKindOfClass:[NSString class]] ) {
        dkp = [ACBKey newKeyWithKStr:dkey];
        mustRelease = YES;
    }
    else if ( [dkey isKindOfClass:[ACBKey class]] )
        dkp = (ACBKey *)dkey;
    else
        @throw [ANTLRIllegalArgumentException newException:[NSString stringWithFormat:@"Don't understand this key:\"%@\"", dkey]];
    sNode = [self search:dkp.key];
    if ( sNode == nil || [sNode searchnode:dkp.key match:YES] == FAILURE ) {
        if ( mustRelease ) [dkp release];
        return(self);
    }
    told = dict.root;
    /* del = */[self internaldelete:dkp];
    
    /*  check for shrink at the root  */
    if ( numkeys == 1 && nodeType != LEAF ) {
        told = btNodes[0];
        told.nodeid = 1;
        told.updtd = YES;
        dict.root = told;
    }
#ifdef DONTUSENOMO
    if (debug == 'd') [self printtree];
#endif
    if ( mustRelease ) [dkp release];
    return(told);
}

/** insertKey is the insertion entry point
 *  It determines if the key exists in the tree already
 *  it calls internalInsert to determine if the key already exists in the tree,
 *  and returns the node to be updated
 */
- (ACBTree *)insertkey:(ACBKey *)kp value:(id)value
{
    ACBTree *tnew, *q;
    NSInteger h, nodeNum;
    
    tnew = self;
    q = [self internalinsert:kp value:value split:&h];
    /*  check for growth at the root  */
    if ( q != nil ) {
        tnew = [[ACBTree newNodeWithDictionary:dict] retain];
        tnew.nodeType = BTNODE;
        nodeNum = tnew.nodeid;
        tnew.nodeid = 0;
        self.nodeid = nodeNum;
        [tnew insert:self.keys[numkeys-1] value:self index:0 split:&h];
        [tnew insert:q.keys[q.numkeys-1] value:q index:1 split:&h];
        tnew.numrecs = self.numrecs + q.numrecs;
        tnew.lnodeid = self.nodeid;
        tnew.rnodeid = self.rnodeid;
        self.rnodeid = tnew.nodeid;
        tnew.lnode = self;
        tnew.rnode = self.rnode;
        self.rnode = tnew;
        /* affected by nodeid swap */
        // newnode.lnodeid = tnew.btNodes[0].nodeid;
    }
    //dict.root = t;
    //l.reccnt++;
    return(tnew);
}

- (ACBTree *)search:(NSString *)kstr
{
    NSInteger i, ret;
    NSInteger srchlvl = 0;
    ACBTree *t;

    t = self;
    if ( self.numkeys == 0 && self.nodeType == LEAF )
        return nil;
    while (t != nil) {
        for (i = 0; i < t.numkeys; i++) {
            ret = [t.keys[i].key compare:kstr];
            if ( ret >= 0 ) {
                if ( t.nodeType == LEAF ) {
                    if ( ret == 0 ) return (t);    /* node containing keyentry found */
                    else return nil;
                }
                else {
                    break;
                }
            }
        }
        srchlvl++;
        if ( t.nodeType == BTNODE ) t = t.btNodes[i];
        else {
            t = nil;
        }
    }
    return(nil);          /* entry not found */
}

/** SEARCHNODE
 *  calling parameters --
 *      BKEY PTR for key to search for.
 *      TYPE for exact match(YES) or position(NO)
 *  returns -- i
 *      i == FAILURE when match required but does not exist.
 *      i == t.numkeys if no existing insertion branch found.
 *      otherwise i == insertion branch.
 */
- (NSInteger)searchnode:(NSString *)kstr match:(BOOL)match
{
    NSInteger i, ret;
    for ( i = 0; i < numkeys; i++ ) {
        ret = [keys[i].key compare:kstr];
        if ( ret >= 0 ) {         /* key node found */
            if ( ret == 0 && match == NO ) {
                return FAILURE;
            }
            else if ( ret > 0 &&  match == YES ) {
                return FAILURE;
            }
            break;
        }
    }
    if ( i == numkeys && match == YES ) {
        i = FAILURE;
    }
    return(i);
}

- (ACBKey *)internaldelete:(ACBKey *)dkp
{
    NSInteger i, nkey;
    __strong ACBKey *del = nil;
    ACBTree *tsb;
    NSInteger srchlvl = 0;
    
    /* find deletion branch */
    if ( self.nodeType != LEAF ) {
        srchlvl++;
        /* search for end of tree */
        i = [self searchnode:dkp.key match:NO];
        del = [btNodes[i] internaldelete:dkp];
        srchlvl--;
        /* if not LEAF propagate back high key    */
        tsb = btNodes[i];
        nkey = tsb.numkeys - 1;
    }
    /***  the bottom of the tree has been reached       ***/
    else {                   /* set up deletion ptrs      */
        if ( [self delfrmnode:dkp] == SUCCESS ) {
            if ( numkeys < BTHNODESIZE+1 ) {
                del = dkp;
            }
            else {
                del = nil;
            }
            dkp.recnum = nodeid;
            return(del);
        }
    }
    /***       indicate deletion to be done            ***/
    if ( del != nil ) {
        /*** the key in "del" has to be deleted from in present node ***/
        if ( btNodes[i].numkeys >= BTHNODESIZE+1 ) {
            /* node does not need balancing */
            del = nil;
            self.keys[i] = tsb.keys[nkey];
        }
        else {                         /* node requires balancing */
            if ( i == 0 ) {
                [self rotateright:0];
                self.btNodes[0] = tsb;
            } else if ( i < numkeys-1 ) {     /* look to the right first */
                if ( self.btNodes[i+1].numkeys > BTHNODESIZE+1 ) {  /* carry from right */
                    [self borrowright:i];
                }
                else {           /* merge present node with right node */
                    [self mergenode:i];
                }
            }
            else {                      /* look to the left */
                if ( i > 0 ) {          /* carry or merge with left node */
                    if ( self.btNodes[i-1].numkeys > BTHNODESIZE+1 ) { /* carry from left */
                        [self borrowleft:i];
                    }
                    else { /*** merge present node with left node ***/
                        i--;
                        [self mergenode:i];
                        tsb = self.btNodes[i];
                    }
                }
            }
        self.keys[i] = tsb.keys[nkey];
        }
    }
    numrecs--;
    updtd = TRUE;
    return(del);
}

/** Search key kp on B-tree with root t; if found increment counter.
 *  otherwise insert an item with key kp in tree.  If an ACBKey
 *  emerges to be passed to a lower level, then assign it to kp;
 *  h = "tree t has become higher"
 */
- (ACBTree *) internalinsert:(ACBKey *)kp value:(id)value split:(NSInteger *)h
{
    /* search key ins on node t^; h = false  */
    NSInteger i, ret;
    ACBTree *q, *tmp;
    
    for (i = 0; i < numkeys; i++) {
        ret = [keys[i].key compare:kp.key];
        if ( ret >= 0 ) {
            if ( nodeType == LEAF && ret == 0 ) return (self);    /* node containing keyentry found */
            break;
        }
    }
    if ( nodeType == LEAF ) { /*  key goes in this node  */
        q = [self insert:kp value:value index:i split:h];
    }
    else  { /* nodeType == BTNODE */
        /*  key is not on this node  */
        q = [self.btNodes[i] internalinsert:kp value:value split:h];
        if ( *h ) {
            [self insert:kp value:q index:i split:h];
        }
        else {
            self.numrecs++;
        }
        tmp = self.btNodes[numkeys-1];
        keys[numkeys-1] = tmp.keys[tmp.numkeys-1];
        if ( i != numkeys-1 ) {
            tmp = self.btNodes[i];
            keys[i] = tmp.keys[tmp.numkeys-1];
        }
        updtd = YES;
    } /* search */
    return q;
}

/** Do the actual insertion or split and insert
 *  insert key to the right of t.keys[hi] 
 */
- (ACBTree *) insert:(ACBKey *)kp value:(id)value index:(NSInteger)hi split:(NSInteger *)h
{
    ACBTree *b;
    
    if ( numkeys < BTNODESIZE ) {
        *h = NO;
        [self rotateright:hi];
        keys[hi] = kp;
        btNodes[hi] = value;
        numrecs++;
        numkeys++;
        updtd = YES;
        //[kp retain];
        return nil;
    }
    else { /*  node t is full; split it and assign the emerging ACBKey to olditem  */
        b = [self splitnode:hi];
        if ( hi <= BTHNODESIZE ) {              /* insert key in left page */
            [self rotateright:hi];
            keys[hi] = kp;
            btNodes[hi] = value;
            numrecs++;
            numkeys++;
        }
        else {                                  /* insert key in right page */
            hi -= BTHNODESIZE;
            if ( b.rnode == nil ) hi--;
            [b rotateright:hi];
            b.keys[hi] = kp;
            b.btNodes[hi] = value;
            b.numrecs++;
            b.numkeys++;
        }
        numkeys = b.numkeys = BTHNODESIZE+1;
        b.updtd = updtd = YES;
    }
    return b;
} /* insert */

- (void)borrowleft:(NSInteger)i
{
    ACBTree *t0, *t1;
    NSInteger nkey;
    
    t0 = btNodes[i];
    t1 = btNodes[i-1];
    nkey = t1.numkeys-1;
    [t0 insinnode:t1.keys[nkey] value:t1.btNodes[nkey]];
    [t1 delfrmnode:t1.keys[nkey]];
    nkey--;
    keys[i-1] = t1.keys[nkey];
    keys[i-1].recnum = t1.nodeid;
}

- (void)borrowright:(NSInteger)i
{
    ACBTree *t0, *t1;
    NSInteger nkey;
    
    t0 = btNodes[i];
    t1 = btNodes[i+1];
    [t0 insinnode:t1.keys[0] value:t1.btNodes[0]];
    [t1 delfrmnode:t1.keys[0]];
    nkey = t0.numkeys - 1;
    keys[i] = t0.keys[nkey];
    keys[i].recnum = t0.nodeid;
}

- (NSInteger)delfrmnode:(ACBKey *)ikp
{
    NSInteger j;
    
    j = [self searchnode:ikp.key match:YES];
    if (j == FAILURE) {
        return(FAILURE);
    }
    ACBKey *k0 = nil;
    ACBTree *n0 = nil;
    if ( self.nodeType == LEAF ) {
        k0 = self.keys[j];
        n0 = self.btNodes[j];
    }
    [self rotateleft:j];
    self.numkeys--;
    numrecs -= ((self.nodeType == LEAF)?1:btNodes[j].numrecs);
    if ( k0 ) [k0 release];
    if ( n0 ) [n0 release];
    updtd = TRUE;
    return(SUCCESS);
}

- (NSInteger)insinnode:(ACBKey *)ikp value:(id)value
{
    NSInteger j;
    
    j = [self searchnode:ikp.key match:NO];
    [self rotateright:j];
    keys[j] = ikp;
    btNodes[j] = value;
    numkeys++;
    if ( nodeType == LEAF ) {
        numrecs++;
    }
    else {
        numrecs += btNodes[j].numrecs;
    }
    updtd = TRUE;
    return(j);
}

- (void)mergenode:(NSInteger)i
{
    ACBTree *t0, *t1, *tr;
    NSInteger j, k, nkeys;
    
    t0 = btNodes[i];
    t1 = btNodes[i+1];
    /*** move keys and pointers from
     t1 node to t0 node           ***/
    for (j=t0.numkeys, k=0; j < BTNODESIZE && k < t1.numkeys; j++, k++) {
        t0.keys[j] = t1.keys[k];
        t0.btNodes[j] = t1.btNodes[k];
        t0.numkeys++;
    }
    t0.numrecs += t1.numrecs;
    t0.rnode = t1.rnode;
    t0.rnodeid = t1.rnodeid;
    t0.updtd = YES;
    nkeys = t0.numkeys - 1;
    keys[i] = t0.keys[nkeys]; /* update key to point to new high key */
    [self rotateleft:i+1]; /* copy over the keys and nodes */
    
    t1.nodeType = -1;
    if (t1.rnodeid != 0xffff && i < numkeys - 2) {
        tr = btNodes[i+1];
        tr.lnodeid = t0.nodeid;
        tr.lnode = t0;
        tr.updtd = YES;
    }
    self.numkeys--;
    updtd = YES;
}

- (ACBTree *)splitnode:(NSInteger)idx
{
    ACBTree *t1;
    NSInteger j, k;
    
    k = (idx <= BTHNODESIZE) ? BTHNODESIZE : BTHNODESIZE+1;
    /*** create new node ***/
    // checknode(l, t, k);
    t1 = [ACBTree newNodeWithDictionary:dict];
    t1.nodeType = nodeType;
    t1.rnode = self.rnode;
    self.rnode = t1;
    t1.lnode = self;
    self.updtd = t1.updtd = YES;
    /*** move keys and pointers ***/
    NSInteger i = 0;
    for (j = k; j < BTNODESIZE; j++, i++ ) {
        t1.keys[i] = keys[j];
        t1.btNodes[i] = btNodes[j];
        t1.numrecs += ((nodeType == LEAF) ? 1 : btNodes[j].numrecs);
        numrecs     -= ((nodeType == LEAF) ? 1 : btNodes[j].numrecs);
        keys[j] = nil;
        btNodes[j] = nil;
    }
    t1.numkeys  = BTNODESIZE-k;
    self.numkeys = k;
    return(t1);
}

#ifdef DONTUSENOMO
freetree(l, t)
FIDB *l;
ACBTree *t;
{
    ACBTree *tmp;
    NSInteger i;
    
    if (dict.root == nil) return(SUCCESS);
    if (t.nodeid == 1) {
        srchlvl = 0;
    }
    else srchlvl++;
    for (i = 0; i < t.numkeys; i++) {
        tmp = t.btNodes[i];
        if (tmp != nil) {
            if (tmp.nodeType == LEAF) {
                free(tmp);    /* free the leaf */
                if (tmp == l.rrnode) {
                    l.rrnode = nil;
                }
                t.btNodes[i] = nil;
                l.chknode.nods_inuse--;
                /*              putpage(l, l.chknode, 0);
                 */
            }
            else {
                freetree(l, tmp); /* continue up the tree */
                srchlvl--;        /* decrement the srchlvl on return */
            }
        }
    }
    free(t); /* free the node entered with */
    if (t == l.rrnode) {
        l.rrnode = nil;
    }
    l.chknode.nods_inuse--;
    /*     putpage(l, l.chknode, 0);
     */
    t = nil;
}

- (void) notfound:(ACBKey *)kp
{
    /* error routine to perform if entry was expected and not found */
}

- (void)printtree:(ACBTree *)t
{
    BYTE *str;
    NSInteger i, j;
    NSUInteger *pdate, *ptime;
    
    syslst = stdprn;
    if ( t.nodeid == 1 ) {
        srchlvl = 0;
    }
    else srchlvl++;
    for (j = 0; j < t.numkeys; j++) {
        checknode(l, t, j);
        if ( t.btNodes[j] != nil ) [self printtree:t.btNodes[j]];
    }
    NSLog(@"Nodeid = %d, nodeType = %s, numkeys = %d, numrecs = %d\n",
          t.nodeid, (t.nodeType == BTNODE)?@"NODE":@"LEAF", t.numkeys, t.numrecs);
    NSLog(@"Left nodeid = %d, Right nodeid = %d\n", t.lnodeid, t.rnodeid);
    for (i = 0; i < t.numkeys; i++) {
        NSLog(@"     t.keys[%d] recnum = %d, keyval = %@",
              i, t.keys[i].recnum, t.keys[i]);
        str = t.keys[i].kstr;
        pdate = (NSUInteger *) (str + 6);
        ptime = (NSUInteger *) (str + 8);
        NSLog(@" date = %04.4x,  time = %04.4x\n",
              *pdate, *ptime);
    }
}

- (BOOL)puttree:(ACBTree *)t
{
    NSInteger i;
    if (t.nodeType != LEAF) {
        for (i = 0; i < t.numkeys; i++) {
            if ( t.btNodes[i] != nil ) puttree(l, t.btNodes[i]);
        }
    }
    if ( t.updtd ) {
        putnode(l, t, t.nodeid);
        return(YES);
    }
    return(NO);
}

#endif

/** ROTATELEFT -- rotate keys from right to the left
 *  starting at position j
 */
- (void)rotateleft:(NSInteger)j
{
    while ( j+1 < numkeys ) {
        keys[j] = keys[j+1];
        btNodes[j] = btNodes[j+1];
        j++;
    }
}

/** ROTATERIGHT -- rotate keys to the right by 1 position
 *  starting at the last key down to position j.
 */
- (void)rotateright:(NSInteger)j
{
    NSInteger k;
    
    for ( k = numkeys; k > j; k-- ) {
        keys[k] = keys[k-1];
        btNodes[k] = btNodes[k-1];
    }
    keys[j] = nil;
    btNodes[j] = nil;
}

- (NSInteger) keyWalkLeaves
{
    NSInteger i, idx = 0;
    NSInteger keycnt;
    ACBTree *t;

    if ( self != dict.root ) {
        return 0; // maybe I need to throw an exception here
    }
    t = self;
    self.dict.data = [[NSMutableData dataWithLength:(numkeys * sizeof(id))] retain];
    self.dict.ptrBuffer = [self.dict.data mutableBytes];
    while ( t != nil && t.nodeType != LEAF ) {
        t = t.btNodes[0];
    }
    do {
        keycnt = t.numkeys;
        for ( i = 0; i < keycnt; i++ ) {
            if ( t.btNodes[i] != nil ) {
                dict.ptrBuffer[idx++] = (id) t.keys[i].key;
            }
        }
        t = t.rnode;
    } while ( t != nil );
    return( idx );
}

- (NSInteger) objectWalkLeaves
{
    NSInteger i, idx = 0;
    NSInteger keycnt;
    ACBTree *t;
    
    if ( self != dict.root ) {
        return 0; // maybe I need to throw an exception here
    }
    t = self;
    self.dict.data = [[NSMutableData dataWithLength:(numrecs * sizeof(id))] retain];
    self.dict.ptrBuffer = [self.dict.data mutableBytes];
    while ( t != nil && t.nodeType != LEAF ) {
        t = t.btNodes[0];
    }
    do {
        keycnt = t.numkeys;
        for ( i = 0; i < keycnt; i++ ) {
            if ( t.btNodes[i] != nil ) {
                dict.ptrBuffer[idx++] = (id) t.btNodes[i];
            }
        }
        t = t.rnode;
    } while ( t != nil );
    return( idx );
}

- (void)dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in ACBTree" );
#endif
    [super dealloc];
}

@end
