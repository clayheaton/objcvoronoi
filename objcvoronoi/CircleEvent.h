//
//  CircleEvent.h
//  objcvoronoi
//
//  Created by Clay Heaton on 3/22/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CircleEvent : NSObject {
    CircleEvent *rbNext;
    CircleEvent *rbPrevious;
    CircleEvent *rbParent;
    CircleEvent *rbRight;
    CircleEvent *rbLeft;
    BOOL rbRed;
}

@property (retain, readwrite)CircleEvent *rbNext;
@property (retain, readwrite)CircleEvent *rbPrevious;
@property (retain, readwrite)CircleEvent *rbParent;
@property (retain, readwrite)CircleEvent *rbRight;
@property (retain, readwrite)CircleEvent *rbLeft;
@property (assign, readwrite) BOOL rbRed;

@end
