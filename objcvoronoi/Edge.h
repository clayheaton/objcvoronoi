//
//  Edge.h
//  objcvoronoi
//
//  Created by Clay Heaton on 3/26/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Site;
@class Vertex;
@class Halfedge;

@interface Edge : NSObject {
    Site *lSite;
    Site *rSite;
    Vertex *va;
    Vertex *vb;
}

@property (retain, readwrite) Site *lSite;
@property (retain, readwrite) Site *rSite;
@property (retain, readwrite) Vertex *va;
@property (retain, readwrite) Vertex *vb;

- (id)initWithLSite:(Site *)theLSite andRSite:(Site *)theRSite;

@end
