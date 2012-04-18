//
//  OTSGeometryGraph.h
//

#import <Foundation/Foundation.h>

#import "OTSCoordinate.h"
#import "OTSCoordinateSequence.h" // for auto_ptr<CoordinateSequence>
#import "OTSPlanarGraph.h"
#import "OTSLineString.h" // for LineStringLT

@class OTSLineString;
@class OTSLinearRing;
@class OTSPolygon;
@class OTSGeometry;
@class OTSGeometryCollection;
@class OTSPoint;
@class OTSLineIntersector;
@class OTSBoundaryNodeRule;
@class OTSEdge;
@class OTSNode;
@class OTSSegmentIntersector;
@class OTSEdgeSetIntersector;

@interface OTSGeometryGraph : OTSPlanarGraph {
	OTSGeometry *parentGeom;
	OTSBoundaryNodeRule *boundaryNodeRule;
	BOOL useBoundaryDeterminationRule;
	BOOL hasTooFewPoints;
	int argIndex;
	NSMutableDictionary *lineEdgeMap;
	OTSCoordinateSequence *boundaryPoints;
	NSMutableArray *boundaryNodes;
	OTSCoordinate *invalidPoint;
	NSMutableArray *newSegmentIntersectors;
}

@property (nonatomic, retain) OTSGeometry *parentGeom;
@property (nonatomic, retain) OTSBoundaryNodeRule *boundaryNodeRule;
@property (nonatomic, assign) BOOL useBoundaryDeterminationRule;
@property (nonatomic, assign) BOOL hasTooFewPoints;
@property (nonatomic, assign) int argIndex;
@property (nonatomic, retain) NSMutableDictionary *lineEdgeMap;
@property (nonatomic, retain) OTSCoordinate *invalidPoint;
@property (nonatomic, retain) NSMutableArray *newSegmentIntersectors;

- (id)initWithArgIndex:(int)newArgIndex 
			parentGeom:(OTSGeometry *)newParentGeom;
- (id)initWithArgIndex:(int)newArgIndex 
			parentGeom:(OTSGeometry *)newParentGeom 
	  boundaryNodeRule:(OTSBoundaryNodeRule *)theBoundaryNodeRule;
- (OTSGeometry *)getGeometry;
- (OTSEdgeSetIntersector *)createEdgeSetIntersector;
- (void)add:(OTSGeometry *)g;
- (void)addCollection:(OTSGeometryCollection *)gc;
- (void)addPoint:(OTSPoint *)p;
- (void)addPolygonRing:(OTSLinearRing *)lr cwLeft:(int)cwLeft cwRight:(int)cwRight;
- (void)addPolygon:(OTSPolygon *)p;
- (void)addLineString:(OTSLineString *)line;
- (void)insertPoint:(OTSCoordinate *)coord at:(int)argIndex onLocation:(int)onLocation;
- (void)insertBoundaryPoint:(OTSCoordinate *)coord at:(int)argIndex;
- (void)addSelfIntersectionNodes:(int)argIndex;
- (void)addSelfIntersectionNode:(OTSCoordinate *)coord at:(int)argIndex onLocation:(int)onLocation;

+ (BOOL)isInBoundary:(int)boundaryCount;
+ (int)determineBoundary:(int)boundaryCount;
+ (int)determineBoundary:(int)boundaryCount with:(OTSBoundaryNodeRule *)boundaryNodeRule;

- (NSArray *)getBoundaryNodes;
- (void)getBoundaryNodesIntoArray:(NSMutableArray *)bdyNodes;
- (OTSCoordinateSequence *)getBoundaryPoints;
- (OTSEdge *)findEdge:(OTSLineString *)line;
- (void)computeSplitEdges:(NSMutableArray *)edgelist;
- (void)addEdge:(OTSEdge *)e;
- (void)addPointWithCoordinate:(OTSCoordinate *)pt;

- (OTSSegmentIntersector *)computeSelfNodes:(OTSLineIntersector *)li 
						  computeRingSelfNodes:(BOOL)computeRingSelfNodes;
- (OTSSegmentIntersector *)computeEdgeIntersections:(OTSGeometryGraph *)g 
									   lineIntersector:(OTSLineIntersector *)li 
										 includeProper:(BOOL)includeProper;

@end
