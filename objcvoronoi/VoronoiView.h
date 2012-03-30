//
//  VoronoiView.h
//  objcvoronoi
//

#import <Cocoa/Cocoa.h>

@interface VoronoiView : NSView {
    NSMutableArray *sites;
    NSMutableArray *cells;
    NSMutableArray *dijkstraPathPoints;
}

@property (retain, readwrite) NSMutableArray *sites;
@property (retain, readwrite) NSMutableArray *cells;
@property (retain, readwrite) NSMutableArray *dijkstraPathPoints;

@end
