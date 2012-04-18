//
//  OTSLinearRing.h
//

#import <Foundation/Foundation.h>

#import "OTSLineString.h"

@class OTSCoordinate;

@interface OTSLinearRing : OTSLineString {

}

- (id)initWithLinearRing:(OTSLinearRing *)lr;
- (id)initWithCoordinateSequence:(OTSCoordinateSequence *)pts factory:(OTSGeometryFactory *)newFactory;

@end
