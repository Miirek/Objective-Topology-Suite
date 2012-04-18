//
//  OTSGeometrySnapper.h
//

#import <Foundation/Foundation.h>

#import "OTSCoordinate.h"

@class OTSGeometry;
@class OTSCoordinateSequence;

@interface OTSGeometrySnapper : NSObject {
	OTSGeometry *srcGeom;
}

@property (nonatomic, retain)OTSGeometry *srcGeom;

- (id)initWithGeometry:(OTSGeometry *)g;

/**
 * Snaps two geometries together with a given tolerance.
 *
 * @param g0 a geometry to snap
 * @param g1 a geometry to snap
 * @param snapTolerance the tolerance to use
 * @param ret0 the snapped geometry (first of a pair) (output parameter)
 * @param ret1 the snapped geometry (second of a pair) (output parameter) 
 *            
 */
+ (void)snapGeometry1:(OTSGeometry *)g0
            geometry2:(OTSGeometry *)g1
        snapTolerance:(double)snapTolerance
              result1:(OTSGeometry **)ret0
              result2:(OTSGeometry **)ret1;

- (OTSGeometry *)snapTo:(OTSGeometry *)g snapTolerance:(double)snapTolerance;

+ (double)computeOverlaySnapTolerance:(OTSGeometry *)g;
+ (double)computeSizeBasedSnapTolerance:(OTSGeometry *)g;
+ (double)computeOverlaySnapToleranceOfGeometry1:(OTSGeometry *)g1 
									   geometry2:(OTSGeometry *)g2;
- (NSArray *)extractTargetCoordinates:(OTSGeometry *)g;

@end
