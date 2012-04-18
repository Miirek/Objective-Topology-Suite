//
//  DistanceOpTest.m
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
#import "OTSDistanceOp.h"

@interface DistanceOpTest : GTMTestCase {	
@private
	OTSGeometryFactory *factory;
}
@end

@implementation DistanceOpTest

- (void)setUp {
	factory = [OTSGeometryFactory getDefaultInstance];
}

- (void)tearDown {
	//[factory release];
}

- (void)testPolygonDistance {
	OTSLinearRing *shell = [factory createLinearRingWithCoordinateSequence:
							[OTSCoordinateSequence coordinateSequenceWithCoordinates:
							 [OTSCoordinate coordinateWithX:1.0 Y:0.0], 
							 [OTSCoordinate coordinateWithX:2.0 Y:1.0], 
							 [OTSCoordinate coordinateWithX:3.0 Y:1.0], 
							 [OTSCoordinate coordinateWithX:4.0 Y:0.0], 
							 [OTSCoordinate coordinateWithX:3.0 Y:-1.0], 
							 [OTSCoordinate coordinateWithX:2.0 Y:-1.0],
							 [OTSCoordinate coordinateWithX:1.0 Y:0.0], 
							 nil]];
	OTSPolygon *poly = [factory createPolygonWithShell:shell holes:nil];
	OTSLinearRing *shell1 = [factory createLinearRingWithCoordinateSequence:
							[OTSCoordinateSequence coordinateSequenceWithCoordinates:
							 [OTSCoordinate coordinateWithX:11.0 Y:10.0], 
							 [OTSCoordinate coordinateWithX:12.0 Y:11.0], 
							 [OTSCoordinate coordinateWithX:13.0 Y:11.0], 
							 [OTSCoordinate coordinateWithX:14.0 Y:10.0], 
							 [OTSCoordinate coordinateWithX:13.0 Y:9.0], 
							 [OTSCoordinate coordinateWithX:12.0 Y:9.0],
							 [OTSCoordinate coordinateWithX:11.0 Y:10.0], 
							 nil]];
	OTSPolygon *poly1 = [factory createPolygonWithShell:shell1 holes:nil];
	
	OTSCoordinateSequence *result = [OTSDistanceOp nearestPointsOf:poly andGeometry:poly1];
	for (int i = 0; i < [result size]; i++) {
		NSLog(@"%d:%@", i, [result getAt:i]);
	}
	NSLog(@"distance:%.6f", [OTSDistanceOp distanceOf:poly to:poly1]);	
	STAssertFalse([OTSDistanceOp isGeometry:poly andGeometry:poly1 withinDistanceOf:10.0], @"shouldn't be within 10.0");
	STAssertTrue([OTSDistanceOp isGeometry:poly andGeometry:poly1 withinDistanceOf:15.0], @"should be within 15.0");
}

@end