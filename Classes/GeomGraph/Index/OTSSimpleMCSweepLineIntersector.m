//
//  OTSSimpleMCSweepLineIntersector.m
//

#import "OTSSimpleMCSweepLineIntersector.h"
#import "OTSMonotoneChainEdge.h"
#import "OTSMonotoneChain.h"
#import "OTSSweepLineEvent.h"
#import "OTSEdge.h"

@implementation OTSSimpleMCSweepLineIntersector

@synthesize events;
@synthesize nOverlaps;	

- (id)init {
	if (self = [super init]) {
		self.events = [NSMutableArray array];
	}
	return self;
}

- (void)dealloc {
	[events release];
	[super dealloc];
}

- (void)computeIntersections:(NSArray *)edges 
		  segmentIntersector:(OTSSegmentIntersector *)si 
			 testAllSegments:(BOOL)testAllSegments {
	if (testAllSegments)
		[self addArray:edges edgeSet:nil];
	else
		[self addArray:edges];
	[self computeIntersections:si];
}

- (void)computeIntersections:(NSArray *)edges0 
					  edges1:(NSArray *)edges1 
		  segmentIntersector:(OTSSegmentIntersector *)si {
	[self addArray:edges0 edgeSet:edges0];
	[self addArray:edges1 edgeSet:edges1];
	[self computeIntersections:si];
}

- (void)addArray:(NSArray *)edges {
	for (OTSEdge *edge in edges) {
		[self add:edge edgeSet:edge];
	}
}

- (void)addArray:(NSArray *)edges edgeSet:(id)edgeSet {
	for (OTSEdge *edge in edges) {
		[self add:edge edgeSet:edgeSet];
	}
}

- (void)add:(OTSEdge *)edge edgeSet:(id)edgeSet {
	
	OTSMonotoneChainEdge *mce = [edge getMonotoneChainEdge];
	NSArray *startIndex = [mce getStartIndexes];
	int n = [startIndex count] - 1;

	//events.reserve(events.size()+(n*2));
	for (int i = 0; i < n; ++i) {
		OTSMonotoneChain *mc = [[OTSMonotoneChain alloc] initWithChainEdge:mce chainIndex:i];
		OTSSweepLineEvent *insertEvent = [[OTSSweepLineEvent alloc] initWithEdgeSet:edgeSet x:[mce minX:i] insertEvent:nil object:mc];
		[events addObject:insertEvent];
    OTSSweepLineEvent *sweepEvent = [[OTSSweepLineEvent alloc] initWithEdgeSet:edgeSet x:[mce maxX:i] insertEvent:insertEvent object:mc];
		[events addObject:sweepEvent];
    [sweepEvent release];
    [insertEvent release];
    [mc release];
	}	
}

- (void)prepareEvents {
	
	//NSArray *sortedKeyz = [keyz sortedArrayUsingSelector:@selector(compareForNSComparisonResult:)];
	NSArray *sortedEvents = [events sortedArrayUsingSelector:@selector(compareForNSComparisonResult:)];
	self.events = [NSMutableArray arrayWithArray:sortedEvents];
	int i = 0;
	for (OTSSweepLineEvent *ev in events) {
		if ([ev isDelete]) {
			[ev.insertEvent setDeleteEventIndex:i];
		}
		i++;
	}
	
}

- (void)computeIntersections:(OTSSegmentIntersector *)si {
	
	nOverlaps = 0;
	[self prepareEvents];
	
	int i = 0;
	for (OTSSweepLineEvent *ev in events) {
		if ([ev isInsert]) {
			[self processOverlaps:i end:ev.deleteEventIndex ev0:ev segmentIntersector:si];
		}
		i++;
	}
		
}

- (void)processOverlaps:(int)start 
					end:(int)end 
					ev0:(OTSSweepLineEvent *)ev0 
	 segmentIntersector:(OTSSegmentIntersector *)si {
	
	OTSMonotoneChain *mc0 = (OTSMonotoneChain *)ev0.object;
	
	/*
	 * Since we might need to test for self-intersections,
	 * include current insert event object in list of event objects to test.
	 * Last index can be skipped, because it must be a Delete event.
	 */
	for(int i = start; i < end; ++i) {
		
		OTSSweepLineEvent *ev1 = [events objectAtIndex:i];
		if ([ev1 isInsert]) {
			OTSMonotoneChain *mc1 = (OTSMonotoneChain *) ev1.object;
			// don't compare edges in same group
			// null group indicates that edges should be compared
			if (ev0.edgeSet == nil || (ev0.edgeSet != ev1.edgeSet)) {
				[mc0 computeIntersections:mc1 segmentIntersector:si];
				nOverlaps++;
			}
		}
	}
	
}

@end
