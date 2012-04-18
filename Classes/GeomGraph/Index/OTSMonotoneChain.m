//
//  OTSMonotoneChain.m
//

#import "OTSMonotoneChain.h"

@implementation OTSMonotoneChain

@synthesize mce;
@synthesize chainIndex;

- (id)initWithChainEdge:(OTSMonotoneChainEdge *)newMce chainIndex:(int)newChainIndex {
	if (self = [super init]) {
		self.mce = newMce;
		chainIndex = newChainIndex;
	}
	return self;
}

- (void)dealloc {
	[mce release];
	[super dealloc];
}

- (void)computeIntersections:(OTSMonotoneChain *)mc segmentIntersector:(OTSSegmentIntersector *)si {
	[mce computeIntersectsForChainWithChainIndex0:chainIndex mce:mc.mce chainIndex1:mc.chainIndex si:si];
}

@end
