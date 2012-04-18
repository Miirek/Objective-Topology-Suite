//
//  OTSGeometryTransformer.m
//

#import "OTSGeometryTransformer.h"
#import "OTSGeometryFactory.h"
#import "OTSCoordinateSequenceFactory.h"
#import "OTSGeometry.h"
#import "OTSMultiPoint.h"
#import "OTSMultiPolygon.h"
#import "OTSMultiLineString.h"
#import "OTSCoordinateSequence.h"
#import "OTSPolygon.h"
#import "OTSPoint.h"
#import "OTSLineString.h"
#import "OTSLinearRing.h"
#import "OTSGeometryCollection.h"

@implementation OTSGeometryTransformer

@synthesize factory;
@synthesize inputGeom;
@synthesize pruneEmptyGeometry;
@synthesize preserveGeometryCollectionType;
@synthesize preserveCollections;
@synthesize preserveType;

- (id)init {
	if (self = [super init]) {
		factory = nil;
		inputGeom = nil;
		pruneEmptyGeometry = YES;
		preserveGeometryCollectionType = YES;
		preserveCollections = NO;
		preserveType = NO;
	}
	return self;
}

- (void)dealloc {
	[factory release];
	[inputGeom release];
	[super dealloc];
}

- (OTSGeometry *)transform:(OTSGeometry *)nInputGeom {
	
	self.inputGeom = nInputGeom;
	self.factory = inputGeom.factory;
	
	if ([inputGeom isKindOfClass:[OTSPoint class]])
		return [self transformPoint:(OTSPoint *)inputGeom parent:nil];
	if ([inputGeom isKindOfClass:[OTSMultiPoint class]])
		return [self transformMultiPoint:(OTSMultiPoint *)inputGeom parent:nil];
	if ([inputGeom isKindOfClass:[OTSLinearRing class]])
		return [self transformLinearRing:(OTSLinearRing *)inputGeom parent:nil];
	if ([inputGeom isKindOfClass:[OTSLineString class]])
		return [self transformLineString:(OTSLineString *)inputGeom parent:nil];
	if ([inputGeom isKindOfClass:[OTSMultiLineString class]])
		return [self transformMultiLineString:(OTSMultiLineString *)inputGeom parent:nil];
	if ([inputGeom isKindOfClass:[OTSPolygon class]])
		return [self transformPolygon:(OTSPolygon *)inputGeom parent:nil];
	if ([inputGeom isKindOfClass:[OTSMultiPolygon class]])
		return [self transformMultiPolygon:(OTSMultiPolygon *)inputGeom parent:nil];
	if ([inputGeom isKindOfClass:[OTSGeometryCollection class]])
		return [self transformGeometryCollection:(OTSGeometryCollection *)inputGeom parent:nil];

	NSException *ex = [NSException exceptionWithName:@"IllegalArgumentException" 
											  reason:@"Unknown Geometry subtype." 
											userInfo:nil];
	@throw ex;
}

- (OTSCoordinateSequence *)transformCoordinates:(OTSCoordinateSequence *)coords parent:(OTSGeometry *)parent {
	return [coords clone];
}

- (OTSGeometry *)transformPoint:(OTSPoint *)geom parent:(OTSGeometry *)parent {
	OTSCoordinateSequence *cs = [self transformCoordinates:geom.coordinates parent:geom];
	return [factory createPointWithCoordinateSequence:cs];	
}

- (OTSGeometry *)transformMultiPoint:(OTSMultiPoint *)geom parent:(OTSGeometry *)parent {
	
	NSMutableArray *transGeomList = [NSMutableArray array];
	for (int i = 0; i < [geom getNumGeometries]; i++) {
		OTSPoint *p = (OTSPoint *)[geom getGeometryN:i];
		OTSGeometry *transformGeom = [self transformPoint:p parent:geom];
		if (transformGeom == nil) continue;
		if ([transformGeom isEmpty]) continue;
		[transGeomList addObject:transformGeom];
	}
	
	return [factory buildGeometry:transGeomList];
	
}

- (OTSGeometry *)transformLinearRing:(OTSLinearRing *)geom parent:(OTSGeometry *)parent {
	
	OTSCoordinateSequence *seq = [self transformCoordinates:geom.points parent:geom];
	int seqSize = [seq size];
	
	// ensure a valid LinearRing
	if (seqSize > 0 && seqSize < 4 && ! preserveType) {
		return [factory createLineStringWithCoordinateSequence:seq];
	}
	
	return [factory createLinearRingWithCoordinateSequence:seq];
	
}

- (OTSGeometry *)transformLineString:(OTSLineString *)geom parent:(OTSGeometry *)parent {
	return [factory createLineStringWithCoordinateSequence:[self transformCoordinates:geom.points parent:geom]];
}

- (OTSGeometry *)transformMultiLineString:(OTSMultiLineString *)geom parent:(OTSGeometry *)parent {
	
	NSMutableArray *transGeomList = [NSMutableArray array];
	for (int i = 0; i < [geom getNumGeometries]; i++) {
		OTSLineString *l = (OTSLineString *)[geom getGeometryN:i];
		OTSGeometry *transformGeom = [self transformLineString:l parent:geom];
		if (transformGeom == nil) continue;
		if ([transformGeom isEmpty]) continue;
		[transGeomList addObject:transformGeom];
	}
	
	return [factory buildGeometry:transGeomList];
	
}

- (OTSGeometry *)transformPolygon:(OTSPolygon *)geom parent:(OTSGeometry *)parent {
	
	BOOL isAllValidLinearRings = YES;
	OTSLinearRing *lr = (OTSLinearRing *)[geom getExteriorRing];
	
	OTSGeometry *shell = [self transformLinearRing:lr parent:geom];
	if (shell == nil
		|| ![shell isKindOfClass:[OTSLinearRing class]]
		|| [shell isEmpty]) {
		isAllValidLinearRings = NO;
	}
	
	NSMutableArray *holes = [NSMutableArray array];
	
	for (int i = 0, n = [geom getNumInteriorRing]; i < n; i++) {
		lr = (OTSLinearRing *)[geom getInteriorRingN:i];
		OTSGeometry *hole = [self transformLinearRing:lr parent:geom];		
		if (hole == nil || [hole isEmpty]) {
			continue;
		}
		if (![hole isKindOfClass:[OTSLinearRing class]]) {
			isAllValidLinearRings = false;
		}
		[holes addObject:hole];
	}
		
	if (isAllValidLinearRings) {
		return [factory createPolygonWithShell:(OTSLinearRing *)shell holes:holes];
	} else {
		// would like to use a manager constructor here
		NSMutableArray *components = [NSMutableArray array];
		if (shell != nil) {
			[components addObject:shell];
		}
		[components addObjectsFromArray:holes];
		return [factory buildGeometry:components];
	}
		
}

- (OTSGeometry *)transformMultiPolygon:(OTSMultiPolygon *)geom parent:(OTSGeometry *)parent {
	
	NSMutableArray *transGeomList = [NSMutableArray array];
	for (int i = 0; i < [geom getNumGeometries]; i++) {
		OTSPolygon *p = (OTSPolygon *)[geom getGeometryN:i];
		OTSGeometry *transformGeom = [self transformPolygon:p parent:geom];
		if (transformGeom == nil) continue;
		if ([transformGeom isEmpty]) continue;
		[transGeomList addObject:transformGeom];
	}
	
	return [factory buildGeometry:transGeomList];
	
}

- (OTSGeometry *)transformGeometryCollection:(OTSGeometryCollection *)geom parent:(OTSGeometry *)parent {
	
	NSMutableArray *transGeomList = [NSMutableArray array];
	for (int i = 0; i < [geom getNumGeometries]; i++) {
		OTSGeometry *transformGeom = [self transform:[geom getGeometryN:i]];
		if (transformGeom == nil) continue;
		if (pruneEmptyGeometry && [transformGeom isEmpty]) continue;
		[transGeomList addObject:transformGeom];
	}
	
	if ( preserveGeometryCollectionType ) {
		return [factory createGeometryCollectionWithArray:transGeomList];
	} else {
		return [factory buildGeometry:transGeomList];
	}
		
}

@end
