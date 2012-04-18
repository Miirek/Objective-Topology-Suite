//
//  OTSPointLocator.h
//

#import <Foundation/Foundation.h>

#import "OTSLocation.h" // for inlines

@class OTSCoordinate;
@class OTSGeometry;
@class OTSLinearRing;
@class OTSLineString;
@class OTSPolygon;

@interface OTSPointLocator : NSObject {
	BOOL isIn;         // true if the point lies in or on any Geometry element
	int numBoundaries;    // the number of sub-elements whose boundaries the point lies in
}

@property (nonatomic, assign) BOOL isIn;
@property (nonatomic, assign) int numBoundaries;

- (int)locate:(OTSCoordinate *)p relativeTo:(OTSGeometry *)geom;
- (BOOL)isPoint:(OTSCoordinate *)p intersectsGeometry:(OTSGeometry *)geom;
- (void)computeLocation:(OTSCoordinate *)p relativeTo:(OTSGeometry *)geom;
- (void)updateLocationInfo:(int)loc;
- (int)locate:(OTSCoordinate *)p relativeToLineString:(OTSLineString *)l;
- (int)locate:(OTSCoordinate *)p inPolygonRing:(OTSLineString *)l;
- (int)locate:(OTSCoordinate *)p relativeToPolygon:(OTSPolygon *)poly;

@end
