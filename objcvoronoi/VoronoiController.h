//
//  VoronoiController.h
//  objcvoronoi
//
//  Created by Clay Heaton on 3/27/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Voronoi;
@class VoronoiResult;
@class VoronoiView;

@interface VoronoiController : NSObject {
    Voronoi *voronoi;
    IBOutlet VoronoiView *voronoiview;
}

- (IBAction)testVoronoi:(id)sender;

@end
