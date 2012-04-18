//
//  OTSGeometry.h
//

#import <Foundation/Foundation.h>

#import "OTSEnvelope.h"
#import "OTSDimension.h" // for Dimension::DimensionType
#import "OTSGeometryComponentFilter.h" // for inheritance

@class OTSCoordinate;
@class OTSCoordinateFilter;
@class OTSCoordinateSequence;
//@class OTSCoordinateSequenceFilter;
@class OTSGeometryComponentFilter;
@class OTSGeometryFactory;
@class OTSGeometryFilter;
@class OTSIntersectionMatrix;
@class OTSPrecisionModel;
@class OTSPoint;

//@class OTSUnload;

@class OTSGeometryFactory;

/// Geometry types
typedef enum {
	/// undefined
	kOTSGeometryNull = -1,
	/// a point
	kOTSGeometryPoint,
	/// a linestring
	kOTSGeometryLineString,
	/// a linear ring (linestring with 1st point == last point)
	kOTSGeometryLinearRing,
	/// a polygon
	kOTSGeometryPolygon,
	/// a collection of points
	kOTSGeometryMultiPoint,
	/// a collection of linestrings
	kOTSGeometryMultiLineString,
	/// a collection of polygons
	kOTSGeometryMultiPolygon,
	/// a collection of heterogeneus geometries
	kOTSGeometryCollection
} OTSGeometryTypeId;

@interface OTSGeometry : NSObject {
	OTSPrecisionModel *precisionModel;
	OTSGeometryFactory *factory;
	OTSEnvelope *envelope;
	int SRID;
}

@property (nonatomic, retain) OTSPrecisionModel *precisionModel;
@property (nonatomic, retain) OTSGeometryFactory *factory;
@property (nonatomic, assign) int SRID;

- (id)initWithFactory:(OTSGeometryFactory *)_factory;

// abstracts

- (OTSGeometry *)clone;
- (BOOL)isEmpty;
- (BOOL)isRectangle;
- (OTSEnvelope *)computeEnvelopeInternal;
- (OTSCoordinate *)getCoordinate;
- (OTSCoordinateSequence *)getCoordinates;
- (int)getNumPoints;
- (int)getNumGeometries;
- (OTSGeometry *)getGeometryN:(int)n;
- (OTSGeometryTypeId)getGeometryTypeId;
- (OTSDimensionType)getDimension;
- (int)getBoundaryDimension;
- (void)apply_rwCoordinateFilter:(OTSCoordinateFilter *)filter;
- (void)apply_roCoordinateFilter:(OTSCoordinateFilter *)filter;

// geometry operations

- (OTSIntersectionMatrix *)relate:(OTSGeometry *)other;
- (BOOL)disjoint:(OTSGeometry *)other;
- (BOOL)touches:(OTSGeometry *)other;
- (BOOL)intersects:(OTSGeometry *)other;
- (BOOL)covers:(OTSGeometry *)other;
- (BOOL)crosses:(OTSGeometry *)other;
- (BOOL)within:(OTSGeometry *)other;
- (BOOL)contains:(OTSGeometry *)other;
- (BOOL)overlaps:(OTSGeometry *)other;
- (OTSGeometry *)intersection:(OTSGeometry *)other;

- (OTSEnvelope *)getEnvelopeInternal;
- (void)geometryChanged;
- (void)geometryChangedAction;
- (BOOL)hasNonEmptyElements:(NSArray *)geometries;
- (BOOL)hasNullElements:(NSArray *)list;

- (void)apply_rwGeometryComponentFilter:(OTSGeometryComponentFilter *)filter;
- (void)apply_roGeometryComponentFilter:(OTSGeometryComponentFilter *)filter;

- (void)applyGeometryFilterReadWrite:(OTSGeometryFilter *)filter;
- (void)applyGeometryFilterReadOnly:(OTSGeometryFilter *)filter;

@end
