//
//  VoronoiView.m
//  objcvoronoi
//
//  Created by Clay Heaton on 3/27/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import "VoronoiView.h"
#import "Cell.h"
#import "Halfedge.h"
#import "Edge.h"
#import "Site.h"
#import "Vertex.h"

@implementation VoronoiView
@synthesize sites, cells;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self setBounds:NSMakeRect(0, 0, 100, 100)];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [NSGraphicsContext saveGraphicsState];
    
    // Fill the background white
    [[NSColor whiteColor]set];
    [NSBezierPath fillRect:[self bounds]];
    
    [[NSColor blackColor] set];
    
    for (NSValue *v in sites) {
        NSBezierPath *p = [[NSBezierPath alloc] init];
        [p appendBezierPathWithArcWithCenter:[v pointValue] radius:0.2 startAngle:0 endAngle:360];
        [p fill];
        
    }
    
    for (Cell *c in cells) {
        // NSLog(@"Cell halfedges: %@", [c halfedges]);
        for (Halfedge *he in [c halfedges]) {
            NSPoint p1 = [[[he edge] va] coord];
            NSPoint p2 = [[[he edge] vb] coord];
            NSBezierPath *p = [[NSBezierPath alloc] init];
            [p setLineWidth:0.2];
            [p moveToPoint:p1];
            [p lineToPoint:p2];
            [p stroke];
        }
    }
    
    [NSGraphicsContext restoreGraphicsState];
}

@end
