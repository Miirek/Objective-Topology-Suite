//
//  OTSRectangleContains.h
//

#import <Foundation/Foundation.h>

#import "OTSPolygon.h" // for inlines

@class OTSEnvelope;
@class OTSGeometry;
@class OTSPoint;
@class OTSCoordinate;
@class OTSLineString;

@interface OTSRectangleContains : NSObject {
	OTSPolygon *rectangle;
	OTSEnvelope *rectEnv;
}

@property (nonatomic, retain) OTSPolygon *rectangle;
@property (nonatomic, retain) OTSEnvelope *rectEnv;

- (id)initWithRectangle:(OTSPolygon *)rect;
- (BOOL)isContainedInBoundary:(OTSGeometry *)geom;
- (BOOL)isPointContainedInBoundary:(OTSPoint *)geom;
- (BOOL)isCoordinateContainedInBoundary:(OTSCoordinate *)pt;
- (BOOL)isLineStringContainedInBoundary:(OTSLineString *)line;
- (BOOL)isLineSegmentContainedInBoundaryFrom:(OTSCoordinate *)p0 to:(OTSCoordinate *)p1;
- (BOOL)contains:(OTSGeometry *)geom;

+ (BOOL)isRectangle:(OTSPolygon *)rect contains:(OTSGeometry *)b;

@end
