//
//  Voronoi.m
//  objcvoronoi
//
//  Created by Clay Heaton on 3/22/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import "Voronoi.h"
#import "RBTree.h"
#import "Beachsection.h"
#import "CircleEvent.h"
#import "Site.h"
#import "Cell.h"
#import "VoronoiResult.h"
#import "Edge.h"
#import "Vertex.h"
#import "Halfedge.h"

@implementation Voronoi
@synthesize firstCircleEvent, boundingBox;

- (id)init
{
    self = [super init];
    if (self) {
        sites = [[NSMutableArray alloc] init];
        edges = [[NSMutableArray alloc] init];
        cells = [[NSMutableArray alloc] init];
        beachsectionJunkyard = [[NSMutableArray alloc] init];
        circleEventJunkyard  = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (VoronoiResult *)computeWithSites:(NSMutableArray *)siteList andBoundingBox:(NSRect)bbox
{
    /////////////////////////////////////////////////////////////////////////////
    // siteList comes in as an array of NSPoints stored as NSValues.           //
    // Convert them to Site class and then make sites an array of Site objects //
    /////////////////////////////////////////////////////////////////////////////
    
    [self reset];
    
    for (NSValue *v in siteList) {
        Site *s = [[Site alloc] initWithValue:v];
        [sites addObject:s];
    }
    
    [self setBoundingBox:bbox];
    
    NSMutableArray *siteEvents = [[NSMutableArray alloc] initWithArray:sites];
    [Site sortSites:siteEvents];
    //NSLog(@"Sorted siteEvents: %@", siteEvents);
    Site *site = [siteEvents lastObject];
    [siteEvents removeLastObject];
    
    int siteid = 0;
    
    float xsitex = FLT_MIN; // To avoid duplicate sites
    float xsitey = FLT_MIN;
    //NSLog(@"%f", xsitex);
    CircleEvent *circle;
    
    ///////////////
    // Main Loop //
    ///////////////
    
    for (;;) {
        ////////////////////////////////////////////////////////////////////
        // We need to figure out whether we handle a site or circle event //
        // For this we find out if there is a site event and it is        //
        // 'earlier' than the circle event                                //
        ////////////////////////////////////////////////////////////////////
        
        circle = [self firstCircleEvent];
        // Add Beach Section
        
        if (site && (!circle || site.y < circle.y || (site.y == circle.y && site.x < circle.x))) {
            // Only if site is not a duplicate
            if (site.x != xsitex || site.y != xsitey) {
                // First, create cell for the new site
                [cells addObject:[[Cell alloc] initWithSite:site]];
                //NSLog(@"cells: %@", cells);
                [site setVoronoiId:siteid];
                siteid += 1;

                // Then create a beachsection for that site
                [self addBeachsection:site];                        
                
                // Remember last site coords to detect duplicates
                xsitey = [site y];
                xsitex = [site x];
            }
            site = [siteEvents lastObject];
            [siteEvents removeLastObject];
            
        } else if (circle) {
            // remove beach section
            [self removeBeachsection:[circle arc]];                 /// PROBLEM HERE!!!!!!!
            
        } else {
            // all done, quit
            break;
        }
    }
    
    ////////////////////////////////////////////////////////////////////
    // Wrapping up:                                                   //
    // - connect dangling edges to bounding box                       //
    // - cut edges as per bounding box                                //
    // - discard edges completely outside bounding box                //
    // - discard edges which are point-like                           //
    ////////////////////////////////////////////////////////////////////
    
    [self clipEdges:[self boundingBox]];
    
    // - add missing edges in order to close opened cells
    [self closeCells:[self boundingBox]];
    
    // - prepare return values
    VoronoiResult *result = [[VoronoiResult alloc] init];
    [result setCells:cells];
    [result setEdges:edges];
    
    return result;
}

- (void)reset
{
    if (!beachline) {
        beachline = [[RBTree alloc] init];
    }
    
    // Move leftover beachsections to the beachsection junkyard.
    if ([beachline root]) {
        Beachsection *beachsection = [beachline getFirst:[beachline root]];
        while (beachsection) {
            [beachsectionJunkyard addObject:beachsection]; // mark for reuse
            beachsection = [beachsection rbNext];
        }
    }
    
    [beachline setRoot:nil];
    if (!circleEvents) {
        circleEvents = [[RBTree alloc] init];
    }
    [circleEvents setRoot:nil];
    [self setFirstCircleEvent:nil];
    [edges removeAllObjects];
    [cells removeAllObjects];
    [sites removeAllObjects];
}

// Probably unnecessary but created to have parity with the javascript version
// Could just call to Beachsection directly...

- (Beachsection *)createBeachsection:(Site *)site
{
    return [Beachsection createBeachSectionFromJunkyard:beachsectionJunkyard withSite:site];
}

// TODO: Revisit FLT_EPISILON vs. 1e-9
- (void)addBeachsection:(Site *)site
{
    float x = site.x;
    float directrix = site.y;
    
    //////////////////////////////////////////////////////////////////////////
    // Find the left and right beach sections which will surround the newly //
    // created beach section.                                               //
    //////////////////////////////////////////////////////////////////////////
    
    Beachsection *node = [beachline root];
    Beachsection *lArc, *rArc;
    float dxl, dxr;
    
    if (node == nil) {
        NSLog(@"node is nil");
    }
    
    while (node) {
        dxl = [self leftBreakPointWithArc:node andDirectrix:directrix] - x;
        if (dxl > 1e-9) {
            node = node.rbLeft;
            //NSLog(@"while(node) case 1");
        } else {
            //NSLog(@"while(node) case 2");
            dxr = x - [self rightBreakPointWithArc:node andDirectrix:directrix];
            if (dxr > 1e-9) {
                if (![node rbRight]) {
                    //NSLog(@"while(node) case 3");
                    lArc = node;
                    break;
                }
                //NSLog(@"while(node) case 4");
                node = [node rbRight];
            } else {
                if (dxl > -1e-9) {
                    //NSLog(@"while(node) case 5");
                    lArc = [node rbPrevious];
                    rArc = node;
                } else if (dxr > -1e-9) {
                    //NSLog(@"while(node) case 6");
                    lArc = node;
                    rArc = [node rbNext];
                } else {
                    //NSLog(@"while(node) case 7");
                    rArc = node;
                    lArc = node;
                }
                break;
            }
        }
    }
    
    //////////////////////////////////////////////////////////////////////////
    // At this point, keep in mind that lArc and/or rArc could be undefined //
    // or nil.                                                              //
    //////////////////////////////////////////////////////////////////////////
    //NSLog(@"lArc: %@", lArc == nil ? @"lArc is nil" : @"lArc");
    // NSLog(@"rArc: %@", rArc == nil ? @"rArc is nil" : @"rArc");
    
    // Create a new beach section object for the site and add it to RB-tree
    Beachsection *newArc = [self createBeachsection:site];
    [beachline rbInsertSuccessorForNode:lArc withSuccessor:newArc];
    //NSLog(@"beachline: %@", beachline);
    // Cases:
    
    // [null, null]
    // Least likely case: new beach section is the first beach section on the beachline.
    // This case means:
    //  No new transition appears
    //  No collapsing beach section
    //  New beachsection becomes root of the RB-tree
    
    if (!lArc && !rArc) {
        NSLog(@"addBeachSection case 1");
        return;
    }
    
    // [lArc, rArc] where larc == rArc
    // Most likely case: new beach section split an existing beach section
    // This case means:
    //  One new transition appears
    //  The left and right beach section might be collapsing as a result
    //  Two new nodes added to the RB-tree
    
    if (lArc == rArc) {
        NSLog(@"addBeachSection case 2");
        // Invalidate the circle event of split beach section
        [self detachCircleEvent:lArc];
        
        // Split the beach section into two separate beach sections
        rArc = [self createBeachsection:[lArc site]];
        [beachline rbInsertSuccessorForNode:newArc withSuccessor:rArc];
        
        // since we have a new transition between two beach sections, a new edge is born
        Edge *e = [self createEdgeWithSite:[lArc site] andSite:[newArc site] andVertex:nil andVertex:nil];
        [rArc setEdge:e];
        [newArc setEdge:e];
        
        // Check whether the left and right beach sections are collapsing
        // and if so, create circle events, to be notified when the point of
        // collapse is reached.
        [self attachCircleEvent:lArc];
        [self attachCircleEvent:rArc];
        return;
    }
    
    // [lArc, null]
    // Even less likely case: new beach section is the *last* beach section on the beachline
    // This can happen *only* if *all* the previous beach sections currently on the beachline
    // share the same y value as the new beach section.
    // This case means:
    //  One new transition appears
    //  No collapsing beach section as a result
    // New beach section becomes right-most node of the RB-tree
    if (lArc && !rArc) {
        NSLog(@"addBeachSection case 3");
        Edge *e2 = [self createEdgeWithSite:[lArc site] andSite:[newArc site] andVertex:nil andVertex:nil];
        [newArc setEdge:e2];
        return;
    }
    
    // [null, rArc]
    // Impossible case: because sites are strictly processed from top to bottom,
    // and left to right, which guarantees that there will always be a beach section
    // on the left -- except of course when there are no beach sections at all on the beachline,
    // which case was handled above.
    // NOT IMPLEMENTED HERE -- SEE ORIGINAL JAVASCRIPT WHERE IT IS COMMENTED OUT
    
    // [lArc, rArc] where lArc != rArc
    // Somewhat less likely case: new beach section falls *exactly* in between two existing sections
    // This case means:
    //  One transition disappears
    //  Two new transitions appear
    //  The left and right beach section might be collapsing as a result
    //  Only one new node added to the RB-tree
    if (lArc != rArc) {
        NSLog(@"addBeachSection case 4");
        // invalidate circle events of left and right sites
        [self detachCircleEvent:lArc];
        [self detachCircleEvent:rArc];
        
        // An existing transition disappears, meaning a vertex is defined at the disappearance point.
        // Since the disappearance is caused by the new beachsection, the 
        // vertex is at the center of the circumscribed circle of the left,
        // new and right beachsections.
        // http://mathforum.org/library/drmath/view/55002.html
        // Except that I bring the origin at A to simplify calculation
        Site *lSite = [lArc site];
        float ax = lSite.x;
        float ay = lSite.y;
        float bx = site.x - ax;
        float by = site.y - ay;
        
        Site *rSite = [rArc site];
        float cx = rSite.x - ax;
        float cy = rSite.y - ay;
        float d = 2 * (bx * cy - by * cx);
        float hb = bx * bx + by * by;
        float hc = cx * cx + cy * cy;
        
        Vertex *vertex = [[Vertex alloc] initWithCoord:NSMakePoint((cy*hb - by*hc)/d+ax,(bx*hc - cx*hb)/d+ay)];
        
        // One transition disappears
        [self setEdgeStartPointWithEdge:[rArc edge]
                                  lSite:lSite
                                  rSite:rSite
                              andVertex:vertex];
        
        // Two new transitions appear at the new vertex location
        [newArc setEdge:[self createEdgeWithSite:lSite
                                         andSite:site
                                       andVertex:nil 
                                       andVertex:vertex]];
        
        //NSLog(@"Here 1");
        
        [rArc setEdge:[self createEdgeWithSite:site
                                       andSite:rSite 
                                     andVertex:nil 
                                     andVertex:vertex]];
        
        // Check whether the left and right beach sections are collapsing
        // and if so create circle events, to handle the point of collapse
        [self attachCircleEvent:lArc];
        [self attachCircleEvent:rArc];
        return;
    }
}

- (void)removeBeachsection:(Beachsection *)bs
{
    CircleEvent *circle = [bs circleEvent]; // Problem with circleEvent having the wrong coord value?
    float x = [circle x];
    float y = [circle ycenter];
    Vertex *vertex = [[Vertex alloc] initWithCoord:NSMakePoint(x, y)];
    Beachsection *previous = [bs rbPrevious];
    Beachsection *next = [bs rbNext];
    NSMutableArray *disappearingTransitions = [[NSMutableArray alloc] initWithObjects:bs, nil];
    
    // Remove collapsed beachsection from beachline
    [self detachBeachsection:bs];
    
    // There could be more than one empty arc at the deletion point, this
    // happens when more than two edges are linked by the same vertex,
    // so we will collect all those edges by looking up both sides of 
    // the deletion point.
    // By the way, there is *always* a predecessor/successor to any collapsed
    // beach section, it's just impossible to have a collapsing first/last
    // beach section on the beachline, since they obviously are unconstrained
    // on their left/right side.
    
    // look left
    Beachsection *lArc = previous;
    while ([lArc circleEvent] && fabs(x - [[lArc circleEvent] x]) < 1e-9 && fabs(y - [[lArc circleEvent] ycenter]) < 1e-9) {
        previous = [lArc rbPrevious];
        [disappearingTransitions insertObject:lArc atIndex:0];
        [self detachBeachsection:lArc]; // Mark for reuse
        lArc = previous;
    }
    
    // Even thought it is not disappearing, I will also add the beach section
    // immediately to the left of the left-most collapsed beach section, for
    // convenience, since we need to reer to it later as this beach section
    // is the 'left' site of an edge for which a start point is set
    
    [disappearingTransitions insertObject:lArc atIndex:0];
    [self detachCircleEvent:lArc];
    
    // look right
    Beachsection *rArc = next;
    while ([rArc circleEvent] && fabs(x - [[rArc circleEvent] x]) < 1e-9 && fabs(y - [[rArc circleEvent] ycenter]) < 1e-9) {
        next = [rArc rbNext];
        [disappearingTransitions addObject:rArc];
        [self detachBeachsection:rArc]; // mark for reuse
        rArc = next;
    }
    
    // We also have to add the beach section immediately to the right of the
    // right-most collapsed beach section, since there is also a disappearing
    // transition representing an edge's start point on its left
    
    [disappearingTransitions addObject:rArc];
    [self detachCircleEvent:rArc];
    
    // Walk through all the disappearing transitions between beach sections and
    // set the start point of their (implied) edge
    
    int nArcs = (int)[disappearingTransitions count];
    for (int iArc = 1; iArc < nArcs; iArc++) {
        rArc = [disappearingTransitions objectAtIndex:iArc];
        lArc = [disappearingTransitions objectAtIndex:(iArc - 1)];
        [self setEdgeStartPointWithEdge:[rArc edge] lSite:[lArc site] rSite:[rArc site] andVertex:vertex];
    }
    
    // Create a new edge as we have now a new transition between
    // two beach sections which were previously not adjacent.
    // Since this edge appears as a new vertex is defined, the vertex
    // actually define an end point of the edge (relative to the site
    // on the left)
    
    lArc = [disappearingTransitions objectAtIndex:0];
    rArc = [disappearingTransitions objectAtIndex:(nArcs - 1)];
    [rArc setEdge:[self createEdgeWithSite:[lArc site] andSite:[rArc site] andVertex:nil andVertex:vertex]];
    
    NSLog(@"Removing Beach Section");
    
    // Create circle events if any foor beach sections nleft in the beachline
    // adjacent to collapsed sections
    [self attachCircleEvent:lArc];
    [self attachCircleEvent:rArc];
}

- (void)detachBeachsection:(Beachsection *)bs
{
    // Detach potentially attached circle event
    [self detachCircleEvent:bs];
    [beachline rbRemoveNode:bs];
    [beachsectionJunkyard addObject:bs];
    
}

- (float)rightBreakPointWithArc:(Beachsection *)arc 
                   andDirectrix:(float)directrix
{
    Beachsection *rArc = [arc rbNext];
    if (rArc) {
        return [self leftBreakPointWithArc:rArc andDirectrix:directrix];
    }
    Site *site = [arc site];
    return [site y] == directrix ? [site x] : INFINITY;
}

// Calculate the left break point of a particular beach section, given a particular sweep line
// TODO: Check that the !pby2 call is legit; might need to check value at zero
- (float)leftBreakPointWithArc:(Beachsection *)arc 
                  andDirectrix:(float)directrix
{
    // http://en.wikipedia.org/wiki/Parabola
	// http://en.wikipedia.org/wiki/Quadratic_equation
	// h1 = x1,
	// k1 = (y1+directrix)/2,
	// h2 = x2,
	// k2 = (y2+directrix)/2,
	// p1 = k1-directrix,
	// a1 = 1/(4*p1),
	// b1 = -h1/(2*p1),
	// c1 = h1*h1/(4*p1)+k1,
	// p2 = k2-directrix,
	// a2 = 1/(4*p2),
	// b2 = -h2/(2*p2),
	// c2 = h2*h2/(4*p2)+k2,
	// x = (-(b2-b1) + Math.sqrt((b2-b1)*(b2-b1) - 4*(a2-a1)*(c2-c1))) / (2*(a2-a1))
	// When x1 become the x-origin:
	// h1 = 0,
	// k1 = (y1+directrix)/2,
	// h2 = x2-x1,
	// k2 = (y2+directrix)/2,
	// p1 = k1-directrix,
	// a1 = 1/(4*p1),
	// b1 = 0,
	// c1 = k1,
	// p2 = k2-directrix,
	// a2 = 1/(4*p2),
	// b2 = -h2/(2*p2),
	// c2 = h2*h2/(4*p2)+k2,
	// x = (-b2 + Math.sqrt(b2*b2 - 4*(a2-a1)*(c2-k1))) / (2*(a2-a1)) + x1
    
    // Change the code below at your own risk: care has been taken to reduce errors due to 
    // computers' finite arithmetic precision.
    // Maybe can still be improved, will see if any more of this
    // kind of errors pop up again.
    
    Site *site = [arc site];
    float rfocx = [site x];
    float rfocy = [site y];
    float pby2 = rfocy - directrix;
    
    // Parabola in degenerate case where focus is on directrix
    if (!pby2) {
        return rfocx;
    }
    
    Beachsection *lArc = [arc rbPrevious];
    if (!lArc) {
        return -INFINITY;
    }
    
    site = [lArc site];
    float lfocx = [site x];
    float lfocy = [site y];
    float plby2 = lfocy - directrix;
    
    // Parabola in degenerate case where focus is on directrix
    if (!plby2) {
        return lfocx;
    }
    
    float hl = lfocx - rfocx;
    float aby2 = 1/pby2 - 1/plby2;
    float b = hl/plby2;
    if (aby2) {
        return (-b + sqrtf(b*b-2*aby2*(hl*hl/(-2*plby2)-lfocy+plby2/2+rfocy-pby2/2)))/aby2+rfocx;
    }
    
    // Both parabolas have same distance to directrix, thus break point is midway
    return (rfocx+lfocx)/2;
}

- (void)setEdgeStartPointWithEdge:(Edge *)tempEdge 
                            lSite:(Site *)tempLSite 
                            rSite:(Site *)tempRSite 
                        andVertex:(Vertex *)tempVertex
{
    if (![tempEdge va] && ![tempEdge vb]) {
        [tempEdge setVa:tempVertex];
        [tempEdge setLSite:tempLSite];
        [tempEdge setRSite:tempRSite];
    } else if ([tempEdge lSite] == tempRSite) {
        [tempEdge setVb:tempVertex];
    } else {
        [tempEdge setVa:tempVertex];
    }
}

- (void)setEdgeEndPointWithEdge:(Edge *)tempEdge 
                          lSite:(Site *)tempLSite 
                          rSite:(Site *)tempRSite 
                      andVertex:(Vertex *)tempVertex
{
    [self setEdgeStartPointWithEdge:tempEdge lSite:tempRSite rSite:tempLSite andVertex:tempVertex];
}

- (void)attachCircleEvent:(Beachsection *)arc
{
    Beachsection *lArc = [arc rbPrevious];
    Beachsection *rArc = [arc rbNext];
    
    if (!lArc || !rArc) {
        return; // This might never happen...
    }
    
    Site *lSite = [lArc site];
    Site *cSite = [arc site];
    Site *rSite = [rArc site];
    
    // If site of left beachsection is same as site of right beachsection, there can't be convergence
    if (lSite == rSite) {
        return;
    }
    
    // Find the circumscribed circle for the three sites associated
    // with the beachsection triplet.
    // It is more efficient to calculate in-place
    // rather than getting the resulting circumscribed circle from an
    // object returned by calling Voronoi.circumcircle()
    // http://mathforum.org/library/drmath/view/55002.html
    // Except that I bring the origin at cSite to simplify calculations.
    // The bottom-most part of the circumcircle is our Fortune 'circle event'
    // and its center is a vertex potentially part of the final Voronoi diagram
    
    float bx = cSite.x;
    float by = cSite.y;
    float ax = lSite.x - bx;
    float ay = lSite.y - by;
    float cx = rSite.x - bx;
    float cy = rSite.y - by;
    
    // If points l -> c -> r are clockwise, then center beach section does not
    // collapse, hence it can't end up as a vertex (we reuse 'd' here, which
    // sign is reverse of the orientation, hence we reverse the test.
    // http://en.wikipedia.org/wiki/Curve_orientation#Orientation_of_a_simple_polygon
    // Nasty finite precision error which caused circumcircle() to return infinites.
    // 1e-12 seems to fix the problem.
    
    float d = 2 * (ax*cy - ay*cx);
    if (d >= -2e-12) {
        return;
    }
    
    float ha = ax*ax + ay*ay;
    float hc = cx*cx + cy*cy;
    float x = (cy*ha - ay*hc) / d;
    float y = (ax*hc - cx*ha) / d;
    float ycenter = y + by;
    
    // Important: ybottom should always be under or at sweep, so no need to waste CPU cycles by checking
    
    // recycle circle event object if possible
    CircleEvent *circleEvent;
    if ([circleEventJunkyard count] > 0) {
        circleEvent = [circleEventJunkyard lastObject];
        [circleEventJunkyard removeLastObject];
    } else {
        circleEvent = [[CircleEvent alloc] init];
    }
    
    [circleEvent setArc:arc];
    [circleEvent setSite:cSite];
    [circleEvent setX:(x+bx)];
    [circleEvent setY:(ycenter + sqrtf(x*x+y*y))];
    [circleEvent setYcenter:ycenter];
    [arc setCircleEvent:circleEvent];
    
    // Find insertion point in RB-tree: circle events are ordered from smallest to largest
    
    CircleEvent *predecessor;
    CircleEvent *node = [circleEvents root];
    
    while (node) {
        if ([circleEvent y] < [node y] || ([circleEvent y] == [node y] && [circleEvent x] <= [node x])) {
            if ([node rbLeft]) {
                node = [node rbLeft];
            } else {
                predecessor = [node rbPrevious];
                break;
            }
        } else {
            if ([node rbRight]) {
                node = [node rbRight];
            } else {
                predecessor = node;
                break;
            }
        }
    }
    [circleEvents rbInsertSuccessorForNode:predecessor withSuccessor:circleEvent];
    if (!predecessor) {
        [self setFirstCircleEvent:circleEvent];
    }
}

- (void)detachCircleEvent:(Beachsection *)arc
{
    CircleEvent *circle = [arc circleEvent];
    if (circle) {
        if (![circle rbPrevious]) {
            firstCircleEvent = [circle rbNext];
        }
        [circleEvents rbRemoveNode:circle]; // Remove from RB-tree
        [circleEventJunkyard addObject:circle];
        [arc setCircleEvent:nil];
    }
}

- (Edge *)edgeWithSite:(Site *)lSite andSite:(Site *)rSite
{
    return [[Edge alloc] initWithLSite:lSite andRSite:rSite];
}

- (Edge *)createEdgeWithSite:(Site *)lSite andSite:(Site *)rSite andVertex:(Vertex *)va andVertex:(Vertex *)vb
{
    // This creates and adds an edge to the internal collection, and also creates
    // two halfedges which are added to each site's counterclockwise array
    // of halfedges
    
    Edge *edge = [self edgeWithSite:lSite andSite:rSite];
    
    [edges addObject:edge];
    NSLog(@"number of edges: %lu", [edges count]);
    
    if (va) {
        [self setEdgeStartPointWithEdge:edge lSite:lSite rSite:rSite andVertex:va];
    }
    if (vb) {
        [self setEdgeEndPointWithEdge:edge lSite:lSite rSite:rSite andVertex:vb];
    }
    
    // Double check that all is ok here...
    
    Cell *lCell = [cells objectAtIndex:[lSite voronoiId]];
    [lCell addHalfedgeToArray:[[Halfedge alloc] initWithEdge:edge lSite:lSite andRSite:rSite]];             // Potential problem area
    
    Cell *rCell = [cells objectAtIndex:[rSite voronoiId]];
    [rCell addHalfedgeToArray:[[Halfedge alloc] initWithEdge:edge lSite:rSite andRSite:lSite]];
    
    return edge;
    
}

- (Edge *)createBorderEdgeWithSite:(Site *)lSite andVertex:(Vertex *)va andVertex:(Vertex *)vb
{
    
    Edge *edge = [self edgeWithSite:lSite andSite:nil];
    [edge setVa:va];
    [edge setVb:vb];
    
    [edges addObject:edge];
    return edge;
}

#pragma mark Diagram completion methods
- (BOOL)connectEdge:(Edge *)edge withBoundingBox:(NSRect)bbox
{
    // Skip if end point already connected
    Vertex *vb = [edge vb];
    if (!!vb) {
        return YES;
    }
    
    Vertex *va = [edge va];
    float xl = bbox.origin.x;
    float xr = bbox.origin.x + bbox.size.width;
    float yt = bbox.origin.y;
    float yb = bbox.origin.y + bbox.size.height;
    Site *lSite = [edge lSite];
    Site *rSite = [edge rSite];
    float lx = [lSite x];
    float ly = [lSite y];
    float rx = [rSite x];
    float ry = [rSite y];
    float fx = (lx + rx)/2;
    float fy = (ly + ry)/2;
    
    float fm, fb;
    
    BOOL fmFbAssigned = NO;
    
    // Get the line equation of the bisector if line is not vertical
    if (ry != ly) {
        fm = (lx-rx)/(ry-ly);
        fb = fy-fm*fx;
        fmFbAssigned = YES;
    }
    
    // remember, direction of line (relative to left site):
    //  upward: left.x < right.x
    //  downward: left.x > right.x
    //  horizontal: left.x == right.x
    //  upward:  left.x < right.x
    //  rightward:  left.y < right.y
    //  leftward: left.y > right.y
    //  vertical: left.y == right.y
    
    // Depending on the direction, find the best side of the 
    // bounding box to use to determine a reasonable start point
    
    // special case: vertial line
    if (!fmFbAssigned ) {
        // doesn't intersect with viewport
        if (fx < xl || fx >= xr) {
            return NO;
        }
        // downward
        if (lx > rx) {
            if (!va) {
                va = [[Vertex alloc] initWithCoord:NSMakePoint(fx, yt)];
            } else if ([va y] >= yb) {
                return NO;
            }
            vb = [[Vertex alloc] initWithCoord:NSMakePoint(fx, yb)];
        } else {
            // upward
            if (!va) {
                va = [[Vertex alloc] initWithCoord:NSMakePoint(fx, yb)];
            } else if ([va y] < yt) {
                return NO;
            }
            vb = [[Vertex alloc] initWithCoord:NSMakePoint(fx, yt)];
        }
    } else if (fm < -1 || fm > 1) {
        // Closer to vertical than horizontal, connect start point to the
        // top or bottom side of the bounding box
        
        //downward
        if (lx > rx) {
            if (!va) {
                va = [[Vertex alloc] initWithCoord:NSMakePoint((yt-fb)/fm, yt)];
            } else if ([va y] >= yb) {
                return NO;
            }
            vb = [[Vertex alloc] initWithCoord:NSMakePoint((yb-fb)/fm, yb)];
        } else {
            // upward
            if (!va) {
                va = [[Vertex alloc] initWithCoord:NSMakePoint((yb-fb)/fm, yb)];
            } else if ([va y] < yt) {
                return NO;
            }
            vb = [[Vertex alloc] initWithCoord:NSMakePoint((yt-fb)/fm, yt)];
        }
    } else {
        // Closer to horizontal than vertical, connect start point to the
        // left or right side of the bounding box
        
        // rightward
        if (ly < ry) {
            if (!va) {
                va = [[Vertex alloc] initWithCoord:NSMakePoint(xl, fm*xl+fb)];
            } else if ([va x] >= xr) {
                return NO;
            }
            vb = [[Vertex alloc] initWithCoord:NSMakePoint(xr, fm*xr+fb)];
        } else {
            // leftward
            if (!va) {
                va = [[Vertex alloc] initWithCoord:NSMakePoint(xr, fm*xr+fb)];
            } else if ([va x] < xl) {
                return NO;
            }
            vb = [[Vertex alloc] initWithCoord:NSMakePoint(xl, fm*xl+fb)];
        }
    }
    [edge setVa:va];
    [edge setVb:vb];
    return YES;
}

- (BOOL)clipEdge:(Edge *)edge withBoundingBox:(NSRect)bbox
{
    // line-clipping code taken from:
    //  Liang-Barsky function by Daniel White
    //  http://www.skytopia.com/project/articles/compsci/clipping.html
    //  Thanks! - modified to minimize code paths
    
    float ax = [[edge va] x];
    float ay = [[edge va] y];
    float bx = [[edge vb] x];
    float by = [[edge vb] y];
    
    float t0 = 0;
    float t1 = 1;
    
    float dx = bx - ax;
    float dy = by - ay;
    
    // left
    float q = ax - bbox.origin.x;
    if (dx == 0 && q < 0) {
        return NO;
    }
    
    float r = -q/dx;
    if (dx < 0) {
        if (r < t0) {
            return NO;
        } else if (r < t1) {
            t1 = r;
        }
    } else if (dx > 0) {
        if (r > t1) {
            return NO;
        } else if (r > t0) {
            t0 = r;
        }
    }
    
    // right
    q = (bbox.origin.x + bbox.size.width) - ax;
    if (dx == 0 && q < 0) {
        return NO;
    }
    r = q/dx;
    if (dx < 0) {
        if (r > t1) {
            return NO;
        } else if (r > t0) {
            t0 = r;
        }
    } else if (dx > 0) {
        if (r < t0) {
            return NO;
        } else if (r < t1) {
            t1 = r;
        }
    }
    
    // top
    q = ay - bbox.origin.y;
    if (dy == 0 && q < 0) {
        return NO;
    }
    r = -q/dy;
    if (dy < 0) {
        if (r < t0) {
            return NO;
        } else if (r < t1) {
            t1 = r;
        }
    } else if (dy > 0) {
        if (r > t1) {
            return NO;
        } else if (r > t0) {
            t0 = r;
        }
    }
    
    // bottom
    q = (bbox.origin.y + bbox.size.height) - ay;
    if (dy == 0 && q < 0) {
        return NO;
    }
    
    r = q/dy;
    if (dy < 0) {
        if (r > t1) {
            return NO;
        } else if (r > t0) {
            t0 = r;
        }
    } else if (dy > 0) {
        if (r < t0) {
            return NO;
        } else if (r < t1) {
            t1 = r;
        }
    }
    
    // if we reach this point Voronoi edge is within box;
    
    // if t0 > 0, va needs to change
    // We need to create a new vertex rather than modifying 
    // the existing one, since the existing one is likely
    // shared with at least another edge
    
    if (t0 > 0) {
        [edge setVa:[[Vertex alloc] initWithCoord:NSMakePoint(ax+t0*dx, ay+t0*dy)]];
    }
    
    // if t1 < 1, vb needs to change
    // We need to create a new vertex rather than modifying 
    // the existing one, since the existing one is likely
    // shared with at least another edge
    
    if (t1 < 1) {
        [edge setVb:[[Vertex alloc] initWithCoord:NSMakePoint(ax+t1*dx, ay+t1*dy)]];
    }
    
    return YES;
}

// Clip/cut edges at the bounding box
- (void)clipEdges:(NSRect)bbox
{
    int iEdge = (int)[edges count];
    Edge *edge;
    
    // iterate backward so we can splice safely
    while (iEdge--) {
        edge = [edges objectAtIndex:iEdge];
        // edge is removed if:
        //  it is wholly outside the bounding box
        //  it is actually a point rather than a line
        if (![self connectEdge:edge withBoundingBox:bbox] 
            || ![self clipEdge:edge withBoundingBox:bbox]
            || (fabs([[edge va] x] - [[edge vb] x]) < 1e-9 && fabs([[edge va] y] - [[edge vb] y]) < 1e-9)) {
            [edge setVb:nil];
            [edge setVa:nil];
            [edges removeObjectAtIndex:iEdge];                                          // Possible problem area: implementation of js splice();
        }
    }
}


// Close the cells.
// The cells are bound by the supplied bounding box.
// Each cell refers to its associated site, and a list of halfedges ordered counterclockwise
- (void)closeCells:(NSRect)bbox
{
    float xl = bbox.origin.x;
    float xr = bbox.origin.x + bbox.size.width;
    float yt = bbox.origin.y;
    float yb = bbox.origin.y + bbox.size.height;
    
    int iCell = (int)[cells count];
    Cell *cell;
    
    /*
     iLeft, iRight
     halfedges, nHalfedges
     edge
     startpoint, endpoint
     va, vb
     */
    
    NSMutableArray *halfedges;
    int iLeft, iRight, nHalfedges;
    Edge *edge;
    Vertex *startpoint;
    Vertex *endpoint;
    Vertex *va;
    Vertex *vb;
    
    while (iCell--) {
        cell = [cells objectAtIndex:iCell];
        //NSLog(@"%@", cell);
        // Trim non full-defined halfedges and sort them counterclockwise
        if (![cell prepare]) {
            continue;
        }
        
        // close open cells
        // step 1: find first 'unclosed' point, if any.
        // An 'unclosed' point will be the end point of a halfedge which
        // does not match the start point of the following halfedge
        halfedges = [cell halfedges];
        nHalfedges = (int)[halfedges count];
        // Special case: only one site, in which case, the viewport is the cell
        // ...
        // all other cases
        NSLog(@"halfedges: %@", halfedges);
        iLeft = 0;
        while (iLeft < nHalfedges) {
            iRight     = (iLeft + 1) % nHalfedges;
            endpoint   = [[halfedges objectAtIndex:iLeft] getEndpoint];
            startpoint = [[halfedges objectAtIndex:iRight] getStartpoint];
            
            float endPointX = [endpoint x];
            float endPointY = [endpoint y];
            float startPointX = [startpoint x];
            float startPointY = [startpoint y];
            
            // if end point is not equal to start point, we need to add the missing halfedge(s) to close the cell
            if (fabs(endPointX - startPointX)>=1e-9 || fabs(endPointY - startPointY) >= 1e-9) {
                // if we reach this point, cell needs to be closed by walking counterclockwise 
                // along the bounding box until it connects to the next halfedge in the list
                va = endpoint;
                    
                if ([Voronoi equalWithEpsilonA:[endpoint x] andB:xl] && [Voronoi lessThanWithEpsilonA:[endpoint y] andB:yb]) {
                    
                    // walk downward along left side
                    float tempY = [Voronoi equalWithEpsilonA:[startpoint x] andB:xl] ? [startpoint y] : yb;
                    vb = [[Vertex alloc] initWithCoord:NSMakePoint(xl, tempY)];
                    
                } else if ([Voronoi equalWithEpsilonA:[endpoint y] andB:yb] && [Voronoi lessThanWithEpsilonA:[endpoint x] andB:xr]) {
                    
                    // walk rightward along the bottom side
                    float tempX = [Voronoi equalWithEpsilonA:[startpoint y] andB:yb] ? [startpoint x] : xr;
                    vb = [[Vertex alloc] initWithCoord:NSMakePoint(tempX, yb)];
                    
                } else if ([Voronoi equalWithEpsilonA:[endpoint x] andB:xr] && [Voronoi greaterThanWithEpsilonA:[endpoint y] andB:yt]) {
                    
                    // walk upward along the right side
                    float tempY = [Voronoi equalWithEpsilonA:[startpoint x] andB:xr] ? [startpoint y] : yt;
                    vb = [[Vertex alloc] initWithCoord:NSMakePoint(xr, tempY)];
                    
                } else if ([Voronoi equalWithEpsilonA:[endpoint y] andB:yt] && [Voronoi greaterThanWithEpsilonA:[endpoint x] andB:xl]) {
                    
                    // walk leftward along top side
                    float tempX = [Voronoi equalWithEpsilonA:[startpoint y] andB:yt] ? [startpoint x] : xl;
                    vb = [[Vertex alloc] initWithCoord:NSMakePoint(tempX, yt)];
                    
                }
                edge = [self createBorderEdgeWithSite:[cell site] andVertex:va andVertex:vb];
                Halfedge *he = [[Halfedge alloc] initWithEdge:edge lSite:[cell site] andRSite:nil];
                [halfedges insertObject:he atIndex:(iLeft + 1)];
                nHalfedges = (int)[halfedges count];
            }
            iLeft++;
        }
    }
}

#pragma mark Math
+ (BOOL)equalWithEpsilonA:(float)a andB:(float)b
{
    return fabs(a-b)<1e-9;
}

+ (BOOL)greaterThanWithEpsilonA:(float)a andB:(float)b
{
    return a-b>1e-9;
}

+ (BOOL)greaterThanOrEqualWithEpsilonA:(float)a andB:(float)b
{
    return b-a<1e-9;
}

+ (BOOL)lessThanWithEpsilonA:(float)a andB:(float)b
{
    return b-a>1e-9;
}

+ (BOOL)lessThanOrEqualWithEpsilonA:(float)a andB:(float)b
{
    return a-b<1e-9;
}
@end
