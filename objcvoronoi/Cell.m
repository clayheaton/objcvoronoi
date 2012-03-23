//
//  Cell.m
//  objcvoronoi
//
//  Created by Clay Heaton on 3/23/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import "Cell.h"
#import "Site.h"

@implementation Cell
@synthesize site;

- (id)initWithSite:(Site *)s
{
    self = [super init];
    if (self) {
        [self setSite:s];
    }
    return self;
}

@end
