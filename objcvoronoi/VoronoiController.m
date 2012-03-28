//
//  VoronoiController.m
//  objcvoronoi
//
//  Created by Clay Heaton on 3/27/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import "VoronoiController.h"
#import "Voronoi.h"
#import "VoronoiResult.h"
#import "VoronoiView.h"
#import "Site.h"
#import "Cell.h"

@implementation VoronoiController


- (IBAction)testVoronoi:(id)sender
{
    //NSLog(@"Testing Voronoi...");
    voronoi = [[Voronoi alloc] init];
    
    // Send in sites as NSPoints that have been converted to NSValue
    
    NSMutableArray *sites = [[NSMutableArray alloc] init];
    
    float xMax = [voronoiview bounds].size.width;
    float yMax = [voronoiview bounds].size.height;
    
    for (int i = 0; i < 1000; i++) {
        float x = arc4random() % (int)xMax;
        float y = arc4random() % (int)yMax;
        NSValue *v = [NSValue valueWithPoint:NSMakePoint(x, y)];
        //NSLog(@"Point: (%i, %i)", (int)x, (int)y);
        [sites addObject:v];
    }
   
    /*
    NSValue *v5 = [NSValue valueWithPoint:NSMakePoint(5, 56)];
    [sites addObject:v5];
    
    NSValue *v10 = [NSValue valueWithPoint:NSMakePoint(77, 19)];
    [sites addObject:v10];
    
    NSValue *v12 = [NSValue valueWithPoint:NSMakePoint(95, 55)];
    [sites addObject:v12];
    
    NSValue *v13 = [NSValue valueWithPoint:NSMakePoint(34, 53)];
    [sites addObject:v13];
     */
    
    VoronoiResult *result = [voronoi computeWithSites:sites andBoundingBox:[voronoiview bounds]];
    
    NSMutableArray *sitesFromCells = [[NSMutableArray alloc] init];
    
    for (Cell *c in [result cells]) {
        Site *s = [c site];
        [sitesFromCells addObject:[s coordAsValue]];
    }
    
    [voronoiview setSites:sitesFromCells];
    [voronoiview setCells:[result cells]];
    
    
    [voronoiview setNeedsDisplay:YES];
    
    // NSLog(@"result edges: %@", [result edges]);
    
}

@end
