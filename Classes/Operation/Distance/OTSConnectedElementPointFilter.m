//
//  OTSConnectedElementPointFilter.m
//  OTS
//
//  Created by Purbo Mohamad on 3/13/10.
//  Copyright 2010 objgeo.org. All rights reserved.
//

#import "OTSConnectedElementPointFilter.h"
#import "OTSGeometry.h"
#import "OTSPoint.h"
#import "OTSLineString.h"
#import "OTSPolygon.h"

@implementation OTSConnectedElementPointFilter

@synthesize pts;

- (id)initWithCoordinates:(NSMutableArray *)_pts {
	if (self = [super init]) {
		self.pts = _pts;
	}
	return self;
}

- (void)dealloc {
	[pts release];
	[super dealloc];
}

+ (NSArray *)getCoordinates:(OTSGeometry * const)geom {
	NSMutableArray *points = [NSMutableArray array];
	OTSGeometryFilter *c = [[OTSConnectedElementPointFilter alloc] initWithCoordinates:points];
	[geom applyGeometryFilterReadOnly:c];
  [c release];
	return points;
}

- (void)filterReadWrite:(OTSGeometry *)geom {
}

- (void)filterReadOnly:(OTSGeometry * const)geom {
	if ([geom isKindOfClass:[OTSPoint class]] ||
		[geom isKindOfClass:[OTSLineString class]] ||
		[geom isKindOfClass:[OTSPolygon class]]) {
		[pts addObject:[geom getCoordinate]];
	}
}


@end
