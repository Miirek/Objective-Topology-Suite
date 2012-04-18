//
//  OTSEdge.m
//

#import "OTSEdge.h"
#import "OTSPosition.h"
#import "OTSLabel.h"
#import "OTSMonotoneChainEdge.h"
#import "OTSLineIntersector.h"
#import "OTSIntersectionMatrix.h"
#import "OTSCoordinateSequence.h"
#import "OTSCoordinate.h"

@implementation OTSEdge

@synthesize name;
@synthesize mce;
@synthesize env;
@synthesize depth;
@synthesize depthDelta;
@synthesize pts;
@synthesize eiList;

- (id)initWithCoordinateSequence:(OTSCoordinateSequence *)newPts {
	return [self initWithCoordinateSequence:newPts label:nil];
}

- (id)initWithCoordinateSequence:(OTSCoordinateSequence *)newPts label:(OTSLabel *)_label {
	if (self = [super initWithLabel:_label]) {
		mce = nil;
		env = nil;
		isolated = YES;
		depth = [[OTSDepth alloc] init];
		depthDelta = 0;
		self.pts = newPts;
		eiList = [[OTSEdgeIntersectionList alloc] initWithEdge:self];
	}
	return self;
}

- (void)dealloc {
	[name release];
	[mce release];
	[env release];
	[depth release];
	[pts release];
	[eiList release];
	[super dealloc];
}

+ (void)updateIM:(OTSLabel *)lbl im:(OTSIntersectionMatrix *)im {
	[im setAtLeastIfValidRow:[lbl locationAtGeometryIndex:0 atPosIndex:kOTSPositionOn] 
					  column:[lbl locationAtGeometryIndex:1 atPosIndex:kOTSPositionOn] 
			  dimensionValue:1];
	
	if ([lbl isArea]) {
		[im setAtLeastIfValidRow:[lbl locationAtGeometryIndex:0 atPosIndex:kOTSPositionLeft] 
						  column:[lbl locationAtGeometryIndex:1 atPosIndex:kOTSPositionLeft] 
				  dimensionValue:2];
		[im setAtLeastIfValidRow:[lbl locationAtGeometryIndex:0 atPosIndex:kOTSPositionRight] 
						  column:[lbl locationAtGeometryIndex:1 atPosIndex:kOTSPositionRight] 
				  dimensionValue:2];
	}	
}

- (int)getNumPoints {
	return [pts size];
}

- (OTSCoordinateSequence *)getCoordinates {
	return pts;
}

- (OTSCoordinate *)getCoordinate:(int)i {
	return [pts getAt:i];
}

- (OTSCoordinate *)getCoordinate {
	return [pts getAt:0];
}

- (int)getMaximumSegmentIndex {
	return [self getNumPoints] - 1;
}

- (OTSEdgeIntersectionList *)getEdgeIntersectionList {
	return eiList;
}

- (OTSMonotoneChainEdge *)getMonotoneChainEdge {
	if (mce == nil) mce = [[OTSMonotoneChainEdge alloc] initWithEdge:self];
	return mce;
}

- (BOOL)isClosed {
	return [pts getAt:0] == [pts getAt:([self getNumPoints] - 1)];
}

- (BOOL)isCollapsed {
	if (![label isArea]) return NO;
	if ([self getNumPoints] != 3) return NO;
	if ([[pts getAt:0] isEqual2D:[pts getAt:2]]) return YES;
	return NO;
}

- (OTSEdge *)getCollapsedEdge {
	OTSCoordinateSequence *newPts = [[OTSCoordinateSequence alloc] initWithCapacity:2];
	[newPts set:[pts getAt:0] at:0];
	[newPts set:[pts getAt:1] at:1];
	OTSEdge *e = [[OTSEdge alloc] initWithCoordinateSequence:newPts label:[OTSLabel lineLabelFromLabel:label]];
	[newPts release];
	return [e autorelease];
}

- (void)addIntersections:(OTSLineIntersector *)li segmentIndex:(int)segmentIndex geomIndex:(int)geomIndex {
	for (int i = 0; i < [li getIntersectionNum]; i++) {
		[self addIntersections:li segmentIndex:segmentIndex geomIndex:geomIndex intIndex:i];
	}	
}

- (void)addIntersections:(OTSLineIntersector *)li segmentIndex:(int)segmentIndex geomIndex:(int)geomIndex intIndex:(int)intIndex {
	
	OTSCoordinate *intPt = [li getIntersection:intIndex];
	int normalizedSegmentIndex = segmentIndex;
	double dist = [li getEdgeDistance:geomIndex intersectionIndex:intIndex];
	
	// normalize the intersection point location
	int nextSegIndex = normalizedSegmentIndex + 1;
	int npts = [self getNumPoints];
	if (nextSegIndex < npts) {
		OTSCoordinate *nextPt = [pts getAt:nextSegIndex];
        // Normalize segment index if intPt falls on vertex
        // The check for point equality is 2D only - Z values are ignored
		if ([intPt isEqual2D:nextPt]) {
			normalizedSegmentIndex = nextSegIndex;
			dist = 0.0;
		}
	}
	
	/*
	 * Add the intersection point to edge intersection list.
	 */
	[eiList add:intPt segmentIndex:normalizedSegmentIndex distance:dist];
}

- (void)computeIM:(OTSIntersectionMatrix *)im {
	[OTSEdge updateIM:label im:im];
}

- (void)updateIMSuper:(OTSIntersectionMatrix *)im {
	[super updateIM:im];
}

- (BOOL)isPointwiseEqual:(OTSEdge *)e {
	int npts = [self getNumPoints];
	int enpts = [e getNumPoints];
	if (npts!=enpts) return NO;
	for (int i = 0; i < npts; ++i) {
		if (![[pts getAt:i] isEqual2D:[e.pts getAt:i]]) {
			return NO;
		}
	}
	return YES;
}

- (BOOL)equalsTo:(OTSEdge*)e {
	int npts1 = [self getNumPoints]; 
	int npts2 = [e getNumPoints]; 
	
	if (npts1 != npts2 ) return NO;
	
	BOOL isEqualForward = YES;
	BOOL isEqualReverse = YES;
	
	for (int i=0, iRev = npts1 - 1; i < npts1; ++i, --iRev)
	{
		OTSCoordinate *e1pi = [pts getAt:i];
		OTSCoordinate *e2pi = [e.pts getAt:i];
		OTSCoordinate *e2piRev = [e.pts getAt:iRev];
		
		if (![e1pi isEqual2D:e2pi]) isEqualForward = NO;
		if (![e1pi isEqual2D:e2piRev]) isEqualReverse = NO;
		if (!isEqualForward && !isEqualReverse) return NO;
	}
	return YES;
	
}

- (OTSEnvelope*)getEnvelope {
	// compute envelope lazily
	if (env == nil)
	{
		env = [[OTSEnvelope alloc] init];
		int npts = [self getNumPoints];
		for (int i = 0; i < npts; ++i) {
			[env expandToIncludeCoordinate:[pts getAt:i]];
		}
	}
	return env;	
}

@end
