//
//  OTSDirectedEdge.m
//

#import "OTSEdge.h"
#import "OTSEdgeRing.h" // for printing
#import "OTSDirectedEdge.h"
#import "OTSLocation.h"
#import "OTSLabel.h"
#import "OTSPosition.h"


@implementation OTSDirectedEdge

@synthesize forward;
@synthesize inResult;
@synthesize visited;
@synthesize sym; 
@synthesize next; 
@synthesize nextMin; 
@synthesize edgeRing;
@synthesize minEdgeRing;

- (id)init {
	if (self = [super init]) {
		
		depth[0]=0;
		depth[1]=-999;
		depth[2]=-999;
		
		inResult = NO;
		visited = NO;
		sym = nil;
		next = nil;
		nextMin = nil;
		edgeRing = nil;
		minEdgeRing = nil;
		
	}
	return self;
}

- (id)initWithEdge:(OTSEdge *)newEdge isForward:(BOOL)newIsForward {
	if (self = [super initWithEdge:newEdge]) {
		
		depth[0]=0;
		depth[1]=-999;
		depth[2]=-999;
		
		forward = newIsForward;
		
		inResult = NO;
		visited = NO;
		sym = nil;
		next = nil;
		nextMin = nil;
		edgeRing = nil;
		minEdgeRing = nil;
		
		if (forward) {
			[self setP0:[edge getCoordinate:0] p1:[edge getCoordinate:1]];
		} else {			
			int n = [edge getNumPoints] - 1;
			[self setP0:[edge getCoordinate:n] p1:[edge getCoordinate:n - 1]];
		}
		[self computeDirectedLabel];
	}
	return self;
}

- (void)dealloc {
	[sym release]; 
	[next release];  
	[nextMin release];  
	[edgeRing release]; 
	[minEdgeRing release]; 
	[super dealloc];
}

+ (int)depthFactor:(int)currLocation nextLocation:(int)nextLocation {
	if (currLocation == kOTSLocationExterior && nextLocation == kOTSLocationInterior)
		return 1;
	else if (currLocation == kOTSLocationInterior && nextLocation == kOTSLocationExterior)
		return -1;
	return 0;
}

- (int)getDepthAt:(int)position {
	return depth[position];
}

- (void)setDepth:(int)newDepth at:(int)position {
	if (depth[position] != -999) {
		if (depth[position] != newDepth) {
			NSException *ex = [NSException exceptionWithName:@"TopologyException" 
													  reason:@"assigned depths do not match" 
													userInfo:nil];
			@throw ex;
		}
	}
	depth[position] = newDepth;
	
}

- (int)getDepthDelta {
	int depthDelta = [edge depthDelta];
	if (!forward) depthDelta = -depthDelta;
	return depthDelta;
}

- (void)setVisitedEdge:(BOOL)newIsVisited {
	visited = newIsVisited;
	sym.visited = newIsVisited;
}

- (BOOL)isLineEdge {
	BOOL isLine = [label isLineAtGeometryIndex:0] || [label isLineAtGeometryIndex:1];
	BOOL isExteriorIfArea0 = ![label isAreaAtGeometryIndex:0] || [label allPositionsEqualAtGeometryIndex:0 toLocation:kOTSLocationExterior];
	BOOL isExteriorIfArea1 = ![label isAreaAtGeometryIndex:1] || [label allPositionsEqualAtGeometryIndex:1 toLocation:kOTSLocationExterior];
	return isLine && isExteriorIfArea0 && isExteriorIfArea1;
	
}

- (BOOL)isInteriorAreaEdge {
	BOOL isInteriorAreaEdge = YES;
	for (int i = 0; i < 2; i++) {
		if (!([label isAreaAtGeometryIndex:i]
			  && [label locationAtGeometryIndex:i atPosIndex:kOTSPositionLeft] == kOTSLocationInterior
			  && [label locationAtGeometryIndex:i atPosIndex:kOTSPositionRight] == kOTSLocationInterior)) {
			isInteriorAreaEdge = NO;
		}
	}
	return isInteriorAreaEdge;	
}

- (void)setEdgeDepths:(int)newDepth at:(int)position {
	// get the depth transition delta from R to L for this directed Edge
	int depthDelta = edge.depthDelta;
	if (!forward) depthDelta = -depthDelta;
	// if moving from L to R instead of R to L must change sign of delta
	int directionFactor = 1;
	if (position == kOTSPositionLeft)
		directionFactor=-1;
	int oppositePos = [OTSPosition opposite:position];
	int delta = depthDelta * directionFactor;
	//TESTINGint delta = depthDelta * DirectedEdge.depthFactor(loc, oppositeLoc);
	int oppositeDepth = newDepth+delta;
	
	[self setDepth:newDepth at:position];
	[self setDepth:oppositeDepth at:oppositePos];
}

- (void)computeDirectedLabel {
	if (label != nil)
		[label release];
	label = [[OTSLabel alloc] initWithLabel:edge.label];
	if (!forward)
		[label flip];	
}

@end
