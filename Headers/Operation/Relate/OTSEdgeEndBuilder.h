//
//  OTSEdgeEndBuilder.h
//

#import <Foundation/Foundation.h>

@class OTSIntersectionMatrix;
@class OTSCoordinate;
@class OTSEdge;
@class OTSEdgeIntersection;
@class OTSEdgeEnd;

@interface OTSEdgeEndBuilder : NSObject {
	
}

- (NSArray *)computeEdgeEnds:(NSArray *)edges;
- (void)computeEdgeEnds:(NSMutableArray *)l edge:(OTSEdge *)edge;

- (void)createEdgeEnd:(NSMutableArray *)l 
				 edge:(OTSEdge *)edge 
  currentIntersection:(OTSEdgeIntersection *)eiCurr 
  forPrevIntersection:(OTSEdgeIntersection *)eiPrev;
- (void)createEdgeEnd:(NSMutableArray *)l 
				 edge:(OTSEdge *)edge 
  currentIntersection:(OTSEdgeIntersection *)eiCurr 
  forNextIntersection:(OTSEdgeIntersection *)eiNext;

@end
