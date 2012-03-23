//
//  Voronoi.h
//  objcvoronoi
//
//  Created by Clay Heaton on 3/22/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RBTree;
@class CircleEvent;
@class Beachsection;
@class Site;
@class VoronoiResult;

@interface Voronoi : NSObject {
    NSMutableArray *edges;
    NSMutableArray *cells;
    NSMutableArray *beachsectionJunkyard;
    NSMutableArray *circleEventJunkyard;
    
    RBTree *beachline;
    RBTree *circleEvents;
    
    CircleEvent *firstCircleEvent;
    
    NSMutableArray *sites;
    NSRect boundingBox;
    
}

@property (retain, readwrite) CircleEvent *firstCircleEvent;

@property (assign, readwrite) NSRect boundingBox;

- (VoronoiResult *)computeWithSites:(NSMutableArray *)siteList andBoundingBox:(NSRect)bbox;
- (void)reset;

- (void)addBeachsection:(Site *)site;
- (void)removeBeachsection:(Beachsection *)bs;

- (void)clipEdges:(NSRect)bbox;
- (void)closeCells:(NSRect)bbox;

#pragma mark Math methods
// Basic math methods handled by the class
+ (BOOL)equalWithEpsilonA:(float)a andB:(float)b;
+ (BOOL)greaterThanWithEpsilonA:(float)a andB:(float)b;
+ (BOOL)greaterThanOrEqualWithEpsilonA:(float)a andB:(float)b;
+ (BOOL)lessThanWithEpsilonA:(float)a andB:(float)b;
+ (BOOL)lessThanOrEqualWithEpsilonA:(float)a andB:(float)b;



@end
