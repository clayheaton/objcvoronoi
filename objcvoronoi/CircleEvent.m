//
//  CircleEvent.m
//  objcvoronoi
//
//  Created by Clay Heaton on 3/22/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import "CircleEvent.h"
#import "Beachsection.h"
#import "Site.h"

@implementation CircleEvent
@synthesize rbNext, rbPrevious, rbParent, rbRight, rbLeft, rbRed, arc, site, ycenter;



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

@end
