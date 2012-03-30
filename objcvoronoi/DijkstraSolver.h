//
//  DijkstraSolver.h
//  objcvoronoi
//
//  Created by Clay Heaton on 3/29/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Edge;
@class Vertex;

@interface DijkstraSolver : NSObject {
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
}

@property (copy, readwrite) NSMutableArray *edges;
@property (retain, readwrite) NSMutableArray *points;
@property (assign, readwrite) NSPoint startPoint;
@property (assign, readwrite) NSPoint endPoint;
@property (retain, readwrite) Vertex *startVertex;
@property (retain, readwrite) Vertex *endVertex;
@property (assign, readwrite) NSRect theBounds;

+ (BOOL)equalWithEpsilonA:(float)a andB:(float)b;

- (id)initWithEdges:(NSMutableArray *)voronoiEdges theStartPoint:(NSPoint)stPt theEndPoint:(NSPoint)endPt andBounds:(NSRect)bbox;
- (NSMutableArray *)solution;
- (void)calculate;
- (float)distanceFromPoint:(NSPoint)pt toVertex:(Vertex *)dv;
- (BOOL)boundingBoxSharesEdgeWithVertex:(Vertex *)dv;
- (void)prepareDijkstra;
- (void)traditionalDijkstra;
- (void)pathByClay;
- (NSMutableArray *)pathNodes;
- (Vertex *)vertexMatchingByPosition:(Vertex *)v;

@end
