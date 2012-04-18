//
//  OTSEdgeIntersectionList.m
//

#import "OTSEdgeIntersectionList.h"
#import "OTSEdgeIntersection.h"
#import "OTSEdge.h"
#import "OTSLabel.h"
#import "OTSCoordinateSequence.h"
#import "OTSCoordinate.h"

@implementation OTSEdgeIntersectionList

@synthesize nodeMap;
@synthesize edge;

- (id)initWithEdge:(OTSEdge *)_edge {
	if (self = [super init]) {
		self.edge = _edge;
		self.nodeMap = [NSMutableArray array];
	}
	return self;
}

- (void)dealloc {
	[nodeMap release];
	[edge release];
	[super dealloc];
}

- (OTSEdgeIntersection *)add:(OTSCoordinate *)coord segmentIndex:(int)segmentIndex distance:(double)dist {
	OTSEdgeIntersection *eiNew = [[OTSEdgeIntersection alloc] initWithCoordinate:coord segmentIndex:segmentIndex distance:dist];
	OTSEdgeIntersection *eiRet = nil;
	
	int pos = -1;
	if ([nodeMap count] > 0) {
		BOOL found = NO;
		for (int i = 0; i < [nodeMap count]; i++) {
			OTSEdgeIntersection *eiCur = [nodeMap objectAtIndex:i];
			if (![OTSEdgeIntersection edgeIntersection:eiCur lessThan:eiNew]) {
				if ([eiCur equalsTo:eiNew]) {
					eiRet = eiCur;
				} else {
					pos = i;				
				}
				found = YES;
				break;
			} 
		}
		if (!found)
			pos = [nodeMap count];
	} else {
		pos = 0;
	}
	
	if (pos > -1) {
		if ([nodeMap count] == pos) {
			[nodeMap addObject:eiNew];
		} else {
			[nodeMap insertObject:eiNew atIndex:pos];
		}		
		eiRet = eiNew;
	}
	
	[eiNew release];	
	return eiRet;
}

- (BOOL)isEmpty {
	return [nodeMap count] == 0;
}

- (BOOL)isIntersection:(OTSCoordinate *)pt {
	for (OTSEdgeIntersection *ei in nodeMap) {
		if ([ei.coordinate isEqual2D:pt])
			return YES;
	}
	return NO;
}

- (void)addEndpoints {
	int maxSegIndex = [edge getNumPoints] - 1;
	[self add:[edge.pts getAt:0] segmentIndex:0 distance:0.0];
	[self add:[edge.pts getAt:maxSegIndex] segmentIndex:maxSegIndex distance:0.0];
}

- (void)addSplitEdges:(NSMutableArray *)edgeList {
	// ensure that the list has entries for the first and last point
	// of the edge
	[self addEndpoints];
	
	if ([nodeMap count] > 1) {
		OTSEdgeIntersection *ei = nil;
		OTSEdgeIntersection *eiPrev = [nodeMap objectAtIndex:0];
		for (int i = 1; i < [nodeMap count]; i++) {
			ei = [nodeMap objectAtIndex:i];
			OTSEdge *newEdge = [self createSplitEdge:eiPrev ei1:ei];
			[edgeList addObject:newEdge];
			eiPrev = ei;
		}
	}	
}

- (OTSEdge *)createSplitEdge:(OTSEdgeIntersection *)ei0 ei1:(OTSEdgeIntersection *)ei1 {
	
	int npts = ei1.segmentIndex - ei0.segmentIndex + 2;
	OTSCoordinate *lastSegStartPt = [edge.pts getAt:ei1.segmentIndex];
	
	// if the last intersection point is not equal to the its segment
	// start pt, add it to the points list as well.
	// (This check is needed because the distance metric is not totally
	// reliable!). The check for point equality is 2D only - Z values
	// are ignored
	BOOL useIntPt1 = ei1.distance > 0.0 || ![ei1.coordinate isEqual2D:lastSegStartPt];
	
	if (!useIntPt1) --npts;
	
	NSMutableArray *vc = [NSMutableArray arrayWithCapacity:npts];
	[vc addObject:ei0.coordinate];
	
	for(int i = ei0.segmentIndex + 1; i <= ei1.segmentIndex;i++) {
		if (!useIntPt1 && ei1.segmentIndex == i) {
			[vc addObject:ei1.coordinate];
		} else {
			[vc addObject:[edge.pts getAt:i]];
		}
	}
	
	if (useIntPt1) {
		[vc addObject:ei1.coordinate];
	}
	
	OTSCoordinateSequence *pts = [[OTSCoordinateSequence alloc] initWithArray:vc];
	OTSEdge *ret = [[OTSEdge alloc] initWithCoordinateSequence:pts label:edge.label];
	
	[pts release];
	return [ret autorelease];
}

@end
