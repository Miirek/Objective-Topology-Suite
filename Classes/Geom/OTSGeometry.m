//
//  OTSGeometry.m
//

#import "OTSPrecisionModel.h"
#import "OTSCoordinate.h"
#import "OTSCoordinateSequence.h"
#import "OTSLineIntersector.h"
#import "OTSGeometryFilter.h"
#import "OTSGeometry.h"
#import "OTSIntersectionMatrix.h"
#import "OTSRectangleContains.h"
#import "OTSRectangleIntersects.h"
#import "OTSPlanarGraph.h"
#import "OTSGeometryGraphOperation.h"
#import "OTSOverlayOp.h"
#import "OTSRelateOp.h"
#import "OTSSnapIfNeededOverlayOp.h"
#import "OTSGeometryCollection.h"
#import "OTSGeometryFactory.h"

@interface OTSGeometryChangedFilter : OTSGeometryComponentFilter {
}
@end

@implementation OTSGeometry

@synthesize precisionModel, factory, SRID;

- (id)initWithFactory:(OTSGeometryFactory *)_factory {
	if (self = [super init]) {
		if (factory == nil) {
			self.factory = [OTSGeometryFactory getDefaultInstance];
		} else {
			self.factory = _factory;
		}
		self.precisionModel = factory.precisionModel;
		SRID = factory.SRID;
	}
	return self;
}

- (void)dealloc {
	[precisionModel release];
	[factory release];
	[envelope release];
	[super dealloc];
}

- (BOOL)isEmpty {
	// abstract
	return YES;
}

- (BOOL)isNull {
	return ([self getGeometryTypeId] == kOTSGeometryNull);
}

- (BOOL)isRectangle { 
	// abstract
	return NO; 
}

- (OTSGeometry *)clone {
	// abstract
	return nil;
}

- (OTSIntersectionMatrix *)relate:(OTSGeometry *)other {
	return [OTSRelateOp relateGeometry:self andGeometry:other];
}

- (BOOL)disjoint:(OTSGeometry *)other {
	// short-circuit test
	/*
	if (![[self getEnvelopeInternal] intersects:[other getEnvelopeInternal]])
		return YES;
	OTSIntersectionMatrix *im = [self relate:other];
	return [im isDisjoint];
	 */
	return ![self intersects:other];
}

- (BOOL)touches:(OTSGeometry *)other {
	// short-circuit test
	if (![[self getEnvelopeInternal] intersects:[other getEnvelopeInternal]])
		return NO;
	OTSIntersectionMatrix *im = [self relate:other];
	return [im isTouchesDimensionOfGeometryA:[self getDimension] dimensionOfGeometryB:[other getDimension]];
}

- (BOOL)intersects:(OTSGeometry *)other {
	
	// short-circuit test
	if (![[self getEnvelopeInternal] intersects:[other getEnvelopeInternal]])
		return NO;
	
	// optimization for rectangle arguments
	if ([self isRectangle]) {
		return [OTSRectangleIntersects rectangle:(OTSPolygon *)self intersects:other];
	}
	if ([other isRectangle]) {
		return [OTSRectangleIntersects rectangle:(OTSPolygon *)other intersects:self];
	}
	
	OTSIntersectionMatrix *im = [self relate:other];
	return [im isIntersects];
}

- (OTSGeometry *)intersection:(OTSGeometry *)other {
	if ([self isEmpty] || [other isEmpty]) {
		return [factory createGeometryCollection];
	}
	return [OTSSnapIfNeededOverlayOp overlayOpFirstGeometry:self 
											 andSecondGeometry:other 
														withOp:kOTSOverlayIntersection];
}

- (BOOL)covers:(OTSGeometry *)other {
	// short-circuit test
	if (![[self getEnvelopeInternal] covers:[other getEnvelopeInternal]])
		return NO;
	// optimization for rectangle arguments
	if ([self isRectangle]) {
		// since we have already tested that the test envelope
		// is covered
		return YES;
	}
	OTSIntersectionMatrix *im = [self relate:other];
	return [im isCovers];
}	

- (BOOL)crosses:(OTSGeometry *)other {
	// short-circuit test
	if (![[self getEnvelopeInternal] intersects:[other getEnvelopeInternal]])
		return NO;
	OTSIntersectionMatrix *im = [self relate:other];
	return [im isCrossesDimensionOfGeometryA:[self getDimension] dimensionOfGeometryB:[other getDimension]];
}

- (BOOL)within:(OTSGeometry *)other {
	return [other contains:self];
}

- (BOOL)contains:(OTSGeometry *)other {
	// short-circuit test
	if (![[self getEnvelopeInternal] contains:[other getEnvelopeInternal]])
		return NO;
	
	// optimization for rectangle arguments
	if ([self isRectangle]) {
		return [OTSRectangleContains isRectangle:(OTSPolygon *)self contains:other];
	}
	
	OTSIntersectionMatrix *im = [self relate:other];
	return [im isContains];
}

- (BOOL)overlaps:(OTSGeometry *)other {
	// short-circuit test
	if (![[self getEnvelopeInternal] intersects:[other getEnvelopeInternal]])
		return NO;
	OTSIntersectionMatrix *im = [self relate:other];
	return [im isOverlapsDimensionOfGeometryA:[self getDimension] dimensionOfGeometryB:[other getDimension]];
}

- (OTSEnvelope *)getEnvelopeInternal {
	if (envelope == nil) {
		envelope = [[self computeEnvelopeInternal] retain];
	}
	return envelope;
}

- (OTSEnvelope *)computeEnvelopeInternal {
	// abstract
	return nil;
}

- (OTSCoordinate *)getCoordinate {
	// abstract
	return nil;
}

- (OTSCoordinateSequence *)getCoordinates {
	// abstract
	return nil;
}

- (int)getNumPoints {
	// abstract
	return 0;
}

- (int)getNumGeometries {
	return 1;
}

- (OTSGeometry *)getGeometryN:(int)n {
	return self;
}

- (OTSGeometryTypeId)getGeometryTypeId {
	return kOTSGeometryNull;
}

- (void)geometryChanged {
	// originally use OTSGeometryChangedFilter, but here call changedAction directly
	[self geometryChangedAction];
}

- (void)geometryChangedAction {
	if (envelope != nil) {
		[envelope release];
		envelope = nil;
	}
}

- (void)apply_rwCoordinateFilter:(OTSCoordinateFilter *)filter {
	// abstract
}

- (void)apply_roCoordinateFilter:(OTSCoordinateFilter *)filter {
	// abstract
}

- (OTSDimensionType)getDimension {
	return kOTSDimensionDontCare;
}

- (int)getBoundaryDimension {
	return kOTSDimensionDontCare;
}

- (void)apply_rwGeometryComponentFilter:(OTSGeometryComponentFilter *)filter {
	[filter filter_rw:self];
}

- (void)apply_roGeometryComponentFilter:(OTSGeometryComponentFilter *)filter {
	[filter filter_ro:self];
}

- (void)applyGeometryFilterReadWrite:(OTSGeometryFilter *)filter {
	[filter filterReadWrite:self];
}

- (void)applyGeometryFilterReadOnly:(OTSGeometryFilter *)filter {
	[filter filterReadOnly:self];
}

- (BOOL)hasNonEmptyElements:(NSArray *)geometries {
	for (OTSGeometry *g in geometries) {
		if ([g isEmpty]) return YES;
	}
	return NO;
}

- (BOOL)hasNullElements:(NSArray *)list {
	int npts = [list count];
	for (int i = 0; i < npts; ++i) {
		if ([[list objectAtIndex:i] isNull]) {
			return YES;
		}
	}
	return NO;
}

@end

@implementation OTSGeometryChangedFilter

- (void)filter_rw:(OTSGeometry *)geom {
	[geom geometryChangedAction];
}

@end