//
//  RBTree.m
//  objcvoronoi
//

#import "RBTree.h"
#import "Beachsection.h"
#import "CircleEvent.h"

@implementation RBTree
@synthesize root;

- (id)init
{
    self = [super init];
    if (self) {
        [self setRoot:nil];
    }
    return self;
}

- (void)rbInsertSuccessorForNode:(id)node withSuccessor:(id)successor
{
     
    id parent;
    if (node) {
        [successor setRbPrevious:node];
        [successor setRbNext:[node rbNext]];

        if ([node rbNext]) {
            [[node rbNext] setRbPrevious:successor];
        }
        [node setRbNext:successor];
        
        if ([node rbRight]) {
            // in-place expansion of node.rbRight.getFirst();
            node = [node rbRight];
            while ([node rbLeft]) {
                node = [node rbLeft];
            }
            [node setRbLeft:successor];
        } else {
            [node setRbRight:successor];
        }
        parent = node;
    } else if ([self root] != nil) {
    // if node is null, successor must be inserted to the left-most part of the tree
        node = [self getFirst:[self root]];
        [successor setRbPrevious:nil];
        [successor setRbNext:node];
        [node setRbPrevious:successor];
        [node setRbLeft:successor];
        parent = node;
    } else {
        // First section added -- root assigned
        [successor setRbPrevious:nil];
        [successor setRbNext:nil];
        [self setRoot:successor];
        parent = nil;
    }
    [successor setRbLeft:nil];
    [successor setRbRight:nil];
    [successor setRbParent:parent];
    [successor setRbRed:YES];
    
    // Fixup the modified tree by recoloring nodes and performing
    // rotations (2 at most) hence the red-black tree properties are
    // preserved.
    
    id grandpa, uncle;
    node = successor;
    while (parent && [parent rbRed]) {
        grandpa = [parent rbParent];
        if (parent == [grandpa rbLeft]) {
            uncle = [grandpa rbRight];
            if (uncle && [uncle rbRed]) {
                [parent setRbRed:NO];
                [uncle setRbRed:NO];
                [grandpa setRbRed:YES];
                node = grandpa;
            } else {
                if (node == [parent rbRight]) {
                    [self rbRotateLeft:parent];
                    node = parent;
                    parent = [node rbParent];
                }
                [parent setRbRed:NO];
                [grandpa setRbRed:YES];
                [self rbRotateRight:grandpa];
            }
        } else {
            uncle = [grandpa rbLeft];
            if (uncle && [uncle rbRed]) {
                [parent setRbRed:NO];
                [uncle setRbRed:NO];
                [grandpa setRbRed:YES];
                node = grandpa;
            } else {
                if (node == [parent rbLeft]) {
                    [self rbRotateRight:parent];
                    node = parent;
                    parent = [node rbParent];
                }
                [parent setRbRed:NO];
                [grandpa setRbRed:YES];
                [self rbRotateLeft:grandpa];
            }
        }
        parent = [node rbParent];
    }
    [[self root] setRbRed:NO];
}

// Multiple assignment used in original javascript
// See here for more info:
// https://developer.mozilla.org/en/JavaScript/Reference/Operators/Operator_Precedence

- (void)rbRemoveNode:(id)node
{
    // Performance caching of previous and next nodes
    if ([node rbNext]) {
        [[node rbNext] setRbPrevious:[node rbPrevious]];
    }
    if ([node rbPrevious]) {
        [[node rbPrevious] setRbNext:[node rbNext]];
    }
    [node setRbNext:nil];
    [node setRbPrevious:nil];
    
    id parent = [node rbParent];
    id left   = [node rbLeft];
    id right  = [node rbRight];
    id next;
    
    if (!left) {
        next = right;
    } else if (!right) {
        next = left;
    } else {
        next = [self getFirst:right];
    }
    
    if (parent) {
        if ([parent rbLeft] == node) {
            [parent setRbLeft:next];
        } else {
            [parent setRbRight:next];
        }
    } else {
        [self setRoot:next];
    }
    
    ////////////////////////////
    // Enforce red-black rules//
    ////////////////////////////
    BOOL isRed;
    if (left && right) {
        isRed = [next rbRed];
        [next setRbRed:[node rbRed]];
        [next setRbLeft:left];
        [left setRbParent:next];
        if (next != right) {
            parent = [next rbParent];
            [next setRbParent:[node rbParent]];
            node = [next rbRight];
            [parent setRbLeft:node];
            [next setRbRight:right];
            [right setRbParent:next];
        } else {
            [next setRbParent:parent];
            parent = next;
            node = [next rbRight];
        }
    } else {
        isRed = [node rbRed];
        node = next;
    }
    
    ///////////////////////////////////////////////////////////////
    // 'node' is now the sole successor's child and 'parent' its //
    //  new parent (since the successor can have been moved)     //
    ///////////////////////////////////////////////////////////////
    if (node) {
        [node setRbParent:parent];
    }
    
    ////////////////////////////
    // The 'easy' cases       //
    ////////////////////////////
    if (isRed) {
        return;
    }
    if (node && [node rbRed]) {
        [node setRbRed:NO];
        return;
    }
    
    ////////////////////////////
    // The other cases        //
    ////////////////////////////
    id sibling;
    do {
        if (node == [self root]) {
            break;
        }
        if (node == [parent rbLeft]) {
            sibling = [parent rbRight];
            if ([sibling rbRed]) {
                [sibling setRbRed:NO];
                [parent setRbRed:YES];
                [self rbRotateLeft:parent];
                sibling = [parent rbRight];
            }
            if (([sibling rbLeft] && [[sibling rbLeft] rbRed]) || ([sibling rbRight] && [[sibling rbRight] rbRed])) {
                if (![sibling rbRight] || ![[sibling rbRight] rbRed]) {
                    [[sibling rbLeft] setRbRed:NO];
                    [sibling setRbRed:YES];
                    [self rbRotateRight:sibling];
                    sibling = [parent rbRight];
                }
                [sibling setRbRed:[parent rbRed]];
                [parent setRbRed:NO];
                [[sibling rbRight] setRbRed:NO];
                [self rbRotateLeft:parent];
                node = [self root];
                break;
            }
        } else {
            sibling = [parent rbLeft];
            if ([sibling rbRed]) {
                [sibling setRbRed:NO];
                [parent setRbRed:YES];
                [self rbRotateRight:parent];
                sibling = [parent rbLeft];
            }
            if (([sibling rbLeft] && [[sibling rbLeft] rbRed]) || ([sibling rbRight] && [[sibling rbRight] rbRed])) {
                if (![sibling rbLeft] || ![[sibling rbLeft] rbRed]) {
                    [[sibling rbRight] setRbRed:NO];
                    [sibling setRbRed:YES];
                    [self rbRotateLeft:sibling];
                    sibling = [parent rbLeft];
                }
                [sibling setRbRed:[parent rbRed]];
                [parent setRbRed:NO];
                [[sibling rbLeft] setRbRed:NO];
                [self rbRotateRight:parent];
                node = [self root];
                break;
            }
        }
        [sibling setRbRed:YES];
        node = parent;
        parent = [parent rbParent];
    } while (![node rbRed]);
    if (node) {
        [node setRbRed:NO];
    }
    
}

- (void)rbRotateLeft:(id)node
{
    id p = node;
    id q = [node rbRight]; // This cannot be nil.
    
    NSAssert(q != nil, @"RBTree rbRotateLeft: q = [node rbRight] cannot equal nil!");
    
    id parent = [p rbParent];
    if (parent) {
        if ([parent rbLeft] == p) {
            [parent setRbLeft:q];
        } else {
            [parent setRbRight:q];
        }
    } else {
        [self setRoot:q];
    }
    [q setRbParent:parent];
    [p setRbParent:q];
    [p setRbRight:[q rbLeft]];
    if ([p rbRight]) {
        [[p rbRight] setRbParent:p];
    }
    [q setRbLeft:p];
}

- (void)rbRotateRight:(id)node
{
    id p = node;
    id q = [node rbLeft]; // This cannot be nil.
    
    NSAssert(q != nil, @"RBTree rbRotateRight: q = [node rbLeft] cannot equal nil!");
    
    id parent = [p rbParent];
    if (parent) {
        if ([parent rbLeft] == p) {
            [parent setRbLeft:q];
        } else {
            [parent setRbRight:q];
        }
    } else {
        [self setRoot:q];
    }
    [q setRbParent:parent];
    [p setRbParent:q];
    [p setRbLeft:[q rbRight]];
    if ([p rbLeft]) {
        [[p rbLeft] setRbParent:p];
    }
    [q setRbRight:p];
}

- (id)getFirst:(id)node
{
    while ([node rbLeft]) {
        node = [node rbLeft];
    }
    return node;
}

- (id)getLast:(id)node
{
    while ([node rbRight]) {
        node = [node rbRight];
    }
    return node;
}

@end
