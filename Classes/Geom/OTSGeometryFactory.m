//
//  OTSGeometryFactory.m
//

#import "OTSCoordinate.h"
#import "OTSCoordinateSequence.h"
#import "OTSCoordinateSequenceFactory.h"
#import "OTSGeometryFactory.h"
#import "OTSDefaultGeometryFactory.h"
#import "OTSPoint.h"
#import "OTSLineString.h"
#import "OTSLinearRing.h"
#import "OTSPolygon.h"
#import "OTSMultiPoint.h"
#import "OTSMultiLineString.h"
#import "OTSMultiPolygon.h"
#import "OTSGeometryCollection.h"
#import "OTSPrecisionModel.h"
#import "OTSEnvelope.h"

@implementation OTSGeometryFactory

@synthesize precisionModel;
@synthesize SRID;
@synthesize coordinateSequenceFactory;	

- (id)init {
	if (self = [super init]) {
		precisionModel = [[OTSPrecisionModel alloc] init];
		SRID = 0;
		self.coordinateSequenceFactory = [OTSCoordinateSequenceFactory instance];
	}
	return self;	
}

- (id)initWithPrecisionModel:(OTSPrecisionModel *)pm SRID:(int)newSRID coordinateSequenceFactory:(OTSCoordinateSequenceFactory *)nCoordinateSequenceFactory {
	if (self = [super init]) {
		self.precisionModel = pm;
		SRID = newSRID;
		self.coordinateSequenceFactory = nCoordinateSequenceFactory;
	}
	return self;
}

- (id)initWithCoordinateSequenceFactory:(OTSCoordinateSequenceFactory *)nCoordinateSequenceFactory {
	if (self = [super init]) {
		precisionModel = [[OTSPrecisionModel alloc] init];
		SRID = 0;
		self.coordinateSequenceFactory = nCoordinateSequenceFactory;
	}
	return self;
}

- (id)initWithPrecisionModel:(OTSPrecisionModel *)pm {
	if (self = [super init]) {
		self.precisionModel = pm;
		SRID = 0;
		self.coordinateSequenceFactory = [OTSCoordinateSequenceFactory instance];
	}
	return self;
}

- (id)initWithPrecisionModel:(OTSPrecisionModel *)pm SRID:(int)newSRID {
	if (self = [super init]) {
		self.precisionModel = pm;
		SRID = newSRID;
		self.coordinateSequenceFactory = [OTSCoordinateSequenceFactory instance];
	}
	return self;
}

- (id)initWithGeometryFactory:(OTSGeometryFactory *)gf {
	if (self = [super init]) {
		self.precisionModel = gf.precisionModel;
		SRID = gf.SRID;
		self.coordinateSequenceFactory = gf.coordinateSequenceFactory;
	}
	return self;
}

- (void)dealloc {
	[precisionModel release];
	[coordinateSequenceFactory release];
	[super dealloc];
}

+ (OTSGeometryFactory *)getDefaultInstance {
	//return [[[OTSGeometryFactory alloc] init] autorelease];
  //return singleton
  return [OTSDefaultGeometryFactory instance];
}

- (OTSPoint *)createPointWithInternalCoord:(OTSCoordinate *)coord exemplar:(OTSGeometry *)exemplar {
	OTSCoordinate *newcoord = coord;
	[exemplar.precisionModel makePrecise:newcoord];
	return [exemplar.factory createPointWithCoordinate:newcoord];
}

- (OTSGeometry *)toGeometry:(OTSEnvelope *)envelope {
	
	OTSCoordinate *coord;
	
	if ([envelope isNull]) {
		return [self createPoint];
	}
	if (envelope.minx == envelope.maxx && envelope.miny == envelope.maxy) {
		coord = [[OTSCoordinate alloc] initWithX:envelope.minx Y:envelope.miny];
		OTSGeometry *ret = [self createPointWithCoordinate:coord];
		[coord release];
		return ret;
	}
	
	OTSCoordinateSequence *cl = [[OTSCoordinateSequenceFactory instance] createWithArray:nil];
	
	coord = [[OTSCoordinate alloc] initWithX:envelope.minx Y:envelope.miny];
	[cl add:coord];
	[coord release];
	
	coord = [[OTSCoordinate alloc] initWithX:envelope.maxx Y:envelope.miny];
	[cl add:coord];
	[coord release];
	
	coord = [[OTSCoordinate alloc] initWithX:envelope.maxx Y:envelope.maxy];
	[cl add:coord];
	[coord release];
	
	coord = [[OTSCoordinate alloc] initWithX:envelope.minx Y:envelope.maxy];
	[cl add:coord];
	[coord release];
	
	coord = [[OTSCoordinate alloc] initWithX:envelope.minx Y:envelope.miny];
	[cl add:coord];
	[coord release];
	
	return [self createPolygonWithShell:[self createLinearRingWithCoordinateSequence:cl] holes:nil];
}

- (OTSPoint *)createPoint {
	return [[[OTSPoint alloc] initWithCoordinateSequence:nil factory:self] autorelease];
}

- (OTSPoint *)createPointWithCoordinate:(OTSCoordinate *)coordinate {
	if ([coordinate isNull]) {
		return [self createPoint];
	} else {		
		OTSCoordinateSequence *cl = [coordinateSequenceFactory createWithArray:[NSArray arrayWithObject:coordinate]];
		return [self createPointWithCoordinateSequence:cl];
	}	
}

- (OTSPoint *)createPointWithCoordinateSequence:(OTSCoordinateSequence *)coordinates {
	return [[[OTSPoint alloc] initWithCoordinateSequence:coordinates factory:self] autorelease];
}

- (OTSGeometryCollection *)createGeometryCollection {
	return [[[OTSGeometryCollection alloc] initWithArray:nil factory:self] autorelease];
}

- (OTSGeometry *)createEmptyGeometry {
	return [[[OTSGeometryCollection alloc] initWithArray:nil factory:self] autorelease];
}

- (OTSGeometryCollection *)createGeometryCollectionWithArray:(NSArray *)newGeoms {
	return [[[OTSGeometryCollection alloc] initWithArray:newGeoms factory:self] autorelease];
}

- (OTSMultiLineString *)createMultiLineString {
	return [[[OTSMultiLineString alloc] initWithArray:nil factory:self] autorelease];
}

- (OTSMultiLineString *)createMultiLineStringWithArray:(NSArray *)newLines {
	return [[[OTSMultiLineString alloc] initWithArray:newLines factory:self] autorelease];
}

- (OTSMultiPolygon *)createMultiPolygon {
	return [[[OTSMultiPolygon alloc] initWithArray:nil factory:self] autorelease];
}

- (OTSMultiPolygon *)createMultiPolygonWithArray:(NSArray *)newPolys {
	return [[[OTSMultiPolygon alloc] initWithArray:newPolys factory:self] autorelease];
}

- (OTSLinearRing *)createLinearRing {
	return [[[OTSLinearRing alloc] initWithCoordinateSequence:nil factory:self] autorelease];
}

- (OTSLinearRing *)createLinearRingWithCoordinateSequence:(OTSCoordinateSequence *)newCoords {
	return [[[OTSLinearRing alloc] initWithCoordinateSequence:newCoords factory:self] autorelease];
}

- (OTSMultiPoint *)createMultiPoint {
	return [[[OTSMultiPoint alloc] initWithArray:nil factory:self] autorelease];
}

- (OTSMultiPoint *)createMultiPointWithArray:(NSArray *)newPoints {
	return [[[OTSMultiPoint alloc] initWithArray:newPoints factory:self] autorelease];
}

- (OTSMultiPoint *)createMultiPointWithCoordinateSequence:(OTSCoordinateSequence *)newCoords {
	NSMutableArray *points = [NSMutableArray array];
	for (int i = 0; i < [newCoords size]; i++) {
		[points addObject:[self createPointWithCoordinate:[newCoords getAt:i]]];
	}	
	return [self createMultiPointWithArray:points];
}

- (OTSPolygon *)createPolygon {
	return [[[OTSPolygon alloc] initWithShell:nil holes:nil factory:self] autorelease];
}

- (OTSPolygon *)createPolygonWithShell:(OTSLinearRing *)shell holes:(NSArray *)holes {
	return [[[OTSPolygon alloc] initWithShell:shell holes:holes factory:self] autorelease];
}

- (OTSLineString *)createLineString {
	return [[[OTSLineString alloc] initWithCoordinateSequence:nil factory:self] autorelease];
}

- (OTSLineString *)createLineStringWithLineString:(OTSLineString *)ls {
	return [[[OTSLineString alloc] initWithLineString:ls] autorelease];
}

- (OTSLineString *)createLineStringWithCoordinateSequence:(OTSCoordinateSequence *)coordinates {
	return [[[OTSLineString alloc] initWithCoordinateSequence:coordinates factory:self] autorelease];
}

- (OTSGeometry *)buildGeometry:(NSArray *)geoms {
	
	OTSGeometryTypeId geomTypeId = kOTSGeometryNull;
	BOOL isHeterogeneous = NO;
	BOOL hasGeometryCollection = NO;
	
	for (OTSGeometry *geom in geoms) {
		OTSGeometryTypeId partTypeId = [geom getGeometryTypeId];
		if (geomTypeId == kOTSGeometryNull)  {
			geomTypeId = partTypeId;
		} else if (geomTypeId != partTypeId) {
			isHeterogeneous = YES;
		} else if ([geom isKindOfClass:[OTSGeometryCollection class]]) {
			hasGeometryCollection = YES;
		}
	}
	
	if (geomTypeId == kOTSGeometryNull)  {
		return [self createGeometryCollection];
	}
	if (isHeterogeneous || hasGeometryCollection) {
		return [self createGeometryCollectionWithArray:geoms];
	}
	
	OTSGeometry *geom0 = [geoms objectAtIndex:0];
	BOOL isCollection = [geoms count] > 1;
	if (isCollection) {
		if ([geom0 isKindOfClass:[OTSPolygon class]]) {
			return [self createMultiPolygonWithArray:geoms];
		} else if ([geom0 isKindOfClass:[OTSLineString class]]) {
			return [self createMultiLineStringWithArray:geoms];
		} else if ([geom0 isKindOfClass:[OTSLinearRing class]]) {
			return [self createMultiLineStringWithArray:geoms];
		} else if ([geom0 isKindOfClass:[OTSPoint class]]) {
			return [self createMultiPointWithArray:geoms];
		} else {
			return [self createGeometryCollectionWithArray:geoms];
		}
	}
	return geom0;	
}

- (OTSGeometry *)createGeometryWithGeometry:(OTSGeometry *)g {
	return [g clone];
}

@end
