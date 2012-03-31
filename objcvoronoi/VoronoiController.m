//
//  VoronoiController.m
//  objcvoronoi
//

#import "VoronoiController.h"
#import "Voronoi.h"
#import "VoronoiResult.h"
#import "VoronoiView.h"
#import "Site.h"
#import "Cell.h"
#import "ClayPathMaker.h"
#import "ClayRelaxer.h"

@implementation VoronoiController
@synthesize xMax, yMax;
- (id)init
{
    self = [super init];
    if (self) {
        randomPoints = [[NSMutableArray alloc] init];
    }
    return self;
}

- (IBAction)relaxWithLloyd:(id)sender
{
    NSMutableArray *newSites = [ClayRelaxer relaxSitesInCells:[activeResult cells]];
    [self newVoronoiWithNewSites:newSites];
}

- (IBAction)newVoronoi:(id)sender
{
    [randomPoints removeAllObjects];
    activeResult = nil;
    
    int numSites = [numSitesEntry intValue];
    int margin   = [marginEntry   intValue];
    
    // Send in sites as NSPoints that have been converted to NSValue
    
    xMax = [voronoiview bounds].size.width;
    yMax = [voronoiview bounds].size.height;
    
    for (int i = 0; i < numSites; i++) {
        float x = margin + (arc4random() % ((int)xMax - margin*2));
        float y = margin + (arc4random() % ((int)yMax - margin*2));
        NSValue *v = [NSValue valueWithPoint:NSMakePoint(x, y)];
        [randomPoints addObject:v];
    }
    
    [self calculateVoronoi];
}

- (void)newVoronoiWithNewSites:(NSMutableArray *)newSites
{
    // Clear the old
    [randomPoints removeAllObjects];
    randomPoints = nil;
    activeResult = nil;
    
    // Set the new points
    randomPoints = newSites;
    
    // Calculate the diagram
    [self calculateVoronoi];
}

- (void)calculateVoronoi
{
    
    voronoi = [[Voronoi alloc] init];
    activeResult = [voronoi computeWithSites:randomPoints andBoundingBox:[voronoiview bounds]];
    
    NSMutableArray *sitesFromCells = [[NSMutableArray alloc] init];
    
    for (Cell *c in [activeResult cells]) {
        Site *s = [c site];
        [sitesFromCells addObject:[s coordAsValue]];
    }
    
    [voronoiview setSites:sitesFromCells];
    [voronoiview setCells:[activeResult cells]];
    
    NSValue *start = [NSValue valueWithPoint:NSMakePoint(0, yMax * 0.5)];
    NSValue *end   = [NSValue valueWithPoint:NSMakePoint(xMax, yMax * 0.5)];
    NSValue *midPoint = [NSValue valueWithPoint:NSMakePoint(xMax * 0.33, 0)];
    NSValue *midPoint2 = [NSValue valueWithPoint:NSMakePoint(xMax * 0.66, yMax)];
    
    NSMutableArray *pathNodes = [[NSMutableArray alloc] init];
    [pathNodes addObject:start];
    [pathNodes addObject:midPoint];
    [pathNodes addObject:midPoint2];
    [pathNodes addObject:end];
    
    ClayPathMaker *dij = [[ClayPathMaker alloc] initWithEdges:[activeResult edges]
                                                   nodesForPath:pathNodes
                                                      andBounds:[voronoiview bounds]];
    [voronoiview setDijkstraPathPoints:[dij pathNodes]];
    
    [voronoiview setNeedsDisplay:YES];

    [relaxButton setEnabled:YES];
    
}

@end
