//
//  Site.m
//  objcvoronoi
//
//  Created by Clay Heaton on 3/23/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import "Site.h"

@implementation Site
@synthesize voronoiId;

- (id)initWithCoord:(NSPoint)tempCoord
{
    self = [super init];
    if (self) {
        [self setCoord:tempCoord];
    }
    return self;
}

- (id)initWithValue:(NSValue *)valueWithCoord
{
    self = [super init];
    if (self) {
        [self setCoord:[valueWithCoord pointValue]];
    }
    return self;
}

- (id)init
{
    NSLog(@"Initializing Site with NSZeroPoint. Consider using initWithCoord: instead");
    return [self initWithCoord:NSZeroPoint];
}

- (void)setCoord:(NSPoint)tempCoord
{
    coord = tempCoord;
}

- (NSPoint)coord
{
    return coord;
}

- (void)setCoordAsValue:(NSValue *)valueWithCoord
{
    coord = [valueWithCoord pointValue];
}

- (NSValue *)coordAsValue
{
    return [NSValue valueWithPoint:coord];
}

- (void)setX:(float)tempX
{
    [self setCoord:NSMakePoint(tempX, coord.y)];
}

- (float)x
{
    return coord.x;
}

- (void)setY:(float)tempY
{
    [self setCoord:NSMakePoint(coord.x, tempY)];
}

- (float)y
{
    return coord.y;
}

+ (void)sortSites:(NSMutableArray *)siteArray
{
    [siteArray sortUsingSelector:@selector(compare:)];
}

// TODO: Check that this is returning in the proper order;
- (NSComparisonResult)compare:(Site *)s
{
    if (self.y < s.y) return NSOrderedAscending;
    if (self.y > s.y) return NSOrderedDescending;
    if (self.x < s.x) return NSOrderedAscending;
    if (self.x > s.x) return NSOrderedDescending;
    
    return NSOrderedSame;
}

@end
