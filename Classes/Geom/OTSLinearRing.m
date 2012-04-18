//
//  OTSLinearRing.m
//

#import "OTSLinearRing.h"
#import "OTSDimension.h"
#import "OTSCoordinateSequence.h"
#import "OTSGeometryFactory.h"

@implementation OTSLinearRing

- (id)initWithLinearRing:(OTSLinearRing *)lr {
	if (self = [super initWithLineString:lr]) {
	}
	return self;
}

- (id)initWithCoordinateSequence:(OTSCoordinateSequence *)pts factory:(OTSGeometryFactory *)newFactory {
	if (self = [super initWithCoordinateSequence:pts factory:newFactory]) {
	}
	return self;
}

- (OTSGeometry *)clone {
	return [[[OTSLinearRing alloc] initWithLinearRing:self] autorelease];
}

- (OTSGeometryTypeId)getGeometryTypeId {
	return kOTSGeometryLinearRing;
}

- (int)getBoundaryDimension {
	return kOTSDimensionFalse;
}

@end
