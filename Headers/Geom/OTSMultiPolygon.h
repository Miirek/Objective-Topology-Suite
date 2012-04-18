//
//  OTSMultiPolygon.h
//

#import <Foundation/Foundation.h>

#import "OTSGeometryCollection.h"
#import "OTSDimension.h" // for Dimension::DimensionType

@class OTSCoordinate;

@interface OTSMultiPolygon : OTSGeometryCollection {

}

- (id)initWithMultiPolygon:(OTSMultiPolygon *)mp;
- (id)initWithArray:(NSArray *)_geometries factory:(OTSGeometryFactory *)newFactory;

@end
