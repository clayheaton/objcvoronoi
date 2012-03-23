//
//  Voronoi.m
//  objcvoronoi
//
//  Created by Clay Heaton on 3/22/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import "Voronoi.h"

@implementation Voronoi
@synthesize sites, boundingBox;

- (id)init
{
    self = [super init];
    if (self) {
        edges = [[NSMutableArray alloc] init];
        cells = [[NSMutableArray alloc] init];
        beachsectionJunkyard = [[NSMutableArray alloc] init];
        circleEventJunkyard  = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)computeWithSites:(NSMutableArray *)siteList andBoundingBox:(NSRect)bbox
{
    [self setSites:siteList];
    [self setBoundingBox:bbox];
    
    [self reset];
}

- (void)reset
{
    
}

#pragma mark Math
+ (BOOL)equalWithEpsilonA:(float)a andB:(float)b
{
    return fabs(a-b)<FLT_EPSILON;
}

+ (BOOL)greaterThanWithEpsilonA:(float)a andB:(float)b
{
    return a-b>FLT_EPSILON;
}

+ (BOOL)greaterThanOrEqualWithEpsilonA:(float)a andB:(float)b
{
    return b-a<FLT_EPSILON;
}

+ (BOOL)lessThanWithEpsilonA:(float)a andB:(float)b
{
    return b-a>FLT_EPSILON;
}

+ (BOOL)lessThanOrEqualWithEpsilonA:(float)a andB:(float)b
{
    return a-b<FLT_EPSILON;
}
@end
