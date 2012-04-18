//
//  OTSRectangleIntersects.h
//

#import <Foundation/Foundation.h>

#import "OTSPolygon.h" // for inlines

@class OTSEnvelope;

@interface OTSRectangleIntersects : NSObject {
	OTSPolygon *rectangle;
	OTSEnvelope *rectEnv;	
}

@property (nonatomic, retain) OTSPolygon *rectangle;
@property (nonatomic, retain) OTSEnvelope *rectEnv;

- (id)initWithPolygon:(OTSPolygon *)newRect;
- (BOOL)intersects:(OTSGeometry *)geom;
+ (BOOL)rectangle:(OTSPolygon *)rectangle intersects:(OTSGeometry *)b;

@end
