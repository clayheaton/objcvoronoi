//
//  CircleEvent.m
//  objcvoronoi
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
