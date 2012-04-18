//
//  OTSPointExtractor.h
//  OTS
//
//  Created by Purbo Mohamad on 3/14/10.
//  Copyright 2010 objgeo.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTSGeometryFilter.h"

@class OTSGeometry;


@interface OTSPointExtractor : NSObject <OTSGeometryFilter> {
	NSMutableArray *comps;
}

+ (void)extractPointsFrom:(OTSGeometry * const)geom into:(NSMutableArray *)ret;
- (id)initWithPoints:(NSMutableArray *)newComps;

@end
