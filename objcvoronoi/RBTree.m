//
//  RBTree.m
//  objcvoronoi
//
//  Created by Clay Heaton on 3/22/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import "RBTree.h"
#import "Beachsection.h"
#import "CircleEvent.h"

NSString * const BeachsectionClassName                    = @"Beachsection";
NSString * const CircleEventClassName                     = @"CircleEvent";

@implementation RBTree
@synthesize nodeClass;

- (id)init
{
    self = [super init];
    if (self) {
        root = nil;
        nodeClass = nil;
    }
    return self;
}

- (void)rbInsertSuccessorForNode:(id)node withSuccessor:(id)successor
{
    NSAssert(nodeClass != nil, @"nodeClass must be set for RBTree to work");
     
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
    } else if (root != nil) {
    // if node is null, successor must be inserted to the left-most part of the tree
        node = [self getFirst:root];
        [successor setRbPrevious:nil];
        [successor setRbNext:node];
        [node setRbPrevious:successor];
        [node setRbLeft:successor];
        parent = node;
    } else {
        [successor setRbPrevious:nil];
        [successor setRbNext:nil];
        root = successor;
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
    [root setRbRed:NO];
}

- (void)rbRemoveNode:(id)node
{
    
}

- (void)rbRotateLeft:(id)node
{
    
}

- (void)rbRotateRight:(id)node
{
    
}

- (id)getFirst:(id)node
{
    
}

- (id)getLast:(id)node
{
    
}

@end
