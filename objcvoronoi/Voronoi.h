//
//  Voronoi.h
//  objcvoronoi
//
//  Created by Clay Heaton on 3/22/12.

#import <Foundation/Foundation.h>

@class RBTree;
@class CircleEvent;
@class Beachsection;
@class Site;
@class VoronoiResult;
@class Edge;
@class Vertex;

@interface Voronoi : NSObject {
    NSMutableArray *edges;
    NSMutableArray *cells;
    NSMutableArray *beachsectionJunkyard;
    NSMutableArray *circleEventJunkyard;
    
    RBTree *beachline;
    RBTree *circleEvents;
    
    CircleEvent *firstCircleEvent;
    
    NSMutableArray *sites;
    NSRect boundingBox;
    
}

@property (retain, readwrite) CircleEvent *firstCircleEvent;

@property (assign, readwrite) NSRect boundingBox;

- (VoronoiResult *)computeWithSites:(NSMutableArray *)siteList andBoundingBox:(NSRect)bbox;
- (void)reset;

- (Beachsection *)createBeachsection:(Site *)site;
- (void)addBeachsection:(Site *)site;
- (void)removeBeachsection:(Beachsection *)bs;
- (void)detachBeachsection:(Beachsection *)bs;

- (float)rightBreakPointWithArc:(Beachsection *)arc andDirectrix:(float)directrix;
- (float)leftBreakPointWithArc:(Beachsection *)arc andDirectrix:(float)directrix;

- (void)setEdgeStartPointWithEdge:(Edge *)tempEdge lSite:(Site *)tempLSite rSite:(Site *)tempRSite andVertex:(Vertex *)tempVertex;
- (void)setEdgeEndPointWithEdge:(Edge *)tempEdge lSite:(Site *)tempLSite rSite:(Site *)tempRSite andVertex:(Vertex *)tempVertex;

- (void)closeCells:(NSRect)bbox;

- (void)attachCircleEvent:(Beachsection *)arc;
- (void)detachCircleEvent:(Beachsection *)arc;

- (Edge *)edgeWithSite:(Site *)lSite andSite:(Site *)rSite;
- (Edge *)createEdgeWithSite:(Site *)lSite andSite:(Site *)rSite andVertex:(Vertex *)va andVertex:(Vertex *)vb;
- (Edge *)createBorderEdgeWithSite:(Site *)lSite andVertex:(Vertex *)va andVertex:(Vertex *)vb;

- (BOOL)connectEdge:(Edge *)edge withBoundingBox:(NSRect)bbox;
- (BOOL)clipEdge:(Edge *)edge withBoundingBox:(NSRect)bbox;
- (void)clipEdges:(NSRect)bbox;

#pragma mark Math methods
// Basic math methods handled by the class
+ (BOOL)equalWithEpsilonA:(float)a andB:(float)b;
+ (BOOL)greaterThanWithEpsilonA:(float)a andB:(float)b;
+ (BOOL)greaterThanOrEqualWithEpsilonA:(float)a andB:(float)b;
+ (BOOL)lessThanWithEpsilonA:(float)a andB:(float)b;
+ (BOOL)lessThanOrEqualWithEpsilonA:(float)a andB:(float)b;



@end
