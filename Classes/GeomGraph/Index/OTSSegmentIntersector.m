//
//  OTSSegmentIntersector.m
//

#import "OTSSegmentIntersector.h"
#import "OTSEdge.h"
#import "OTSNode.h"
#import "OTSLineIntersector.h"
#import "OTSCoordinate.h"
#import "OTSCoordinateSequence.h"

@implementation OTSSegmentIntersector

@synthesize hasIntersection;
@synthesize hasProperIntersection;
@synthesize hasProperInteriorIntersection;
@synthesize properIntersectionPoint;
@synthesize li;
@synthesize includeProper;
@synthesize recordIsolated;
@synthesize numIntersections;
@synthesize bdyNodes;

- (id)initWithLineIntersector:(OTSLineIntersector *)newLi 
			 newIncludeProper:(BOOL)newIncludeProper 
			newRecordIsolated:(BOOL)newRecordIsolated {
	if (self = [super init]) {
		self.hasIntersection = NO;
		self.hasProperIntersection = NO;
		self.hasProperInteriorIntersection = NO;
		self.li = newLi;
		self.includeProper = newIncludeProper;
		self.recordIsolated = newRecordIsolated;
		self.numIntersections = 0;
		self.bdyNodes = [NSMutableArray arrayWithObjects:[NSNull null], [NSNull null], nil];
		properIntersectionPoint = nil;
	}
	return self;
}

- (void)dealloc {
	[li release];
	[properIntersectionPoint release];
	[bdyNodes release];
	[super dealloc];
}

- (BOOL)isTrivialIntersection:(OTSEdge *)e0 
					segIndex0:(int)segIndex0 
						   e1:(OTSEdge *)e1 
					segIndex1:(int)segIndex1 {
	if ([e0 equalsTo:e1]) {
		if ([li getIntersectionNum] == 1) {
			if ([OTSSegmentIntersector isAdjacentSegments:segIndex0 i2:segIndex1])
				return true;
			if ([e0 isClosed]) {
				int maxSegIndex = [e0 getNumPoints] - 1;
				if ((segIndex0 == 0 && segIndex1 == maxSegIndex)
					|| (segIndex1 == 0 && segIndex0 == maxSegIndex)) {
					return YES;
				}
			}
		}
	}
	return NO;	
}

- (BOOL)isBoundaryPoint:(OTSLineIntersector *)_li arrayOfArraysOfNodes:(NSArray *)tstBdyNodes {
	if ([self isBoundaryPoint:_li arrayOfNodes:[tstBdyNodes objectAtIndex:0]]) return YES;
	if ([self isBoundaryPoint:_li arrayOfNodes:[tstBdyNodes objectAtIndex:1]]) return YES;
	return NO;
}

- (BOOL)isBoundaryPoint:(OTSLineIntersector *)_li arrayOfNodes:(NSArray *)tstBdyNodes {	
	if (tstBdyNodes == nil) return NO;
	
	for(OTSNode *node in tstBdyNodes) {
		OTSCoordinate *pt = [node getCoordinate];
		if ([li isIntersection:pt])
			return YES;
	}
	return NO;	
}

+ (BOOL)isAdjacentSegments:(int)i1 i2:(int)i2 {
	return abs(i1-i2)==1;
}

- (void)setBoundaryNodes:(NSArray *)bdyNodes0 bdyNodes1:(NSArray *)bdyNodes1 {
	[bdyNodes replaceObjectAtIndex:0 withObject:bdyNodes0];
	[bdyNodes replaceObjectAtIndex:1 withObject:bdyNodes1];
}

- (void)addIntersections:(OTSEdge *)e0 
			   segIndex0:(int)segIndex0 
					  e1:(OTSEdge *)e1 
			   segIndex1:(int)segIndex1 {
	
	if ([e0 equalsTo:e1] && segIndex0 == segIndex1) return;

	OTSCoordinateSequence *cl0 = [e0 getCoordinates];
	OTSCoordinate *p00 = [[cl0 getAt:segIndex0] clone];
	OTSCoordinate *p01 = [[cl0 getAt:segIndex0 + 1] clone];	
	//OTSCoordinate *p00 = [cl0 getAt:segIndex0];
	//OTSCoordinate *p01 = [cl0 getAt:segIndex0 + 1];
	
	OTSCoordinateSequence *cl1 = [e1 getCoordinates];
	OTSCoordinate *p10 = [[cl1 getAt:segIndex1] clone];
	OTSCoordinate *p11 = [[cl1 getAt:segIndex1 + 1] clone];
	//OTSCoordinate *p10 = [cl1 getAt:segIndex1];
	//OTSCoordinate *p11 = [cl1 getAt:segIndex1 + 1];
	
	[li computeIntersectionOfLineOfPoint:p00 to:p01 andLineOfPoint:p10 to:p11];
	
	/*
	 * Always record any non-proper intersections.
	 * If includeProper is true, record any proper intersections as well.
	 */
	if ([li hasIntersection]) {
		if (recordIsolated) {
			[e0 setIsolated:NO];
			[e1 setIsolated:NO];
		}
		//intersectionFound = true;
		numIntersections++;
		
		// If the segments are adjacent they have at least one trivial
		// intersection, the shared endpoint.
		// Don't bother adding it if it is the
		// only intersection.
		if (![self isTrivialIntersection:e0 segIndex0:segIndex0 e1:e1 segIndex1:segIndex1])
		{
			hasIntersection = true;
			if (includeProper || ![li isProper]) {
				[e0 addIntersections:li segmentIndex:segIndex0 geomIndex:0];
				[e1 addIntersections:li segmentIndex:segIndex1 geomIndex:1];
			}
			if ([li isProper])
			{
				self.properIntersectionPoint = [li getIntersection:0];
				hasProperIntersection = YES;
				if (![self isBoundaryPoint:li arrayOfArraysOfNodes:bdyNodes])
					hasProperInteriorIntersection = YES;
			}
			//if (li.isCollinear())
			//hasCollinear = true;
		}
	}
	
}

@end
