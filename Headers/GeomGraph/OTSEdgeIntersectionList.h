//
//  OTSEdgeIntersectionList.h
//

#import <Foundation/Foundation.h>

#import "OTSEdgeIntersection.h" // for EdgeIntersectionLessThen
#import "OTSCoordinate.h" // for CoordinateLessThen

@class OTSCoordinate;
@class OTSEdge;

@interface OTSEdgeIntersectionList : NSObject {
	NSMutableArray *nodeMap;
	OTSEdge *edge;
}

@property (nonatomic, retain) NSMutableArray *nodeMap;
@property (nonatomic, retain) OTSEdge *edge;

- (id)initWithEdge:(OTSEdge *)_edge;

- (OTSEdgeIntersection *)add:(OTSCoordinate *)coord segmentIndex:(int)segmentIndex distance:(double)dist;
- (BOOL)isEmpty;
- (BOOL)isIntersection:(OTSCoordinate *)pt;
- (void)addEndpoints;
- (void)addSplitEdges:(NSMutableArray *)edgeList;
- (OTSEdge *)createSplitEdge:(OTSEdgeIntersection *)ei0 ei1:(OTSEdgeIntersection *)ei1;

@end
