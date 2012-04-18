//
//  OTSMultiPoint.h
//

#import <Foundation/Foundation.h>

#import "OTSGeometryCollection.h"
#import "OTSDimension.h" // for Dimension::DimensionType

@class OTSCoordinate;

@interface OTSMultiPoint : OTSGeometryCollection {

}

- (id)initWithMultiPoint:(OTSMultiPoint *)mp;
- (id)initWithArray:(NSArray *)_geometries factory:(OTSGeometryFactory *)newFactory;

@end
