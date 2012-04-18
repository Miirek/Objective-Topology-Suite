//
//  OTSPolygonExtractor.h
//  OTS
//
//  Created by Purbo Mohamad on 3/14/10.
//  Copyright 2010 objgeo.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTSGeometryFilter.h"

@class OTSGeometry;

@interface OTSPolygonExtractor : NSObject <OTSGeometryFilter> {
	NSMutableArray *comps;
}

+ (void)extractPolygonsFrom:(OTSGeometry *)geom into:(NSMutableArray *)ret;
- (id)initWithPolygons:(NSMutableArray *)newComps;

@end
