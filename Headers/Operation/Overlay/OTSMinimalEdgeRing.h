//
//  OTSMinimalEdgeRing.h
//

#import <Foundation/Foundation.h>

#import "OTSEdgeRing.h" // for inheritance
#import "OTSDirectedEdge.h" // for inlines

@class OTSGeometryFactory;
@class OTSDirectedEdge;
@class OTSEdgeRing;

@interface OTSMinimalEdgeRing : OTSEdgeRing {

}

- (id)initWithEdgeEnd:(OTSDirectedEdge *)newStart geometryFactory:(OTSGeometryFactory *)newGeometryFactory;

@end
