//
//  OTSMaximalEdgeRing.m
//

#import "OTSMaximalEdgeRing.h"
#import "OTSMinimalEdgeRing.h"
#import "OTSEdgeRing.h"
#import "OTSDirectedEdge.h"
#import "OTSNode.h"
#import "OTSEdgeEndStar.h"
#import "OTSDirectedEdgeStar.h"

@implementation OTSMaximalEdgeRing

- (id)initWithEdgeEnd:(OTSDirectedEdge *)newStart geometryFactory:(OTSGeometryFactory *)newGeometryFactory {
	if (self = [super initWithEdgeEnd:newStart geometryFactory:newGeometryFactory]) {
		[self computePoints:newStart];
		[self computeRing];
	}
	return self;
}

- (OTSDirectedEdge *)getNext:(OTSDirectedEdge *)de {
	return de.next;
}

- (void)setEdgeRing:(OTSDirectedEdge *)de edgeRing:(OTSEdgeRing *)er {
	[de setEdgeRing:er];
}

- (NSArray *)buildMinimalRings {
	NSMutableArray *minEdgeRings = [NSMutableArray array];
	[self buildMinimalRingsUsingMinimalEdgeRings:minEdgeRings];
	return minEdgeRings;
}

- (void)buildMinimalRingsUsingMinimalEdgeRings:(NSMutableArray *)minEdgeRings {
	OTSDirectedEdge *de = startDe;
	do {
		if (de.minEdgeRing == nil) {
			OTSMinimalEdgeRing *minEr = [[OTSMinimalEdgeRing alloc] initWithEdgeEnd:de geometryFactory:geometryFactory];
			[minEdgeRings addObject:minEr];
      [minEr release];
		}
		de = de.next;
	} while (de != startDe);	
}

- (void)linkDirectedEdgesForMinimalEdgeRings {
	OTSDirectedEdge *de = startDe;
	do {
		OTSNode *node = de.node;
		OTSEdgeEndStar *ees = node.edges;
		
		NSAssert([ees isKindOfClass:[OTSDirectedEdgeStar class]], @"Expecting OTSDirectedEdgeStar class");
		OTSDirectedEdgeStar *des = (OTSDirectedEdgeStar *)ees;
		
		[des linkMinimalDirectedEdges:self];
		de = de.next;
		
	} while (de != startDe);
}

@end
