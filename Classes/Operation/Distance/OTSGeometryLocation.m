//
//  OTSGeometryLocation.m
//  OTS
//
//  Created by Purbo Mohamad on 3/13/10.
//  Copyright 2010 objgeo.org. All rights reserved.
//

#import "OTSGeometryLocation.h"


@implementation OTSGeometryLocation

@synthesize component;
@synthesize pt;
@synthesize segIndex;

- (id)initWithGeometry:(OTSGeometry *)_component segIndex:(int)_segIndex pt:(OTSCoordinate *)_pt {
	if (self = [super init]) {
		self.component = _component;
		self.segIndex = _segIndex;
		self.pt = _pt;
	}
	return self;
}

- (id)initWithGeometry:(OTSGeometry *)_component pt:(OTSCoordinate *)_pt {
	return [self initWithGeometry:_component segIndex:kOTSInsideArea pt:_pt];
}

- (void)dealloc {
	[component release];
	[pt release];
	[super dealloc];
}

- (BOOL)isInsideArea {
	return (segIndex == kOTSInsideArea);
}

@end
