//
//  RelateTest.m
//  OTS
//
//  Created by Purbo Mohamad on 3/13/10.
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

@interface RelateTest : GTMTestCase {	
@private
	OTSGeometryFactory *factory;
}
@end

@implementation RelateTest

- (void)setUp {
	factory = [OTSGeometryFactory getDefaultInstance];
}

- (void)tearDown {
	//[factory release];
}

- (void)testRelates {
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
	
	OTSLineString *ls1 = [OTSLineString lineStringWithFactory:factory coordinates:
							 [OTSCoordinate coordinateWithX:0.0 Y:0.0], 
							 [OTSCoordinate coordinateWithX:2.0 Y:0.0],
							 [OTSCoordinate coordinateWithX:2.0 Y:-2.0],
							 nil];
	OTSLineString *ls2 = [OTSLineString lineStringWithFactory:factory coordinates:
							 [OTSCoordinate coordinateWithX:10.0 Y:10.0], 
							 [OTSCoordinate coordinateWithX:15.0 Y:10.0],
							 [OTSCoordinate coordinateWithX:15.0 Y:15.0],
							 nil];
	OTSLineString *ls3 = [OTSLineString lineStringWithFactory:factory coordinates:
							 [OTSCoordinate coordinateWithX:1.5 Y:0.0], 
							 [OTSCoordinate coordinateWithX:2.5 Y:0.0],
							 [OTSCoordinate coordinateWithX:2.5 Y:1.5],
							 nil];
	OTSLineString *ls4 = [OTSLineString lineStringWithFactory:factory coordinates:
							 [OTSCoordinate coordinateWithX:1.5 Y:0.0], 
							 [OTSCoordinate coordinateWithX:2.5 Y:0.0],
							 [OTSCoordinate coordinateWithX:2.5 Y:0.5],
							 nil];
	
	OTSLinearRing *shell2 = [factory createLinearRingWithCoordinateSequence:
								[OTSCoordinateSequence coordinateSequenceWithCoordinates:
								 [OTSCoordinate coordinateWithX:2.5 Y:0.0], 
								 [OTSCoordinate coordinateWithX:2.5 Y:1.0], 
								 [OTSCoordinate coordinateWithX:3.0 Y:2.0], 
								 [OTSCoordinate coordinateWithX:5.0 Y:1.0], 
								 [OTSCoordinate coordinateWithX:5.0 Y:0.0], 
								 [OTSCoordinate coordinateWithX:2.5 Y:0.0],
								 nil]];
	OTSPolygon *poly2 = [factory createPolygonWithShell:shell2 holes:nil];
	
	OTSLinearRing *shell3 = [factory createLinearRingWithCoordinateSequence:
								[OTSCoordinateSequence coordinateSequenceWithCoordinates:
								 [OTSCoordinate coordinateWithX:12.5 Y:10.0], 
								 [OTSCoordinate coordinateWithX:12.5 Y:11.0], 
								 [OTSCoordinate coordinateWithX:13.0 Y:12.0], 
								 [OTSCoordinate coordinateWithX:15.0 Y:11.0], 
								 [OTSCoordinate coordinateWithX:15.0 Y:10.0], 
								 [OTSCoordinate coordinateWithX:12.5 Y:10.0],
								 nil]];
	OTSPolygon *poly3 = [factory createPolygonWithShell:shell3 holes:nil];
	
	STAssertTrue([poly intersects:ls1], nil);
	STAssertTrue(![poly intersects:ls2], nil);
	STAssertTrue([poly intersects:ls3], nil);
	STAssertTrue(![poly contains:ls3], nil);
	STAssertTrue(![ls3 within:poly], nil);
	STAssertTrue([poly contains:ls4], nil);
	STAssertTrue([ls4 within:poly], nil);
	
	STAssertTrue([poly intersects:poly2], nil);
	STAssertTrue(![poly contains:poly2], nil);
	STAssertTrue([poly2 intersects:poly], nil);
	STAssertTrue(![poly2 within:poly], nil);
	
	STAssertTrue(![poly intersects:poly3], nil);
}

- (void)testPolygonIntersects {
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
	
	STAssertTrue([poly1 intersects:poly2], nil);
	STAssertTrue(![poly1 contains:poly2], nil);
	STAssertTrue(![poly1 disjoint:poly2], nil);
	STAssertTrue(![poly1 within:poly2], nil);
	
	[poly1 release];
	[poly2 release];
}

- (void)testPolygonContains {
	OTSLinearRing *shell1 = [factory createLinearRingWithCoordinateSequence:
								[OTSCoordinateSequence coordinateSequenceWithCoordinates:
								 [OTSCoordinate coordinateWithX:0.1 Y:0.1], 
								 [OTSCoordinate coordinateWithX:0.4 Y:0.1], 
								 [OTSCoordinate coordinateWithX:0.4 Y:0.4], 
								 [OTSCoordinate coordinateWithX:0.1 Y:0.4], 
								 [OTSCoordinate coordinateWithX:0.1 Y:0.1], 
								 nil]];
	OTSPolygon *poly1 = [factory createPolygonWithShell:shell1 holes:nil];
	
	OTSLinearRing *shell3 = [factory createLinearRingWithCoordinateSequence:
								[OTSCoordinateSequence coordinateSequenceWithCoordinates:
								 [OTSCoordinate coordinateWithX:0.15 Y:0.15], 
								 [OTSCoordinate coordinateWithX:0.35 Y:0.15], 
								 [OTSCoordinate coordinateWithX:0.35 Y:0.35], 
								 [OTSCoordinate coordinateWithX:0.15 Y:0.35], 
								 [OTSCoordinate coordinateWithX:0.15 Y:0.15], 
								 nil]];
	OTSPolygon *poly3 = [factory createPolygonWithShell:shell3 holes:nil];
	
	STAssertTrue([poly1 intersects:poly3], nil);
	STAssertTrue([poly1 contains:poly3], nil);
	STAssertTrue([poly3 within:poly1], nil);
	STAssertTrue(![poly3 contains:poly1], nil);
	STAssertTrue(![poly1 within:poly3], nil);
}

- (void)testPolygonLineStringsIntersect {
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
	
	OTSLineString *ls1 = [OTSLineString lineStringWithFactory:factory coordinates:
							 [OTSCoordinate coordinateWithX:0.45 Y:0.45], 
							 [OTSCoordinate coordinateWithX:0.65 Y:0.65],
							 [OTSCoordinate coordinateWithX:0.65 Y:0.45],
							 nil];
	OTSLineString *ls2 = [OTSLineString lineStringWithFactory:factory coordinates:
							 [OTSCoordinate coordinateWithX:0.15 Y:0.15], 
							 [OTSCoordinate coordinateWithX:0.175 Y:0.175],
							 [OTSCoordinate coordinateWithX:0.15 Y:0.175],
							 nil];
	
	STAssertTrue(![poly1 intersects:ls1], nil);
	STAssertTrue([poly2 intersects:ls1], nil);
	STAssertTrue(![poly2 contains:ls1], nil);
	STAssertTrue([poly1 contains:ls2], nil);
	STAssertTrue(![ls1 intersects:ls2], nil);
	
}

@end
