//
//  OTSEdgeEndBuilder.m
//

#import "OTSEdgeEndBuilder.h"
#import "OTSCoordinate.h"
#import "OTSEdge.h"
#import "OTSEdgeEnd.h"
#import "OTSEdgeIntersectionList.h"
#import "OTSLabel.h"

@implementation OTSEdgeEndBuilder

- (NSArray *)computeEdgeEnds:(NSArray *)edges {
	NSMutableArray *l = [NSMutableArray array];
	for (OTSEdge *e in edges) {
		[self computeEdgeEnds:l edge:e];
	}
	return l;
}

- (void)computeEdgeEnds:(NSMutableArray *)l edge:(OTSEdge *)edge {
	
	OTSEdgeIntersectionList *eiList = edge.eiList;
	// ensure that the list has entries for the first and last point of the edge
	[eiList addEndpoints];
	
	if ([eiList.nodeMap count] == 0) return;
	
	int it = 0;
	OTSEdgeIntersection *eiPrev = nil;
	OTSEdgeIntersection *eiCurr = nil;
	OTSEdgeIntersection *eiNext = [eiList.nodeMap objectAtIndex:it];
	it++;
	do {
		eiPrev = eiCurr;
		eiCurr = eiNext;
		eiNext = nil;
		
		if (it < [eiList.nodeMap count]) {
			eiNext = [eiList.nodeMap objectAtIndex:it];
			it++;
		}
		
		if (eiCurr != nil) {
			[self createEdgeEnd:l edge:edge currentIntersection:eiCurr forPrevIntersection:eiPrev];
			[self createEdgeEnd:l edge:edge currentIntersection:eiCurr forNextIntersection:eiNext];
		}
		
	} while (eiCurr != nil);
	
}

- (void)createEdgeEnd:(NSMutableArray *)l 
				 edge:(OTSEdge *)edge 
  currentIntersection:(OTSEdgeIntersection *)eiCurr 
  forPrevIntersection:(OTSEdgeIntersection *)eiPrev {
	
	int iPrev = eiCurr.segmentIndex;
	
	if (eiCurr.distance == 0.0) {
		// if at the start of the edge there is no previous edge
		if (iPrev == 0) return;
		iPrev--;
	}
	
	OTSCoordinate *pPrev = nil;
	// if prev intersection is past the previous vertex, use it instead
	if (eiPrev != nil && eiPrev.segmentIndex >= iPrev)
		pPrev = eiPrev.coordinate;
	else
		pPrev = [[[OTSCoordinate alloc] initWithCoordinate:[edge getCoordinate:iPrev]] autorelease];
	
	OTSLabel *label = [[OTSLabel alloc] initWithLabel:edge.label];
	// since edgeStub is oriented opposite to it's parent edge, have to flip sides for edge label
	[label flip];
	OTSEdgeEnd *e = [[OTSEdgeEnd alloc] initWithEdge:edge p0:eiCurr.coordinate p1:pPrev label:label];
	[l addObject:e];
	
	[label release];
	[e release];
	
}

- (void)createEdgeEnd:(NSMutableArray *)l 
				 edge:(OTSEdge *)edge 
  currentIntersection:(OTSEdgeIntersection *)eiCurr 
  forNextIntersection:(OTSEdgeIntersection *)eiNext {
	
	int iNext = eiCurr.segmentIndex + 1;
	// if there is no next edge there is nothing to do
	if (iNext >= [edge getNumPoints] && eiNext == nil) 
		return;
	
	OTSCoordinate *pNext;
	// if the next intersection is in the same segment as the current, use it as the endpoint
	if (eiNext!=NULL && eiNext.segmentIndex == eiCurr.segmentIndex)
		pNext = eiNext.coordinate; 
	else
		pNext = [[[OTSCoordinate alloc] initWithCoordinate:[edge getCoordinate:iNext]] autorelease];
	
	OTSLabel *label = [[OTSLabel alloc] initWithLabel:edge.label];
	OTSEdgeEnd *e = [[OTSEdgeEnd alloc] initWithEdge:edge p0:eiCurr.coordinate p1:pNext label:label];
	[l addObject:e];
	
	[label release];
	[e release];
}

@end
