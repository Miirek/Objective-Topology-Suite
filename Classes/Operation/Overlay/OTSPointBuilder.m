//
//  OTSPointBuilder.m
//

#import "OTSPointBuilder.h"
#import "OTSOverlayOp.h"
#import "OTSNode.h"
#import "OTSEdgeEndStar.h"
#import "OTSLabel.h"

@implementation OTSPointBuilder

@synthesize op;
@synthesize geometryFactory;
@synthesize ptLocator;
@synthesize resultPointList;

- (id)initWithOverlayOp:(OTSOverlayOp *)newOp 
		geometryFactory:(OTSGeometryFactory *)newGeometryFactory 
			  ptLocator:(OTSPointLocator *)newPtLocator {
	if (self = [super init]) {
		self.op = newOp;
		self.geometryFactory = newGeometryFactory;
		self.ptLocator = newPtLocator;		
		self.resultPointList = [NSMutableArray array];
	}
	return self;
}

- (void)dealloc {
	[op release];
	[geometryFactory release];
	[ptLocator release];
	[resultPointList release];
	[super dealloc];
}

- (void)extractNonCoveredResultNodes:(OTSOverlayOpCode)opCode {
	
	NSMutableArray *nodes = [NSMutableArray array];
	[[op.graph getNodeMap] getNodesAsArray:nodes];
	for (OTSNode *n in nodes) {
		// filter out nodes which are known to be in the result
		if (n.inResult) continue;
		
		// if an incident edge is in the result, then
		// the node coordinate is included already
		if ([n isIncidentEdgeInResult]) continue;
		
		if ([n.edges getDegree] == 0 || opCode == kOTSOverlayIntersection) {			
			/**
			 * For nodes on edges, only INTERSECTION can result 
			 * in edge nodes being included even
			 * if none of their incident edges are included
			 */
			OTSLabel *label = n.label;
			if ([OTSOverlayOp isResultOfOp:label opCode:opCode]) 
				[self filterCoveredNodeToPoint:n];
		}		
	}
	
}

- (void)filterCoveredNodeToPoint:(OTSNode *)n {
	
	OTSCoordinate *coord = [n getCoordinate];
	if (![op isCoveredByLA:coord]) {
		OTSPoint *pt = [geometryFactory createPointWithCoordinate:coord];
		[resultPointList addObject:pt];
	}

}

- (NSMutableArray *)build:(OTSOverlayOpCode)opCode {
	[self extractNonCoveredResultNodes:opCode];
	return resultPointList;
}

@end
