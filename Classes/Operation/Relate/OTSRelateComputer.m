//
//  OTSRelateComputer.m
//

#import "OTSRelateComputer.h"
#import "OTSRelateNodeFactory.h"
#import "OTSRelateNode.h"
#import "OTSEdgeEndBuilder.h"
#import "OTSLineIntersector.h"
#import "OTSPointLocator.h"
#import "OTSIntersectionMatrix.h"
#import "OTSGeometry.h"
#import "OTSEnvelope.h"
#import "OTSSegmentIntersector.h"
#import "OTSGeometryGraph.h"
#import "OTSLabel.h"
#import "OTSEdge.h"
#import "OTSEdgeEndStar.h"
#import "OTSNode.h"
#import "OTSEdgeIntersectionList.h"
#import "OTSEdgeIntersection.h"


@implementation OTSRelateComputer

@synthesize li;
@synthesize ptLocator;
@synthesize arg; 	
@synthesize nodes;
@synthesize im;
@synthesize isolatedEdges;
@synthesize invalidPoint;

- (id)initWithGeometryGraphArray:(NSArray *)newArg {
	if (self = [super init]) {
		self.arg = newArg;
		nodes = [[OTSNodeMap alloc] initWithNodeFactory:[OTSRelateNodeFactory instance]];
		im = [[OTSIntersectionMatrix alloc] init];
		
		li = [[OTSLineIntersector alloc] init];
		ptLocator = [[OTSPointLocator alloc] init];
		self.isolatedEdges = [NSMutableArray array];
		invalidPoint = [[OTSCoordinate alloc] init];
	}
	return self;
}

- (void)dealloc {
	[li release];
	[ptLocator release];
	[arg release];
	[nodes release];
	[im release];
	[isolatedEdges release];
	[invalidPoint release];
	[super dealloc];
}

- (OTSIntersectionMatrix *)computeIM {

	// since Geometries are finite and embedded in a 2-D space, the EE element must always be 2
	[im setRow:kOTSLocationExterior column:kOTSLocationExterior dimensionValue:2];
	
	OTSGeometryGraph *argAt0 = [arg objectAtIndex:0];
	OTSGeometryGraph *argAt1 = [arg objectAtIndex:1];
	
	// if the Geometries don't overlap there is nothing to do
	OTSEnvelope *e1 = [[argAt0 getGeometry] getEnvelopeInternal];
	OTSEnvelope *e2 = [[argAt1 getGeometry] getEnvelopeInternal];
	if (![e1 intersects:e2]) {
		[self computeDisjointIM:im];
		return im;
	}
	
	[argAt0 computeSelfNodes:li computeRingSelfNodes:NO];
	[argAt1 computeSelfNodes:li computeRingSelfNodes:NO];
	
	// compute intersections between edges of the two input geometries
	OTSSegmentIntersector *intersector = [argAt0 computeEdgeIntersections:argAt1 lineIntersector:li includeProper:NO];
	[self computeIntersectionNodes:0];
	[self computeIntersectionNodes:1];
	
	/*
	 * Copy the labelling for the nodes in the parent Geometries.
	 * These override any labels determined by intersections
	 * between the geometries.
	 */
	[self copyNodesAndLabels:0];
	[self copyNodesAndLabels:1];
	
	/*
	 * complete the labelling for any nodes which only have a
	 * label for a single geometry
	 */
	[self labelIsolatedNodes];
	
	/*
	 * If a proper intersection was found, we can set a lower bound
	 * on the IM.
	 */
	[self computeProperIntersectionIM:intersector intersectionMatrix:im];
	
	/*
	 * Now process improper intersections
	 * (eg where one or other of the geometrys has a vertex at the
	 * intersection point)
	 * We need to compute the edge graph at all nodes to determine
	 * the IM.
	 */
	// build EdgeEnds for all intersections
	OTSEdgeEndBuilder *eeBuilder = [[OTSEdgeEndBuilder alloc] init];
	NSArray *ee0 = [eeBuilder computeEdgeEnds:argAt0.edges];
	[self insertEdgeEnds:ee0];
	NSArray *ee1 = [eeBuilder computeEdgeEnds:argAt1.edges];
	[self insertEdgeEnds:ee1];
	[self labelNodeEdges];
	
	/**
	 * Compute the labeling for isolated components.
	 * Isolated components are components that do not touch any
	 * other components in the graph.
	 * They can be identified by the fact that they will
	 * contain labels containing ONLY a single element, the one for
	 * their parent geometry.
	 * We only need to check components contained in the input graphs,
	 * since isolated components will not have been replaced by new
	 * components formed by intersections.
	 */
	[self labelIsolatedEdges:0 targetIndex:1];
	[self labelIsolatedEdges:1 targetIndex:0];
	
	// update the IM from all components
	[self updateIM:im];
	[eeBuilder release];
	
	return im;	
	
}

- (void)insertEdgeEnds:(NSArray *)ee {
	for (OTSEdgeEnd *e in ee) {
		[nodes add:e];
	}
}

- (void)computeProperIntersectionIM:(OTSSegmentIntersector *)intersector intersectionMatrix:(OTSIntersectionMatrix *)imX {
	
	OTSGeometryGraph *argAt0 = [arg objectAtIndex:0];
	OTSGeometryGraph *argAt1 = [arg objectAtIndex:1];
	
	// If a proper intersection is found, we can set a lower bound on the IM.
	int dimA = [[argAt0 getGeometry] getDimension];
	int dimB = [[argAt1 getGeometry] getDimension];
	BOOL hasProper = [intersector hasProperIntersection];
	BOOL hasProperInterior = [intersector hasProperInteriorIntersection];
	// For Geometry's of dim 0 there can never be proper intersections.
	/**
	 * If edge segments of Areas properly intersect, the areas must properly overlap.
	 */
	if (dimA == 2 && dimB == 2) {
		if (hasProper) [imX setAtLeastDimensionSymbols:@"212101212"];
	}
	/**
	 * If an Line segment properly intersects an edge segment of an Area,
	 * it follows that the Interior of the Line intersects the Boundary of the Area.
	 * If the intersection is a proper <i>interior</i> intersection, then
	 * there is an Interior-Interior intersection too.
	 * Note that it does not follow that the Interior of the Line intersects the Exterior
	 * of the Area, since there may be another Area component which contains the rest of the Line.
	 */
	else if (dimA == 2 && dimB == 1) {
		if (hasProper) [imX setAtLeastDimensionSymbols:@"FFF0FFFF2"];
		if (hasProperInterior) [imX setAtLeastDimensionSymbols:@"1FFFFF1FF"];
	} else if (dimA == 1 && dimB == 2) {
		if (hasProper) [imX setAtLeastDimensionSymbols:@"F0FFFFFF2"];
		if (hasProperInterior) [imX setAtLeastDimensionSymbols:@"1F1FFFFFF"];
	}
	/* If edges of LineStrings properly intersect *in an interior point*, all
	 we can deduce is that
	 the interiors intersect.  (We can NOT deduce that the exteriors intersect,
	 since some other segments in the geometries might cover the points in the
	 neighbourhood of the intersection.)
	 It is important that the point be known to be an interior point of
	 both Geometries, since it is possible in a self-intersecting geometry to
	 have a proper intersection on one segment that is also a boundary point of another segment.
	 */
	else if (dimA == 1 && dimB == 1) {
		if (hasProperInterior) [imX setAtLeastDimensionSymbols:@"0FFFFFFFF"];
	}
	
}

- (void)copyNodesAndLabels:(int)argIndex {
	
	OTSGeometryGraph *argAtIndex = [arg objectAtIndex:argIndex];
	
	OTSNodeMap *nm = [argAtIndex getNodeMap];
	NSMutableArray *nma = [NSMutableArray array];
	[nm getNodesAsArray:nma];
	for (OTSNode *graphNode in nma) {
		OTSNode *newNode = [nodes addNodeWithCoordinate:[graphNode getCoordinate]];
		[newNode setLabel:argIndex onLocation:[graphNode.label locationAtGeometryIndex:argIndex]];
	}
	
}

- (void)computeIntersectionNodes:(int)argIndex {
	
	OTSGeometryGraph *argAtIndex = [arg objectAtIndex:argIndex];
	NSArray *edges = argAtIndex.edges;
	
	for (OTSEdge *e in edges) {
		int eLoc = [e.label locationAtGeometryIndex:argIndex];
		for (OTSEdgeIntersection *ei in [e.eiList nodeMap]) {
			OTSRelateNode *n = (OTSRelateNode *)[nodes addNodeWithCoordinate:ei.coordinate];
			if (eLoc == kOTSLocationBoundary) {
				[n setLabelBoundary:argIndex];
			} else {
				if ([n.label isNullAtGeometryIndex:argIndex])
					[n setLabel:argIndex onLocation:kOTSLocationInterior];
			}			
		}
	}
		
}

- (void)labelIntersectionNodes:(int)argIndex {
	
	OTSGeometryGraph *argAtIndex = [arg objectAtIndex:argIndex];
	NSArray *edges = argAtIndex.edges;
	
	for (OTSEdge *e in edges) {
		int eLoc = [e.label locationAtGeometryIndex:argIndex];
		for (OTSEdgeIntersection *ei in [e.eiList nodeMap]) {
			OTSRelateNode *n = (OTSRelateNode *)[nodes find:ei.coordinate];
			if ([n.label isNullAtGeometryIndex:argIndex]) {
				if (eLoc == kOTSLocationBoundary)
					[n setLabelBoundary:argIndex];
				else
					[n setLabel:argIndex onLocation:kOTSLocationInterior];
			}
		}
	}
		
}

- (void)computeDisjointIM:(OTSIntersectionMatrix *)imX {
	
	OTSGeometryGraph *argAt0 = [arg objectAtIndex:0];
	OTSGeometryGraph *argAt1 = [arg objectAtIndex:1];
	
	OTSGeometry *ga = [argAt0 getGeometry];
	if (![ga isEmpty]) {
		[imX setRow:kOTSLocationInterior column:kOTSLocationExterior dimensionValue:[ga getDimension]];
		[imX setRow:kOTSLocationBoundary column:kOTSLocationExterior dimensionValue:[ga getBoundaryDimension]];
	}
	OTSGeometry *gb = [argAt1 getGeometry];
	if (![gb isEmpty]) {
		[imX setRow:kOTSLocationExterior column:kOTSLocationInterior dimensionValue:[ga getDimension]];
		[imX setRow:kOTSLocationExterior column:kOTSLocationBoundary dimensionValue:[ga getBoundaryDimension]];
	}
	
}

- (void)labelNodeEdges {
	NSMutableArray *ns = [NSMutableArray array];
	[nodes getNodesAsArray:ns];
	for (OTSRelateNode *node in ns) {
		[node.edges computeLabelling:arg];
	}
}

- (void)updateIM:(OTSIntersectionMatrix *)imX {
	
	for (OTSEdge *e in isolatedEdges) {
		[e updateIMSuper:imX];
	}
	
	NSMutableArray *ns = [NSMutableArray array];
	[nodes getNodesAsArray:ns];
	for (OTSRelateNode *node in ns) {
		[node updateIM:imX];
		[node updateIMFromEdges:imX];
	}
	
}

- (void)labelIsolatedEdges:(int)thisIndex targetIndex:(int)targetIndex {	
	OTSGeometryGraph *argAtIndex = [arg objectAtIndex:thisIndex];
	OTSGeometryGraph *argAtTargetIndex = [arg objectAtIndex:targetIndex];
	NSArray *edges = argAtIndex.edges;
	for (OTSEdge *e in edges) {
		if (e.isolated) {
			[self labelIsolatedEdge:e targetIndex:targetIndex target:[argAtTargetIndex getGeometry]];
			[isolatedEdges addObject:e];
		}
	}	
}

- (void)labelIsolatedEdge:(OTSEdge *)e targetIndex:(int)targetIndex target:(OTSGeometry *)target {
	// this won't work for GeometryCollections with both dim 2 and 1 geoms
	if ([target getDimension] > 0) {
		// since edge is not in boundary, may not need the full generality of PointLocator?
		// Possibly should use ptInArea locator instead?  We probably know here
		// that the edge does not touch the bdy of the target Geometry
		int loc = [ptLocator locate:[e getCoordinate] relativeTo:target];
		[e.label setAllLocations:loc atGeometryIndex:targetIndex];
	} else {
		[e.label setAllLocations:kOTSLocationExterior atGeometryIndex:targetIndex];
	}	
}

- (void)labelIsolatedNodes {	
	NSMutableArray *na = [NSMutableArray array];
	[nodes getNodesAsArray:na];
	for (OTSNode *n in na) {
		OTSLabel *label = n.label;
		// isolated nodes should always have at least one geometry in their label
		NSAssert([label geometryCount] > 0, @"node with empty label found");
		if ([n isIsolated]) {
			if ([label isNullAtGeometryIndex:0])
				[self labelIsolatedNode:n targetIndex:0];
			else
				[self labelIsolatedNode:n targetIndex:1];
		}
	}
}

- (void)labelIsolatedNode:(OTSNode *)n targetIndex:(int)targetIndex {
	OTSGeometryGraph *argAtIndex = [arg objectAtIndex:targetIndex];
	int loc = [ptLocator locate:[n getCoordinate] relativeTo:[argAtIndex getGeometry]];
	[n.label setAllLocations:loc atGeometryIndex:targetIndex];
}


@end
