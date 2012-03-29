//
//  Edge.m
//  objcvoronoi
//

#import "Edge.h"
#import "Site.h"
#import "Vertex.h"
#import "Halfedge.h"

@implementation Edge
@synthesize lSite, rSite, va, vb;

- (id)initWithLSite:(Site *)theLSite andRSite:(Site *)theRSite
{
    self = [super init];
    if (self) {
        [self setLSite:theLSite];
        [self setRSite:theRSite];
        [self setVa:nil];
        [self setVb:nil];
    }
    return self;
}

@end
