//
//  OTSMonotoneChainEdge.m
//


#import "OTSEdge.h"
#import "OTSMonotoneChainEdge.h"
#import "OTSMonotoneChainIndexer.h"
#import "OTSSegmentIntersector.h"
#import "OTSCoordinate.h"
#import "OTSCoordinateSequence.h"

@implementation OTSMonotoneChainEdge

@synthesize e;
@synthesize pts; 
@synthesize startIndex;
@synthesize env1;
@synthesize env2;

- (id)initWithEdge:(OTSEdge *)newE {
	if (self = [super init]) {
		self.e = newE;
		self.pts = [newE getCoordinates];
		
		OTSMonotoneChainIndexer *mcb = [[OTSMonotoneChainIndexer alloc] init];
		self.startIndex = [NSMutableArray array];
		[mcb getChainStartIndices:pts startIndexList:startIndex];
		[mcb release];
		
		env1 = [[OTSEnvelope alloc] init];
		env2 = [[OTSEnvelope alloc] init];
	}
	return self;
}

- (void)dealloc {
	[e release];
	[pts release];
	[startIndex release];
	[env1 release];
	[env2 release];
	[super dealloc];
}

- (double)minX:(int)chainIndex {
	double x1 = [pts getAt:[[startIndex objectAtIndex:chainIndex] intValue]].x;
	double x2 = [pts getAt:[[startIndex objectAtIndex:chainIndex+1] intValue]].x;
	return x1 < x2 ? x1 : x2;	
}

- (double)maxX:(int)chainIndex {
	double x1 = [pts getAt:[[startIndex objectAtIndex:chainIndex] intValue]].x;
	double x2 = [pts getAt:[[startIndex objectAtIndex:chainIndex+1] intValue]].x;
	return x1 > x2 ? x1 : x2;	
}

- (OTSCoordinateSequence *)getCoordinates {
	return pts;
}

- (NSMutableArray *)getStartIndexes {
	return startIndex;
}

- (void)computeIntersects:(OTSMonotoneChainEdge *)mce si:(OTSSegmentIntersector *)si {
	int I = [startIndex count] - 1;
	int J = [mce.startIndex count] - 1;
	for(int i = 0; i < I; ++i) {
		for(int j = 0; j < J; ++j) {
			[self computeIntersectsForChainWithChainIndex0:i mce:mce chainIndex1:j si:si];
		}
	}	
}

- (void)computeIntersectsForChainWithChainIndex0:(int)chainIndex0 mce:(OTSMonotoneChainEdge *)mce chainIndex1:(int)chainIndex1 si:(OTSSegmentIntersector *)si {
	[self computeIntersectsForChainWithStart0:[[startIndex objectAtIndex:chainIndex0] intValue]
										 end0:[[startIndex objectAtIndex:chainIndex0 + 1] intValue] 
										  mce:mce 
									   start1:[[mce.startIndex objectAtIndex:chainIndex1] intValue]
										 end1:[[mce.startIndex objectAtIndex:chainIndex1 + 1] intValue] 
										   si:si];
}

- (void)computeIntersectsForChainWithStart0:(int)start0 end0:(int)end0 mce:(OTSMonotoneChainEdge *)mce start1:(int)start1 end1:(int)end1 si:(OTSSegmentIntersector *)si {
	
	// terminating condition for the recursion
	if (end0 - start0 == 1 && end1 - start1 == 1) {
		[si addIntersections:e segIndex0:start0 e1:mce.e segIndex1:start1];
		return;
	}
	
	OTSCoordinate *p00 = [pts getAt:start0];
	OTSCoordinate *p01 = [pts getAt:end0];	
	OTSCoordinate *p10 = [mce.pts getAt:start1];
	OTSCoordinate *p11 = [mce.pts getAt:end1];
		
	// nothing to do if the envelopes of these chains don't overlap
	[env1 setWithFirstCoordinate:p00 secondCoordinate:p01];
	[env2 setWithFirstCoordinate:p10 secondCoordinate:p11];
	
	if (![env1 intersects:env2]) return;
	// the chains overlap, so split each in half and iterate 
	// (binary search)
	int mid0 = (start0 + end0)/2;
	int mid1 = (start1 + end1)/2;
	
	// Assert: mid != start or end
	// (since we checked above for end - start <= 1)
	// check terminating conditions before recursing
	if (start0 < mid0) {
		if (start1 < mid1)
			[self computeIntersectsForChainWithStart0:start0 end0:mid0 mce:mce start1:start1 end1:mid1 si:si];
		if (mid1 < end1)
			[self computeIntersectsForChainWithStart0:start0 end0:mid0 mce:mce start1:mid1 end1:end1 si:si];
	}
	if (mid0 < end0) {
		if (start1 < mid1)
			[self computeIntersectsForChainWithStart0:mid0 end0:end0 mce:mce start1:start1 end1:mid1 si:si];
		if (mid1 < end1)
			[self computeIntersectsForChainWithStart0:mid0 end0:end0 mce:mce start1:mid1 end1:end1 si:si];
	}
}


@end
