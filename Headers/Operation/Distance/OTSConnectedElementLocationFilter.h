//
//  OTSConnectedElementLocationFilter.h
//  OTS
//
//  Created by Purbo Mohamad on 3/13/10.
//  Copyright 2010 objgeo.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTSGeometryFilter.h" // for inheritance

@class Geometry;
@class GeometryLocation;

@interface OTSConnectedElementLocationFilter : NSObject <OTSGeometryFilter> {
	NSArray *locations;
}

@property (nonatomic, retain) NSArray *locations;

+ (NSArray *)getLocations:(OTSGeometry *)geom;

@end
