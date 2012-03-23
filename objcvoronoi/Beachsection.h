//
//  Beachsection.h
//  objcvoronoi
//
//  Created by Clay Heaton on 3/22/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Beachsection : NSObject {
    Beachsection *rbNext;
    Beachsection *rbPrevious;
    Beachsection *rbParent;
    Beachsection *rbRight;
    Beachsection *rbLeft;
    BOOL rbRed;
}

@property (retain, readwrite)Beachsection *rbNext;
@property (retain, readwrite)Beachsection *rbPrevious;
@property (retain, readwrite)Beachsection *rbParent;
@property (retain, readwrite)Beachsection *rbRight;
@property (retain, readwrite)Beachsection *rbLeft;
@property (assign, readwrite) BOOL rbRed;


@end
