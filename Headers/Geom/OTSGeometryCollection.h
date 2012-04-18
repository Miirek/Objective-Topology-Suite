//
//  OTSGeometryCollection.h
//

#import <Foundation/Foundation.h>

#import "OTSGeometry.h" // for inheritance
#import "OTSEnvelope.h" // for proper use of auto_ptr<>
#import "OTSDimension.h" // for Dimension::DimensionType

@class OTSCoordinate;
//@class OTSCoordinateSequenceFilter;

@interface OTSGeometryCollection : OTSGeometry {
	NSMutableArray *geometries;
}

@property (nonatomic, retain)NSMutableArray *geometries;

- (id)initWithGeometryCollection:(OTSGeometryCollection *)gc;
- (id)initWithArray:(NSArray *)_geometries factory:(OTSGeometryFactory *)newFactory;

@end
