//
//  OTSGeometryLocation.h
//  OTS
//
//  Created by Purbo Mohamad on 3/13/10.
//  Copyright 2010 objgeo.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTSCoordinate.h" // for composition

@class OTSGeometry;

static const int kOTSInsideArea = -1;

@interface OTSGeometryLocation : NSObject {
	OTSGeometry *component;
	OTSCoordinate *pt;
	int segIndex;
}

@property (nonatomic, retain) OTSGeometry *component;
@property (nonatomic, retain) OTSCoordinate *pt;
@property (nonatomic, assign) int segIndex;

- (id)initWithGeometry:(OTSGeometry *)_component segIndex:(int)_segIndex pt:(OTSCoordinate *)_pt;
- (id)initWithGeometry:(OTSGeometry *)_component pt:(OTSCoordinate *)_pt;
- (BOOL)isInsideArea;

@end
