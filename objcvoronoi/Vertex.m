//
//  Vertex.m
//  objcvoronoi
//
//  Created by Clay Heaton on 3/26/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import "Vertex.h"

@implementation Vertex

- (NSString *)description
{
    return [NSString stringWithFormat:@"x: %f, y: %f", [self x], [self y]];
}

@end
