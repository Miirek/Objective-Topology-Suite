//
//  OTSRelateComputer.h
//

#import <Foundation/Foundation.h>

#import "OTSPointLocator.h" // for RelateComputer composition
#import "OTSLineIntersector.h" // for RelateComputer composition
#import "OTSNodeMap.h" // for RelateComputer composition
#import "OTSCoordinate.h" // for RelateComputer composition

@class OTSIntersectionMatrix;
@class OTSGeometry;
@class OTSGeometryGraph;
@class OTSEdge;
@class OTSEdgeEnd;
@class OTSNode;
@class OTSSegmentIntersector;

@interface OTSRelateComputer : NSObject {
	OTSLineIntersector *li;
	OTSPointLocator *ptLocator;
	NSArray *arg; 	
	OTSNodeMap *nodes;
	OTSIntersectionMatrix *im;
	NSMutableArray *isolatedEdges;
	OTSCoordinate *invalidPoint;
}

@property (nonatomic, retain) OTSLineIntersector *li;
@property (nonatomic, retain) OTSPointLocator *ptLocator;
@property (nonatomic, retain) NSArray *arg; 	
@property (nonatomic, retain) OTSNodeMap *nodes;
@property (nonatomic, retain) OTSIntersectionMatrix *im;
@property (nonatomic, retain) NSMutableArray *isolatedEdges;
@property (nonatomic, retain) OTSCoordinate *invalidPoint;

- (id)initWithGeometryGraphArray:(NSArray *)newArg;
- (OTSIntersectionMatrix *)computeIM;
- (void)insertEdgeEnds:(NSArray *)ee;
- (void)computeProperIntersectionIM:(OTSSegmentIntersector *)intersector intersectionMatrix:(OTSIntersectionMatrix *)imX;
- (void)copyNodesAndLabels:(int)argIndex;
- (void)computeIntersectionNodes:(int)argIndex;
- (void)labelIntersectionNodes:(int)argIndex;
- (void)computeDisjointIM:(OTSIntersectionMatrix *)imX;
- (void)labelNodeEdges;
- (void)updateIM:(OTSIntersectionMatrix *)imX;
- (void)labelIsolatedEdges:(int)thisIndex targetIndex:(int)targetIndex;
- (void)labelIsolatedEdge:(OTSEdge *)e targetIndex:(int)targetIndex target:(OTSGeometry *)target;
- (void)labelIsolatedNodes;
- (void)labelIsolatedNode:(OTSNode *)n targetIndex:(int)targetIndex;

@end
