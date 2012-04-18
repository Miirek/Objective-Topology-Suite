//
//  OTSEdgeEnd.m
//

#import "OTSEdgeEnd.h"
#import "OTSNode.h" // for assertions 
#import "OTSCGAlgorithms.h"
#import "OTSLabel.h"
#import "OTSQuadrant.h"
#import "OTSCoordinate.h"

@implementation OTSEdgeEnd

@synthesize edge;
@synthesize label;
@synthesize node;         
@synthesize p0;
@synthesize p1; 	
@synthesize dx;
@synthesize dy;	
@synthesize quadrant;

- (id)initWithEdge:(OTSEdge *)newEdge p0:(OTSCoordinate *)newP0 p1:(OTSCoordinate *)newP1 label:(OTSLabel *)newLabel {
	if (self = [super init]) {
		self.edge = newEdge;
		self.label = newLabel;
		node = nil;
		dx = 0.0;
		dy = 0.0;
		quadrant = 0;
		[self setP0:newP0 p1:newP1];
	}
	return self;
}

- (id)initWithEdge:(OTSEdge *)newEdge {
	if (self = [super init]) {
		self.edge = newEdge;
		self.p0 = nil;
		self.p1 = nil;
		self.label = nil;
		node = nil;
		dx = 0.0;
		dy = 0.0;
		quadrant = 0;
	}
	return self;
}

- (id)init {
	if (self = [super init]) {
		self.edge = nil;
		self.p0 = nil;
		self.p1 = nil;
		self.label = nil;
		node = nil;
		dx = 0.0;
		dy = 0.0;
		quadrant = 0;
	}
	return self;
}

- (void)dealloc {
	[edge release];
	[label release];
	[node release];
	[p0 release];
	[p1 release];
	[super dealloc];
}

- (OTSCoordinate *)getCoordinate {
	return p0;
}

- (OTSCoordinate *)getDirectedCoordinate {
	return p1;
}

- (int)compareTo:(OTSEdgeEnd *)e {
	return [self compareDirection:e];
}

- (int)compareDirection:(OTSEdgeEnd *)e {
	if (dx == e.dx && dy == e.dy)
		return 0;
	
	// if the rays are in different quadrants,
	// determining the ordering is trivial
	if (quadrant > e.quadrant) return 1;
	if (quadrant < e.quadrant) return -1;
	
	// vectors are in the same quadrant - check relative
	// orientation of direction vectors
	// this is > e if it is CCW of e
	return [OTSCGAlgorithms computeOrientation:e.p0 p2:e.p1 q:p1];
}

- (void)computeLabel:(OTSBoundaryNodeRule *)bnr {
	// subclasses should override this if they are using labels
}

- (void)setP0:(OTSCoordinate *)newP0 p1:(OTSCoordinate *)newP1 {
	self.p0 = newP0;
	self.p1 = newP1;
	dx = p1.x - p0.x;
	dy = p1.y - p0.y;
	quadrant = [OTSQuadrant quadrant:dx dy:dy];
	
	NSAssert(!(dx == 0 && dy == 0), @"EdgeEnd with identical endpoints found");
}

+ (BOOL)edgeEnd:(OTSEdgeEnd *)s1 lessThan:(OTSEdgeEnd *)s2 {
	return [s1 compareTo:s2] < 0;	
}

@end
