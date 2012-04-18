//
//  OTSPoint.m
//

#import "OTSCoordinate.h"
#import "OTSPoint.h"
#import "OTSCoordinateSequence.h"
//#import "OTSCoordinateSequenceFilter.h"
#import "OTSCoordinateFilter.h"
//#import "OTSGeometryFilter.h"
#import "OTSGeometryComponentFilter.h"
#import "OTSCoordinateSequenceFactory.h"
#import "OTSDimension.h"
#import "OTSEnvelope.h"
#import "OTSGeometryCollection.h"
#import "OTSGeometryFactory.h"

@implementation OTSPoint

@synthesize coordinates;

- (id)initWithPoint:(OTSPoint *)pt {
	if (self = [super initWithFactory:pt.factory]) {
		self.coordinates = [pt.coordinates clone];
	}
	return self;
}

- (id)initWithCoordinateSequence:(OTSCoordinateSequence *)pts factory:(OTSGeometryFactory *)newFactory {
	if (self = [super initWithFactory:newFactory]) {
		if (pts == nil) {
			self.coordinates = [factory.coordinateSequenceFactory createWithArray:nil];
		} else {
			self.coordinates = pts;
		}
	}
	return self;
}

- (void)dealloc {
	[coordinates release];
	[super dealloc];
}

- (OTSGeometry *)clone {
	return [[[OTSPoint alloc] initWithPoint:self] autorelease];
}

- (BOOL)isEmpty {
	return [coordinates size] == 0;
}


- (OTSEnvelope *)computeEnvelopeInternal {
	if ([coordinates size] == 0) {
		return [[[OTSEnvelope alloc] init] autorelease];
	}	
	OTSCoordinate *c = [self getCoordinate];
	return [[[OTSEnvelope alloc] initWithFirstX:c.x secondX:c.x firstY:c.y secondY:c.y] autorelease];
}

- (OTSCoordinate *)getCoordinate {
	return [coordinates size] != 0 ? [coordinates getAt:0] : nil;
}

- (OTSCoordinateSequence *)getCoordinates {
	return [coordinates clone];
}

- (int)getNumPoints {
	return [self isEmpty] ? 0 : 1;
}

- (double)getX {
	if ([coordinates size] == 0) {
		//throw util::UnsupportedOperationException("getX called on empty Point\n");
	}
	return [self getCoordinate].x;
}

- (double)getY {
	if ([coordinates size] == 0) {
		//throw util::UnsupportedOperationException("getX called on empty Point\n");
	}
	return [self getCoordinate].y;
}

- (OTSGeometryTypeId)getGeometryTypeId {
	return kOTSGeometryPoint;
}

- (OTSDimensionType)getDimension {
	return kOTSDimensionP;
}

- (int)getBoundaryDimension {
	return kOTSDimensionFalse;
}

- (void)apply_rwCoordinateFilter:(OTSCoordinateFilter *)filter {
	if ([self isEmpty]) {return;}
	OTSCoordinate *newcoord = [self getCoordinate];
	[filter filter_rw:newcoord];
	[coordinates set:newcoord at:0];
}

- (void)apply_roCoordinateFilter:(OTSCoordinateFilter *)filter {
	if ([self isEmpty]) {return;}
	[filter filter_ro:[self getCoordinate]];
}

@end
