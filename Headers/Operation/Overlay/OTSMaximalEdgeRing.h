//
//  OTSMaximalEdgeRing.h
//

#import <Foundation/Foundation.h>

#import "OTSEdgeRing.h" // for inheritance

@class OTSGeometryFactory;
@class OTSDirectedEdge;
@class OTSMinimalEdgeRing;

@interface OTSMaximalEdgeRing : OTSEdgeRing {
	
}

- (id)initWithEdgeEnd:(OTSDirectedEdge *)newStart geometryFactory:(OTSGeometryFactory *)newGeometryFactory;
- (NSArray *)buildMinimalRings;
- (void)buildMinimalRingsUsingMinimalEdgeRings:(NSMutableArray *)minEdgeRings;
- (void)linkDirectedEdgesForMinimalEdgeRings;

@end
