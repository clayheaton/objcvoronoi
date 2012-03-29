//
//  Cell.h
//  objcvoronoi
//

#import <Foundation/Foundation.h>

@class Site;
@class Halfedge;

@interface Cell : NSObject {
    Site *site;
    NSMutableArray *halfedges;
}

@property (retain, readwrite) Site *site;

- (id)initWithSite:(Site *)s;
- (int)prepare;
- (void)addHalfedgeToArray:(Halfedge *)he;
- (NSMutableArray *)halfedges;

@end
