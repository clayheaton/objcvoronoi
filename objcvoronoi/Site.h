//
//  Site.h
//  objcvoronoi
//
//  Created by Clay Heaton on 3/23/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Site : NSObject {
    NSPoint coord;
    int voronoiId;
}

@property (assign, readwrite) int voronoiId;

- (id)initWithCoord:(NSPoint)tempCoord;
- (id)initWithValue:(NSValue *)valueWithCoord;

- (void)setCoord:(NSPoint)tempCoord;
- (NSPoint)coord;

- (void)setCoordAsValue:(NSValue *)valueWithCoord;
- (NSValue *)coordAsValue;

- (void)setX:(float)tempX;
- (float)x;

- (void)setY:(float)tempY;
- (float)y;

+ (void)sortSites:(NSMutableArray *)siteArray;
- (NSComparisonResult)compare:(Site *)s;

@end
