//
//  OTSLineString.h
//

#import <Foundation/Foundation.h>

#import "OTSGeometry.h" // for inheritance
#import "OTSCoordinateSequence.h" // for proper use of auto_ptr<>
#import "OTSEnvelope.h" // for proper use of auto_ptr<>
#import "OTSDimension.h" // for Dimension::DimensionType

@class OTSCoordinate;
//@class OTSCoordinateSequenceFilter;

@interface OTSLineString : OTSGeometry <NSCopying> {
	OTSCoordinateSequence *points;
}

@property (nonatomic, retain) OTSCoordinateSequence *points;

- (id)initWithLineString:(OTSLineString *)ls;
- (id)initWithCoordinateSequence:(OTSCoordinateSequence *)pts factory:(OTSGeometryFactory *)newFactory;
- (OTSCoordinateSequence *)getCoordinatesRO;
- (OTSCoordinate *)getCoordinateN:(int)n;
- (BOOL)isClosed;

+ (id)lineStringWithFactory:(OTSGeometryFactory *)newFactory coordinates:(OTSCoordinate *)firstObject, ...;

@end
