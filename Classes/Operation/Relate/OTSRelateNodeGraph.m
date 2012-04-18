//
//  OTSRelateNodeGraph.m
//

#import "OTSRelateNodeGraph.h"
#import "OTSRelateNodeFactory.h"
#import "OTSEdgeEndBuilder.h"
#import "OTSRelateNode.h"
#import "OTSNodeMap.h"
#import "OTSGeometryGraph.h"
#import "OTSEdgeIntersectionList.h"
#import "OTSEdge.h"
#import "OTSLabel.h"
#import "OTSLocation.h"

@implementation OTSRelateNodeGraph

@synthesize nodes;

- (id)init {
	if (self = [super init]) {
		nodes = [[OTSNodeMap alloc] initWithNodeFactory:[OTSRelateNodeFactory instance]];
	}
	return self;
}

- (void)dealloc {
	[nodes release];
	[super dealloc];
}

- (NSDictionary *)getNodeMap {
	return nodes.nodeMap;
}

- (void)build:(OTSGeometryGraph *)geomGraph {
	// compute nodes for intersections between previously noded edges
	[self computeIntersectionNodes:geomGraph argIndex:0];
	
	/**
	 * Copy the labelling for the nodes in the parent Geometry.  These override
	 * any labels determined by intersections.
	 */
	[self copyNodesAndLabels:geomGraph argIndex:0];
	
	/**
	 * Build EdgeEnds for all intersections.
	 */
	OTSEdgeEndBuilder *eeBuilder = [[OTSEdgeEndBuilder alloc] init];
	NSArray *eeList = [eeBuilder computeEdgeEnds:geomGraph.edges];
	[self insertEdgeEnds:eeList];
	[eeBuilder release];
}

- (void)computeIntersectionNodes:(OTSGeometryGraph *)geomGraph argIndex:(int)argIndex {
	for (OTSEdge *e in geomGraph.edges) {
		int eLoc = [e.label locationAtGeometryIndex:argIndex];
		OTSEdgeIntersectionList *eiL = e.eiList;
		for (OTSEdgeIntersection *ei in eiL.nodeMap) {
			OTSRelateNode *n = (OTSRelateNode *)[nodes addNodeWithCoordinate:ei.coordinate];
			if (eLoc == kOTSLocationBoundary)
				[n setLabelBoundary:argIndex];
			else {
				if ([n.label isNullAtGeometryIndex:argIndex])
					[n setLabel:argIndex onLocation:kOTSLocationInterior];
			}	
		}		
	}	
}

- (void)copyNodesAndLabels:(OTSGeometryGraph *)geomGraph argIndex:(int)argIndex {
	NSMutableArray *ni = [NSMutableArray array];
	[[geomGraph getNodeMap] getNodesAsArray:ni];
	for (OTSNode *graphNode in ni) {
		OTSNode *newNode = [nodes addNodeWithCoordinate:[graphNode getCoordinate]];
		[newNode setLabel:argIndex onLocation:[graphNode.label locationAtGeometryIndex:argIndex]];
	}
}

- (void)insertEdgeEnds:(NSArray *)ee {
	for (OTSEdgeEnd *e in ee) {
		[nodes add:e];
	}
}

@end
