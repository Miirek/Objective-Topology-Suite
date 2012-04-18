//
//  OTSPointExtractor.m
//  OTS
//
//  Created by Purbo Mohamad on 3/14/10.
//  Copyright 2010 objgeo.org. All rights reserved.
//

#import "OTSPointExtractor.h"
#import "OTSPoint.h"

@implementation OTSPointExtractor

+ (void)extractPointsFrom:(OTSGeometry * const)geom into:(NSMutableArray *)ret {
	OTSGeometryFilter *pe = [[OTSPointExtractor alloc] initWithPoints:ret];
	[geom applyGeometryFilterReadOnly:pe];
	[pe release];
}

- (id)initWithPoints:(NSMutableArray *)newComps {
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
	if ([geom isKindOfClass:[OTSPoint class]]) {
		[comps addObject:geom];
	}
}

- (void)filterReadOnly:(OTSGeometry * const)geom {
	if ([geom isKindOfClass:[OTSPoint class]]) {
		[comps addObject:geom];
	}
}

@end
