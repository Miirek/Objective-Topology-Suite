//
//  OTSPointLocator.m
//

#import "OTSPointLocator.h"
#import "OTSCGAlgorithms.h"
#import "OTSGeometry.h"
#import "OTSLineString.h"
#import "OTSLinearRing.h"
#import "OTSMultiLineString.h"
#import "OTSPolygon.h"
#import "OTSMultiPolygon.h"
#import "OTSLocation.h"
#import "OTSGeometryGraph.h"

@implementation OTSPointLocator

@synthesize isIn;
@synthesize numBoundaries;

- (int)locate:(OTSCoordinate *)p relativeTo:(OTSGeometry *)geom {
	if ([geom isEmpty]) return kOTSLocationExterior;
	
	if ([geom isKindOfClass:[OTSLineString class]]) {
		OTSLineString *ls_geom = (OTSLineString *)geom;
		return [self locate:p relativeToLineString:ls_geom];
	}

	if ([geom isKindOfClass:[OTSPolygon class]]) {
		OTSPolygon *poly_geom = (OTSPolygon *)geom;
		return [self locate:p relativeToPolygon:poly_geom];
	}
	
	isIn = NO;
	numBoundaries = 0;
	[self computeLocation:p relativeTo:geom];
	if ([OTSGeometryGraph isInBoundary:numBoundaries]) return kOTSLocationBoundary;
	if (numBoundaries > 0 || isIn) return kOTSLocationInterior;
	return kOTSLocationExterior;	
}

- (BOOL)isPoint:(OTSCoordinate *)p intersectsGeometry:(OTSGeometry *)geom {
	return [self locate:p relativeTo:geom] != kOTSLocationExterior;
}

- (void)computeLocation:(OTSCoordinate *)p relativeTo:(OTSGeometry *)geom {
	
	if ([geom isKindOfClass:[OTSLineString class]]) {
		OTSLineString *ls = (OTSLineString *)geom;
		[self updateLocationInfo:[self locate:p relativeToLineString:ls]];
	} else if ([geom isKindOfClass:[OTSPolygon class]]) {
		OTSPolygon *poly = (OTSPolygon *)geom;
		[self updateLocationInfo:[self locate:p relativeToPolygon:poly]];
	} else if ([geom isKindOfClass:[OTSMultiLineString class]]) {
		OTSMultiLineString *mls = (OTSMultiLineString *)geom;
		for (int i = 0, n = [mls getNumGeometries]; i < n; ++i) {
			OTSLineString *ls = (OTSLineString *)[mls getGeometryN:i];
			[self updateLocationInfo:[self locate:p relativeToLineString:ls]];
		}
	} else if ([geom isKindOfClass:[OTSMultiPolygon class]]) {
		OTSMultiPolygon *mpo = (OTSMultiPolygon *)geom;
		for (int i = 0, n = [mpo getNumGeometries]; i < n; ++i) {
			OTSPolygon *poly = (OTSPolygon *)[mpo getGeometryN:i];
			[self updateLocationInfo:[self locate:p relativeToPolygon:poly]];
		}
	} else if ([geom isKindOfClass:[OTSGeometryCollection class]]) {
		OTSGeometryCollection *col = (OTSGeometryCollection *)geom;
		for (int i = 0, n = [col getNumGeometries]; i < n; ++i) {
			OTSGeometry *g2 = [col getGeometryN:i];
			[self computeLocation:p relativeTo:g2];
		}
	}
	
}

- (void)updateLocationInfo:(int)loc {
	if (loc == kOTSLocationInterior) isIn = YES;
	if (loc == kOTSLocationBoundary) ++numBoundaries;
}

- (int)locate:(OTSCoordinate *)p relativeToLineString:(OTSLineString *)l {
	OTSCoordinateSequence *pt = [l getCoordinatesRO];
	if (![l isClosed]) {
		if ([p isEqual2D:[pt getAt:0]] || [p isEqual2D:[pt getAt:[pt size] - 1]]) {
			return kOTSLocationBoundary;
		}
	}
	if ([OTSCGAlgorithms isPoint:p onLine:pt])
		return kOTSLocationInterior;
	return kOTSLocationExterior;
}

- (int)locate:(OTSCoordinate *)p inPolygonRing:(OTSLineString *)ring {
	// can this test be folded into isPointInRing ?
	
	OTSCoordinateSequence *cl = [ring getCoordinatesRO];
	
	if ([OTSCGAlgorithms isPoint:p onLine:cl]) 
		return kOTSLocationBoundary;
	if ([OTSCGAlgorithms isPoint:p inRing:cl])
		return kOTSLocationInterior;
	return kOTSLocationExterior;
	
}

- (int)locate:(OTSCoordinate *)p relativeToPolygon:(OTSPolygon *)poly {
	if ([poly isEmpty]) return kOTSLocationExterior;
	
	OTSLinearRing *shell = (OTSLinearRing *)[poly getExteriorRing];
	
	int shellLoc = [self locate:p inPolygonRing:shell];
	if (shellLoc == kOTSLocationExterior) return kOTSLocationExterior;
	if (shellLoc == kOTSLocationBoundary) return kOTSLocationBoundary;
	
	// now test if the point lies in or on the holes
	for (int i=0, n = [poly getNumInteriorRing]; i < n; ++i) {
		OTSLinearRing *hole = (OTSLinearRing *)[poly getInteriorRingN:i];
		int holeLoc = [self locate:p inPolygonRing:hole];
		if (holeLoc == kOTSLocationInterior) return kOTSLocationExterior;
		if (holeLoc == kOTSLocationBoundary) return kOTSLocationBoundary;
	}
	
	return kOTSLocationInterior;	
}

@end
