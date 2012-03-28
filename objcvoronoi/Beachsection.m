//
//  Beachsection.m
//  objcvoronoi
//
//  Created by Clay Heaton on 3/22/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import "Beachsection.h"
#import "Site.h"
#import "Edge.h"
#import "CircleEvent.h"

@implementation Beachsection
@synthesize rbNext, rbPrevious, rbParent, rbRight, rbLeft, rbRed, site, edge, circleEvent;

- (id)initWithSite:(Site *)theSite
{
    self = [super init];
    if (self) {
        [self setSite:theSite];
    }
    return self;
}

// Use this to create Beachsections

+ (id)createBeachSectionFromJunkyard:(NSMutableArray *)junkyard withSite:(Site *)theSite
{
    if ([junkyard count] > 0) {
        Beachsection *section = [junkyard lastObject];
        [junkyard removeLastObject];
        [section setSite:theSite];
        return section;
    } else {
        return [[Beachsection alloc] initWithSite:theSite];
    }
}

@end
