//
//  OTSDirectedEdgeStar.m
//

#import "OTSDirectedEdgeStar.h"
#import "OTSEdgeEndStar.h"
#import "OTSEdgeEnd.h"
#import "OTSEdge.h"
#import "OTSDirectedEdge.h"
#import "OTSEdgeRing.h"
#import "OTSPosition.h"
#import "OTSQuadrant.h"
#import "OTSLocation.h"

@implementation OTSDirectedEdgeStar

@synthesize resultAreaEdgeList;	
@synthesize label;


- (id)init {
	if (self = [super init]) {
		resultAreaEdgeList = nil;
		label = nil;
	}
	return self;
}

- (void)dealloc {
	[resultAreaEdgeList release];
	[label release];
	[super dealloc];
}

- (void)insert:(OTSEdgeEnd *)ee {
	OTSDirectedEdge *de = (OTSDirectedEdge *)ee;
	[self insertEdgeEnd:de];
}

- (int)getOutgoingDegree {
	int degree = 0;
	for (OTSDirectedEdge *de in edgeMap) {
		if (de.inResult) ++degree;
	}
	return degree;	
}

- (int)getOutgoingDegreeOf:(OTSEdgeRing *)er {
	int degree = 0;
	for (OTSDirectedEdge *de in edgeMap) {
		if (de.edgeRing == er) ++degree;
	}
	return degree;
}

- (OTSDirectedEdge *)getRightmostEdge {
	
	if ([edgeMap count] == 0) return nil;
	
	int idx = 0;
	OTSDirectedEdge *de0 = [edgeMap objectAtIndex:idx];
	++idx;
	if (idx == [edgeMap count]) return de0;
	
	idx = [edgeMap count] - 1;
	OTSDirectedEdge *deLast = [edgeMap objectAtIndex:idx];
	
	int quad0 = de0.quadrant;
	int quad1 = deLast.quadrant;
	
	if ([OTSQuadrant isNorthern:quad0] && [OTSQuadrant isNorthern:quad1])
		return de0;
	else if (![OTSQuadrant isNorthern:quad0] && ![OTSQuadrant isNorthern:quad1])
		return deLast;
	else {
		// edges are in different hemispheres - make sure we return one that is non-horizontal
		if (de0.dy != 0)
			return de0;
		else if (deLast.dy != 0)
			return deLast;
	}
	//assert(0); // found two horizontal edges incident on node
	
	return nil;	
}

- (void)computeLabelling:(NSArray *)geom {
	// this call can throw a TopologyException 
	// we don't have any cleanup to do...
	[super computeLabelling:geom];
	
	// determine the overall labelling for this DirectedEdgeStar
	// (i.e. for the node it is based at)
	if (label != nil) [label release];
	label = [[OTSLabel alloc] initWithOnLocation:kOTSLocationUndefined];
	
	for (OTSDirectedEdge *de in edgeMap) {
		OTSEdge *e = de.edge;
		OTSLabel *eLabel = e.label;
		for (int i = 0; i < 2; ++i) {
			int eLoc = [eLabel locationAtGeometryIndex:i];
			if (eLoc == kOTSLocationInterior || eLoc == kOTSLocationBoundary)
				[label setLocation:kOTSLocationInterior atGeometryIndex:i];
		}
	}
}

- (void)mergeSymLabels {
	for (OTSDirectedEdge *de in edgeMap) {
		OTSLabel *deLabel = de.label;
		OTSDirectedEdge *deSym = de.sym;
		OTSLabel *labelToMerge = deSym.label;
		[deLabel merge:labelToMerge];
	}
}

- (void)updateLabelling:(OTSLabel *)nodeLabel {
	for (OTSDirectedEdge *de in edgeMap) {
		OTSLabel *deLabel = de.label;
		[deLabel setAllLocationsIfNull:[nodeLabel locationAtGeometryIndex:0] atGeometryIndex:0];
		[deLabel setAllLocationsIfNull:[nodeLabel locationAtGeometryIndex:1] atGeometryIndex:1];
	}
}

- (void)linkResultDirectedEdges {
	// make sure edges are copied to resultAreaEdges list
	[self getResultAreaEdges];
	// find first area edge (if any) to start linking at
	OTSDirectedEdge *firstOut = nil;
	OTSDirectedEdge *incoming = nil;
	int state = kOTSEdgeScanningForIncoming;
	// link edges in CCW order
	for (int i = 0; i < [edgeMap count]; ++i) {
		
		OTSDirectedEdge *nextOut = [edgeMap objectAtIndex:i];
		
		// skip de's that we're not interested in
		if (![nextOut.label isArea]) continue;
		
		OTSDirectedEdge *nextIn = nextOut.sym;
		
		// record first outgoing edge, in order to link the last incoming edge
		if (firstOut == nil && nextOut.inResult) 
			firstOut = nextOut;
		
		switch (state) {
			case kOTSEdgeScanningForIncoming:
				if (!nextIn.inResult) continue;
				incoming = nextIn;
				state = kOTSEdgeLinkingToOutgoing;
				break;
			case kOTSEdgeLinkingToOutgoing:
				if (!nextOut.inResult) continue;
				[incoming setNext:nextOut];
				state = kOTSEdgeScanningForIncoming;
				break;
		}
		
	}
	
	if (state == kOTSEdgeLinkingToOutgoing) {
		if (firstOut == nil) {
			NSException *ex = [NSException exceptionWithName:@"TopologyException" 
													  reason:@"no outgoing dirEdge found" 
													userInfo:nil];
			@throw ex;
		}
		[incoming setNext:firstOut];
	}	
}

- (void)linkMinimalDirectedEdges:(OTSEdgeRing *)er {
	
	// find first area edge (if any) to start linking at
	OTSDirectedEdge *firstOut = nil;
	OTSDirectedEdge *incoming = nil;
	int state = kOTSEdgeScanningForIncoming;
	
	// link edges in CW order
	for (int i = [edgeMap count] - 1; i >= 0; --i) {
		OTSDirectedEdge *nextOut = [edgeMap objectAtIndex:i];		
		OTSDirectedEdge *nextIn = nextOut.sym;
		
		// record first outgoing edge, in order to link the last incoming edge
		if (firstOut == nil && nextOut.edgeRing == er) firstOut = nextOut;
		switch (state) {
			case kOTSEdgeScanningForIncoming:
				if (nextIn.edgeRing != er) continue;
				incoming = nextIn;
				state = kOTSEdgeLinkingToOutgoing;
				break;
			case kOTSEdgeLinkingToOutgoing:
				if (nextOut.edgeRing != er) continue;
				[incoming setNextMin:nextOut];
				state = kOTSEdgeScanningForIncoming;
				break;
		}
		
	}	
	
	if (state == kOTSEdgeLinkingToOutgoing) {
		[incoming setNextMin:firstOut];
	}
	
}

- (void)linkAllDirectedEdges {
	
	OTSDirectedEdge *prevOut = nil;
	OTSDirectedEdge *firstIn = nil;
	
	// link edges in CW order
	for (int i = [edgeMap count] - 1; i >= 0; --i) {
		OTSDirectedEdge *nextOut = [edgeMap objectAtIndex:i];		
		OTSDirectedEdge *nextIn = nextOut.sym;
		
		if (firstIn == nil) firstIn = nextIn;
		if (prevOut != nil) [nextIn setNext:prevOut];
		// record outgoing edge, in order to link the last incoming edge
		prevOut = nextOut;
	}
	
	[firstIn setNext:prevOut];
}

- (void)findCoveredLineEdges {
	
	// Since edges are stored in CCW order around the node,
	// as we move around the ring we move from the right to the left side of the edge
	
	/**
	 * Find first DirectedEdge of result area (if any).
	 * The interior of the result is on the RHS of the edge,
	 * so the start location will be:
	 * - INTERIOR if the edge is outgoing
	 * - EXTERIOR if the edge is incoming
	 */
	int startLoc = kOTSLocationUndefined;
	
	for (int i = 0; i < [edgeMap count]; ++i) {		
		OTSDirectedEdge *nextOut = [edgeMap objectAtIndex:i];
		OTSDirectedEdge *nextIn = nextOut.sym;
		
		if (![nextOut isLineEdge]) {
			if (nextOut.inResult) {
				startLoc = kOTSLocationInterior;
				break;
			}
			if (nextIn.inResult) {
				startLoc = kOTSLocationExterior;
				break;
			}
		}
		
	}		
	
	// no A edges found, so can't determine if L edges are covered or not
	if (startLoc == kOTSLocationUndefined) return;
	
	/**
	 * move around ring, keeping track of the current location
	 * (Interior or Exterior) for the result area.
	 * If L edges are found, mark them as covered if they are in the interior
	 */
	int currLoc = startLoc;
	for (int i = 0; i < [edgeMap count]; ++i) {		
		OTSDirectedEdge *nextOut = [edgeMap objectAtIndex:i];
		OTSDirectedEdge *nextIn = nextOut.sym;
		
		if ([nextOut isLineEdge]) {
			[nextOut.edge setCovered:(currLoc == kOTSLocationInterior)];
		} else {  // edge is an Area edge
			if (nextOut.inResult)
				currLoc = kOTSLocationExterior;
			if (nextIn.inResult)
				currLoc = kOTSLocationInterior;
		}
	}
		
}

- (void)computeDepths:(OTSDirectedEdge *)de {
	
	int edgeIdx = [self find:de];
	int startDepth = [de getDepthAt:kOTSPositionLeft];
	int targetLastDepth = [de getDepthAt:kOTSPositionRight];
	
	// compute the depths from this edge up to the end of the edge array
	int nextEdgeIdx = edgeIdx;
	++nextEdgeIdx;
	int nextDepth = [self computeDepths:nextEdgeIdx endIdx:[edgeMap count] - 1 startDepth:startDepth];
		
	// compute the depths for the initial part of the array
	int lastDepth = [self computeDepths:0 endIdx:edgeIdx startDepth:nextDepth];
	
	if (lastDepth != targetLastDepth) {
		NSException *ex = [NSException exceptionWithName:@"TopologyException" 
												  reason:@"depth mismatch" 
												userInfo:nil];
		@throw ex;
	}
	
}

- (NSArray *)getResultAreaEdges {
	
	if (resultAreaEdgeList != nil) return resultAreaEdgeList;
	
	resultAreaEdgeList = [NSMutableArray array];
	
	for (OTSDirectedEdge *de in edgeMap) {
		if (de.inResult || de.sym.inResult)
			[resultAreaEdgeList addObject:de];
	}
	return resultAreaEdgeList;
	
}

- (int)computeDepths:(int)startIdx endIdx:(int)endIdx startDepth:(int)startDepth {
	
	int currDepth = startDepth;
	for (int i = startIdx; i <= endIdx; i++) {
		OTSDirectedEdge *nextDe = [edgeMap objectAtIndex:i];
		[nextDe setEdgeDepths:currDepth at:kOTSPositionRight];
		currDepth = [nextDe getDepthAt:kOTSPositionLeft];
	}
	return currDepth;
}

@end
