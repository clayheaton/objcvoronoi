//
//  VoronoiView.h
//  objcvoronoi
//
//  Created by Clay Heaton on 3/27/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VoronoiView : NSView {
    NSMutableArray *sites;
    NSMutableArray *cells;
}

@property (retain, readwrite) NSMutableArray *sites;
@property (retain, readwrite) NSMutableArray *cells;

@end
