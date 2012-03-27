//
//  Halfedge.h
//  objcvoronoi
//
//  Created by Clay Heaton on 3/27/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Site;
@class Edge;
@class Vertex;

@interface Halfedge : NSObject {
    Site *site;
    Edge *edge;
    float angle;
}

@property (retain, readwrite) Site *site;
@property (retain, readwrite) Edge *edge;
@property (assign, readwrite) float angle;

- (id)initWithEdge:(Edge *)theEdge lSite:(Site *)theLSite andRSite:(Site *)theRSite;
- (Vertex *)getStartpoint;
- (Vertex *)getEndpoint;


+ (void)sortArrayOfHalfedges:(NSMutableArray *)theArray;
- (NSComparisonResult)compare:(Halfedge *)he;

@end
