//
//  Cell.h
//  objcvoronoi
//
//  Created by Clay Heaton on 3/23/12.
//  Copyright (c) 2012 The Perihelion Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Site;

@interface Cell : NSObject {
    Site *site;
}

@property (retain, readwrite) Site *site;

- (id)initWithSite:(Site *)s;

@end
