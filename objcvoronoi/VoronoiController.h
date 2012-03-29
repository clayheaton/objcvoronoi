//
//  VoronoiController.h
//  objcvoronoi
//

/*  
 
    Howdy.
    
    I ported this library as part of a hobby project. C or C++ would be faster,
    but I wanted it in obj-c, so here it is.
 
    The library is a direct port of Raymond Hill's javascript voronoi library.
    You can find that here: http://www.raymondhill.net/voronoi/rhill-voronoi.php
    or on github here: https://github.com/gorhill/Javascript-Voronoi
 
    Most of his notes are preserved and you will find them in-situ in the code (without his name/date).
 
    His library builds on the work of several others. The notes from his library, as of 28 March 2012,
    are found at the bottom of this page. I made every attempt to preserve the general structure of his
    code, though I made several small changes to fit the obj-c model, including method names, etc.
 
    If you try to use this library and you find that it does not work, the fault probably is mine
    and not Raymond Hill's. 
 
    If you would like to use this library, have fun! Usage notes are in the Read Me. 
 
    If you would like to help improve this library, you are free to do so: please retain all notices
    from this version of the library and from the libraries upon which this is built.
 
    Finally, if you use this library, please let me know! I'd love to hear about it.
 
    :)
 
    Basic Instructions
    ^^^^^^^^^^^^^^^^^^
    1. Create a bunch of NSPoints.
 
    2. Convert them to NSValues and put them in an NSArray or NSMutableArray.
 
    3. Include these classes/headers in your controller file:
       Voronoi
       VoronoiResult
 
    4. Instantiate an instance of the Voronoi class like so:
       Voronoi *voronoi - [[Voronoi alloc] init];
 
    5. Instantiate an instance of the Voronoi results class by sending the following message to your Voronoi instance:
       VoronoiResult *result = [voronoi computeWithSites:sites andBoundingBox:[voronoiview bounds]];
 
    6. In 5. 'sites' is the array that you created in step 2. The 'andBoundingBox' is an NSRect with the bounds of your view
       or the bounds that you wish to use to calculate your diagram.
 
    7. The following messages sent to your VoronoiResult object will provide you with what you need in order to work
       with your diagram:
       [result cells];
       [result edges];
 
    8. You may need to include the classes Cell and Edge (and others) in your view or controller in order to process results.
  
    ps. In this example, VoronoiController and VoronoiView are for example purposes only. 
        They are not needed for the library to function.
       
 
    Clay Heaton - 28 March 2012
 
*/

#import <Foundation/Foundation.h>

@class Voronoi;
@class VoronoiResult;
@class VoronoiView;

@interface VoronoiController : NSObject {
    Voronoi *voronoi;
    IBOutlet VoronoiView *voronoiview;
    IBOutlet NSTextField *numSitesEntry;
    IBOutlet NSTextField *marginEntry;
    IBOutlet NSButton *drawButton;
}

- (IBAction)testVoronoi:(id)sender;

@end
