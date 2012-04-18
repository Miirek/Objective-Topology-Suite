//
//  OTSPolygon.m
//

#import "OTSCGAlgorithms.h"
#import "OTSCoordinate.h"
#import "OTSPolygon.h"
#import "OTSLinearRing.h"
#import "OTSMultiLineString.h" // for getBoundary()
#import "OTSGeometryFactory.h"
#import "OTSDimension.h"
#import "OTSEnvelope.h"
#import "OTSCoordinateSequenceFactory.h"
#import "OTSCoordinateSequence.h"
//#import "OTSCoordinateSequenceFilter.h>
//#import "OTSGeometryFilter.h>
//#import "OTSGeometryComponentFilter.h>

@implementation OTSPolygon

@synthesize shell;
@synthesize holes;

- (id)initWithPolygon:(OTSPolygon *)p {
	if (self = [super initWithFactory:p.factory]) {
		shell = [[OTSLinearRing alloc] initWithLinearRing:p.shell];
		self.holes = [NSMutableArray array];
		for (OTSLinearRing *h in p.holes) {
			OTSLinearRing *nh = [[OTSLinearRing alloc] initWithLinearRing:h];
			[((NSMutableArray *)holes) addObject:nh];
			[nh release];
		}
	}
	return self;
}

- (id)initWithShell:(OTSLinearRing *)newShell holes:(NSArray *)newHoles factory:(OTSGeometryFactory *)newFactory {
	if (self = [super initWithFactory:newFactory]) {
		if (newShell == nil) {
			self.shell = [factory createLinearRingWithCoordinateSequence:nil];
		} else {
			if (newHoles != nil && [newShell isEmpty] && [self hasNonEmptyElements:newHoles]) {
				NSException *ex = [NSException exceptionWithName:@"IllegalArgumentException" 
														  reason:@"shell is empty but holes are not" 
														userInfo:nil];
				@throw ex;
			}
			self.shell = newShell;
		}
		
		if (newHoles == nil || [newHoles count] == 0) {
			self.holes = [NSArray array];
		} else {
			if ([self hasNullElements:newHoles]) {
				NSException *ex = [NSException exceptionWithName:@"IllegalArgumentException" 
														  reason:@"holes must not contain null elements" 
														userInfo:nil];
				@throw ex;
			}
			for (OTSGeometry *h in newHoles) {
				if ([h getGeometryTypeId] != kOTSGeometryLinearRing) {
					NSException *ex = [NSException exceptionWithName:@"IllegalArgumentException" 
															  reason:@"holes must be LinearRings" 
															userInfo:nil];
					@throw ex;	
				}
			}
			self.holes = newHoles;
		}
	}
	return self;
}

- (void)dealloc {
	[shell release];
	[holes release];
	[super dealloc];
}

- (OTSLineString *)getExteriorRing {
	return shell;
}

- (int)getNumInteriorRing {
	return [holes count];
}

- (OTSLineString *)getInteriorRingN:(int)n {
	return [holes objectAtIndex:n];
}

- (OTSGeometry *)clone {
	return [[[OTSPolygon alloc] initWithPolygon:self] autorelease];
}

- (BOOL)isEmpty {
	return [shell isEmpty];
}

- (BOOL)isRectangle {
	
	if ([holes count] != 0) return NO;
	if ([shell getNumPoints] != 5 ) return NO;
	
	OTSCoordinateSequence *seq = [shell getCoordinatesRO];
	
	// check vertices have correct values
	OTSEnvelope *env = [self getEnvelopeInternal];
	for (int i = 0; i < 5; i++) {
		OTSCoordinate *c = [seq getAt:i];
		double x = c.x;
		if (! (x == env.minx || x == env.maxx)) return NO;
		double y = c.y;
		if (! (y == env.miny || y == env.maxy)) return NO;
	}
	
	// check vertices are in right order
	OTSCoordinate *c = [seq getAt:0];
	double prevX = c.x;
	double prevY = c.y;
	for (int i = 1; i <= 4; i++) {
		OTSCoordinate *c = [seq getAt:i];
		double x = c.x;
		double y = c.y;
		BOOL xChanged = (x != prevX);
		BOOL yChanged = (y != prevY);
		if (xChanged == yChanged) return NO;
		prevX = x;
		prevY = y;
	}
	return YES;
	
}

- (OTSEnvelope *)computeEnvelopeInternal {
	return [[[OTSEnvelope alloc] initWithEnvelope:[shell getEnvelopeInternal]] autorelease];
}

- (OTSCoordinate *)getCoordinate {
	return [shell getCoordinate];
}

- (OTSCoordinateSequence *)getCoordinates {
	
	if ([self isEmpty]) {
		return [factory.coordinateSequenceFactory createWithArray:nil];
	}
	
	NSMutableArray *cl = [NSMutableArray array];	
	// Add shell points
	[cl addObjectsFromArray:[[shell getCoordinatesRO] toArray]];
	
	// Add holes points
	for (OTSLinearRing *lr in holes) {
		[cl addObjectsFromArray:[[lr getCoordinatesRO] toArray]];
	}
		
	return [factory.coordinateSequenceFactory createWithArray:cl];
	
}

- (int)getNumPoints {
	int numPoints = [shell getNumPoints];
	for (OTSLinearRing *lr in holes) {
		numPoints += [lr getNumPoints];
	}
	return numPoints;	
}

- (OTSGeometryTypeId)getGeometryTypeId {
	return kOTSGeometryPolygon;
}

- (OTSDimensionType)getDimension {
	return kOTSDimensionA;
}

- (int)getBoundaryDimension {
	return 1;
}

- (void)apply_rwCoordinateFilter:(OTSCoordinateFilter *)filter {
	[shell apply_rwCoordinateFilter:filter];
	for (OTSLinearRing *lr in holes) {
		[lr apply_rwCoordinateFilter:filter];
	}
}

- (void)apply_roCoordinateFilter:(OTSCoordinateFilter *)filter {
	[shell apply_roCoordinateFilter:filter];
	for (OTSLinearRing *lr in holes) {
		[lr apply_roCoordinateFilter:filter];
	}
}

- (void)apply_rwGeometryComponentFilter:(OTSGeometryComponentFilter *)filter {
	[shell apply_rwGeometryComponentFilter:filter];
	for (OTSLinearRing *lr in holes) {
		[lr apply_rwGeometryComponentFilter:filter];
	}
}

- (void)apply_roGeometryComponentFilter:(OTSGeometryComponentFilter *)filter {
	[shell apply_roGeometryComponentFilter:filter];
	for (OTSLinearRing *lr in holes) {
		[lr apply_roGeometryComponentFilter:filter];
	}
}

@end
