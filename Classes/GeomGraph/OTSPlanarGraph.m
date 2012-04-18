//
//  OTSPlanarGraph.m
//

#import "OTSCoordinate.h"
#import "OTSCoordinateSequence.h"
#import "OTSLocation.h"

#import "OTSPlanarGraph.h"
#import "OTSNode.h"
#import "OTSNodeFactory.h"
#import "OTSEdge.h"
#import "OTSEdgeEndStar.h"
#import "OTSDirectedEdge.h"
#import "OTSDirectedEdgeStar.h"
#import "OTSNodeMap.h"
#import "OTSQuadrant.h"

#import "OTSCGAlgorithms.h"

@implementation OTSPlanarGraph

@synthesize edges;
@synthesize nodes;
@synthesize edgeEndList;

+ (void)linkResultDirectedEdges:(NSArray *)v start:(int)start end:(int)end {
	for (int i = start; i <= end; i++) {
		OTSNode *node = [v objectAtIndex:i];		
		OTSEdgeEndStar* ees = node.edges;
		OTSDirectedEdgeStar* des = (OTSDirectedEdgeStar*)ees;
		
		// this might throw an exception
		[des linkResultDirectedEdges];
	}
}

- (id)initWithNodeFactory:(OTSNodeFactory *)nodeFact {
	if (self = [super init]) {
		self.edges = [NSMutableArray array];
		nodes = [[OTSNodeMap alloc] initWithNodeFactory:nodeFact];
		self.edgeEndList = [NSMutableArray array];
	}
	return self;
}

- (id)init {
	if (self = [super init]) {
		self.edges = [NSMutableArray array];
		nodes = [[OTSNodeMap alloc] initWithNodeFactory:[OTSNodeFactory instance]];
		self.edgeEndList = [NSMutableArray array];
	}
	return self;
}

- (void)dealloc {
	[edges release];
	[nodes release];
	[edgeEndList release];
	[super dealloc];
}

- (NSArray *)getEdgeEnds {
	return edgeEndList;
}

- (BOOL)isBoundaryNode:(int)geomIndex coord:(OTSCoordinate *)coord {
	OTSNode *node = [nodes find:coord];
	if (node == nil) return NO;
	
	OTSLabel *label = node.label;
	if (label != nil && [label locationAtGeometryIndex:geomIndex] == kOTSLocationBoundary)
		return YES;
	
	return NO;
}

- (void)add:(OTSEdgeEnd *)e {
	[nodes add:e];
	[edgeEndList addObject:e];	
}

- (void)getNodesAsArray:(NSMutableArray *)_nodes {
	[nodes getNodesAsArray:_nodes];
}

- (OTSNode *)addNode:(OTSNode *)node {
	return [nodes addNode:node];
}

- (OTSNode *)addNodeWithCoordinate:(OTSCoordinate *)coord {
	return [nodes addNodeWithCoordinate:coord];
}

- (OTSNode *)find:(OTSCoordinate *)coord {
	return [nodes find:coord];
}

- (void)addEdgesWithArray:(NSArray *)edgesToAdd {
	// create all the nodes for the edges
	for (OTSEdge *e in edgesToAdd) {
		[edges addObject:e];
		
		// PlanarGraph destructor will delete all DirectedEdges 
		// in edgeEndList, which is where these are added
		// by the ::add(EdgeEnd) call
		OTSDirectedEdge *de1 = [[OTSDirectedEdge alloc] initWithEdge:e isForward:YES];
		OTSDirectedEdge *de2 = [[OTSDirectedEdge alloc] initWithEdge:e isForward:FALSE];
		de1.sym = de2;
		de2.sym = de1;
		[self add:de1];
		[self add:de2];
		
		[de1 release];
		[de2 release];
	}
}

- (void)linkResultDirectedEdges {
	
	NSArray *nv = [nodes.nodeMap allValues];
	for (OTSNode *node in nv) {
		OTSEdgeEndStar *ees = node.edges;
		OTSDirectedEdgeStar *des = (OTSDirectedEdgeStar *)ees;
		
		// this might throw an exception
		[des linkResultDirectedEdges];
	}
	
}

- (void)linkAllDirectedEdges {
	
	NSArray *nv = [nodes.nodeMap allValues];
	for (OTSNode *node in nv) {
		OTSEdgeEndStar *ees = node.edges;
		OTSDirectedEdgeStar *des = (OTSDirectedEdgeStar *)ees;
		
		[des linkAllDirectedEdges];
	}
	
}

- (OTSEdgeEnd *)findEdgeEnd:(OTSEdge *)e {
	
	for (OTSEdgeEnd *ee in edgeEndList) {
		// should test using values rather then pointers ?
		if ([ee.edge equalsTo:e]) return ee;
	}
	return nil;

}

- (OTSEdge *)findEdge:(OTSCoordinate *)p0 p1:(OTSCoordinate *)p1 {
	
	for (OTSEdge *e in edges) {
		OTSCoordinateSequence* eCoord = [e getCoordinates];
		if ([p0 isEqual2D:[eCoord getAt:0]] && [p1 isEqual2D:[eCoord getAt:1]]) {
			return e;
		}
	}
	return nil;
	
}

- (OTSEdge *)findEdgeInSameDirection:(OTSCoordinate *)p0 p1:(OTSCoordinate *)p1 {
	
	for (OTSEdge *e in edges) {
		OTSCoordinateSequence* eCoord = [e getCoordinates];
		int nCoords = [eCoord size];
		if ([self matchInSameDirection:p0 p1:p1 ep0:[eCoord getAt:0] ep1:[eCoord getAt:1]]) {
			return e;
		}
		if ([self matchInSameDirection:p0 p1:p1 ep0:[eCoord getAt:nCoords - 1] ep1:[eCoord getAt:nCoords - 2]]) {
			return e;
		}
	}
	return nil;
	
}

- (OTSNodeMap *)getNodeMap {
	return nodes;
}

- (void)insertEdge:(OTSEdge *)e {
	[edges addObject:e];
}

- (BOOL)matchInSameDirection:(OTSCoordinate *)p0 
						  p1:(OTSCoordinate *)p1 
						 ep0:(OTSCoordinate *)ep0 
						 ep1:(OTSCoordinate *)ep1 {
	if (!([p0 isEqual2D:ep0]))
		return NO;
	
	if ([OTSCGAlgorithms computeOrientation:p0 p2:p1 q:ep1] == kOTSCGACollinear
		&& [OTSQuadrant quadrant:p0 p1:p1] == [OTSQuadrant quadrant:ep0 p1:ep1])
		return YES;
	return NO;
	
}

@end
