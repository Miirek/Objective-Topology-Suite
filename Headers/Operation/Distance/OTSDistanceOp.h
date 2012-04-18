//
//  OTSDistanceOp.h
//  OTS
//
//  Created by Purbo Mohamad on 3/13/10.
//  Copyright 2010 objgeo.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTSPointLocator.h" // for composition

@class OTSCoordinate;
@class OTSPolygon;
@class OTSLineString;
@class OTSPoint;
@class OTSGeometry;
@class OTSCoordinateSequence;
@class OTSGeometryLocation;

@interface OTSDistanceOp : NSObject {
	OTSGeometry *geom0;
	OTSGeometry *geom1;
	double terminateDistance; 
	OTSPointLocator *ptLocator;
	OTSGeometryLocation *minDistanceLocation0;
	OTSGeometryLocation *minDistanceLocation1;
	double minDistance;
	
	OTSGeometryLocation *locGeom0;
	OTSGeometryLocation *locGeom1;
	OTSGeometryLocation *locPtPoly0;
	OTSGeometryLocation *locPtPoly1;
}

+ (double)distanceOf:(OTSGeometry * const)g0 to:(OTSGeometry * const)g1;
+ (BOOL)isGeometry:(OTSGeometry * const)g0 andGeometry:(OTSGeometry * const)g1 withinDistanceOf:(double)distance;
+ (OTSCoordinateSequence *)nearestPointsOf:(OTSGeometry * const)g0 andGeometry:(OTSGeometry * const)g1;
+ (OTSCoordinateSequence *)closestPointsOf:(OTSGeometry * const)g0 andGeometry:(OTSGeometry * const)g1;

- (id)initWithGeometry:(OTSGeometry * const)g0 andGeometry:(OTSGeometry * const)g1;
- (id)initWithGeometry:(OTSGeometry * const)g0 andGeometry:(OTSGeometry * const)g1 terminateDistance:(double)_terminateDistance;
- (double)distance;
- (OTSCoordinateSequence *)closestPoints;
- (OTSCoordinateSequence *)nearestPoints;

@property (nonatomic, retain) OTSGeometryLocation *locGeom0;
@property (nonatomic, retain) OTSGeometryLocation *locGeom1;
@property (nonatomic, retain) OTSGeometryLocation *locPtPoly0;
@property (nonatomic, retain) OTSGeometryLocation *locPtPoly1;
@property (nonatomic, retain) OTSGeometryLocation *minDistanceLocation0;
@property (nonatomic, retain) OTSGeometryLocation *minDistanceLocation1;

@end
