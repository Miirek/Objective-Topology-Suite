//
//  OTSPolygonExtractor.m
//  OTS
//
//  Created by Purbo Mohamad on 3/14/10.
//  Copyright 2010 objgeo.org. All rights reserved.
//

#import "OTSPolygonExtractor.h"
#import "OTSPolygon.h"

@implementation OTSPolygonExtractor

+ (void)extractPolygonsFrom:(OTSGeometry *)geom into:(NSMutableArray *)ret {
	OTSGeometryFilter *pe = [[OTSPolygonExtractor alloc] initWithPolygons:ret];
	[geom applyGeometryFilterReadOnly:pe];
	[pe release];
}

- (id)initWithPolygons:(NSMutableArray *)newComps {
	if (self = [super init]) {
		comps = [newComps retain];
	}
	return self;
}

- (void)dealloc {
	[comps release];
	[super dealloc];
}

- (void)filterReadWrite:(OTSGeometry *)geom {
	if ([geom isKindOfClass:[OTSPolygon class]]) {
		[comps addObject:geom];
	}
}

- (void)filterReadOnly:(OTSGeometry * const)geom {
	if ([geom isKindOfClass:[OTSPolygon class]]) {
		[comps addObject:geom];
	}
}

@end
