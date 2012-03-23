//
//  RBTree.h
//  objcvoronoi
//
//  Created by Clay Heaton on 3/22/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const BeachsectionClassName;
extern NSString * const CircleEventClassName;

@interface RBTree : NSObject {
    id root;
    NSString *nodeClass;
}

@property (copy, readwrite) NSString *nodeClass;

- (void)rbInsertSuccessorForNode:(id)node withSuccessor:(id)successor;
- (void)rbRemoveNode:(id)node;
- (void)rbRotateLeft:(id)node;
- (void)rbRotateRight:(id)node;
- (id)getFirst:(id)node;
- (id)getLast:(id)node;

@end
