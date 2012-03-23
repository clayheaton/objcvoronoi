//
//  Voronoi.h
//  objcvoronoi
//
//  Created by Clay Heaton on 3/22/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Voronoi : NSObject {
    NSMutableArray *edges;
    NSMutableArray *cells;
    NSMutableArray *beachsectionJunkyard;
    NSMutableArray *circleEventJunkyard;
    
    NSMutableArray *sites;
    NSRect boundingBox;
    
}

@property (retain, readwrite) NSMutableArray *sites;
@property (assign, readwrite) NSRect boundingBox;

- (void)computeWithSites:(NSMutableArray *)siteList andBoundingBox:(NSRect)bbox;
- (void)reset;

#pragma mark Math methods
// Basic math methods handled by the class
+ (BOOL)equalWithEpsilonA:(float)a andB:(float)b;
+ (BOOL)greaterThanWithEpsilonA:(float)a andB:(float)b;
+ (BOOL)greaterThanOrEqualWithEpsilonA:(float)a andB:(float)b;
+ (BOOL)lessThanWithEpsilonA:(float)a andB:(float)b;
+ (BOOL)lessThanOrEqualWithEpsilonA:(float)a andB:(float)b;



@end
