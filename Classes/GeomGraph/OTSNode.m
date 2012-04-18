//
//  OTSNode.m
//

#import "OTSCoordinate.h"
#import "OTSNode.h"
#import "OTSEdge.h"
#import "OTSEdgeEndStar.h"
#import "OTSLabel.h"
#import "OTSDirectedEdge.h"
#import "OTSLocation.h"

@implementation OTSNode

@synthesize edges;
@synthesize coord;
@synthesize zvals;	
@synthesize ztot;

- (id)initWithCoordinate:(OTSCoordinate *)newCoord edges:(OTSEdgeEndStar *)newEdges {
	if (self = [super initWithLabel:[[[OTSLabel alloc] initWithGeometryIndex:0 onLocation:kOTSLocationUndefined] autorelease]]) {
		self.coord = newCoord;
		self.edges = newEdges;
//#if COMPUTE_Z
//		ztot = 0;
//		[self addZ:newCoord.z];
//		if (edges) {
//			for (OTSEdgeEnd *ee in edges.edgeMap) {
//				[self addZ:[ee getCoordinate].z];
//			}
//		}
//#endif // COMPUTE_Z		
	}
	return self;
}

- (void)dealloc {
	[edges release];
	[coord release];
	[zvals release];
	[super dealloc];
}

- (OTSCoordinate *)getCoordinate {
	return coord;
}

- (BOOL)isIsolated {
	return ([label geometryCount] == 1);
}

- (void)add:(OTSEdgeEnd *)e {
	
	[edges insert:e];
	[e setNode:self];
//#if COMPUTE_Z
//	[self addZ:[e getCoordinate].z];
//#endif
		
}

- (void)mergeLabelWithNode:(OTSNode *)n {
	[self mergeLabel:n.label];
}

- (void)mergeLabel:(OTSLabel *)label2 {
	for (int i = 0; i < 2; i++) {
		int loc = [self computeMergedLocation:label2 eltIndex:i];
		int thisLoc = [label locationAtGeometryIndex:i];
		if (thisLoc == kOTSLocationUndefined) 
			[label setLocation:loc atGeometryIndex:i];
	}	
}

- (void)setLabel:(int)argIndex onLocation:(int)onLocation {
	if (label == nil) {
		label = [[OTSLabel alloc] initWithGeometryIndex:argIndex onLocation:onLocation];
	} else {
		[label setLocation:onLocation atGeometryIndex:argIndex];
	}
}

- (void)setLabelBoundary:(int)argIndex {
	
	int loc = kOTSLocationUndefined;
	if (label != nil)
		loc = [label locationAtGeometryIndex:argIndex];
	// flip the loc
	int newLoc;
	switch (loc){
		case kOTSLocationBoundary: newLoc = kOTSLocationInterior; break;
		case kOTSLocationInterior: newLoc = kOTSLocationBoundary; break;
		default: newLoc = kOTSLocationBoundary;  break;
	}
	[label setLocation:newLoc atGeometryIndex:argIndex];
	
}

- (int)computeMergedLocation:(OTSLabel *)label2 eltIndex:(int)eltIndex {
	
	int loc = kOTSLocationUndefined;
	loc = [label locationAtGeometryIndex:eltIndex];
	if (![label2 isNullAtGeometryIndex:eltIndex]) {
		int nLoc = [label2 locationAtGeometryIndex:eltIndex];
		if (loc != kOTSLocationBoundary) loc = nLoc;
	}
	
	return loc;
	
}

- (NSArray *)getZ {
	return zvals;
}

- (void)addZ:(double)z {
	
	if (isnan(z)) {
		return;
	}
	
	double zfound = NAN;
	for (NSNumber *zv in zvals) {
		if ([zv doubleValue] == z) {
			zfound = [zv doubleValue];
			break;
		}
	}
	
	if (!isnan(zfound)) {
		return;
	}
	
	[zvals addObject:[NSNumber numberWithDouble:z]];
	ztot += z;
	coord.z = ztot/[zvals count];
	
}

- (BOOL)isIncidentEdgeInResult {
	
	if (edges == nil) return NO;
	
	for (OTSDirectedEdge *de in edges.edgeMap) {
		if (de.edge.inResult) return YES;
	}
	return NO;
	
}

- (void)computeIM:(OTSIntersectionMatrix *)im {
	// Basic nodes do not compute IMs
}

@end
