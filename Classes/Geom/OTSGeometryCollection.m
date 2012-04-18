//
//  OTSGeometryCollection.m
//

#import "OTSGeometryCollection.h"
#import "OTSCGAlgorithms.h"
#import "OTSCoordinateSequence.h"
//#import "OTSCoordinateSequenceFilter.h"
#import "OTSCoordinateSequenceFactory.h"
#import "OTSDimension.h"
//#import "OTSGeometryFilter.h"
#import "OTSGeometryComponentFilter.h"
#import "OTSEnvelope.h"

@implementation OTSGeometryCollection

@synthesize geometries;

- (id)initWithGeometryCollection:(OTSGeometryCollection *)gc {
	if (self = [super initWithFactory:gc.factory]) {
		geometries = [[NSMutableArray alloc] initWithArray:gc.geometries];
	}
	return self;
}

- (id)initWithArray:(NSArray *)_geometries factory:(OTSGeometryFactory *)newFactory {
	if (self = [super initWithFactory:newFactory]) {
		if (_geometries == nil) {
			geometries = [[NSMutableArray alloc] init];
		} else {
			geometries = [[NSMutableArray alloc] initWithArray:_geometries];
		}
	}
	return self;
}

- (void)dealloc {
	[geometries release];
	[super dealloc];
}

- (int)getNumGeometries {
	return [geometries count];
}

- (OTSGeometry *)getGeometryN:(int)n {
	return [geometries objectAtIndex:n];
}

- (OTSGeometry *)clone {
	return [[[OTSGeometryCollection alloc] initWithGeometryCollection:self] autorelease];
}

- (BOOL)isEmpty {
	for (OTSGeometry *g in geometries) {
		if (![g isEmpty]) {
			return NO;
		}
	}
	return YES;
}

- (OTSEnvelope *)computeEnvelopeInternal {
	OTSEnvelope *_envelope = [[OTSEnvelope alloc] init];
	for (OTSGeometry *g in geometries) {
		[_envelope expandToInclude:[g getEnvelopeInternal]];
	}
	return [_envelope autorelease];
}

- (OTSCoordinate *)getCoordinate {
	if ([self isEmpty]) return [[[OTSCoordinate alloc] init] autorelease];
	OTSGeometry *g = [geometries objectAtIndex:0];
	return [g getCoordinate];
}

- (OTSCoordinateSequence *)getCoordinates {
	
	NSMutableArray *coordinates = [NSMutableArray array];
	
	for (OTSGeometry *g in geometries) {
		OTSCoordinateSequence *childCoordinates = [g getCoordinates];
		for (OTSCoordinate *c in childCoordinates.coordinates) {
			[coordinates addObject:c];
		}
	}
	return [[OTSCoordinateSequenceFactory instance] createWithArray:coordinates];
	
}

- (int)getNumPoints {
	int numPoints = 0;
	for (OTSGeometry *g in geometries) {
		numPoints += [g getNumPoints];
	}
	return numPoints;	
}

- (OTSGeometryTypeId)getGeometryTypeId {
	return kOTSGeometryCollection;
}

- (void)apply_rwCoordinateFilter:(OTSCoordinateFilter *)filter {
	for (OTSGeometry *g in geometries) {
		[g apply_rwCoordinateFilter:filter];
	}
}

- (void)apply_roCoordinateFilter:(OTSCoordinateFilter *)filter {
	for (OTSGeometry *g in geometries) {
		[g apply_roCoordinateFilter:filter];
	}
}

- (void)apply_rwGeometryComponentFilter:(OTSGeometryComponentFilter *)filter {
	[filter filter_rw:self];
	for (OTSGeometry *g in geometries) {
		[g apply_rwGeometryComponentFilter:filter];
	}
}

- (void)apply_roGeometryComponentFilter:(OTSGeometryComponentFilter *)filter {
	[filter filter_ro:self];
	for (OTSGeometry *g in geometries) {
		[g apply_roGeometryComponentFilter:filter];
	}
}

- (OTSDimensionType)getDimension {
	OTSDimensionType dimension = kOTSDimensionFalse;
	for (OTSGeometry *g in geometries) {
		dimension = MAX(dimension, [g getDimension]);
	}
	return dimension;
}

- (int)getBoundaryDimension {
	OTSDimensionType dimension = kOTSDimensionFalse;
	for (OTSGeometry *g in geometries) {
		dimension = MAX(dimension, [g getBoundaryDimension]);
	}
	return dimension;
}

@end
