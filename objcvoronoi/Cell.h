//
//  Cell.h
//  objcvoronoi
//
//  Created by Clay Heaton on 3/23/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Site;
@class Halfedge;

@interface Cell : NSObject {
    Site *site;
    NSMutableArray *halfedges;
}

@property (retain, readwrite) Site *site;

- (id)initWithSite:(Site *)s;
- (int)prepare;
- (void)addHalfedgeToArray:(Halfedge *)he;
- (NSMutableArray *)halfedges;

@end
