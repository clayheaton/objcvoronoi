//
//  VoronoiResult.h
//  objcvoronoi
//
//  Created by Clay Heaton on 3/23/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoronoiResult : NSObject {
    NSMutableArray *cells;
    NSMutableArray *edges;
}

@property (retain, readwrite) NSMutableArray *cells;
@property (retain, readwrite) NSMutableArray *edges;

@end
