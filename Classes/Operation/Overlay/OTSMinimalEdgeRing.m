//
//  OTSMinimalEdgeRing.m
//

#import "OTSMinimalEdgeRing.h"
#import "OTSEdgeRing.h"


@implementation OTSMinimalEdgeRing

- (id)initWithEdgeEnd:(OTSDirectedEdge *)newStart geometryFactory:(OTSGeometryFactory *)newGeometryFactory {
	if (self = [super initWithEdgeEnd:newStart geometryFactory:newGeometryFactory]) {
		[self computePoints:newStart];
		[self computeRing];
	}
	return self;
	
}

- (OTSDirectedEdge *)getNext:(OTSDirectedEdge *)de {
	return de.nextMin;
}

- (void)setEdgeRing:(OTSDirectedEdge *)de edgeRing:(OTSEdgeRing *)er {
	de.minEdgeRing = er;
}

@end
