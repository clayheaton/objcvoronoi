//
//  RBTree.h
//  objcvoronoi
//

#import <Foundation/Foundation.h>

@interface RBTree : NSObject {
    id root;
}

@property (retain, readwrite) id root;

- (void)rbInsertSuccessorForNode:(id)node withSuccessor:(id)successor;
- (void)rbRemoveNode:(id)node;
- (void)rbRotateLeft:(id)node;
- (void)rbRotateRight:(id)node;
- (id)getFirst:(id)node;
- (id)getLast:(id)node;

@end
