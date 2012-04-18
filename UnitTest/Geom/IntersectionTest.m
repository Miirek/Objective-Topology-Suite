//
//  PolygonIntersectionTest.m
//  OTS
//
//  Created by Purbo Mohamad on 3/11/10.
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

@interface IntersectionTest : GTMTestCase {	
	@private
	OTSGeometryFactory *factory;
}
@end

@implementation IntersectionTest

- (void)setUp {
	factory = [OTSGeometryFactory getDefaultInstance];
}

- (void)tearDown {
	//[factory release];
}

- (void)testIntersection2Polygons {
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
	OTSGeometry *result = [poly1 intersection:poly2];
	
	STAssertNotNil(result, @"Result shouldn't be nil");
	STAssertEquals([result getGeometryTypeId], kOTSGeometryPolygon, @"Result type should be polygon");
	STAssertTrue([result isKindOfClass:[OTSPolygon class]], @"Result type should be polygon");

	OTSPolygon *resultPoly = (OTSPolygon *)result;
	OTSLinearRing *resultShell = [resultPoly shell];

	STAssertNotNil(resultShell, @"Result shell shouldn't be nil");
	STAssertEquals([resultShell getNumPoints], 5, @"Result shell should have 5 points");
	
	STAssertEquals([resultShell getCoordinateN:0].x, 0.2, @"Unexpected result");
	STAssertEquals([resultShell getCoordinateN:0].y, 0.4, @"Unexpected result");
	STAssertEquals([resultShell getCoordinateN:1].x, 0.4, @"Unexpected result");
	STAssertEquals([resultShell getCoordinateN:1].y, 0.4, @"Unexpected result");
	STAssertEquals([resultShell getCoordinateN:2].x, 0.4, @"Unexpected result");
	STAssertEquals([resultShell getCoordinateN:2].y, 0.2, @"Unexpected result");
	STAssertEquals([resultShell getCoordinateN:3].x, 0.2, @"Unexpected result");
	STAssertEquals([resultShell getCoordinateN:3].y, 0.2, @"Unexpected result");
	STAssertEquals([resultShell getCoordinateN:4].x, 0.2, @"Unexpected result");
	STAssertEquals([resultShell getCoordinateN:4].y, 0.4, @"Unexpected result");
}

- (void)testIntersectionPolygonAnd2Lines {
	
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
	
	OTSMultiLineString *mls = [factory createMultiLineStringWithArray:
								  [NSArray arrayWithObjects:
								   [OTSLineString lineStringWithFactory:factory coordinates:
									[OTSCoordinate coordinateWithX:0.0 Y:0.0], 
									[OTSCoordinate coordinateWithX:2.0 Y:0.0],
									[OTSCoordinate coordinateWithX:2.0 Y:-2.0],
									nil], 
								   [OTSLineString lineStringWithFactory:factory coordinates:
									[OTSCoordinate coordinateWithX:2.5 Y:3.0], 
									[OTSCoordinate coordinateWithX:2.5 Y:0.0],
									[OTSCoordinate coordinateWithX:5.0 Y:0.0],
									nil], 
								   nil]];
	
	OTSGeometry *result = [poly intersection:mls];
	
	STAssertNotNil(result, @"Result shouldn't be nil");
	STAssertEquals([result getGeometryTypeId], kOTSGeometryMultiLineString, @"Result should be multi line string");
	STAssertTrue([result isKindOfClass:[OTSMultiLineString class]], @"Result should be multi line string");
	
	OTSMultiLineString *resultMls = (OTSMultiLineString *)result;
	STAssertEquals([resultMls getNumGeometries], 2, @"Expecting 2 geometries");
	
	OTSGeometry *resultGeom1 = [resultMls getGeometryN:0];
	STAssertTrue([resultGeom1 isKindOfClass:[OTSLineString class]], @"Expecting line string result");
	
	OTSLineString *resultLs1 = (OTSLineString *)resultGeom1;
	STAssertEquals([resultLs1 getNumPoints], 3, @"Expecting 3 points");
	STAssertEquals(1.0, [resultLs1 getCoordinateN:0].x, @"Unexpected result");
	STAssertEquals(0.0, [resultLs1 getCoordinateN:0].y, @"Unexpected result");
	STAssertEquals(2.0, [resultLs1 getCoordinateN:1].x, @"Unexpected result");
	STAssertEquals(0.0, [resultLs1 getCoordinateN:1].y, @"Unexpected result");
	STAssertEquals(2.0, [resultLs1 getCoordinateN:2].x, @"Unexpected result");
	STAssertEquals(-1.0, [resultLs1 getCoordinateN:2].y, @"Unexpected result");
	
	OTSGeometry *resultGeom2 = [resultMls getGeometryN:1];
	STAssertTrue([resultGeom2 isKindOfClass:[OTSLineString class]], @"Expecting line string result");
	
	OTSLineString *resultLs2 = (OTSLineString *)resultGeom2;
	STAssertEquals([resultLs2 getNumPoints], 3, @"Expecting 3 points");
	STAssertEquals(2.5, [resultLs2 getCoordinateN:0].x, @"Unexpected result");
	STAssertEquals(1.0, [resultLs2 getCoordinateN:0].y, @"Unexpected result");
	STAssertEquals(2.5, [resultLs2 getCoordinateN:1].x, @"Unexpected result");
	STAssertEquals(0.0, [resultLs2 getCoordinateN:1].y, @"Unexpected result");
	STAssertEquals(4.0, [resultLs2 getCoordinateN:2].x, @"Unexpected result");
	STAssertEquals(0.0, [resultLs2 getCoordinateN:2].y, @"Unexpected result");
}

@end
