//
//  OTSEdgeSetIntersector.h
//

#import <Foundation/Foundation.h>

@class OTSEdge;
@class OTSSegmentIntersector;

@interface OTSEdgeSetIntersector : NSObject {

}

- (void)computeIntersections:(NSArray *)edges segmentIntersector:(OTSSegmentIntersector *)si testAllSegments:(BOOL)testAllSegments;
- (void)computeIntersections:(NSArray *)edges0 edges1:(NSArray *)edges1 segmentIntersector:(OTSSegmentIntersector *)si;

@end
