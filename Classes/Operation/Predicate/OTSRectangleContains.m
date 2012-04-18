//
//  OTSRectangleContains.m
//

#import "OTSRectangleContains.h"
#import "OTSGeometry.h"
#import "OTSEnvelope.h"
#import "OTSPoint.h"
#import "OTSPolygon.h"
#import "OTSLineString.h"
#import "OTSCoordinate.h"
#import "OTSCoordinateSequence.h"

@implementation OTSRectangleContains

@synthesize rectangle;
@synthesize rectEnv;

- (id)initWithRectangle:(OTSPolygon *)rect {
	if (self = [super init]) {
		self.rectangle = rect;
		self.rectEnv = [rect getEnvelopeInternal];
	}
	return self;
}

- (void)dealloc {
	[rectangle release];
	[rectEnv release];
	[super dealloc];
}

- (BOOL)isContainedInBoundary:(OTSGeometry *)geom {
	// polygons can never be wholely contained in the boundary
	if ([geom isKindOfClass:[OTSPolygon class]]) return NO;
	if ([geom isKindOfClass:[OTSPoint class]])
		return [self isPointContainedInBoundary:(OTSPoint *)geom];
	if ([geom isKindOfClass:[OTSLineString class]])
		return [self isLineStringContainedInBoundary:(OTSLineString *)geom];
	
	for (int i = 0, n = [geom getNumGeometries]; i < n; i++) {
		OTSGeometry *comp = [geom getGeometryN:i];		
		if (![self isContainedInBoundary:comp]) 
			return NO;
	}
	
	return YES;
}

- (BOOL)isPointContainedInBoundary:(OTSPoint *)geom {
	return [self isCoordinateContainedInBoundary:[geom getCoordinate]];
}

- (BOOL)isCoordinateContainedInBoundary:(OTSCoordinate *)pt {
	/**
	 * contains = false iff the point is properly contained
	 * in the rectangle.
	 *
	 * This code assumes that the point lies in the rectangle envelope
	 */
	return pt.x == rectEnv.minx || pt.x == rectEnv.maxx || pt.y == rectEnv.miny || pt.y == rectEnv.maxy;
}

- (BOOL)isLineStringContainedInBoundary:(OTSLineString *)line {
	OTSCoordinateSequence *seq = [line getCoordinatesRO];	
	for (int i=0, n = [seq size] - 1; i < n; ++i) {
		OTSCoordinate *p0 = [seq getAt:i];
		OTSCoordinate *p1 = [seq getAt:i+1];
		if (![self isLineSegmentContainedInBoundaryFrom:p0 to:p1])
			return NO;
	}
	return YES;
}

- (BOOL)isLineSegmentContainedInBoundaryFrom:(OTSCoordinate *)p0 to:(OTSCoordinate *)p1 {
	if ([p0 isEqual2D:p1])
		return [self isCoordinateContainedInBoundary:p0];
	
	// we already know that the segment is contained in
	// the rectangle envelope
	if (p0.x == p1.x) {
		if (p0.x == rectEnv.minx ||
			p0.x == rectEnv.maxx) {
			return YES;
		}
	} else if (p0.y == p1.y) {
		if (p0.y == rectEnv.miny ||
			p0.y == rectEnv.maxy) {
			return YES;
		}
	}
	
	/**
	 * Either
	 *   both x and y values are different
	 * or
	 *   one of x and y are the same, but the other ordinate
	 *   is not the same as a boundary ordinate
	 *
	 * In either case, the segment is not wholely in the boundary
	 */
	return NO;
}

- (BOOL)contains:(OTSGeometry *)geom {
	if (![rectEnv contains:[geom getEnvelopeInternal]])
		return NO;
	
	// check that geom is not contained entirely in the rectangle boundary
	if ([self isContainedInBoundary:geom])
		return NO;
	
	return YES;
	
}

+ (BOOL)isRectangle:(OTSPolygon *)rect contains:(OTSGeometry *)b {
	OTSRectangleContains *rc = [[OTSRectangleContains alloc] initWithRectangle:rect];
	BOOL ret = [rc contains:b];
	[rc release];
	return ret;
}

@end
