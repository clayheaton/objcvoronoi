//
//  VoronoiResult.h
//  objcvoronoi
//

#import <Foundation/Foundation.h>

@interface VoronoiResult : NSObject {
    NSMutableArray *cells;
    NSMutableArray *edges;
}

@property (retain, readwrite) NSMutableArray *cells;
@property (retain, readwrite) NSMutableArray *edges;

@end
