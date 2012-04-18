//
//  OTSSimplePointInAreaLocator.m
//

#import "OTSCGAlgorithms.h"
#import "OTSSimplePointInAreaLocator.h"
#import "OTSGeometry.h"
#import "OTSPolygon.h"
#import "OTSGeometryCollection.h"
#import "OTSLocation.h"
#import "OTSCoordinateSequence.h"
#import "OTSLineString.h"

@implementation OTSSimplePointInAreaLocator

@synthesize g;

- (id)initWithGeometry:(OTSGeometry *)_g {
	if (self = [super init]) {
		self.g = _g;
	}
	return self;
}

- (void)dealloc {
	[g release];
	[super dealloc];
}

+ (int)locate:(OTSCoordinate *)p geom:(OTSGeometry *)geom {
	if ([geom isEmpty]) return kOTSLocationExterior;
	if ([OTSSimplePointInAreaLocator containsPoint:p geom:geom])
		return kOTSLocationInterior;
	return kOTSLocationExterior;	
}

+ (BOOL)containsPoint:(OTSCoordinate *)p inPolygon:(OTSPolygon *)poly {
	
	if ([poly isEmpty]) return NO;
	
	OTSLineString *shell = [poly getExteriorRing];
	OTSCoordinateSequence *cl = [shell getCoordinatesRO];
	
	if (![OTSCGAlgorithms isPoint:p inRing:cl]) {
		return NO;
	}
	
	for (int i = 0, n = [poly getNumInteriorRing]; i < n; i++) {
		OTSLineString *hole = [poly getInteriorRingN:i];
		cl = [hole getCoordinatesRO];
		if ([OTSCGAlgorithms isPoint:p inRing:cl]) {
			return NO;
		}
	}		
	return YES;
}

- (int)locate:(OTSCoordinate *)p {
	return [OTSSimplePointInAreaLocator locate:p geom:g];
}

+ (BOOL)containsPoint:(OTSCoordinate *)p geom:(OTSGeometry *)geom {
	
	if ([geom isKindOfClass:[OTSPolygon class]]) {
		return [OTSSimplePointInAreaLocator containsPoint:p inPolygon:(OTSPolygon *)geom];
	}

	if ([geom isKindOfClass:[OTSGeometryCollection class]]) {
		OTSGeometryCollection *col = (OTSGeometryCollection *)geom;
		for (int i = 0; i < [col getNumGeometries]; i++) {
			OTSGeometry *g2 = [col getGeometryN:i];
			if ([OTSSimplePointInAreaLocator containsPoint:p geom:g2]) {
				return YES;
			}
		}
	}	
	return NO;
	
}

@end
