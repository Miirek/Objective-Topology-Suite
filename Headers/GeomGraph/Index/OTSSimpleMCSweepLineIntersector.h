//
//  OTSSimpleMCSweepLineIntersector.h
//

#import <Foundation/Foundation.h>

#import "OTSEdgeSetIntersector.h" // for inheritance

@class OTSSegmentIntersector;
@class OTSSweepLineEvent;

@interface OTSSimpleMCSweepLineIntersector : OTSEdgeSetIntersector {
	NSMutableArray *events;
	int nOverlaps;	
}

@property (nonatomic, retain) NSMutableArray *events;
@property (nonatomic, assign) int nOverlaps;	

- (void)computeIntersections:(NSArray *)edges 
		  segmentIntersector:(OTSSegmentIntersector *)si 
			 testAllSegments:(BOOL)testAllSegments;
- (void)computeIntersections:(NSArray *)edges0 
					  edges1:(NSArray *)edges1 
		  segmentIntersector:(OTSSegmentIntersector *)si;

- (void)addArray:(NSArray *)edges;
- (void)addArray:(NSArray *)edges edgeSet:(id)edgeSet;
- (void)add:(OTSEdge *)edge edgeSet:(id)edgeSet;
- (void)prepareEvents;
- (void)computeIntersections:(OTSSegmentIntersector *)si;
- (void)processOverlaps:(int)start 
					end:(int)end 
					ev0:(OTSSweepLineEvent *)ev0 
	 segmentIntersector:(OTSSegmentIntersector *)si;

@end
