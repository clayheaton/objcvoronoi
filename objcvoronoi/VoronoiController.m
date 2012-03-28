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
    NSLog(@"Testing Voronoi...");
    voronoi = [[Voronoi alloc] init];
    
    // Send in sites as NSPoints that have been converted to NSValue
    
    NSMutableArray *sites = [[NSMutableArray alloc] init];
    
    /*
    for (int i = 0; i < 5; i++) {
        float x = arc4random() % 95 + 1;
        float y = arc4random() % 95 + 1;
        NSValue *v = [NSValue valueWithPoint:NSMakePoint(x, y)];
        NSLog(@"Point: (%i, %i)", (int)x, (int)y);
        [sites addObject:v];
    } */
   
    
    NSValue *v5 = [NSValue valueWithPoint:NSMakePoint(64, 14)];
    [sites addObject:v5];
    
    NSValue *v10 = [NSValue valueWithPoint:NSMakePoint(80, 83)];
    [sites addObject:v10];
    
    NSValue *v12 = [NSValue valueWithPoint:NSMakePoint(59, 18)];
    [sites addObject:v12];
    
    NSValue *v13 = [NSValue valueWithPoint:NSMakePoint(29, 33)];
    [sites addObject:v13];
    
    
    VoronoiResult *result = [voronoi computeWithSites:sites andBoundingBox:NSMakeRect(0, 0, 100, 100)];
    
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
