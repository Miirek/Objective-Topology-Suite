//
//  OTSConnectedElementLocationFilter.m
//  OTS
//
//  Created by Purbo Mohamad on 3/13/10.
//  Copyright 2010 objgeo.org. All rights reserved.
//

#import "OTSConnectedElementLocationFilter.h"
#import "OTSGeometryLocation.h"
#import "OTSGeometry.h"
#import "OTSPoint.h"
#import "OTSLineString.h"
#import "OTSLinearRing.h"
#import "OTSPolygon.h"

@implementation OTSConnectedElementLocationFilter

@synthesize locations;

- (id)init {
	if (self = [super init]) {
		self.locations = [NSMutableArray array];
	}
	return self;
}

- (void)dealloc {
	[locations release];
	[super dealloc];
}

+ (NSArray *)getLocations:(OTSGeometry *)geom {
	OTSGeometryFilter *c = [[[OTSConnectedElementLocationFilter alloc] init] autorelease];
	[geom applyGeometryFilterReadOnly:c];
	return ((OTSConnectedElementLocationFilter *)c).locations;
}

- (void)filterReadWrite:(OTSGeometry *)geom {
	if ([geom isKindOfClass:[OTSPoint class]] ||
		[geom isKindOfClass:[OTSLineString class]] ||
		[geom isKindOfClass:[OTSLinearRing class]] ||
		[geom isKindOfClass:[OTSPolygon class]]) {
		OTSGeometryLocation *tmp = [[OTSGeometryLocation alloc] initWithGeometry:geom segIndex:0 pt:[geom getCoordinate]];
		[((NSMutableArray *)locations) addObject:tmp];
		[tmp release];
	}
}

- (void)filterReadOnly:(OTSGeometry * const)geom {
	if ([geom isKindOfClass:[OTSPoint class]] ||
		[geom isKindOfClass:[OTSLineString class]] ||
		[geom isKindOfClass:[OTSLinearRing class]] ||
		[geom isKindOfClass:[OTSPolygon class]]) {
		OTSGeometryLocation *tmp = [[OTSGeometryLocation alloc] initWithGeometry:geom segIndex:0 pt:[geom getCoordinate]];
		[((NSMutableArray *)locations) addObject:tmp];
		[tmp release];
	}
}

@end
