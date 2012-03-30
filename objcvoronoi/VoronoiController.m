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

@implementation VoronoiController


- (IBAction)testVoronoi:(id)sender
{
    int numSites = [numSitesEntry intValue];
    int margin   = [marginEntry   intValue];
    
    voronoi = [[Voronoi alloc] init];
    
    // Send in sites as NSPoints that have been converted to NSValue
    
    NSMutableArray *sites = [[NSMutableArray alloc] init];
    
    float xMax = [voronoiview bounds].size.width;
    float yMax = [voronoiview bounds].size.height;
    
    NSValue *start = [NSValue valueWithPoint:NSMakePoint(100, 0)];
    NSValue *end   = [NSValue valueWithPoint:NSMakePoint(xMax, 100)];
   [sites addObject:start];
   [sites addObject:end];
    
    for (int i = 0; i < numSites; i++) {
        float x = margin + (arc4random() % ((int)xMax - margin*2));
        float y = margin + (arc4random() % ((int)yMax - margin*2));
        NSValue *v = [NSValue valueWithPoint:NSMakePoint(x, y)];
        [sites addObject:v];
    }
    
    VoronoiResult *result = [voronoi computeWithSites:sites andBoundingBox:[voronoiview bounds]];
    
    NSMutableArray *sitesFromCells = [[NSMutableArray alloc] init];
    
    for (Cell *c in [result cells]) {
        Site *s = [c site];
        [sitesFromCells addObject:[s coordAsValue]];
    }
    
    [voronoiview setSites:sitesFromCells];
    [voronoiview setCells:[result cells]];
    
    NSValue *midPoint = [NSValue valueWithPoint:NSMakePoint(xMax * 0.3, yMax * 0.3)];
    NSValue *midPoint2 = [NSValue valueWithPoint:NSMakePoint(xMax * 0.7, yMax * 0.75)];
    
    NSMutableArray *pathNodes = [[NSMutableArray alloc] init];
    [pathNodes addObject:start];
    [pathNodes addObject:midPoint];
    [pathNodes addObject:midPoint2];
    [pathNodes addObject:end];
    
    ClayPathMaker *dij = [[ClayPathMaker alloc] initWithEdges:[result edges]
                                                   nodesForPath:pathNodes
                                                      andBounds:[voronoiview bounds]];
    [voronoiview setDijkstraPathPoints:[dij pathNodes]];
    
    [voronoiview setNeedsDisplay:YES];

    [drawButton setTitle:@"Draw Again"];
    
}

@end
