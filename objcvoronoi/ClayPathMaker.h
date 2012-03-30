//
//  ClayPathMaker.h
//  objcvoronoi
//


#import <Foundation/Foundation.h>

@class Edge;
@class Vertex;

@interface ClayPathMaker : NSObject {
    NSMutableArray *solution;
    NSMutableArray *edges;
    NSMutableArray *newEdges;
    NSPoint startPoint;
    NSPoint endPoint;
    Vertex *startVertex;
    Vertex *endVertex;
    NSRect theBounds;
    NSMutableDictionary *vertices;
    
    NSMutableArray *pathNodes;
    
    NSMutableArray *points;
    
    int pathsToCalculate;
    
    BOOL workingOnFirstPath;
    BOOL workingOnLastPath;
}

@property (copy, readwrite) NSMutableArray *edges;
@property (retain, readwrite) NSMutableArray *points;
@property (assign, readwrite) NSPoint startPoint;
@property (assign, readwrite) NSPoint endPoint;
@property (retain, readwrite) Vertex *startVertex;
@property (retain, readwrite) Vertex *endVertex;
@property (assign, readwrite) NSRect theBounds;

+ (BOOL)equalWithEpsilonA:(float)a andB:(float)b;

- (id)initWithEdges:(NSMutableArray *)voronoiEdges nodesForPath:(NSMutableArray *)pointsArray andBounds:(NSRect)bbox;
- (NSMutableArray *)solution;
- (void)calculate;
- (float)distanceFromPoint:(NSPoint)pt toVertex:(Vertex *)dv;
- (BOOL)boundingBoxSharesEdgeWithVertex:(Vertex *)dv;
- (void)prepareData;
- (void)setStartAndEndForPathNum:(int)pathNum;
- (void)pathByClay;
- (NSMutableArray *)pathNodes;
- (Vertex *)vertexMatchingByPosition:(Vertex *)v;

@end