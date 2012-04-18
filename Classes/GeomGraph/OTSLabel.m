//
//  OTSLabel.m
//

#import "OTSLabel.h"
#import "OTSTopologyLocation.h"
#import "OTSPosition.h"
#import "OTSLocation.h"


@implementation OTSLabel

+ (OTSLabel *)lineLabelFromLabel:(OTSLabel *)label {
	OTSLabel *lineLabel = [[OTSLabel alloc] initWithOnLocation:kOTSLocationUndefined];
	for (int i = 0; i < 2; i++) {
		[lineLabel setLocation:[label locationAtGeometryIndex:i] atGeometryIndex:i];
	}
	return [lineLabel autorelease];
}

- (id)init {
	if (self = [super init]) {
		elt[0] = [[OTSTopologyLocation alloc] initWithOnLocation:kOTSLocationUndefined];
		elt[1] = [[OTSTopologyLocation alloc] initWithOnLocation:kOTSLocationUndefined];
	}
	return self;	
}

- (id)initWithOnLocation:(int)onLoc {
	if (self = [super init]) {
		elt[0] = [[OTSTopologyLocation alloc] initWithOnLocation:onLoc];
		elt[1] = [[OTSTopologyLocation alloc] initWithOnLocation:onLoc];
	}
	return self;
}

- (id)initWithGeometryIndex:(int)geomIndex onLocation:(int)onLoc {
	NSAssert(geomIndex >= 0 && geomIndex < 2, @"Geometry index needs to be >= 0 and < 2");
	if (self = [super init]) {
		elt[0] = [[OTSTopologyLocation alloc] initWithOnLocation:kOTSLocationUndefined];
		elt[1] = [[OTSTopologyLocation alloc] initWithOnLocation:kOTSLocationUndefined];
		[elt[geomIndex] setLocation:onLoc];
	}
	return self;	
}

- (id)initWithOnLocation:(int)onLoc 
			leftLocation:(int)leftLoc 
		   rightLocation:(int)rightLoc {
	if (self = [super init]) {
		elt[0] = [[OTSTopologyLocation alloc] initWithOnPosition:onLoc leftPosition:leftLoc rightPosition:rightLoc];
		elt[1] = [[OTSTopologyLocation alloc] initWithOnPosition:onLoc leftPosition:leftLoc rightPosition:rightLoc];
	}
	return self;	
}

- (id)initWithGeometryIndex:(int)geomIndex 
				 onLocation:(int)onLoc 
			   leftLocation:(int)leftLoc 
			  rightLocation:(int)rightLoc {
	NSAssert(geomIndex >= 0 && geomIndex < 2, @"Geometry index needs to be >= 0 and < 2");
	if (self = [super init]) {
		elt[0] = [[OTSTopologyLocation alloc] initWithOnPosition:kOTSLocationUndefined leftPosition:kOTSLocationUndefined rightPosition:kOTSLocationUndefined];
		elt[1] = [[OTSTopologyLocation alloc] initWithOnPosition:kOTSLocationUndefined leftPosition:kOTSLocationUndefined rightPosition:kOTSLocationUndefined];
		[elt[geomIndex] setWithOnLocation:onLoc leftPosition:leftLoc rightPosition:rightLoc];
	}
	return self;
}

- (id)initWithLabel:(OTSLabel *)l {
	if (self = [super init]) {
		elt[0] = [[OTSTopologyLocation alloc] initWithTopologyLocation:[l getLocationAt:0]];
		elt[1] = [[OTSTopologyLocation alloc] initWithTopologyLocation:[l getLocationAt:1]];
	}
	return self;	
}

- (void)flip {
	[elt[0] flip];
	[elt[1] flip];
}

- (int)locationAtGeometryIndex:(int)geomIndex atPosIndex:(int)posIndex {
	NSAssert(geomIndex >= 0 && geomIndex < 2, @"Geometry index needs to be >= 0 and < 2");
	return [elt[geomIndex] getAt:posIndex];
}

- (int)locationAtGeometryIndex:(int)geomIndex {
	NSAssert(geomIndex >= 0 && geomIndex < 2, @"Geometry index needs to be >= 0 and < 2");
	return [elt[geomIndex] getAt:kOTSPositionOn];
}

- (void)setLocation:(int)location atGeometryIndex:(int)geomIndex atPosIndex:(int)posIndex {
	NSAssert(geomIndex >= 0 && geomIndex < 2, @"Geometry index needs to be >= 0 and < 2");
	[elt[geomIndex] setAt:posIndex withLocation:location];
}

- (void)setLocation:(int)location atGeometryIndex:(int)geomIndex {
	NSAssert(geomIndex >= 0 && geomIndex < 2, @"Geometry index needs to be >= 0 and < 2");
	[elt[geomIndex] setAt:kOTSPositionOn withLocation:location];	
}

- (void)setAllLocations:(int)location atGeometryIndex:(int)geomIndex {
	NSAssert(geomIndex >= 0 && geomIndex < 2, @"Geometry index needs to be >= 0 and < 2");
	[elt[geomIndex] setAllLocationsWith:location];
}

- (void)setAllLocationsIfNull:(int)location atGeometryIndex:(int)geomIndex {
	NSAssert(geomIndex >= 0 && geomIndex < 2, @"Geometry index needs to be >= 0 and < 2");
	[elt[geomIndex] setAllLocationsIfNullWith:location];
}

- (void)setAllLocationsIfNull:(int)location {
	[self setAllLocationsIfNull:location atGeometryIndex:0];
	[self setAllLocationsIfNull:location atGeometryIndex:1];
}

- (void)merge:(OTSLabel *)lbl {
	for (int i = 0; i < 2; i++)
		[elt[i] mergeWith:[lbl getLocationAt:i]];
}

- (int)geometryCount {
	int count = 0;
	if (![elt[0] isNull]) count++;
	if (![elt[1] isNull]) count++;
	return count;	
}

- (BOOL)isNullAtGeometryIndex:(int)geomIndex {
	NSAssert(geomIndex >= 0 && geomIndex < 2, @"Geometry index needs to be >= 0 and < 2");
	return [elt[geomIndex] isNull];
}

- (BOOL)isAnyNullAtGeometryIndex:(int)geomIndex {
	NSAssert(geomIndex >= 0 && geomIndex < 2, @"Geometry index needs to be >= 0 and < 2");
	return [elt[geomIndex] isAnyNull];
}

- (BOOL)isArea {
	return [elt[0] isArea] || [elt[1] isArea];
}

- (BOOL)isAreaAtGeometryIndex:(int)geomIndex {
	NSAssert(geomIndex >= 0 && geomIndex < 2, @"Geometry index needs to be >= 0 and < 2");
	return [elt[geomIndex] isArea];
}

- (BOOL)isLineAtGeometryIndex:(int)geomIndex {
	NSAssert(geomIndex >= 0 && geomIndex < 2, @"Geometry index needs to be >= 0 and < 2");
	return [elt[geomIndex] isLine];
}

- (BOOL)isLabel:(OTSLabel *)lbl equalOnSide:(int)side {
	return [elt[0] isEqualOnSide:[lbl getLocationAt:0] onLocationIndex:side] && [elt[1] isEqualOnSide:[lbl getLocationAt:1] onLocationIndex:side];
}

- (BOOL)allPositionsEqualAtGeometryIndex:(int)geomIndex toLocation:(int)location {
	NSAssert(geomIndex >= 0 && geomIndex < 2, @"Geometry index needs to be >= 0 and < 2");
	return [elt[geomIndex] allPositionsEqualWith:location];
}

- (void) toLineAtGeometryIndex:(int)geomIndex {
	NSAssert(geomIndex >= 0 && geomIndex < 2, @"Geometry index needs to be >= 0 and < 2");
	if ([elt[geomIndex] isArea]) {
		OTSTopologyLocation *tmp = elt[geomIndex];
		NSNumber *tmpN = [[tmp locations] objectAtIndex:0];
		elt[geomIndex] = [[OTSTopologyLocation alloc] initWithOnLocation:[tmpN intValue]];
		[tmp release];
	}
}

- (void)dealloc {
	[elt[0] release];
	[elt[1] release];
	[super dealloc];
}

- (OTSTopologyLocation *)getLocationAt:(int)idx {
	return elt[idx];
}

@end
