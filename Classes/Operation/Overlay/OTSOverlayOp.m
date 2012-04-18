//
//  OTSOverlayOp.m
//

#import "OTSOverlayOp.h"
#import "OTSOverlayResultValidator.h"
#import "OTSElevationMatrix.h"
#import "OTSOverlayNodeFactory.h"
#import "OTSPolygonBuilder.h"
#import "OTSLineBuilder.h"
#import "OTSPointBuilder.h"
#import "OTSGeometry.h"
#import "OTSCoordinate.h"
#import "OTSGeometryFactory.h"
#import "OTSPolygon.h"
#import "OTSLineString.h"
#import "OTSPoint.h"
#import "OTSPrecisionModel.h"
#import "OTSLabel.h"
#import "OTSEdge.h"
#import "OTSNode.h"
#import "OTSGeometryGraph.h"
#import "OTSEdgeEndStar.h"
#import "OTSDirectedEdgeStar.h"
#import "OTSDirectedEdge.h"
#import "OTSPosition.h"
#import "OTSSegmentIntersector.h"
#import "OTSSimpleGeometryPrecisionReducer.h"
#import "OTSEdgeNodingValidator.h"

@implementation OTSOverlayOp

@synthesize geomFact, resultGeom, graph, resultPolyList, resultLineList, resultPointList;
@synthesize elevationMatrix;
@synthesize edgeList;
@synthesize dupEdges;
@synthesize ptLocator;

+ (OTSGeometry *)overlayOpFirstGeometry:(OTSGeometry *)g0 
						 andSecondGeometry:(OTSGeometry *)g1 
									withOp:(OTSOverlayOpCode)opCode {
	OTSOverlayOp *op = [[OTSOverlayOp alloc] initWithFirstGeometry:g0 andSecondGeometry:g1];
	OTSGeometry *ret = [op resultGeometryWithOp:opCode];
	[op release];
	return ret;
}

- (id)initWithFirstGeometry:(OTSGeometry *)g0 
		  andSecondGeometry:(OTSGeometry *)g1 {
	if (self = [super initWithFirstGeometry:g0 andSecondGeometry:g1]) {
		resultGeom = nil;
		self.geomFact = g0.factory;
		
		graph = [[OTSPlanarGraph alloc] initWithNodeFactory:[OTSOverlayNodeFactory instance]];
		resultPolyList = nil;
		resultLineList = nil;
		resultPointList = nil;
		
		edgeList = [[OTSEdgeList alloc] init];
		self.dupEdges = [NSMutableArray array];
		ptLocator = [[OTSPointLocator alloc] init];
		
//#if COMPUTE_Z
//#if USE_INPUT_AVGZ
//		avgz[0] = NAN;
//		avgz[1] = NAN;
//		avgzcomputed[0] = NO;
//		avgzcomputed[1] = NO;
//#endif // USE_INPUT_AVGZ
//		OTSEnvelope *env = [g0 getEnvelopeInternal];
//		[env expandToInclude:[g1 getEnvelopeInternal]];
//#if USE_ELEVATION_MATRIX
//		elevationMatrix = [[OTSElevationMatrix alloc] initWithEnvelope:env rows:3 cols:3];
//		[elevationMatrix add:g0];
//		[elevationMatrix add:g1];
//#endif // USE_ELEVATION_MATRIX
//#endif // COMPUTE_Z
	}
	return self;
}

- (void)dealloc {
	[resultGeom release];
	[geomFact release];
	[graph release];
	[edgeList release];
	[dupEdges release];
	[ptLocator release];
	[resultPolyList release];
	[resultLineList release];
	[resultPointList release];
	[super dealloc];
}

- (OTSGeometry *)resultGeometryWithOp:(OTSOverlayOpCode)opCode {
	[self computeOverlay:opCode];
	return resultGeom;
}

- (void)computeOverlay:(OTSOverlayOpCode)opCode {
	
	// copy points from input Geometries.
	// This ensures that any Point geometries
	// in the input are considered for inclusion in the result set
	[self copyPoints:0];
	[self copyPoints:1];
	
	OTSGeometryGraph *argAt0 = [arg objectAtIndex:0];
	OTSGeometryGraph *argAt1 = [arg objectAtIndex:1];
	
	// node the input Geometries
	[argAt0 computeSelfNodes:li computeRingSelfNodes:NO];
	[argAt1 computeSelfNodes:li computeRingSelfNodes:NO];
	
	// compute intersections between edges of the two input geometries
	[argAt0 computeEdgeIntersections:argAt1 lineIntersector:li includeProper:YES];
	
	NSMutableArray *baseSplitEdges = [NSMutableArray array];
	[argAt0 computeSplitEdges:baseSplitEdges];
	[argAt1 computeSplitEdges:baseSplitEdges];
	
	// add the noded edges to this result graph
	[self insertUniqueEdges:baseSplitEdges];
	[self computeLabelsFromDepths];
	[self replaceCollapsedEdges];
	
//#ifdef ENABLE_EDGE_NODING_VALIDATOR // {
//	/**
//	 * Check that the noding completed correctly.
//	 *
//	 * This test is slow, but necessary in order to catch
//	 * robustness failure situations.
//	 * If an exception is thrown because of a noding failure,
//	 * then snapping will be performed, which will hopefully avoid
//	 * the problem.
//	 * In the future hopefully a faster check can be developed.
//	 *
//	 */
//	if ( resultPrecisionModel->isFloating() ) // NOTE: this is not in JTS
//	{
//		
//		try
//		{
//			// Will throw TopologyException if noding is
//			// found to be invalid
//			EdgeNodingValidator::checkValid(edgeList.getEdges());
//		}
//		catch (const util::TopologyException& ex)
//		{
//			// In the error scenario, the edgeList is not properly
//			// deleted. Cannot add to the destructor of EdgeList
//			// (as it should) because 
//			// "graph.addEdges(edgeList.getEdges());" below
//			// takes over edgeList ownership in the success case.
//			edgeList.clearList();
//			
//			throw ex;
//		}
//		
//	}
//#ifdef GEOS_DEBUG_VALIDATION // {
//	else
//	{
//		cout << "Did not run EdgeNodingValidator as the precision model is not floating" << endl;
//	}
//#endif // GEOS_DEBUG_VALIDATION }
//#endif // ENABLE_EDGE_NODING_VALIDATOR }
	
	
	[graph addEdgesWithArray:edgeList.edges];
	
	NSMutableArray *nodes = [NSMutableArray array];
	[graph.nodes getNodesAsArray:nodes];
	[self computeLabelling:nodes];		
	[self labelIncompleteNodes:nodes];

	/*
	 * The ordering of building the result Geometries is important.
	 * Areas must be built before lines, which must be built
	 * before points.
	 * This is so that lines which are covered by areas are not
	 * included explicitly, and similarly for points.
	 */
	[self findResultAreaEdges:opCode];	
	[self cancelDuplicateResultEdges];
			
	OTSPolygonBuilder *polyBuilder = [[OTSPolygonBuilder alloc] initWithGeometryFactory:geomFact];
	[polyBuilder add:graph];	
	NSArray *gv = [polyBuilder getPolygons];
	
	if (resultPolyList != nil) [resultPolyList release];
	self.resultPolyList = [NSMutableArray array];	
	for (OTSPolygon *poly in gv) {
		[resultPolyList addObject:poly];
	}
	[polyBuilder release];
	
	/*
	self.resultLineList = [NSMutableArray array];
	self.resultPointList = [NSMutableArray array];
	 */
	
	OTSLineBuilder *lineBuilder = [[OTSLineBuilder alloc] initWithOverlayOp:self 
																  geometryFactory:geomFact 
																		ptLocator:ptLocator];
	if (resultLineList != nil) [resultLineList release];
	self.resultLineList = [lineBuilder build:opCode];
	[lineBuilder release];
	
	OTSPointBuilder *pointBuilder = [[OTSPointBuilder alloc] initWithOverlayOp:self 
																	 geometryFactory:geomFact 
																		   ptLocator:ptLocator];
	if (resultPointList != nil) [resultPointList release];
	self.resultPointList = [pointBuilder build:opCode];
	[pointBuilder release];
	
	// gather the results from all calculations into a single
	// Geometry for the result set
	self.resultGeom = [self computeGeometryInPointList:resultPointList 
											  lineList:resultLineList 
											  polyList:resultPolyList];

	//checkObviouslyWrongResult(opCode);
	
//#if USE_ELEVATION_MATRIX
	//[elevationMatrix elevate:resultGeom];
//#endif // USE_ELEVATION_MATRIX
	
}

- (void)copyPoints:(int)argIndex {
	
	OTSGeometryGraph *argAtIndex = [arg objectAtIndex:argIndex];
	
	NSMutableArray *tmp = [NSMutableArray array];
	[argAtIndex.nodes getNodesAsArray:tmp];
	for (OTSNode *graphNode in tmp) {
		OTSNode *newNode = [graph addNodeWithCoordinate:[graphNode getCoordinate]];
		[newNode setLabel:argIndex onLocation:[graphNode.label locationAtGeometryIndex:argIndex]];
	}
	
}

- (void)insertUniqueEdges:(NSMutableArray *)edges {
	for (OTSEdge *e in edges) {
		[self insertUniqueEdge:e];
	}
}

- (void)insertUniqueEdge:(OTSEdge *)e {
	
	//<FIX> MD 8 Oct 03  speed up identical edge lookup
	// fast lookup
	OTSEdge *existingEdge = [edgeList findEqualEdge:e];
	
	// If an identical edge already exists, simply update its label
	if (existingEdge != nil) {
		
		OTSLabel *existingLabel = existingEdge.label;		
		OTSLabel *labelToMerge = e.label;
		
		// check if new edge is in reverse direction to existing edge
		// if so, must flip the label before merging it
		if (![existingEdge isPointwiseEqual:e]) {
			[labelToMerge flip];
		}
		
		OTSDepth *depth = existingEdge.depth;
		
		// if this is the first duplicate found for this edge,
		// initialize the depths
		if ([depth isNull]) {
			[depth addLabel:existingLabel];
		}
		
		[depth addLabel:labelToMerge];
		
		[existingLabel merge:labelToMerge];
		[dupEdges addObject:e];
	} else {  // no matching existing edge was found
		// add this new edge to the list of edges in this graph
		[edgeList add:e];
	}
		
}

- (void)computeLabelsFromDepths {
	
	for (OTSEdge *e in edgeList.edges) {
		
		OTSLabel *lbl = e.label;
		OTSDepth *depth = e.depth;
		
		/*
		 * Only check edges for which there were duplicates,
		 * since these are the only ones which might
		 * be the result of dimensional collapses.
		 */
		if ([depth isNull]) continue;
		
		[depth normalize];
		for (int i = 0; i < 2; i++) {
			
			if (![lbl isNullAtGeometryIndex:i] && [lbl isArea] && ![depth isNullAt:i]) {
				/*
				 * if the depths are equal, this edge is the result of
				 * the dimensional collapse of two or more edges.
				 * It has the same location on both sides of the edge,
				 * so it has collapsed to a line.
				 */
				if ([depth deltaAt:i] == 0) {
					[lbl toLineAtGeometryIndex:i];
				} else {
					/*
					 * This edge may be the result of a dimensional collapse,
					 * but it still has different locations on both sides.  The
					 * label of the edge must be updated to reflect the resultant
					 * side locations indicated by the depth values.
					 */
					NSAssert(![depth isNullAt:i posIndex:kOTSPositionLeft], @"depth of LEFT side has not been initialized");
					[lbl setLocation:[depth locationAt:i posIndex:kOTSPositionLeft] atGeometryIndex:i atPosIndex:kOTSPositionLeft];
					NSAssert(![depth isNullAt:i posIndex:kOTSPositionRight], @"depth of RIGHT side has not been initialized");
					[lbl setLocation:[depth locationAt:i posIndex:kOTSPositionRight] atGeometryIndex:i atPosIndex:kOTSPositionRight];
				}
			}
		}
	}
}

- (void)replaceCollapsedEdges {
	
	for (int i = 0, n = [edgeList.edges count]; i < n; ++i) {
		OTSEdge *e = [edgeList.edges objectAtIndex:i];
		if ([e isCollapsed]) {
			[edgeList.edges replaceObjectAtIndex:i withObject:[e getCollapsedEdge]];
		}
	}
	
}

- (void)computeLabelling:(NSMutableArray *)nodes {
	for (OTSNode *node in nodes) {
		[node.edges computeLabelling:arg];
	}
	
	[self mergeSymLabels:nodes];
	[self updateNodeLabelling:nodes];
}

- (void)mergeSymLabels:(NSMutableArray *)nodes {
	for (OTSNode *node in nodes) {
		OTSEdgeEndStar *ees = node.edges;
		NSAssert([ees isKindOfClass:[OTSDirectedEdgeStar class]], @"Expecting OTSDirectedEdgeStar class");
		[((OTSDirectedEdgeStar *)ees) mergeSymLabels];
	}
}

- (void)updateNodeLabelling:(NSMutableArray *)nodes {
	for (OTSNode *node in nodes) {
		OTSEdgeEndStar *ees = node.edges;
		OTSDirectedEdgeStar *des = (OTSDirectedEdgeStar *)ees;
		[node.label merge:des.label];
	}
}

/*private*/
- (void)labelIncompleteNodes:(NSMutableArray *)nodes {	
	for (OTSNode *n in nodes) {
		
		OTSLabel *label = n.label;
		if ([n isIsolated]) {
			if ([label isNullAtGeometryIndex:0]) {
				[self labelIncompleteNode:n targetIndex:0];
			} else {
				[self labelIncompleteNode:n targetIndex:1];
			}
		}
		
		// now update the labelling for the DirectedEdges incident on this node
		OTSEdgeEndStar *ees = n.edges;
		OTSDirectedEdgeStar *des = (OTSDirectedEdgeStar *)ees;
		[des updateLabelling:label];		
	}
}

- (void)labelIncompleteNode:(OTSNode *)n targetIndex:(int)targetIndex {
	
	OTSGeometryGraph *argAtIndex = [arg objectAtIndex:targetIndex];
	OTSGeometry *targetGeom = [argAtIndex getGeometry];
	
	int loc = [ptLocator locate:n.coord relativeTo:targetGeom];
	[n.label setLocation:loc atGeometryIndex:targetIndex];
	
//#if COMPUTE_Z
//	/*
//	 * If this node has been labeled INTERIOR of a line
//	 * or BOUNDARY of a polygon we must merge
//	 * Z values of the intersected segment.
//	 * The intersection point has been already computed
//	 * by LineIntersector invoked by CGAlgorithms::isOnLine
//	 * invoked by PointLocator.
//	 */
//	if ([targetGeom isKindOfClass:[OTSLineString class]]) {
//		OTSLineString *line = (OTSLineString *)targetGeom;
//		if (loc == kOTSLocationInterior) {
//			[self mergeZ:n ofLineString:line];
//		}
//	}
//	if ([targetGeom isKindOfClass:[OTSPolygon class]]) {
//		OTSPolygon *poly = (OTSPolygon *)targetGeom;
//		if (loc == kOTSLocationBoundary) {
//			[self mergeZ:n ofPolygon:poly];
//		}
//		//#if USE_INPUT_AVGZ
//		if (loc == kOTSLocationInterior) {
//			[n addZ:[self getAverageZ:targetIndex]];
//		}
//		//#endif // USE_INPUT_AVGZ		
//	}
//#endif // COMPUTE_Z
}

- (int)mergeZ:(OTSNode *)n ofLineString:(OTSLineString *)line {
	
	OTSCoordinateSequence *pts = [line getCoordinatesRO];
	OTSCoordinate *p = n.coord;
	OTSLineIntersector *lli = [[OTSLineIntersector alloc] init];
	for (int i = 1, size = [pts size]; i < size; ++i) {
		OTSCoordinate *p0 = [pts getAt:i-1];
		OTSCoordinate *p1 = [pts getAt:i];
		[li computeIntersectionOfPoint:p along:p0 to:p1];
		if ([li hasIntersection]) {
			if ([p isEqual2D:p0]) {
				[n addZ:p0.z];
			} else if ([p isEqual2D:p1]) {
				[n addZ:p1.z];
			} else {
				[n addZ:[OTSLineIntersector interpolateZAtPoint:p from:p0 to:p1]];
			}
      [lli release];
			return 1;
		}
	}
	
	[lli release];
	return 0;
}

- (int)mergeZ:(OTSNode *)n ofPolygon:(OTSPolygon *)poly {
	
	OTSLineString *ls;
	int found = 0;
	ls = [poly getExteriorRing];
	found = [self mergeZ:n ofLineString:ls];
	if ( found == 1 ) return 1;
	
	for (int i = 0, nr = [poly getNumInteriorRing]; i < nr; ++i) {
		ls = [poly getInteriorRingN:i];
		found = [self mergeZ:n ofLineString:ls];
		if ( found == 1 ) return 1;
	}
	return 0;
}

+ (double)getAverageZOfPolygon:(OTSPolygon *)poly {
	double totz = 0.0;
	int zcount = 0;
	
	OTSCoordinateSequence *pts = [[poly getExteriorRing] getCoordinatesRO];
	int npts = [pts size];
	for (int i = 0; i < npts; ++i) {
		OTSCoordinate *c = [pts getAt:i];
		if (!isnan(c.z)) {
			totz += c.z;
			zcount++;
		}
	}
	
	if (zcount > 0) return totz/zcount;
	else return NAN;
}

- (double)getAverageZ:(int)targetIndex {
	
	if (avgzcomputed[targetIndex]) return avgz[targetIndex];
	OTSGeometryGraph *argAtIndex = [arg objectAtIndex:targetIndex];
	
	const OTSGeometry *targetGeom = [argAtIndex getGeometry];
	
	// OverlayOp::getAverageZ(int) called with a ! polygon
	NSAssert([targetGeom getGeometryTypeId] == kOTSGeometryPolygon, @"getAverageZ(int) called with other than a polygon");
	
	avgz[targetIndex] = [OTSOverlayOp getAverageZOfPolygon:(OTSPolygon *)targetGeom];
	avgzcomputed[targetIndex] = YES;
	return avgz[targetIndex];
}

- (void)findResultAreaEdges:(OTSOverlayOpCode)opCode {
	
	NSArray *ee = [graph getEdgeEnds];
	for (OTSDirectedEdge *de in ee) {
		// mark all dirEdges with the appropriate label
		OTSLabel *label = de.label;
		if ([label isArea]
			&& ![de isInteriorAreaEdge]
			&& [OTSOverlayOp isResultOfOp:opCode 
								   location0:[label locationAtGeometryIndex:0 atPosIndex:kOTSPositionRight] 
								   location1:[label locationAtGeometryIndex:1 atPosIndex:kOTSPositionRight]]
			) {			
			[de setInResult:YES];
		}
	}	
}

+ (BOOL)isResultOfOp:(OTSOverlayOpCode)opCode location0:(int)loc0 location1:(int)loc1 {
	
	if (loc0 == kOTSLocationBoundary) loc0 = kOTSLocationInterior;
	if (loc1 == kOTSLocationBoundary) loc1 = kOTSLocationInterior;
	switch (opCode) {
		case kOTSOverlayIntersection:
			return loc0 == kOTSLocationInterior && loc1 == kOTSLocationInterior;
		case kOTSOverlayUnion:
			return loc0 == kOTSLocationInterior || loc1 == kOTSLocationInterior;
		case kOTSOverlayDifference:
			return loc0 == kOTSLocationInterior && loc1 != kOTSLocationInterior;
		case kOTSOverlaySymDifference:
			return (loc0 == kOTSLocationInterior && loc1 != kOTSLocationInterior) 
			|| (loc0 != kOTSLocationInterior && loc1 == kOTSLocationInterior);
	}
	return NO;
}

+ (BOOL)isResultOfOp:(OTSLabel *)label opCode:(OTSOverlayOpCode)opCode {
	int loc0 = [label locationAtGeometryIndex:0];
	int loc1 = [label locationAtGeometryIndex:1];
	return [OTSOverlayOp isResultOfOp:opCode location0:loc0 location1:loc1];
}

- (void)cancelDuplicateResultEdges {
	// remove any dirEdges whose sym is also included
	// (they "cancel each other out")
	NSArray *ee = [graph getEdgeEnds];
	for (OTSDirectedEdge *de in ee) {
		OTSDirectedEdge *sym = de.sym;
		if (de.inResult && sym.inResult) {
			[de setInResult:NO];
			[sym setInResult:NO];
		}
	}
}

- (BOOL)isCoveredByA:(OTSCoordinate *)coord {
	return [self isCoordinate:coord coveredByPolygons:resultPolyList];
}

- (BOOL)isCoveredByLA:(OTSCoordinate *)coord {
	if ([self isCoordinate:coord coveredByLineStrings:resultLineList]) return YES;
	if ([self isCoordinate:coord coveredByPolygons:resultPolyList]) return YES;
	return NO;
}

- (BOOL)isCoordinate:(OTSCoordinate *)coord coveredByPolygons:(NSArray *)geomList {
	for (OTSGeometry *geom in geomList) {
		int loc = [ptLocator locate:coord relativeTo:geom];
		if (loc != kOTSLocationExterior) return YES;
	}
	return NO;
}

- (BOOL)isCoordinate:(OTSCoordinate *)coord coveredByLineStrings:(NSArray *)geomList {
	for (OTSGeometry *geom in geomList) {
		int loc = [ptLocator locate:coord relativeTo:geom];
		if (loc != kOTSLocationExterior) return YES;
	}
	return NO;
}

- (OTSGeometry *)computeGeometryInPointList:(NSMutableArray *)nResultPointList 
									  lineList:(NSMutableArray *)nResultLineList 
									  polyList:(NSMutableArray *)nResultPolyList {
	
	NSMutableArray *geomList = [NSMutableArray array];
	[geomList addObjectsFromArray:nResultPointList];
	[geomList addObjectsFromArray:nResultLineList];
	[geomList addObjectsFromArray:nResultPolyList];
		
	// build the most specific geometry possible
	return [geomFact buildGeometry:geomList];
}

@end
