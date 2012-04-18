//
//  OTSPoint.h
//

#import <Foundation/Foundation.h>

#import "OTSGeometry.h"
#import "OTSCoordinateSequence.h" // for proper use of auto_ptr<>
#import "OTSEnvelope.h" // for proper use of auto_ptr<>
#import "OTSDimension.h" // for Dimension::DimensionType

@class OTSCoordinate;
@class OTSCoordinateFilter;
//@class OTSCoordinateSequenceFilter;
@class OTSGeometryComponentFilter;
//@class OTSGeometryFilter;

@interface OTSPoint : OTSGeometry {
	OTSCoordinateSequence *coordinates;
}

@property (nonatomic, retain) OTSCoordinateSequence *coordinates;

- (id)initWithPoint:(OTSPoint *)pt;
- (id)initWithCoordinateSequence:(OTSCoordinateSequence *)pts factory:(OTSGeometryFactory *)newFactory;

- (double)getX;
- (double)getY;

@end
