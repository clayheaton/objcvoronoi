//
//  Voronoi.m
//  objcvoronoi
//
//  Created by Clay Heaton on 3/22/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import "Voronoi.h"
#import "RBTree.h"
#import "Beachsection.h"
#import "CircleEvent.h"
#import "Site.h"
#import "Cell.h"
#import "VoronoiResult.h"

@implementation Voronoi
@synthesize firstCircleEvent, boundingBox;

- (id)init
{
    self = [super init];
    if (self) {
        sites = [[NSMutableArray alloc] init];
        edges = [[NSMutableArray alloc] init];
        cells = [[NSMutableArray alloc] init];
        beachsectionJunkyard = [[NSMutableArray alloc] init];
        circleEventJunkyard  = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (VoronoiResult *)computeWithSites:(NSMutableArray *)siteList andBoundingBox:(NSRect)bbox
{
    /////////////////////////////////////////////////////////////////////////////
    // siteList comes in as an array of NSPoints stored as NSValues.           //
    // Convert them to Site class and then make sites an array of Site objects //
    /////////////////////////////////////////////////////////////////////////////
    
    [self reset];
    
    for (NSValue *v in siteList) {
        Site *s = [[Site alloc] initWithValue:v];
        [sites addObject:s];
    }
    
    [self setBoundingBox:bbox];
    
    NSMutableArray *siteEvents = [[NSMutableArray alloc] initWithArray:sites];
    NSLog(@"Unsorted sites: %@", siteEvents);
    [Site sortSites:siteEvents];
    NSLog(@"Sorted Sites: %@", siteEvents);
    
    Site *site = [siteEvents lastObject];
    [siteEvents removeLastObject];
    
    int siteid = 0;
    
    float xsitex = -FLT_MAX; // To avoid duplicate sites
    float xsitey = -FLT_MAX;
    
    CircleEvent *circle;
    
    ///////////////
    // Main Loop //
    ///////////////
    
    for (;;) {
        ////////////////////////////////////////////////////////////////////
        // We need to figure out whether we handle a site or circle event //
        // For this we find out if there is a site event and it is        //
        // 'earlier' than the circle event                                //
        ////////////////////////////////////////////////////////////////////
        
        circle = [self firstCircleEvent];
        
        // Add Beach Section
        if (site && (!circle || site.y < circle.y || (site.y == circle.y && site.x < circle.x))) {
            // Only if site is not a duplicate
            if (site.x != xsitex || site.y != xsitey) {
                // First, create cell for the new site
                [cells addObject:[[Cell alloc] initWithSite:site]];
                [site setVoronoiId:siteid];
                siteid += 1;
                
                // Then create a beachsection for that site
                [self addBeachsection:site];                        /// PROBLEM HERE!!!!!!
                
                // Remember last site coords to detect duplicates
                xsitey = [site y];
                xsitex = [site x];
            }
            site = [siteEvents lastObject];
            [siteEvents removeLastObject];
        } else if (circle) {
            // remove beach section
            [self removeBeachsection:[circle arc]];                 /// PROBLEM HERE!!!!!!!
        } else {
            // all done, quit
            break;
        }
    }
    
    ////////////////////////////////////////////////////////////////////
    // Wrapping up:                                                   //
    // - connect dangling edges to bounding box                       //
    // - cut edges as per bounding box                                //
    // - discard edges completely outside bounding box                //
    // - discard edges which are point-like                           //
    ////////////////////////////////////////////////////////////////////
    [self clipEdges:[self boundingBox]];
    
    // - add missing edges in order to close opened cells
    [self closeCells:[self boundingBox]];
    
    // - prepare return values
    VoronoiResult *result = [[VoronoiResult alloc] init];
    [result setCells:cells];
    [result setEdges:edges];
    
    [self reset];
    return result;
}

- (void)reset
{
    if (!beachline) {
        beachline = [[RBTree alloc] init];
    }
    
    // Move leftover beachsections to the beachsection junkyard.
    if ([beachline root]) {
        Beachsection *beachsection = [beachline getFirst:[beachline root]];
        while (beachsection) {
            [beachsectionJunkyard addObject:beachsection]; // mark for reuse
            beachsection = [beachsection rbNext];
        }
    }
    
    [beachline setRoot:nil];
    if (!circleEvents) {
        circleEvents = [[RBTree alloc] init];
    }
    [circleEvents setRoot:nil];
    [self setFirstCircleEvent:nil];
    [edges removeAllObjects];
    [cells removeAllObjects];
    [sites removeAllObjects];
}

// TODO: Implement addBeachSection
- (void)addBeachSection:(Site *)site
{
    
}

- (void)removeBeachsection:(Beachsection *)bs
{
    
}

- (void)clipEdges:(NSRect)bbox
{
    
}

- (void)closeCells:(NSRect)bbox
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
