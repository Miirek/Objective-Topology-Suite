//
//  OTSGeometryGraph.m
//

#import "OTSCGAlgorithms.h"
#import "OTSBoundaryNodeRule.h"

#import "OTSGeometryGraph.h"
#import "OTSNode.h"
#import "OTSEdge.h"
#import "OTSLabel.h"
#import "OTSPosition.h"

#import "OTSSimpleMCSweepLineIntersector.h"
#import "OTSSegmentIntersector.h"
#import "OTSEdgeSetIntersector.h"

#import "OTSCoordinateSequence.h"
#import "OTSLocation.h"
#import "OTSPoint.h"
#import "OTSLinearRing.h"
#import "OTSLineString.h"
#import "OTSPolygon.h"
#import "OTSMultiPoint.h"
#import "OTSMultiLineString.h"
#import "OTSMultiPolygon.h"
#import "OTSGeometryCollection.h"

@implementation OTSGeometryGraph

@synthesize parentGeom, boundaryNodeRule, useBoundaryDeterminationRule, hasTooFewPoints, argIndex;
@synthesize lineEdgeMap;
@synthesize invalidPoint;
@synthesize newSegmentIntersectors;

- (id)init {
	
	if (self = [super init]) {
		
		self.lineEdgeMap = [NSMutableDictionary dictionary];
		self.newSegmentIntersectors = [NSMutableArray array];
		
		self.parentGeom = nil;
		useBoundaryDeterminationRule = YES;
		self.boundaryNodeRule = [OTSBoundaryNodeRule OGC_SFS_BOUNDARY_RULE];
		argIndex = -1;
		hasTooFewPoints = NO;
		if (parentGeom != nil) {
			[self add:parentGeom];
		}
	}
	return self;

}

- (id)initWithArgIndex:(int)newArgIndex 
			parentGeom:(OTSGeometry *)newParentGeom 
	  boundaryNodeRule:(OTSBoundaryNodeRule *)theBoundaryNodeRule {
	
	if (self = [super init]) {
		self.lineEdgeMap = [NSMutableDictionary dictionary];
		self.newSegmentIntersectors = [NSMutableArray array];
		
		self.parentGeom = newParentGeom;
		useBoundaryDeterminationRule = YES;
		self.boundaryNodeRule = theBoundaryNodeRule;
		argIndex = newArgIndex;
		hasTooFewPoints = NO;
		if (parentGeom != nil) {
			[self add:parentGeom];
		}		
	}
	return self;
	
}

- (id)initWithArgIndex:(int)newArgIndex 
			parentGeom:(OTSGeometry *)newParentGeom {
	
	if (self = [super init]) {
		
		self.lineEdgeMap = [NSMutableDictionary dictionary];
		self.newSegmentIntersectors = [NSMutableArray array];
		
		self.parentGeom = newParentGeom;
		useBoundaryDeterminationRule = YES;
		self.boundaryNodeRule = [OTSBoundaryNodeRule OGC_SFS_BOUNDARY_RULE];
		argIndex = newArgIndex;
		hasTooFewPoints = NO;
		if (parentGeom != nil) {
			[self add:parentGeom];
		}
		
	}
	return self;
}

- (void)dealloc {	
	[parentGeom release];
	[boundaryNodeRule release];
	[lineEdgeMap release];
	[boundaryPoints release];
	[boundaryNodes release];
	[invalidPoint release];
	[newSegmentIntersectors release];
	[super dealloc];
}

- (OTSGeometry *)getGeometry {
	return parentGeom;
}

- (OTSEdgeSetIntersector *)createEdgeSetIntersector {
	return [[[OTSSimpleMCSweepLineIntersector alloc] init] autorelease];
}

- (void)add:(OTSGeometry *)g {
	
	if ([g isEmpty]) return;
	
	// check if this Geometry should obey the Boundary Determination Rule
	// all collections except MultiPolygons obey the rule
	if ([g isKindOfClass:[OTSMultiPolygon class]])
		useBoundaryDeterminationRule = NO;
	
	if ([g isKindOfClass:[OTSPolygon class]])
		[self addPolygon:(OTSPolygon *)g];
	
	// LineString also handles LinearRings
	else if ([g isKindOfClass:[OTSLineString class]])
		[self addLineString:(OTSLineString *)g];
	
	else if ([g isKindOfClass:[OTSPoint class]])
		[self addPoint:(OTSPoint *)g];
	
	else if ([g isKindOfClass:[OTSMultiPoint class]])
		[self addCollection:(OTSMultiPoint *)g];
	
	else if ([g isKindOfClass:[OTSMultiLineString class]])
		[self addCollection:(OTSMultiLineString *)g];
	
	else if ([g isKindOfClass:[OTSMultiPolygon class]])
		[self addCollection:(OTSMultiPolygon *)g];
	
	else if ([g isKindOfClass:[OTSGeometryCollection class]])
		[self addCollection:(OTSGeometryCollection *)g];
	
	else {
		NSException *ex = [NSException exceptionWithName:@"UnsupportedOperationException" 
												  reason:@"unknown geometry type" 
												userInfo:nil];
		@throw ex;
	}	
}

- (void)addCollection:(OTSGeometryCollection *)gc {
	for (OTSGeometry *g in gc.geometries) {
		[self add:g];
	}
}

- (void)addPoint:(OTSPoint *)p {
	OTSCoordinate *coord = [p getCoordinate];
	[self insertPoint:coord at:argIndex onLocation:kOTSLocationInterior];
}

- (void)addPolygonRing:(OTSLinearRing *)lr cwLeft:(int)cwLeft cwRight:(int)cwRight {
	
	// skip empty component (see bug #234)
	if ([lr isEmpty]) return;
	
	OTSCoordinateSequence *lrcl = [lr getCoordinatesRO];
	
	OTSCoordinateSequence *coord = [OTSCoordinateSequence removeRepeatedPoints:lrcl];
	if ([coord size] < 4) {
		hasTooFewPoints = YES;
		invalidPoint = [coord getAt:0]; // its now a Coordinate
		return;
	}
	
	int left = cwLeft;
	int right = cwRight;
	
	/*
	 * the isCCW call might throw an
	 * IllegalArgumentException if degenerate ring does
	 * not contain 3 distinct points.
	 */
	if ([OTSCGAlgorithms isCCW:coord]) {
		left = cwRight;
		right = cwLeft;
	}
	
	OTSLabel *label = [[OTSLabel alloc] initWithGeometryIndex:argIndex 
														 onLocation:kOTSLocationBoundary 
													   leftLocation:left 
													  rightLocation:right];
	OTSEdge *e = [[OTSEdge alloc] initWithCoordinateSequence:coord label:label];
	[lineEdgeMap setObject:e forKey:lr];
	[self insertEdge:e];
	[self insertPoint:[coord getAt:0] at:argIndex onLocation:kOTSLocationBoundary];
	[label release];
	[e release];
	
}

- (void)addPolygon:(OTSPolygon *)p {
	
	OTSLineString *ls;
	OTSLinearRing *lr;
	
	ls = [p getExteriorRing];
	lr = (OTSLinearRing *)ls;
	[self addPolygonRing:lr cwLeft:kOTSLocationExterior cwRight:kOTSLocationInterior];
	
	for (int i=0, n = [p getNumInteriorRing]; i < n; ++i) {
		// Holes are topologically labelled opposite to the shell, since
		// the interior of the polygon lies on their opposite side
		// (on the left, if the hole is oriented CW)
		ls = [p getInteriorRingN:i];
		lr = (OTSLinearRing *)ls;
		[self addPolygonRing:lr cwLeft:kOTSLocationInterior cwRight:kOTSLocationExterior];
	}
	
}

- (void)addLineString:(OTSLineString *)line {
	
	OTSCoordinateSequence *coord = [OTSCoordinateSequence removeRepeatedPoints:[line getCoordinatesRO]];
	if ([coord size] < 2) {
		hasTooFewPoints = YES;
		invalidPoint = [coord getAt:0];
		return;
	}
	
	OTSLabel *label = [[OTSLabel alloc] initWithGeometryIndex:argIndex onLocation:kOTSLocationInterior];
	OTSEdge *e = [[OTSEdge alloc] initWithCoordinateSequence:coord label:label];
	[lineEdgeMap setObject:e forKey:line];
	[self insertEdge:e];
	[e release];
	[label release];
	
	/*
	 * Add the boundary points of the LineString, if any.
	 * Even if the LineString is closed, add both points as if they
	 * were endpoints.
	 * This allows for the case that the node already exists and is
	 * a boundary point.
	 */
	[self insertBoundaryPoint:[coord getAt:0] at:argIndex];
	[self insertBoundaryPoint:[coord getAt:[coord size] - 1] at:argIndex];
	
}

- (void)insertPoint:(OTSCoordinate *)coord at:(int)_argIndex onLocation:(int)onLocation {
	OTSNode *n = [nodes addNodeWithCoordinate:coord];
	OTSLabel *lbl = n.label;
	if (lbl == nil) {
		[n setLabel:_argIndex onLocation:onLocation];
	} else {
		[lbl setLocation:onLocation atGeometryIndex:_argIndex];
	}	
}

- (void)insertBoundaryPoint:(OTSCoordinate *)coord at:(int)_argIndex {
	
	OTSNode *n = [nodes addNodeWithCoordinate:coord];
	OTSLabel *lbl = n.label;
	
	// the new point to insert is on a boundary
	int boundaryCount = 1;
	// determine the current location for the point (if any)
	int loc = kOTSLocationUndefined;
	if (lbl != nil) loc = [lbl locationAtGeometryIndex:_argIndex atPosIndex:kOTSPositionOn];
	if (loc == kOTSLocationBoundary) boundaryCount++;
	
	// determine the boundary status of the point according to the
	// Boundary Determination Rule
	int newLoc = [OTSGeometryGraph determineBoundary:boundaryCount with:boundaryNodeRule];
	[lbl setLocation:newLoc atGeometryIndex:_argIndex];
	
}

- (void)addSelfIntersectionNodes:(int)_argIndex {
	for (OTSEdge *e in edges) {
		int eLoc = [e.label locationAtGeometryIndex:_argIndex];
		OTSEdgeIntersectionList *eiL = e.eiList;		
		for (OTSEdgeIntersection *ei in eiL.nodeMap) {
			[self addSelfIntersectionNode:ei.coordinate at:_argIndex onLocation:eLoc];
		}
	}
}

- (void)addSelfIntersectionNode:(OTSCoordinate *)coord at:(int)_argIndex onLocation:(int)onLocation {
	// if this node is already a boundary node, don't change it
	if ([self isBoundaryNode:_argIndex coord:coord]) return;
	if (onLocation == kOTSLocationBoundary && useBoundaryDeterminationRule) {
		[self insertBoundaryPoint:coord at:_argIndex];
	} else {
		[self insertPoint:coord at:_argIndex onLocation:onLocation];
	}	
}

+ (BOOL)isInBoundary:(int)boundaryCount {
	return boundaryCount%2 == 1;
}

+ (int)determineBoundary:(int)boundaryCount {
	return [OTSGeometryGraph isInBoundary:boundaryCount] ? kOTSLocationBoundary : kOTSLocationInterior;
}

+ (int)determineBoundary:(int)boundaryCount with:(OTSBoundaryNodeRule *)boundaryNodeRule {
	return [boundaryNodeRule isInBoundary:boundaryCount] ? kOTSLocationBoundary : kOTSLocationInterior;
}

- (NSArray *)getBoundaryNodes {
	if (boundaryNodes == nil) {
		boundaryNodes = [[NSMutableArray alloc] init];
		[self getBoundaryNodesIntoArray:boundaryNodes];
	}
	return boundaryNodes;
}

- (void)getBoundaryNodesIntoArray:(NSMutableArray *)bdyNodes {
	[nodes getBoundaryNodes:argIndex bdyNodes:bdyNodes];
}

- (OTSCoordinateSequence *)getBoundaryPoints {	
	if (boundaryPoints == nil) {
		// Collection will be destroied by GeometryGraph dtor
		NSArray *coll = [self getBoundaryNodes];
		
		boundaryPoints = [[OTSCoordinateSequence alloc] init];
		for (OTSNode *node in coll) {
			[boundaryPoints add:[node getCoordinate]];
		}
	}
	return boundaryPoints;
}

- (OTSEdge *)findEdge:(OTSLineString *)line {	
	return [lineEdgeMap objectForKey:line];
}

- (void)computeSplitEdges:(NSMutableArray *)edgelist {
	for (OTSEdge *e in edges) {
		[e.eiList addSplitEdges:edgelist];
	}
}

- (void)addEdge:(OTSEdge *)e {	
	[self insertEdge:e];
	OTSCoordinateSequence *coord = [e getCoordinates];
	// insert the endpoint as a node, to mark that it is on the boundary
	[self insertPoint:[coord getAt:0] at:argIndex onLocation:kOTSLocationBoundary];
	[self insertPoint:[coord getAt:[coord size] - 1] at:argIndex onLocation:kOTSLocationBoundary];
}

- (void)addPointWithCoordinate:(OTSCoordinate *)pt {
	[self insertPoint:pt at:argIndex onLocation:kOTSLocationInterior];
}

- (OTSSegmentIntersector *)computeSelfNodes:(OTSLineIntersector *)li 
						  computeRingSelfNodes:(BOOL)computeRingSelfNodes {
	
	OTSSegmentIntersector *si = [[OTSSegmentIntersector alloc] initWithLineIntersector:li 
																			newIncludeProper:YES 
																		   newRecordIsolated:NO];
	OTSEdgeSetIntersector *esi = [self createEdgeSetIntersector];
	// optimized test for Polygons and Rings
	if (parentGeom == nil) {
		[esi computeIntersections:edges segmentIntersector:si testAllSegments:YES];
	} else if (!computeRingSelfNodes & 
			   ([parentGeom isKindOfClass:[OTSLinearRing class]] || 
				[parentGeom isKindOfClass:[OTSPolygon class]] || 
				[parentGeom isKindOfClass:[OTSMultiPolygon class]])) {
		[esi computeIntersections:edges segmentIntersector:si testAllSegments:NO];
	} else {
		[esi computeIntersections:edges segmentIntersector:si testAllSegments:YES];
	}

	[self addSelfIntersectionNodes:argIndex];
	return [si autorelease];	
}

- (OTSSegmentIntersector *)computeEdgeIntersections:(OTSGeometryGraph *)g 
									   lineIntersector:(OTSLineIntersector *)li 
										 includeProper:(BOOL)includeProper {
	OTSSegmentIntersector *si = [[OTSSegmentIntersector alloc] initWithLineIntersector:li 
																			newIncludeProper:includeProper 
																		   newRecordIsolated:YES];
	[newSegmentIntersectors addObject:si];
	[si setBoundaryNodes:[self getBoundaryNodes] bdyNodes1:[g getBoundaryNodes]];
	OTSEdgeSetIntersector *esi = [self createEdgeSetIntersector];
	[esi computeIntersections:edges edges1:g.edges segmentIntersector:si];
	return [si autorelease];
}

@end
