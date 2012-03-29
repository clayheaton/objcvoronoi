//
//  VoronoiView.m
//  objcvoronoi
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
    }
    
    return self;
}

/* Can be useful for testing
 
- (BOOL)isFlipped
{
    return YES;
}
 
*/

- (void)drawRect:(NSRect)dirtyRect
{
    [NSGraphicsContext saveGraphicsState];
    
    // Fill the background white
    [[NSColor whiteColor]set];
    [NSBezierPath fillRect:[self bounds]];
    
    
    [[NSColor redColor] set];
    
    for (NSValue *v in sites) {
        NSBezierPath *p = [[NSBezierPath alloc] init];
        [p appendBezierPathWithArcWithCenter:[v pointValue] radius:0.8 startAngle:0 endAngle:360];
        [p fill];
        
    }
    
    [[NSColor blackColor] set];
    
    for (Cell *c in cells) {
        for (Halfedge *he in [c halfedges]) {
            NSPoint p1 = [[[he edge] va] coord];
            NSPoint p2 = [[[he edge] vb] coord];
            NSBezierPath *p = [[NSBezierPath alloc] init];
            [p setLineWidth:0.3];
            [p moveToPoint:p1];
            [p lineToPoint:p2];
            [p stroke];
        }
    }
    
    [NSGraphicsContext restoreGraphicsState];
}

@end
