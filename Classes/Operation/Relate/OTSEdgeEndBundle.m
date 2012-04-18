//
//  OTSEdgeEndBundle.m
//

#import "OTSEdgeEndBundle.h"
#import "OTSLocation.h"
#import "OTSLabel.h"
#import "OTSEdgeEnd.h"
#import "OTSEdge.h"
#import "OTSGeometryGraph.h"
#import "OTSPosition.h"


@implementation OTSEdgeEndBundle

@synthesize edgeEnds;

- (id)initWithEdgeEnd:(OTSEdgeEnd *)e {
	if (self = [super initWithEdge:e.edge p0:[e getCoordinate] p1:[e getDirectedCoordinate] label:e.label]) {
		self.edgeEnds = [NSMutableArray array];
		[self insert:e];
	}
	return self;
}

- (void)dealloc {
	[edgeEnds release];
	[super dealloc];
}

- (void)insert:(OTSEdgeEnd *)e {
	[edgeEnds addObject:e];
}

- (void)computeLabel:(OTSBoundaryNodeRule *)bnr {
	
	// create the label.  If any of the edges belong to areas,
	// the label must be an area label
	BOOL isArea = NO;
	
	for (OTSEdgeEnd *e in edgeEnds) {
		if ([e.label isArea])
			isArea = YES;
	}
		
	if (isArea) {
		[label release];
		label = [[OTSLabel alloc] initWithOnLocation:kOTSLocationUndefined leftLocation:kOTSLocationUndefined rightLocation:kOTSLocationUndefined];
	} else {
		[label release];
		label = [[OTSLabel alloc] initWithOnLocation:kOTSLocationUndefined];
	}
	
	// compute the On label, and the side labels if present
	for(int i=0; i<2; i++) {
		[self computeLabelOn:i boundaryNodeRule:bnr];
		if (isArea)
			[self computeLabelSidesAt:i];
	}
	
}

- (void)updateIM:(OTSIntersectionMatrix *)im {
	[OTSEdge updateIM:label im:im];
}

- (void)computeLabelOn:(int)geomIndex boundaryNodeRule:(OTSBoundaryNodeRule *)boundaryNodeRule {
	
	// compute the ON location value
	int boundaryCount = 0;
	BOOL foundInterior = NO;
	
	for (OTSEdgeEnd *e in edgeEnds) {
		int loc = [e.label locationAtGeometryIndex:geomIndex];
		if (loc == kOTSLocationBoundary) boundaryCount++;
		if (loc == kOTSLocationInterior) foundInterior = true;
	}
	
	int loc = kOTSLocationUndefined;
	if (foundInterior) loc = kOTSLocationInterior;
	if (boundaryCount > 0) {
		loc = [OTSGeometryGraph determineBoundary:boundaryCount with:boundaryNodeRule];
	}
	[label setLocation:loc atGeometryIndex:geomIndex];
	
}

- (void)computeLabelSidesAt:(int)geomIndex {
	[self computeLabelSide:kOTSPositionLeft at:geomIndex];
	[self computeLabelSide:kOTSPositionRight at:geomIndex];
}

- (void)computeLabelSide:(int)side at:(int)geomIndex {
	
	for (OTSEdgeEnd *e in edgeEnds) {
		if ([e.label isArea]) {
			int loc = [e.label locationAtGeometryIndex:geomIndex atPosIndex:side];
			if (loc == kOTSLocationInterior) {
				[label setLocation:kOTSLocationInterior atGeometryIndex:geomIndex atPosIndex:side];
				return;
			} else if (loc == kOTSLocationExterior) {
				[label setLocation:kOTSLocationExterior atGeometryIndex:geomIndex atPosIndex:side];
			}
		}
	}
	
}

@end
