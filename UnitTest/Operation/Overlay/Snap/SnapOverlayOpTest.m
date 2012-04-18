//
//  SnapOverlayOpTest.m
//  OTS
//
//  Created by Purbo Mohamad on 3/15/10.
//  Copyright 2010 objgeo.org. All rights reserved.
//

#import "GTMSenTestCase.h"
#import <UIKit/UIKit.h>
#import "OTSCoordinate.h"
#import "OTSCoordinateSequence.h"
#import "OTSGeometryFactory.h"
#import "OTSMultiLineString.h"
#import "OTSLinearRing.h"
#import "OTSPolygon.h"
#import "OTSSnapOverlayOp.h"

@interface SnapOverlayOpTest : GTMTestCase {	
@private
	OTSGeometryFactory *factory;
}
@end

@implementation SnapOverlayOpTest

- (void)setUp {
	factory = [OTSGeometryFactory getDefaultInstance];
}

- (void)tearDown {
	//[factory release];
}

- (void)testIntersectionOfGeometry {
  
	OTSLinearRing *shell1 = [factory createLinearRingWithCoordinateSequence:
                           [OTSCoordinateSequence coordinateSequenceWithCoordinates:
                            [OTSCoordinate coordinateWithX:0.1 Y:0.1], 
                            [OTSCoordinate coordinateWithX:0.4 Y:0.1], 
                            [OTSCoordinate coordinateWithX:0.4 Y:0.4], 
                            [OTSCoordinate coordinateWithX:0.1 Y:0.4], 
                            [OTSCoordinate coordinateWithX:0.1 Y:0.1], 
                            nil]];
	OTSPolygon *poly1 = [factory createPolygonWithShell:shell1 holes:nil];
	
	OTSLinearRing *shell2 = [factory createLinearRingWithCoordinateSequence:
                           [OTSCoordinateSequence coordinateSequenceWithCoordinates:
                            [OTSCoordinate coordinateWithX:0.2 Y:0.2], 
                            [OTSCoordinate coordinateWithX:0.5 Y:0.2], 
                            [OTSCoordinate coordinateWithX:0.5 Y:0.5], 
                            [OTSCoordinate coordinateWithX:0.2 Y:0.5], 
                            [OTSCoordinate coordinateWithX:0.2 Y:0.2], 
                            nil]];
	OTSPolygon *poly2 = [factory createPolygonWithShell:shell2 holes:nil];
	
	[poly1 retain];
	[poly2 retain];
	
	STAssertTrue(([OTSSnapOverlayOp intersectionOfGeometry1:poly1 geometry2:poly2] != nil), nil);
	
	[poly1 release];
	[poly2 release];
}

@end


