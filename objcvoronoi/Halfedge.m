//
//  Halfedge.m
//  objcvoronoi
//
//  Created by Clay Heaton on 3/27/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import "Halfedge.h"
#import "Site.h"
#import "Edge.h"
#import "Vertex.h"

@implementation Halfedge
@synthesize site, edge, angle;

- (id)initWithEdge:(Edge *)theEdge lSite:(Site *)theLSite andRSite:(Site *)theRSite
{
    self = [super init];
    if (self) {
        [self setSite:theLSite];
        [self setEdge:theEdge];
        
        // 'angle' is a value to be used for properly sorting the 
        // halfsegments counterclockwise. By convention, we will
        // use the angle of the line defined by the 'site to the left'
        // to the 'site to the right'.
        // However, border edges have no 'site to the right': thus we
        // use the angle of the line perpendicular to the halfsegment (the
        // edge should have both end points defined in such case.)
        
        if (theRSite) {
            [self setAngle:atan2f([theRSite y] - [theLSite y], [theRSite x] - [theLSite x])];
        } else {
            Vertex *va = [theEdge va];
            Vertex *vb = [theEdge vb];
            float tempAngle = [theEdge lSite] == theLSite ? atan2f([vb x] - [va x] , [va y] - [vb y]) : atan2f([va x] - [vb x], [vb y] - [va y]);
            [self setAngle:tempAngle];
        }
    }
    return self;
}

- (NSString *)description
{
    
    NSString *startPoint = [[self getStartpoint] description];
    NSString *endPoint   = [[self getEndpoint] description];
    
    
    return [NSString stringWithFormat:@"Halfedge - Angle: %f,  Start Point: %@,  End Point: %@",angle, startPoint, endPoint];
}

- (Vertex *)getStartpoint
{
    return [[self edge] lSite] == [self site] ? [[self edge] va] : [[self edge] vb];
}

- (Vertex *)getEndpoint
{
    return [[self edge] lSite] == [self site] ? [[self edge] vb] : [[self edge] va];
}

+ (void)sortArrayOfHalfedges:(NSMutableArray *)theArray
{
    [theArray sortUsingSelector:@selector(compare:)];
}

// TODO: Check this for accuracy
- (NSComparisonResult)compare:(Halfedge *)he
{
    if ([self angle] < [he angle]) {
        return NSOrderedDescending;
    } else if ([self angle] > [he angle]) {
        return NSOrderedAscending;
    } else {
        return NSOrderedSame;
    }

}

@end
