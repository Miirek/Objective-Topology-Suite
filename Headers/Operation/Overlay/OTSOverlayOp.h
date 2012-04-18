//
//  OTSOverlayOp.h
//

#import <Foundation/Foundation.h>

#import "OTSGeometryGraphOperation.h" // for inheritance
#import "OTSEdgeList.h" // for composition
#import "OTSPointLocator.h" // for composition
#import "OTSPlanarGraph.h" // for inline (GeometryGraph->PlanarGraph)

@class OTSGeometry;
@class OTSCoordinate;
@class OTSGeometryFactory;
@class OTSPolygon;
@class OTSLineString;
@class OTSPoint;
@class OTSLabel;
@class OTSEdge;
@class OTSNode;
@class OTSElevationMatrix;

typedef enum {
	kOTSOverlayIntersection = 1,
	kOTSOverlayUnion,
	kOTSOverlayDifference,
	kOTSOverlaySymDifference
} OTSOverlayOpCode;

@interface OTSOverlayOp : OTSGeometryGraphOperation {
	OTSGeometryFactory *geomFact;
	OTSGeometry *resultGeom;
	OTSPlanarGraph *graph;
	OTSEdgeList *edgeList;
	NSMutableArray *dupEdges;
	NSMutableArray *resultPolyList;
	NSMutableArray *resultLineList;
	NSMutableArray *resultPointList;
	OTSPointLocator *ptLocator;
	
	double avgz[2];
	BOOL avgzcomputed[2];	
	OTSElevationMatrix *elevationMatrix;
}

@property (nonatomic, retain) OTSGeometryFactory *geomFact;
@property (nonatomic, retain) OTSGeometry *resultGeom;
@property (nonatomic, retain) OTSPlanarGraph *graph;
@property (nonatomic, retain) NSMutableArray *resultPolyList;
@property (nonatomic, retain) NSMutableArray *resultLineList;
@property (nonatomic, retain) NSMutableArray *resultPointList;
@property (nonatomic, retain) NSMutableArray *dupEdges;
@property (nonatomic, retain) OTSElevationMatrix *elevationMatrix;
@property (nonatomic, retain) OTSEdgeList *edgeList;
@property (nonatomic, retain) OTSPointLocator *ptLocator;

- (id)initWithFirstGeometry:(OTSGeometry *)g0 
		  andSecondGeometry:(OTSGeometry *)g1;
- (OTSGeometry *)resultGeometryWithOp:(OTSOverlayOpCode)opCode;
- (void)computeOverlay:(OTSOverlayOpCode)opCode;
- (void)copyPoints:(int)argIndex;
- (void)insertUniqueEdges:(NSMutableArray *)edges;
- (void)insertUniqueEdge:(OTSEdge *)e;
- (void)computeLabelsFromDepths;
- (void)replaceCollapsedEdges;
- (void)computeLabelling:(NSMutableArray *)nodes;
- (void)mergeSymLabels:(NSMutableArray *)nodes;
- (void)updateNodeLabelling:(NSMutableArray *)nodes;
- (void)labelIncompleteNodes:(NSMutableArray *)nodes;
- (void)labelIncompleteNode:(OTSNode *)n targetIndex:(int)targetIndex;
- (int)mergeZ:(OTSNode *)n ofLineString:(OTSLineString *)line;
- (int)mergeZ:(OTSNode *)n ofPolygon:(OTSPolygon *)poly;
- (double)getAverageZ:(int)targetIndex;
+ (double)getAverageZOfPolygon:(OTSPolygon *)poly;
- (void)findResultAreaEdges:(OTSOverlayOpCode)opCode;
+ (BOOL)isResultOfOp:(OTSOverlayOpCode)opCode location0:(int)loc0 location1:(int)loc1;
+ (BOOL)isResultOfOp:(OTSLabel *)label opCode:(OTSOverlayOpCode)opCode;
- (void)cancelDuplicateResultEdges;
- (BOOL)isCoveredByA:(OTSCoordinate *)coord;
- (BOOL)isCoveredByLA:(OTSCoordinate *)coord;
- (BOOL)isCoordinate:(OTSCoordinate *)coord coveredByPolygons:(NSArray *)geomList;
- (BOOL)isCoordinate:(OTSCoordinate *)coord coveredByLineStrings:(NSArray *)geomList;
- (OTSGeometry *)computeGeometryInPointList:(NSMutableArray *)nResultPointList 
									  lineList:(NSMutableArray *)nResultLineList 
									  polyList:(NSMutableArray *)nResultPolyList;

+ (OTSGeometry *)overlayOpFirstGeometry:(OTSGeometry *)g0 
						 andSecondGeometry:(OTSGeometry *)g1 
									withOp:(OTSOverlayOpCode)opCode;

@end
