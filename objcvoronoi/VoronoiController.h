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



// Original comments from Raymond Hill's javascript library:

/*!
 Author: Raymond Hill (rhill@raymondhill.net)
 File: rhill-voronoi-core.js
 Version: 0.96
 Date: May 26, 2011
 Description: This is my personal Javascript implementation of
 Steven Fortune's algorithm to compute Voronoi diagrams.
 
 Copyright (C) 2010,2011 Raymond Hill
 https://github.com/gorhill/Javascript-Voronoi
 
 Licensed under The MIT License
 http://en.wikipedia.org/wiki/MIT_License
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 *****
 
 Portions of this software use, depend, or was inspired by the work of:
 
 "Fortune's algorithm" by Steven J. Fortune: For his clever
 algorithm to compute Voronoi diagrams.
 http://ect.bell-labs.com/who/sjf/
 
 "The Liang-Barsky line clipping algorithm in a nutshell!" by Daniel White,
 to efficiently clip a line within a rectangle.
 http://www.skytopia.com/project/articles/compsci/clipping.html
 
 "rbtree" by Franck Bui-Huu
 https://github.com/fbuihuu/libtree/blob/master/rb.c
 I ported to Javascript the C code of a Red-Black tree implementation by
 Franck Bui-Huu, and further altered the code for Javascript efficiency
 and to very specifically fit the purpose of holding the beachline (the key
 is a variable range rather than an unmutable data point), and unused
 code paths have been removed. Each node in the tree is actually a beach
 section on the beachline. Using a tree structure for the beachline remove
 the need to lookup the beach section in the array at removal time, as
 now a circle event can safely hold a reference to its associated
 beach section (thus findDeletionPoint() is no longer needed). This
 finally take care of nagging finite arithmetic precision issues arising
 at lookup time, such that epsilon could be brought down to 1e-9 (from 1e-4).
 rhill 2011-05-27: added a 'previous' and 'next' members which keeps track
 of previous and next nodes, and remove the need for Beachsection.getPrevious()
 and Beachsection.getNext().
 
 *****
 
 History:
 
 0.96 (26 May 2011):
 Returned diagram.cells is now an array, whereas the index of a cell
 matches the index of its associated site in the array of sites passed
 to Voronoi.compute(). This allowed some gain in performance. The
 'voronoiId' member is still used internally by the Voronoi object.
 The Voronoi.Cells object is no longer necessary and has been removed.
 
 0.95 (19 May 2011):
 No longer using Javascript array to keep track of the beach sections of
 the beachline, now using Red-Black tree.
 
 The move to a binary tree was unavoidable, as I ran into finite precision
 arithmetic problems when I started to use sites with fractional values.
 The problem arose when the code had to find the arc associated with a
 triggered Fortune circle event: the collapsing arc was not always properly
 found due to finite precision arithmetic-related errors. Using a tree structure
 eliminate the need to look-up a beachsection in the array structure
 (findDeletionPoint()), and allowed to bring back epsilon down to 1e-9.
 
 0.91(21 September 2010):
 Lower epsilon from 1e-5 to 1e-4, to fix problem reported at
 http://www.raymondhill.net/blog/?p=9#comment-1414
 
 0.90 (21 September 2010):
 First version.
 
 *****
 
 Usage:
 
 var sites = [{x:300,y:300}, {x:100,y:100}, {x:200,y:500}, {x:250,y:450}, {x:600,y:150}];
 // xl, xr means x left, x right
 // yt, yb means y top, y bottom
 var bbox = {xl:0, xr:800, yt:0, yb:600};
 var voronoi = new Voronoi();
 // pass an object which exhibits xl, xr, yt, yb properties. The bounding
 // box will be used to connect unbound edges, and to close open cells
 result = voronoi.compute(sites, bbox);
 // render, further analyze, etc.
 
 Return value:
 An object with the following properties:
 
 result.edges = an array of unordered, unique Voronoi.Edge objects making up the Voronoi diagram.
 result.cells = an array of Voronoi.Cell object making up the Voronoi diagram. A Cell object
 might have an empty array of halfedges, meaning no Voronoi cell could be computed for a
 particular cell.
 result.execTime = the time it took to compute the Voronoi diagram, in milliseconds.
 
 Voronoi.Edge object:
 lSite: the Voronoi site object at the left of this Voronoi.Edge object.
 rSite: the Voronoi site object at the right of this Voronoi.Edge object (can be null).
 va: an object with an 'x' and a 'y' property defining the start point
 (relative to the Voronoi site on the left) of this Voronoi.Edge object.
 vb: an object with an 'x' and a 'y' property defining the end point
 (relative to Voronoi site on the left) of this Voronoi.Edge object.
 
 For edges which are used to close open cells (using the supplied bounding box), the
 rSite property will be null.
 
 Voronoi.Cell object:
 site: the Voronoi site object associated with the Voronoi cell.
 halfedges: an array of Voronoi.Halfedge objects, ordered counterclockwise, defining the
 polygon for this Voronoi cell.
 
 Voronoi.Halfedge object:
 site: the Voronoi site object owning this Voronoi.Halfedge object.
 edge: a reference to the unique Voronoi.Edge object underlying this Voronoi.Halfedge object.
 getStartpoint(): a method returning an object with an 'x' and a 'y' property for
 the start point of this halfedge. Keep in mind halfedges are always countercockwise.
 getEndpoint(): a method returning an object with an 'x' and a 'y' property for
 the end point of this halfedge. Keep in mind halfedges are always countercockwise.
 
 TODO: Identify opportunities for performance improvement.
 TODO: Let the user close the Voronoi cells, do not do it automatically. Not only let
 him close the cells, but also allow him to close more than once using a different
 bounding box for the same Voronoi diagram.
 */
