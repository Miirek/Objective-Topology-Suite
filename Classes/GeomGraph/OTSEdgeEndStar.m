//
//  OTSEdgeEndStar.m
//

#import "OTSEdgeEndStar.h"
#import "OTSSimplePointInAreaLocator.h"
#import "OTSLocation.h"
#import "OTSLabel.h"
#import "OTSPosition.h"
#import "OTSGeometryGraph.h"

@implementation OTSEdgeEndStar

@synthesize edgeMap;

- (id)init {
	if (self = [super init]) {
		self.edgeMap = [NSMutableArray array];
		ptInAreaLocation[0] = kOTSLocationUndefined;
		ptInAreaLocation[1] = kOTSLocationUndefined;
	}
	return self;
}

- (void)dealloc {
	[edgeMap release];
	[super dealloc];
}

- (void)insert:(OTSEdgeEnd *)e {
	[self insertEdgeEnd:e];
}

- (OTSCoordinate *)getCoordinate {
	if ([edgeMap count] == 0)
		return [[[OTSCoordinate alloc] initWithX:NAN Y:NAN Z:NAN] autorelease];
	else
		return [[edgeMap objectAtIndex:0] getCoordinate];
}

- (int)getDegree {
	return [edgeMap count];
}

- (OTSEdgeEnd *)getNextCW:(OTSEdgeEnd *)ee {
	int idx = [self find:ee];
	if (idx == [edgeMap count]) return nil;
	if (idx == 0) return [edgeMap lastObject];
	else return [edgeMap objectAtIndex:idx - 1];
}

- (void)computeLabelling:(NSArray *)geomGraph {
	
	OTSGeometryGraph *gg = [geomGraph objectAtIndex:0];
	[self computeEdgeEndLabels:gg.boundaryNodeRule];
	
	// Propagate side labels  around the edges in the star
	// for each parent Geometry
	//
	// these calls can throw a TopologyException
	[self propagateSideLabels:0];
	[self propagateSideLabels:1];
	
	/**
	 * If there are edges that still have null labels for a geometry
	 * this must be because there are no area edges for that geometry
	 * incident on this node.
	 * In this case, to label the edge for that geometry we must test
	 * whether the edge is in the interior of the geometry.
	 * To do this it suffices to determine whether the node for the
	 * edge is in the interior of an area.
	 * If so, the edge has location INTERIOR for the geometry.
	 * In all other cases (e.g. the node is on a line, on a point, or
	 * not on the geometry at all) the edge
	 * has the location EXTERIOR for the geometry.
	 * 
	 * Note that the edge cannot be on the BOUNDARY of the geometry,
	 * since then there would have been a parallel edge from the
	 * Geometry at this node also labelled BOUNDARY
	 * and this edge would have been labelled in the previous step.
	 *
	 * This code causes a problem when dimensional collapses are present,
	 * since it may try and determine the location of a node where a
	 * dimensional collapse has occurred.
	 * The point should be considered to be on the EXTERIOR
	 * of the polygon, but locate() will return INTERIOR, since it is
	 * passed the original Geometry, not the collapsed version.
	 *
	 * If there are incident edges which are Line edges labelled BOUNDARY,
	 * then they must be edges resulting from dimensional collapses.
	 * In this case the other edges can be labelled EXTERIOR for this
	 * Geometry.
	 *
	 * MD 8/11/01 - NOT TRUE!  The collapsed edges may in fact be in the
	 * interior of the Geometry, which means the other edges should be
	 * labelled INTERIOR for this Geometry.
	 * Not sure how solve this...  Possibly labelling needs to be split
	 * into several phases:
	 * area label propagation, symLabel merging, then finally null label
	 * resolution.
	 */
	BOOL hasDimensionalCollapseEdge[2] = {NO, NO};
	
	for (OTSEdgeEnd *e in edgeMap) {
		OTSLabel *label = e.label;
		for(int geomi = 0; geomi < 2; geomi++) {
			if ([label isLineAtGeometryIndex:geomi] && [label locationAtGeometryIndex:geomi] == kOTSLocationBoundary)
				hasDimensionalCollapseEdge[geomi] = YES;
		}
	}
	
	for (OTSEdgeEnd *e in edgeMap) {
		OTSLabel *label = e.label;
		for(int geomi = 0; geomi < 2; geomi++) {
			if ([label isAnyNullAtGeometryIndex:geomi]) {
				int loc = kOTSLocationUndefined;
				if (hasDimensionalCollapseEdge[geomi]){
					loc = kOTSLocationExterior;
				} else {
					OTSCoordinate *p = [e getCoordinate];
					loc = [self getLocation:geomi p:p geom:geomGraph];
				}
				[label setAllLocationsIfNull:loc atGeometryIndex:geomi];
			}
		}
	}	
	
}

- (BOOL)isAreaLabelsConsistent:(OTSGeometryGraph *)geomGraph {
	[self computeEdgeEndLabels:geomGraph.boundaryNodeRule];
	return [self checkAreaLabelsConsistent:0];
}

- (void)propagateSideLabels:(int)geomIndex {
	// Since edges are stored in CCW order around the node,
	// As we move around the ring we move from the right to the
	// left side of the edge
	int startLoc = kOTSLocationUndefined;
	
	// initialize loc to location of last L side (if any)
	for (OTSEdgeEnd *e in edgeMap) {
		OTSLabel *label = e.label;
		if ([label isAreaAtGeometryIndex:geomIndex] &&
			[label locationAtGeometryIndex:geomIndex atPosIndex:kOTSPositionLeft] != kOTSLocationUndefined)
			startLoc = [label locationAtGeometryIndex:geomIndex atPosIndex:kOTSPositionLeft];
	}
	
	// no labelled sides found, so no labels to propagate
	if (startLoc == kOTSLocationUndefined) return;
	
	int currLoc = startLoc;	
	for (OTSEdgeEnd *e in edgeMap) {
		
		OTSLabel *label = e.label;
		
		// set null ON values to be in current location
		if ([label locationAtGeometryIndex:geomIndex atPosIndex:kOTSPositionOn] == kOTSLocationUndefined)
			[label setLocation:currLoc atGeometryIndex:geomIndex atPosIndex:kOTSPositionOn];
		// set side labels (if any)
		// if (label.isArea())  //ORIGINAL
		if ([label isAreaAtGeometryIndex:geomIndex]) {
			
			int leftLoc = [label locationAtGeometryIndex:geomIndex atPosIndex:kOTSPositionLeft];
			int rightLoc = [label locationAtGeometryIndex:geomIndex atPosIndex:kOTSPositionRight];
			
			// if there is a right location, that is the next
			// location to propagate
			if (rightLoc != kOTSLocationUndefined) {
				if (rightLoc != currLoc) {
					NSException *ex = [NSException exceptionWithName:@"TopologyException" 
															 reason:@"side location conflict" 
														   userInfo:nil];
					@throw ex;
				}
				if (leftLoc == kOTSLocationUndefined) {
					// found single null side at e->getCoordinate()
					//assert(0);
					NSException *ex = [NSException exceptionWithName:@"TopologyException" 
															 reason:@"found single null side" 
														   userInfo:nil];
					@throw ex;
				}
				currLoc = leftLoc;
			} else {
				/**
				 * RHS is null - LHS must be null too.
				 * This must be an edge from the other
				 * geometry, which has no location
				 * labelling for this geometry.
				 * This edge must lie wholly inside or
				 * outside the other geometry (which is
				 * determined by the current location).
				 * Assign both sides to be the current
				 * location.
				 */
				// found single null side
				NSAssert([label locationAtGeometryIndex:geomIndex atPosIndex:kOTSPositionLeft] == kOTSLocationUndefined, @"found single null side");
				
				[label setLocation:currLoc atGeometryIndex:geomIndex atPosIndex:kOTSPositionRight];
				[label setLocation:currLoc atGeometryIndex:geomIndex atPosIndex:kOTSPositionLeft];
			}
		}
	}	
}

- (int)find:(OTSEdgeEnd *)eSearch {
	for (int i = 0; i < [edgeMap count]; i++) {
		OTSEdgeEnd *eeCur = [edgeMap objectAtIndex:i];
		if (eeCur == eSearch)
			return i;
	}
	return -1;
}

- (void)insertEdgeEnd:(OTSEdgeEnd *)ee {
	int pos = -1;
	if ([edgeMap count] > 0) {
		BOOL found = NO;
		for (int i = 0; i < [edgeMap count]; i++) {
			OTSEdgeEnd *eeCur = [edgeMap objectAtIndex:i];
			if (![OTSEdgeEnd edgeEnd:eeCur lessThan:ee]) {
				if (eeCur != ee) {
					pos = i;
				}
				found = YES;
				break;
			} 
		}
		if (!found) {
			pos = [edgeMap count];
		}
	} else {
		pos = 0;
	}
	
	if (pos > -1) {
		if (pos == [edgeMap count]) {
			[edgeMap addObject:ee];
		} else {
			[edgeMap insertObject:ee atIndex:pos];
		}
	}
}

- (int)getLocation:(int)geomIndex p:(OTSCoordinate *)p geom:(NSArray *)geom {
	// compute location only on demand
	if (ptInAreaLocation[geomIndex] == kOTSLocationUndefined) {
		ptInAreaLocation[geomIndex] = [OTSSimplePointInAreaLocator locate:p geom:[[geom objectAtIndex:geomIndex] getGeometry]];
	}
	return ptInAreaLocation[geomIndex];	
}

- (void)computeEdgeEndLabels:(OTSBoundaryNodeRule *)bnr {
	// Compute edge label for each EdgeEnd
	for (OTSEdgeEnd *ee in edgeMap) {
		[ee computeLabel:bnr];
	}
}

- (BOOL)checkAreaLabelsConsistent:(int)geomIndex {
	// Since edges are stored in CCW order around the node,
	// As we move around the ring we move from the right to
	// the left side of the edge
	
	// if no edges, trivially consistent
	if ([edgeMap count] == 0) return YES;
	
	// initialize startLoc to location of last L side (if any)
	int idx = [edgeMap count] - 1;
	OTSEdgeEnd *ee = [edgeMap objectAtIndex:idx];
	OTSLabel *startLabel = ee.label;
	
	int startLoc = [startLabel locationAtGeometryIndex:geomIndex atPosIndex:kOTSPositionLeft];
	
	NSAssert(startLoc != kOTSLocationUndefined, @"Found unlabelled area edge");
	
	int currLoc = startLoc;
	
	for (OTSEdgeEnd *e in edgeMap) {
		OTSLabel *eLabel = e.label;
		
		// we assume that we are only checking a area
		
		// Found non-area edge
		NSAssert([eLabel isAreaAtGeometryIndex:geomIndex], @"Found non-area edge");
		
		int leftLoc = [eLabel locationAtGeometryIndex:geomIndex atPosIndex:kOTSPositionLeft];
		int rightLoc = [eLabel locationAtGeometryIndex:geomIndex atPosIndex:kOTSPositionRight];
		// check that edge is really a boundary between inside and outside!
		if (leftLoc == rightLoc) {
			return NO;
		}
		// check side location conflict
		//assert(rightLoc == currLoc); // "side location conflict " + locStr);
		if (rightLoc != currLoc) {
			return NO;
		}
		currLoc = leftLoc;
	}
	return YES;
}

@end
