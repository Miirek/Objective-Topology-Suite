//
//  OTSSimplePointInAreaLocator.h
//

#import <Foundation/Foundation.h>

#import "OTSPointOnGeometryLocator.h"

@class OTSGeometry;
@class OTSCoordinate;
@class OTSPolygon;

@interface OTSSimplePointInAreaLocator : OTSPointOnGeometryLocator {
	OTSGeometry *g;
}

@property (nonatomic, retain) OTSGeometry *g;

- (id)initWithGeometry:(OTSGeometry *)_g;

+ (int)locate:(OTSCoordinate *)p geom:(OTSGeometry *)geom;
+ (BOOL)containsPoint:(OTSCoordinate *)p inPolygon:(OTSPolygon *)poly;
+ (BOOL)containsPoint:(OTSCoordinate *)p geom:(OTSGeometry *)geom;

@end
