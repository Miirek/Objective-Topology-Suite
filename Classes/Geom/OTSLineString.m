//
//  OTSLineString.m
//

#import "OTSCoordinate.h"
#import "OTSCoordinateSequence.h"
#import "OTSPrecisionModel.h"
#import "OTSGeometry.h"
#import "OTSLineString.h"

@implementation OTSLineString

@synthesize points;

- (id)initWithLineString:(OTSLineString *)ls {
	if (self = [super initWithFactory:ls.factory]) {
		self.points = [ls.points clone];
	}
	return self;
}

- (id)initWithCoordinateSequence:(OTSCoordinateSequence *)pts factory:(OTSGeometryFactory *)newFactory {
	if (self = [super initWithFactory:newFactory]) {
		if (pts == nil) {
			points = [[OTSCoordinateSequence alloc] init];
		} else {
			self.points = pts;
		}		
	}
	return self;
}

- (void)dealloc {
	[points release];
	[super dealloc];
}

+ (id)lineStringWithFactory:(OTSGeometryFactory *)newFactory coordinates:(OTSCoordinate *)firstObject, ... {
	
	OTSCoordinate *eachObject;
	OTSCoordinateSequence *ret = [[OTSCoordinateSequence alloc] init];
	va_list argumentList;
	if (firstObject) {                    // The first argument isn't part of the varargs list, so we'll handle it separately.
		[ret add:firstObject];
		va_start(argumentList, firstObject);          // Start scanning for arguments after firstObject.
		while (eachObject = va_arg(argumentList, OTSCoordinate *)) // As many times as we can get an argument of type "id"
			[ret add:eachObject]; // that isn't nil, add it to self's contents.
		va_end(argumentList);
	}
	
	OTSLineString *lret = [[OTSLineString alloc] initWithCoordinateSequence:ret factory:newFactory];
	[ret release];
	return [lret autorelease];
	
}

- (OTSCoordinateSequence *)getCoordinatesRO {
	return points;
}

- (OTSCoordinate *)getCoordinateN:(int)n {
	return [points getAt:n];
}

- (BOOL)isClosed {
	if ([self isEmpty]) {
		return NO;
	}
	return [[points getAt:0] isEqual2D:[points getAt:[points size] - 1]];
}

- (OTSGeometry *)clone {
	return [[[OTSLineString alloc] initWithLineString:self] autorelease];
}

- (BOOL)isEmpty {
	return ([points size] == 0);
}

- (OTSEnvelope *)computeEnvelopeInternal {
	if ([self isEmpty]) {
		// We don't return NULL here
		// as it would indicate "unknown"
		// envelope. In this case we
		// *know* the envelope is EMPTY.
		return [[[OTSEnvelope alloc] init] autorelease];
	}
	
	OTSCoordinate *c = [points getAt:0];
	double minx = c.x;
	double miny = c.y;
	double maxx = c.x;
	double maxy = c.y;
	int npts = [points size];
	for (int i = 1; i < npts; i++) {
		c = [points getAt:i];
		minx = minx < c.x ? minx : c.x;
		maxx = maxx > c.x ? maxx : c.x;
		miny = miny < c.y ? miny : c.y;
		maxy = maxy > c.y ? maxy : c.y;
	}
	
	return [[[OTSEnvelope alloc] initWithFirstX:minx secondX:maxx firstY:miny secondY:maxy] autorelease];
}

- (OTSCoordinate *)getCoordinate {
	if ([self isEmpty]) return nil; 
	return [points getAt:0];
}

- (OTSCoordinateSequence *)getCoordinates {
	return [points clone];
}

- (int)getNumPoints {
	return [points size];
}

- (OTSGeometryTypeId)getGeometryTypeId {
	return kOTSGeometryLineString;
}

- (void)apply_rwCoordinateFilter:(OTSCoordinateFilter *)filter {
	[points apply_rw:filter];
}

- (void)apply_roCoordinateFilter:(OTSCoordinateFilter *)filter {
	[points apply_ro:filter];
}

- (OTSDimensionType)getDimension {
	return kOTSDimensionL;
}

- (int)getBoundaryDimension {
	if ([self isClosed]) {
		return kOTSDimensionFalse;
	}
	return 0;
}

- (BOOL)isEqual:(id)anObject {
	if ([anObject isKindOfClass:[OTSLineString class]]) {
		OTSLineString *other = (OTSLineString *)anObject;
		
		if ([points size] == [other.points size]) {
			for (int i = 0, n = [points size]; i < n; ++i) {
				if (![[points getAt:i] isEqual2D:[other.points getAt:i]]) {
					return NO;
				}
			}
			return YES;
		}
	}
	return NO;
}

- (id)copyWithZone:(NSZone *)zone {
	OTSLineString *copy = [[[self class] allocWithZone:zone] initWithCoordinateSequence:[self points] factory:[self factory]];
    return copy;
}

@end
