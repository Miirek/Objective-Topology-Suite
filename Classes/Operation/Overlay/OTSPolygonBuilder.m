//
//  OTSPolygonBuilder.m
//

#import "OTSPolygonBuilder.h"
#import "OTSOverlayOp.h"
#import "OTSMaximalEdgeRing.h"
#import "OTSMinimalEdgeRing.h"
#import "OTSNode.h"
#import "OTSNodeMap.h"
#import "OTSDirectedEdgeStar.h"
#import "OTSGeometryFactory.h"
#import "OTSLinearRing.h"
#import "OTSPolygon.h"
#import "OTSCGAlgorithms.h"

@implementation OTSPolygonBuilder

@synthesize geometryFactory;
@synthesize shellList;

- (id)initWithGeometryFactory:(OTSGeometryFactory *)newGeometryFactory {
	if (self = [super init]) {
		self.geometryFactory = newGeometryFactory;
		self.shellList = [NSMutableArray array];
	}
	return self;
}

- (void)dealloc {
	[geometryFactory release];
	[shellList release];
	[super dealloc];
}

- (void)add:(OTSPlanarGraph *)graph {
	
	NSArray *ee = [graph getEdgeEnds];
	//int eeSize = [ee count];
	
	NSMutableArray *dirEdges = [NSMutableArray array];
	for (OTSDirectedEdge *de in ee) {
		[dirEdges addObject:de];
	}
	
	NSMutableArray *nodes = [NSMutableArray array];
	[graph.nodes getNodesAsArray:nodes];
	
	[self addEdges:dirEdges nodes:nodes];
}

- (void)addEdges:(NSArray *)dirEdges nodes:(NSArray *)nodes {
	
	for (OTSNode *node in nodes) {
		OTSDirectedEdgeStar *des = (OTSDirectedEdgeStar *)node.edges;
		[des linkResultDirectedEdges];
	}
		
	NSArray *maxEdgeRings = [self buildMaximalEdgeRings:dirEdges];
	NSMutableArray *freeHoleList = [NSMutableArray array];
	NSArray *edgeRings = [self buildMinimalEdgeRingsWithMaxEdgeRings:maxEdgeRings 
														   shellList:shellList 
														freeHoleList:freeHoleList];
	
	[self sortShellsAndHoles:edgeRings shellList:shellList freeHoleList:freeHoleList];
	[self placeFreeHoles:shellList freeHoleList:freeHoleList];
}

- (NSArray *)getPolygons {
	return [self computePolygons:shellList];
}

- (BOOL)containsPoint:(OTSCoordinate *)p {
	
	for (OTSEdgeRing *er in shellList) {
		if ([er containsPoint:p]) {
			return YES;
		}
	}
	return NO;
	
}

- (NSArray *)buildMaximalEdgeRings:(NSArray *)dirEdges {

	NSMutableArray *maxEdgeRings = [NSMutableArray array];
	for (OTSDirectedEdge *de in dirEdges) {
		if (de.inResult && [de.label isArea]) {
			
			// if this edge has not yet been processed
			if (de.edgeRing == nil) {
				OTSMaximalEdgeRing *er = [[OTSMaximalEdgeRing alloc] initWithEdgeEnd:de geometryFactory:geometryFactory];
				[maxEdgeRings addObject:er];
				[er setInResult];
				[er release];
			}
		}		
	}	
	return maxEdgeRings;
	
}

- (NSArray *)buildMinimalEdgeRingsWithMaxEdgeRings:(NSArray *)maxEdgeRings 
										 shellList:(NSMutableArray *)newShellList 
									  freeHoleList:(NSMutableArray *)freeHoleList {
	
	NSMutableArray *edgeRings = [NSMutableArray array];
	for (OTSMaximalEdgeRing *er in maxEdgeRings) {
		if (er.maxNodeDegree > 2) {
			[er linkDirectedEdgesForMinimalEdgeRings];
			NSArray *minEdgeRings = [er buildMinimalRings];
			// at this point we can go ahead and attempt to place
			// holes, if this EdgeRing is a polygon
			OTSEdgeRing *shell = [self findShell:minEdgeRings];
			if (shell != nil) {
				[self placePolygonHoles:shell minEdgeRings:minEdgeRings];
				[newShellList addObject:shell];				
			} else {
				[freeHoleList addObjectsFromArray:minEdgeRings];
			}
		} else {
			[edgeRings addObject:er];
		}
	}	
	return edgeRings;
	
}

- (OTSEdgeRing *)findShell:(NSArray *)minEdgeRings {
	OTSEdgeRing *shell = nil;
	for (OTSEdgeRing *er in minEdgeRings) {
		if ([er isHole]) {
			shell = er;
		}
	}
	return shell;
}

- (void)placePolygonHoles:(OTSEdgeRing *)shell minEdgeRings:(NSArray *)minEdgeRings {
	for (OTSMinimalEdgeRing *er in minEdgeRings) {
		if ([er isHole]) {
			[er setShell:shell];
		}
	}
}

- (void)sortShellsAndHoles:(NSArray *)edgeRings 
				 shellList:(NSMutableArray *)newShellList 
			  freeHoleList:(NSMutableArray *)freeHoleList {
	for (OTSEdgeRing *er in edgeRings) {
		if ([er isHole]) {
			[freeHoleList addObject:er];
		} else {
			[newShellList addObject:er];
		}
	}
}

- (void)placeFreeHoles:(NSMutableArray *)newShellList 
		  freeHoleList:(NSMutableArray *)freeHoleList {
	
	for (OTSEdgeRing *hole in freeHoleList) {
		// only place this hole if it doesn't yet have a shell
		if (hole.shell == nil) {
			OTSEdgeRing *shell = [self findEdgeRingContaining:hole shellList:newShellList];
			if (shell == nil) {
				NSException *ex = [NSException exceptionWithName:@"TopologyException" 
														  reason:@"unable to assign hole to a shell" 
														userInfo:nil];
				@throw ex;
			}
			hole.shell = shell;
		}
	}
	
}

- (OTSEdgeRing *)findEdgeRingContaining:(OTSEdgeRing *)testEr shellList:(NSArray *)newShellList {
	
	OTSLinearRing *testRing = [testEr getLinearRing];
	OTSEnvelope *testEnv = [testRing getEnvelopeInternal];
	OTSCoordinate *testPt = [testRing getCoordinateN:0];	
	OTSEdgeRing *minShell = nil;
	OTSEnvelope *minEnv = nil;
	
	for (OTSEdgeRing *tryShell in newShellList) {
		OTSLinearRing *lr = nil;		
		OTSLinearRing *tryRing = [tryShell getLinearRing];
		OTSEnvelope *tryEnv = [tryRing getEnvelopeInternal];
		if (minShell != nil) {
			lr = [minShell getLinearRing];
			minEnv = [lr getEnvelopeInternal];
		}
		BOOL isContained = NO;
		OTSCoordinateSequence *rcl = [tryRing getCoordinatesRO];
		if ([tryEnv contains:testEnv]
			&& [OTSCGAlgorithms isPoint:testPt inRing:rcl])
			isContained = YES;
		// check if this new containing ring is smaller than
		// the current minimum ring
		if (isContained) {
			if (minShell == nil
				|| [minEnv contains:tryEnv]) {
				minShell = tryShell;
			}
		}
	}
	
	return minShell;
	
	
}

- (NSArray *)computePolygons:(NSArray *)newShellList {
	
	NSMutableArray *resultPolyList = [NSMutableArray array];
	
	// add Polygons for all shells
	for (OTSEdgeRing *er in newShellList) {
		OTSPolygon *poly = [er toPolygon:geometryFactory];
		[resultPolyList addObject:poly];
	}	
	return resultPolyList;
	
}

@end
