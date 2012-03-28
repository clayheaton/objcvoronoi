//
//  Cell.m
//  objcvoronoi
//
//  Created by Clay Heaton on 3/23/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import "Cell.h"
#import "Site.h"
#import "Halfedge.h"
#import "Edge.h"

@implementation Cell
@synthesize site;

- (NSString *)description
{
    NSString *d = [NSString stringWithFormat:@"Cell | site: %@, halfedges: %@", site, halfedges];
    return d;
}

- (id)initWithSite:(Site *)s
{
    self = [super init];
    if (self) {
        [self setSite:s];
        halfedges = [[NSMutableArray alloc] init];
    }
    return self;
}

- (int)prepare
{
    int iHalfedge = (int)[halfedges count];
    Edge *thisEdge;
    // get rid of unused halfedges
    while (iHalfedge--) {
        Halfedge *he = [halfedges objectAtIndex:iHalfedge];
        thisEdge = [he edge];
        if (![thisEdge vb] || ![thisEdge va]) {
            [halfedges removeObjectAtIndex:iHalfedge]; // Double-check this in production vs. js
            // halfedges.splice(iHalfedge,1);
        }
    }
    [Halfedge sortArrayOfHalfedges:halfedges];          // Possible problem point...
    
    return (int)[halfedges count];
}

- (void)addHalfedgeToArray:(Halfedge *)he
{
    [halfedges addObject:he];
}

- (NSMutableArray *)halfedges
{
    return halfedges;
}

@end
