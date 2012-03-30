//
//  Vertex.m
//  objcvoronoi
//

#import "Vertex.h"
#import "Edge.h"

static int identifier = 0;

@implementation Vertex
@synthesize visited, target, distance;

- (id)initWithCoord:(NSPoint)tempCoord
{
    self = [super initWithCoord:tempCoord];
    if (self) {
        uniqueID = identifier;
        identifier++;
        [self setVisited:NO];
        [self setTarget:NO];
        [self setDistance:INFINITY];
        edges = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithValue:(NSValue *)valueWithCoord
{
    self = [super initWithValue:valueWithCoord];
    if (self) {
        uniqueID = identifier;
        identifier++;
        [self setVisited:NO];
        [self setTarget:NO];
        [self setDistance:INFINITY];
        edges = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"x: %f, y: %f", [self x], [self y]];
}

- (NSString *)uniqueID
{
    return [NSString stringWithFormat:@"%i", uniqueID];
}

- (int)uniqueIDAsInt
{
    return uniqueID;
}

- (float)distanceToVertex:(Vertex *)v
{
    float x1 = [self coord].x;
    float y1 = [self coord].y;
    float x2 = [v    coord].x;
    float y2 = [v    coord].y;
    
    float a = fabsf(x2 - x1);
    float b = fabsf(y2 - y1);
    
    return sqrtf(a*a + b*b);
}

- (void)addEdge:(Edge *)e
{
    if (![edges containsObject:e]) {
        [edges addObject:e];
    }
}

- (NSMutableArray *)neighborKeys
{
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    
    if ([edges count] == 0) {
        return keys;
    }
    
    // We know that this vertex is associated with each edge in the edges array
    // We have to figure out which vertex it is on each edge and then store the
    // uniqueID of the other vertex in 
    
    for (Edge *e in edges) {
        Vertex *otherVertex;
        if ([self uniqueID] == [[e va] uniqueID]) {
            otherVertex = [e vb];
        } else if ([self uniqueID] == [[e vb] uniqueID]) {
            otherVertex = [e va];
        }
        NSAssert(otherVertex != nil, @"Vertex: neighborKeys -- otherVertex is nil");
        [keys addObject:[otherVertex uniqueID]];
    }
    return keys;
}

@end
