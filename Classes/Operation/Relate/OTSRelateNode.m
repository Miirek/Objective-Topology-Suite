//
//  OTSRelateNode.m
//

#import "OTSRelateNode.h"
#import "OTSEdgeEndBundleStar.h"
#import "OTSIntersectionMatrix.h"
#import "OTSLabel.h"
#import "OTSNode.h"

@implementation OTSRelateNode

- (id)initWithCoordinate:(OTSCoordinate *)newCoord edges:(OTSEdgeEndStar *)newEdges {
	if (self = [super initWithCoordinate:newCoord edges:newEdges]) {
	}
	return self;
}

- (void)updateIMFromEdges:(OTSIntersectionMatrix *)im {
	OTSEdgeEndBundleStar *eebs = (OTSEdgeEndBundleStar *)edges;
	[eebs updateIM:im];
}

- (void)computeIM:(OTSIntersectionMatrix *)im {
	[im setAtLeastIfValidRow:[label locationAtGeometryIndex:0] 
					  column:[label locationAtGeometryIndex:1] 
			  dimensionValue:0];
}

@end
