//
//  Vertex.m
//  objcvoronoi
//

#import "Vertex.h"

@implementation Vertex

- (NSString *)description
{
    return [NSString stringWithFormat:@"x: %f, y: %f", [self x], [self y]];
}

@end
