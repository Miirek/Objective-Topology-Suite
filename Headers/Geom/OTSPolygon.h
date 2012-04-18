//
//  OTSPolygon.h
//

#import <Foundation/Foundation.h>

#import "OTSGeometry.h"
#import "OTSEnvelope.h" 
#import "OTSDimension.h" 

@class OTSCoordinate;
//@class OTSCoordinateSequenceFilter;
@class OTSLinearRing;
@class OTSLineString;

@interface OTSPolygon : OTSGeometry {
	OTSLinearRing *shell;
	NSArray *holes;
}

@property (nonatomic, retain) OTSLinearRing *shell;
@property (nonatomic, retain) NSArray *holes;

- (id)initWithPolygon:(OTSPolygon *)p;
- (id)initWithShell:(OTSLinearRing *)newShell holes:(NSArray *)newHoles factory:(OTSGeometryFactory *)newFactory;

- (OTSLineString *)getExteriorRing;
- (int)getNumInteriorRing;
- (OTSLineString *)getInteriorRingN:(int)n;

@end
