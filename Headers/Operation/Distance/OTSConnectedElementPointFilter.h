//
//  OTSConnectedElementPointFilter.h
//  OTS
//
//  Created by Purbo Mohamad on 3/13/10.
//  Copyright 2010 objgeo.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTSGeometryFilter.h" // for inheritance

@class OTSCoordinate;
@class OTSGeometry;

@interface OTSConnectedElementPointFilter : NSObject <OTSGeometryFilter> {
	NSMutableArray *pts;
}

@property (nonatomic, retain) NSMutableArray *pts;

- (id)initWithCoordinates:(NSMutableArray *)_pts;
+ (NSArray *)getCoordinates:(OTSGeometry * const)geom;

@end
