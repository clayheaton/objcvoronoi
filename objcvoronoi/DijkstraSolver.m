//
//  DijkstraSolver.m
//  objcvoronoi
//
//  Created by Clay Heaton on 3/29/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import "DijkstraSolver.h"
#import "Edge.h"
#import "Vertex.h"

@implementation DijkstraSolver
@synthesize edges, startPoint, endPoint, startVertex, endVertex, theBounds, points;

- (id)initWithEdges:(NSMutableArray *)voronoiEdges theStartPoint:(NSPoint)stPt theEndPoint:(NSPoint)endPt andBounds:(NSRect)bbox
{
    self = [super init];
    if (self) {
        [self setEdges:voronoiEdges];
        [self setStartPoint:stPt];
        [self setEndPoint:endPt];
        [self setTheBounds:bbox];
        
        vertices  = [[NSMutableDictionary alloc] init];
        pathNodes = [[NSMutableArray alloc] init];
        newEdges  = [[NSMutableArray alloc] init];
        
        [self calculate];
    }
    return self;
}

- (void)calculate
{
    [self prepareDijkstra];
    [self pathByClay];

}

- (void)pathByClay
{
    [[self endVertex] setTarget:YES];
    
    for (NSValue *key in vertices) {
        Vertex *v = [vertices objectForKey:key];
        [v setDistance:[v distanceToVertex:endVertex]];
    }
    
    // NSLog(@"Vertices: %@", vertices);
    
    [[self startVertex] setDistance:1];
    
    Vertex *currentVertex = [self startVertex];
    Vertex *nextVertex;
    Vertex *reserveVertex; // To be used in case we get stuck
    
    // NSLog(@"Target Vertex: %@", endVertex);
    
    NSMutableDictionary *unvisitedSet = [[NSMutableDictionary alloc] initWithDictionary:vertices];
    [unvisitedSet removeObjectForKey:[currentVertex uniqueID]];
    
    int nilLoops = 0;
    
    while (![currentVertex target]) {
        float shortestDistance = INFINITY;
        int numkeys = (int)[[currentVertex neighborKeys] count];
        int numnilkeys = 0;
        // NSLog(@"Current Vertex: %@", currentVertex);
        for (NSString *key in [currentVertex neighborKeys]) {
            Vertex *evalVertex = [unvisitedSet objectForKey:key];
            // NSLog(@"  evalVertex is number %@", [evalVertex uniqueID]);
            if (evalVertex == nil) {
                numnilkeys += 1;
            }
            if ([evalVertex target]) {
                // Found the target
                // NSLog(@"  Found the target...");
                [evalVertex setPreviousVertex:currentVertex];
                nextVertex = evalVertex;
                currentVertex = nextVertex;
                break;
            }
            
            if (evalVertex != nil && [evalVertex distance] < shortestDistance) {
                // NSLog(@"  evalVertex is the closest.");
                shortestDistance = [evalVertex distance];
                reserveVertex = [currentVertex previousVertex];
                nextVertex = evalVertex;
                [nextVertex setPreviousVertex:currentVertex];
            }
        }
        
        // Condition to break out if all of the remaining keys to evaluate are null
        if (numkeys == numnilkeys) {
            nilLoops ++;
            NSLog(@"  broke out because of nil keys.");
            NSLog(@"  %lu objects remain in unvisitedSet.", [unvisitedSet count]);
            nextVertex = reserveVertex;
            [nextVertex setPreviousVertex:[reserveVertex previousVertex]];
            
            // We know the current vertex won't work for pathfinding
            [unvisitedSet removeObjectForKey:[currentVertex uniqueID]];
        }
        
        if (nilLoops > 3) {
            nilLoops = 0;
            // We're stuck.
            nextVertex = [reserveVertex previousVertex];
            [unvisitedSet removeObjectForKey:[reserveVertex uniqueID]];
            reserveVertex = nextVertex;
        }
        
        // We've iterated through all neighbors
        currentVertex = nextVertex;
        [unvisitedSet removeObjectForKey:[currentVertex uniqueID]];
    }
    
    // Now iterate through them backwards to build the path
    // currentVertex should be the target now
    
    [pathNodes addObject:currentVertex];
    while (currentVertex != nil) {
        if ([currentVertex previousVertex] != nil) {
            [pathNodes insertObject:[currentVertex previousVertex] atIndex:0];
        }
        currentVertex = [currentVertex previousVertex];
    }
    
    // Should be done.
    
}

- (void)traditionalDijkstra
{
    //NSLog(@"Calculating Dijkstra Path");
    
    
    /* http://en.wikipedia.org/wiki/Dijkstra's_algorithm
     
     Let the node at which we are starting be called the initial node. Let the distance of node Y be the distance from the initial node to Y. Dijkstra's algorithm will assign some initial distance values and will try to improve them step by step.
     
     */
    
    // 1. Assign to every node a tentative distance value: set it to zero for our initial node and to infinity for all other nodes.
    
    [[self startVertex] setDistance:0];
    [[self endVertex] setTarget:YES];
    
    // 2. Mark all nodes unvisited. Set the initial node as current. Create a set of the unvisited nodes called the unvisited set consisting of all the nodes except the initial node.
    
    Vertex *currentNode = [self startVertex];
    
    NSMutableDictionary *unvisitedSet = [[NSMutableDictionary alloc] initWithDictionary:vertices];
    [unvisitedSet removeObjectForKey:[currentNode uniqueID]];
    
    // Establishes the first node.
    NSAssert(currentNode != nil, @"Current node is nil");
    
    
    
    //NSLog(@"Entering Dijkstra loop...");
    
    
    //  3. For the current node, consider all of its unvisited neighbors and calculate their tentative distances. For example, if the current node A is marked with a tentative distance of 6, and the edge connecting it with a neighbor B has length 2, then the distance to B (through A) will be 6+2=8. If this distance is less than the previously recorded tentative distance of B, then overwrite that distance. Even though a neighbor has been examined, it is not marked as visited at this time, and it remains in the unvisited set.
    BOOL foundTarget = NO;
    
    while (![currentNode target]) {
        //NSLog(@"----------------");
        //NSLog(@"Current Node: %@", currentNode);
        //NSLog(@"[currentNode dist] is: %f", [currentNode distance]);
        
        // Loop through until the current node is the target node -- which means we're done
        NSMutableArray *currentNodeNeighborKeys = [currentNode neighborKeys];
        
        //NSLog(@"Current Node neighborKeys: %@", currentNodeNeighborKeys);
        
        Vertex *closestNeighbor;
        float shortestDist = INFINITY;
        int keyCount = 0;
        for (NSString *key in currentNodeNeighborKeys) {
            keyCount++;
            //NSLog(@"Neighbor key %i", keyCount);
            Vertex *evalVertex = [unvisitedSet objectForKey:key]; // Nil if visited
            
            if (evalVertex != nil) {
                //NSLog(@"  Found evalVertex in unvisitedSet: %@", evalVertex);
                
                if ([evalVertex target]) {
                    
                    //  5. If the destination node has been marked visited (when planning a route between two specific nodes) or if the smallest tentative distance among the nodes in the unvisited set is infinity (when planning a complete traversal), then stop. The algorithm has finished.
                    
                    //NSLog(@"  Reached target vertex! Wrap things up...");
                    closestNeighbor = evalVertex;
                    foundTarget = YES;
                    break;
                } else {
                    float dist = [currentNode distanceToVertex:evalVertex] + [currentNode distance];
                    //NSLog(@"  Existing dist to evalVertex is:   %f", [evalVertex distance]);
                    //NSLog(@"  Calculated dist to evalVertex is: %f", dist);
                    if (dist < [evalVertex distance]) {
                        //NSLog(@"  Resetting evalVertex distance to: %f", dist);
                        [evalVertex setDistance:dist];
                    } else {
                        //NSLog(@"  Leaving evalVertex distance as is.");
                    }
                    
                    if (dist < shortestDist) {
                        //NSLog(@"  evalVertex is now closestNeighbor.");
                        shortestDist = dist;
                        closestNeighbor = evalVertex;
                    } else {
                        //NSLog(@"  evalVertex is not closest.");
                    }
                    
                }
            } else {
                //NSLog(@"  Did not find an evalVertex; set to nil.");
            }
        }
        
        if (foundTarget) {
            break;
        }
        if (!closestNeighbor) {
            break;
        }
        NSAssert(closestNeighbor != nil, @"Closest Neighbor is nil");
        
        // Make sure there are no duplicates in the path nodes
        
        if (![pathNodes containsObject:currentNode]) {
            [pathNodes addObject:currentNode];
        }
        
        // 4. When we are done considering all of the neighbors of the current node, mark the current node as visited and remove it from the unvisited set. A visited node will never be checked again; its distance recorded now is final and minimal.
        
        [currentNode setVisited:YES];
        [unvisitedSet removeObjectForKey:[currentNode uniqueID]];
        
        // 6. Set the unvisited node marked with the smallest tentative distance as the next "current node" and go back to step 3.
        currentNode = closestNeighbor;
        //NSLog(@"  Setting closestNeighbor to currentNode and restarting loop.");
    }
    //NSLog(@"  Exited loop!");
    
    [pathNodes addObject:currentNode];
    
    //NSLog(@"Pathfinding complete");
    //NSLog(@"Calculated path: %@", pathNodes);
}

// Checks whether two vertices match by position
// Since more than one vertex can have the same spot
// If they match, then we return the matching one

- (Vertex *)vertexMatchingByPosition:(Vertex *)v
{
    float incomingX = [v x];
    float incomingY = [v y];
    
    for (NSValue *key in [vertices allKeys]) {
        Vertex *existing = [vertices objectForKey:key];
        float existingX = [existing x];
        float existingY = [existing y];
        if ([DijkstraSolver equalWithEpsilonA:existingX andB:incomingX]) {
            if ([DijkstraSolver equalWithEpsilonA:existingY andB:incomingY]) {
                return existing;
            }
        }
    }
    return nil;
}

- (void)prepareDijkstra
{
    //NSLog(@"Preparing Dijkstra Data");
    
    // Initialize a vertex
    // Check whether its key is in the dictionary
    // If it isn't, add the vertex to the dictionary
    // Add the edge to the vertex.
    // If it is, then just add the edge to dictionary version of the vertex
    
    for (Edge *e in edges) {
        // For each edge, we want to create a new edge with the appropriate 
        // vertices and store it with each vertex.
        
        // Remove edges connected to the bounding box
        // The vertices of the existing edge
        Vertex *va = [e va];
        Vertex *vb = [e vb];
        
        if ([self boundingBoxSharesEdgeWithVertex:va] ||[self boundingBoxSharesEdgeWithVertex:vb]) {
            continue;
        }
        
        // Create the new edge
        Edge *f = [[Edge alloc] initWithLSite:[e lSite] andRSite:[e rSite]];
        
        // There are three goals here:
        // 1. Idendify the unique vertices (remove duplicates)
        // 2. Store the unique vertices with the new edges
        // 3. Store the new edges with the unique vertices;
        

        
        // Check for existing by uniqueID
        Vertex *existingByKey = [vertices objectForKey:[va uniqueID]];
        if (!existingByKey) {
            
            // Check whether it's existing by position and return the matching existing one
            Vertex *existingByPosition = [self vertexMatchingByPosition:va];
            
            if (!existingByPosition) {
                // it's not existing either by position or key, so we add this vertex
                // to the dictionary of vertices and we assign it as the va vertex for the
                // new edge and add the new edge to its 'edges' array
                
                [vertices setObject:va forKey:[va uniqueID]];
                [f setVa:va];
                [va addEdge:f];
            } else {
                
                // It does exist by position, so we retrieved the existing vertex
                // and now we'll assign the existing vertex as the va vertex of the new edge
                // and add the new edge to the existing vertex's edge array
                [f setVa:existingByPosition];
                [existingByPosition addEdge:f];
            }
        } else {
            // It exists by key, so we retrieve the existing vertex
            // and assign it as the va vertex for the new edge and then add the new edge
            // to the 'edges' array of the vertex.
            [f setVa:existingByKey];
            [existingByKey addEdge:f];
        }
        
        
        // Check for existing by uniqueID
        existingByKey = [vertices objectForKey:[vb uniqueID]];
        if (!existingByKey) {
            
            // Check whether it's existing by position and return the matching existing one
            Vertex *existingByPosition = [self vertexMatchingByPosition:vb];
            
            if (!existingByPosition) {
                // It's not existing either by position or key, so we add this vertex
                // to the dictionary of vertices and we assign it as the vb vertex for the
                // new edge and add the new edge to its 'edges' array
                
                [vertices setObject:vb forKey:[vb uniqueID]];
                [f setVb:vb];
                [vb addEdge:f];
            } else {
                // It does exist by position, so we retrieved the existing vertex
                // and now we'll assign the existing vertex as the vb vertex of the new edge
                // and add the new edge to the existing vertex's edge array
                [f setVb:existingByPosition];
                [existingByPosition addEdge:f];
            }
        } else {
            // It exists by key, so we retrieve the existing vertex
            // and assign it as the vb vertex for the new edge and then add the new edge
            // to the 'edges' array of the vertex.
            [f setVb:existingByKey];
            [existingByKey addEdge:f];
        }
        
        // Add the new edge to the newEdges array
        [newEdges addObject:f];
        //NSLog(@"Added to newEdges: %@", f);
    }
    
    // Remove vertices on the edge because I don't want to use them
    for (NSValue *key in [vertices allKeys]) {
        Vertex *v = [vertices objectForKey:key];
        if ([self boundingBoxSharesEdgeWithVertex:v]) {
            [v setOnBoundingBox:YES];
        }
    }
    
    
    // Calculate the neighbor vertices for each vertex that isn't on the edge
    for (NSValue *key in vertices) {
        Vertex *v = [vertices objectForKey:key];
        //NSLog(@"Calculating neighborKeys for Vertex %@", [v uniqueID]);
        [v calcNeighborKeys];
        //NSLog(@"  Set as: %@", [v neighborKeys]);
    }

    //NSLog(@"Vertices in the dictionary: %lu", [vertices count]);
    //NSLog(@"Vertices in the dictionary: %@", vertices);
    //NSLog(@"Number of Edges: %lu", [newEdges count]);
    //NSLog(@"Edges: %@", newEdges);

    
    // Find the closest vertex to the start point and make it the start vertex
    float closestStartDist = INFINITY;
    float closestEndDist   = INFINITY;
    NSString *closestStartKey, *closestEndKey;
    
    /* Iterate through the vertices in the dictionary.
     Compare the distances from each to the start and end points.
     Set the closest to be the start and end vertices.
     */
    
    for (NSValue *key in [vertices allKeys]) {
        Vertex *v = [vertices objectForKey:key];
        
        if (![self boundingBoxSharesEdgeWithVertex:v]) {
            
            // For my purposes -- looking for a vertex that isn't on the edge of the bounding box...
            
            float stDist = [self distanceFromPoint:startPoint toVertex:v];
            float edDist = [self distanceFromPoint:endPoint   toVertex:v];
            
            if (stDist < closestStartDist) {
                closestStartDist = stDist;
                closestStartKey  = [v uniqueID];
            }
            
            if (edDist < closestEndDist) {
                closestEndDist = edDist;
                closestEndKey  = [v uniqueID];
            }
        }
    }
    
    [self setStartVertex:[vertices objectForKey:closestStartKey]];
    [self setEndVertex:[vertices objectForKey:closestEndKey]];
    
    //NSLog(@"Start Vertex: %@", startVertex);
    //NSLog(@"End Vertex: %@", endVertex);
    
    // Now we have identified the start and end vertices and 
    // assigned all edges to the arrays belonging to the vertices.
    // Begin Dijkstra Algorithm.
}

// Let's return an array of NSPoints as values
// Don't forget to include the start point and end point
- (NSMutableArray *)pathNodes
{
    NSMutableArray *finalPath = [[NSMutableArray alloc] initWithCapacity:[pathNodes count] + 2];
    
    // Add the start point
    [finalPath addObject:[NSValue valueWithPoint:startPoint]];
    
    // Iterate through the pathNodes and add them
    for (Vertex *v in pathNodes) {
        [finalPath addObject:[NSValue valueWithPoint:[v coord]]];
    }
    
    // Add the end point
    [finalPath addObject:[NSValue valueWithPoint:endPoint]];
    
    return finalPath;
}

+ (BOOL)equalWithEpsilonA:(float)a andB:(float)b
{
    return fabsf(a - b) < 0.00005;
}

/* For my purposes, I don't want the vertex located as closest to the start/end
   point to be on the edge of the bounding box, so this checks whether it is
*/

- (BOOL)boundingBoxSharesEdgeWithVertex:(Vertex *)dv
{
    float boundsMinX = theBounds.origin.x;
    float boundsMaxX = theBounds.origin.x + theBounds.size.width;
    float boundsMinY = theBounds.origin.y;
    float boundsMaxY = theBounds.origin.y + theBounds.size.height;
    
    float dvx = [dv x];
    float dvy = [dv y];
    
    if ([DijkstraSolver equalWithEpsilonA:boundsMinX andB:dvx]) {
        return YES;
    }
    if ([DijkstraSolver equalWithEpsilonA:boundsMaxX andB:dvx]) {
        return YES;
    }
    if ([DijkstraSolver equalWithEpsilonA:boundsMinY andB:dvy]) {
        return YES;
    }
    if ([DijkstraSolver equalWithEpsilonA:boundsMaxY andB:dvy]) {
        return YES;
    }
    
    return NO;
}

- (float)distanceFromPoint:(NSPoint)pt toVertex:(Vertex *)dv
{
    float x1 = pt.x;
    float y1 = pt.y;
    float x2 = [dv x];
    float y2 = [dv y];
    
    float a = fabsf(x2 - x1);
    float b = fabsf(y2 - y1);
    
    float dist = sqrtf(a*a + b*b);
    return dist;
}

- (NSMutableArray *)solution
{
    return solution;
}
@end
