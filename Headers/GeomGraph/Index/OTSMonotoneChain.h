//
//  OTSMonotoneChain.h
//

#import <Foundation/Foundation.h>

#import "OTSSweepLineEventOBJ.h" // for inheritance
#import "OTSMonotoneChainEdge.h" // for inline

@class OTSEdge;
@class OTSSegmentIntersector;

@interface OTSMonotoneChain : OTSSweepLineEventOBJ {
	OTSMonotoneChainEdge *mce;
	int chainIndex;
}

@property (nonatomic, retain) OTSMonotoneChainEdge *mce;
@property (nonatomic, assign) int chainIndex;

- (id)initWithChainEdge:(OTSMonotoneChainEdge *)newMce chainIndex:(int)newChainIndex;
- (void)computeIntersections:(OTSMonotoneChain *)mc segmentIntersector:(OTSSegmentIntersector *)si;

@end
