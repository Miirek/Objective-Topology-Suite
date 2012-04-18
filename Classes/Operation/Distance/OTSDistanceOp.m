//
//  OTSDistanceOp.m
//  OTS
//
//  Created by Purbo Mohamad on 3/13/10.
//  Copyright 2010 objgeo.org. All rights reserved.
//

#import "OTSDistanceOp.h"
#import "OTSGeometryLocation.h"
#import "OTSConnectedElementLocationFilter.h"
#import "OTSPointLocator.h"
#import "OTSCGAlgorithms.h" 
#import "OTSCoordinate.h"
#import "OTSCoordinateSequence.h"
#import "OTSLineString.h"
#import "OTSPoint.h"
#import "OTSPolygon.h"
#import "OTSEnvelope.h"
#import "OTSLineSegment.h"
#import "OTSPolygonExtractor.h"
#import "OTSLinearComponentExtractor.h"
#import "OTSPointExtractor.h"

@interface OTSDistanceOp(Private)

- (void)updateMinDistanceWithFlip:(BOOL)flip;
- (void)computeMinDistance;
- (void)computeContainmentDistance;
- (void)computeInside:(NSArray *)locs polys:(NSArray *)polys;
- (void)computeInside:(OTSGeometryLocation *)ptLoc poly:(OTSPolygon *)poly;

- (void)computeFacetDistance;
- (void)computeMinDistanceLines:(NSArray *)lines0 andLines:(NSArray *)lines1;
- (void)computeMinDistancePoints:(NSArray *)points0 andPoints:(NSArray *)points1;
- (void)computeMinDistanceLines:(NSArray *)lines andPoints:(NSArray *)points;
- (void)computeMinDistanceLine:(OTSLineString * const)line0 andLine:(OTSLineString * const)line1;
- (void)computeMinDistanceLine:(OTSLineString * const)line andPoint:(OTSPoint * const)pt;

@end

@implementation OTSDistanceOp

@synthesize locGeom0, locGeom1, locPtPoly0, locPtPoly1, minDistanceLocation0, minDistanceLocation1;

+ (double)distanceOf:(OTSGeometry * const)g0 to:(OTSGeometry * const)g1 {
	OTSDistanceOp *distOp = [[OTSDistanceOp alloc] initWithGeometry:g0 andGeometry:g1];
	double distance = [distOp distance];
	[distOp release];
	return distance;	
}

+ (BOOL)isGeometry:(OTSGeometry * const)g0 andGeometry:(OTSGeometry * const)g1 withinDistanceOf:(double)distance {
	OTSDistanceOp *distOp = [[OTSDistanceOp alloc] initWithGeometry:g0 andGeometry:g1 terminateDistance:distance];
	BOOL ret = [distOp distance] <= distance;
	[distOp release];
	return ret;	
}

+ (OTSCoordinateSequence *)nearestPointsOf:(OTSGeometry * const)g0 andGeometry:(OTSGeometry * const)g1 {
	OTSDistanceOp *distOp = [[OTSDistanceOp alloc] initWithGeometry:g0 andGeometry:g1];
	OTSCoordinateSequence *nearestPoints = [distOp nearestPoints];
	[distOp release];
	return nearestPoints;
}

+ (OTSCoordinateSequence *)closestPointsOf:(OTSGeometry * const)g0 andGeometry:(OTSGeometry * const)g1 {
	OTSDistanceOp *distOp = [[OTSDistanceOp alloc] initWithGeometry:g0 andGeometry:g1];
	OTSCoordinateSequence *closestPoints = [distOp closestPoints];
	[distOp release];
	return closestPoints;
}

- (id)initWithGeometry:(OTSGeometry * const)g0 andGeometry:(OTSGeometry * const)g1 {
	if (self = [super init]) {
		geom0 = [g0 retain];
		geom1 = [g1 retain];
		terminateDistance = 0.0;
		minDistance = DBL_MAX;
		
		minDistanceLocation0 = nil;
		minDistanceLocation1 = nil;
		locGeom0 = nil;
		locGeom1 = nil;
		locPtPoly0 = nil;
		locPtPoly1 = nil;
		
		ptLocator = [[OTSPointLocator alloc] init];
	}
	return self;
}

- (id)initWithGeometry:(OTSGeometry * const)g0 andGeometry:(OTSGeometry * const)g1 terminateDistance:(double)_terminateDistance {
	if (self = [super init]) {
		geom0 = [g0 retain];
		geom1 = [g1 retain];
		terminateDistance = _terminateDistance;
		minDistance = DBL_MAX;
		
		minDistanceLocation0 = nil;
		minDistanceLocation1 = nil;		
		locGeom0 = nil;
		locGeom1 = nil;
		locPtPoly0 = nil;
		locPtPoly1 = nil;
		
		ptLocator = [[OTSPointLocator alloc] init];
	}
	return self;
}

- (void)dealloc {
	[geom0 release];
	[geom1 release];
	[ptLocator release];
	[minDistanceLocation0 release];
	[minDistanceLocation1 release];
	[locGeom0 release];
	[locGeom1 release];
	[locPtPoly0 release];
	[locPtPoly1 release];
	[super dealloc];
}

- (double)distance {
	[self computeMinDistance];
	return minDistance;
}

- (OTSCoordinateSequence *)closestPoints {
	return [self nearestPoints];
}

- (OTSCoordinateSequence *)nearestPoints {
	// lazily creates minDistanceLocation
	[self computeMinDistance];
	
	// Empty input geometries result in this behaviour
	if (minDistanceLocation0 == nil || minDistanceLocation1 == nil) {
		// either both or none are set..
		NSAssert(minDistanceLocation0 == nil && minDistanceLocation1 == nil, @"Either both or none of min distance needs to be set");
		return nil;
	}
	OTSCoordinateSequence *nearestPts = [[OTSCoordinateSequence alloc] init];
	[nearestPts add:minDistanceLocation0.pt];
	[nearestPts add:minDistanceLocation1.pt];	 
	return [nearestPts autorelease];
}

- (void)updateMinDistanceWithFlip:(BOOL)flip {
	// if not set then don't update
	if (locGeom0 == nil) {
		NSAssert(locGeom1 == nil, @"None or both should be set");
		return;
	}
	
	if (flip) {
		self.minDistanceLocation0 = locGeom1;
		self.minDistanceLocation1 = locGeom0;
	} else {
		self.minDistanceLocation0 = locGeom0;
		self.minDistanceLocation1 = locGeom1;
	}	
}

- (void)computeMinDistance {
	// only compute once!
	if (minDistanceLocation0 != nil && minDistanceLocation1 != nil) return;	
	[self computeContainmentDistance];	
	if (minDistance <= terminateDistance) {
		return;
	}
	[self computeFacetDistance];
}

- (void)computeContainmentDistance {
	
	NSMutableArray *polys1 = [[NSMutableArray alloc] init];
	[OTSPolygonExtractor extractPolygonsFrom:geom1 into:polys1];
	
	// NOTE:
	// Expected to fill minDistanceLocation items
	// if minDistance <= terminateDistance
	
	// test if either geometry has a vertex inside the other
	if ([polys1 count] > 0) {
		NSArray *insideLocs0 = [OTSConnectedElementLocationFilter getLocations:geom0];
		[self computeInside:insideLocs0 polys:polys1];
		if (minDistance <= terminateDistance) {
			self.minDistanceLocation0 = locPtPoly0;
			self.minDistanceLocation1 = locPtPoly1;
      [polys1 release];
			return;
		}
	}
	
	NSMutableArray *polys0 = [[NSMutableArray alloc] init];
	[OTSPolygonExtractor extractPolygonsFrom:geom0 into:polys0];
	
	if ([polys0 count] > 0) {
		NSArray *insideLocs1 = [OTSConnectedElementLocationFilter getLocations:geom1];
		[self computeInside:insideLocs1 polys:polys0];
		if (minDistance <= terminateDistance) {
			self.minDistanceLocation0 = locPtPoly0;
			self.minDistanceLocation1 = locPtPoly1;
		}
	}
	
	[polys0 release];
	[polys1 release];
	
	// If minDistance <= terminateDistance we must have
	// set minDistanceLocations to some non-null item
	/*
	assert( minDistance > terminateDistance ||
		   ( (*minDistanceLocation)[0] && (*minDistanceLocation)[1] ) );	
	 */
}

- (void)computeInside:(NSArray *)locs polys:(NSArray *)polys {
	for (int i = 0, ni = [locs count]; i < ni; ++i) {
		OTSGeometryLocation *loc = [locs objectAtIndex:i];
		for (int j = 0, nj = [polys count]; j < nj; ++j) {
			[self computeInside:loc poly:[polys objectAtIndex:j]];
			if (minDistance <= terminateDistance) return;
		}
	}
}

- (void)computeInside:(OTSGeometryLocation *)ptLoc poly:(OTSPolygon *)poly {	
	// if pt is not in exterior, distance to geom is 0
	if ([ptLocator locate:ptLoc.pt relativeTo:poly] != kOTSLocationExterior) {
		minDistance = 0.0;
		self.locPtPoly0 = ptLoc;
		self.locPtPoly1 = [[[OTSGeometryLocation alloc] initWithGeometry:poly pt:ptLoc.pt] autorelease];
	}
}

- (void)computeFacetDistance {
	/**
	 * Geometries are not wholely inside, so compute distance from lines
	 * and points
	 * of one to lines and points of the other
	 */
	NSMutableArray *lines0 = [[NSMutableArray alloc] init];
	NSMutableArray *lines1 = [[NSMutableArray alloc] init];
	[OTSLinearComponentExtractor getLinesFromGeometry:geom0 into:lines0];
	[OTSLinearComponentExtractor getLinesFromGeometry:geom1 into:lines1];
	
	NSMutableArray *pts0 = [[NSMutableArray alloc] init];
	NSMutableArray *pts1 = [[NSMutableArray alloc] init];
	[OTSPointExtractor extractPointsFrom:geom0 into:pts0];
	[OTSPointExtractor extractPointsFrom:geom1 into:pts1];
	
	// exit whenever minDistance goes LE than terminateDistance
	[self computeMinDistanceLines:lines0 andLines:lines1];
	[self updateMinDistanceWithFlip:false];
	if (minDistance <= terminateDistance) {
    [lines0 release];
    [lines1 release];
    [pts0 release];
    [pts1 release];
		return;
	};
	
	self.locGeom0 = nil;
	self.locGeom1 = nil;
	[self computeMinDistanceLines:lines0 andPoints:pts1];
	[self updateMinDistanceWithFlip:false];
	if (minDistance <= terminateDistance) {
    [lines0 release];
    [lines1 release];
    [pts0 release];
    [pts1 release];
		return;
	};
	
	self.locGeom0 = nil;
	self.locGeom1 = nil;
	[self computeMinDistanceLines:lines1 andPoints:pts0];
	[self updateMinDistanceWithFlip:true];
	if (minDistance <= terminateDistance){
    [lines0 release];
    [lines1 release];
    [pts0 release];
    [pts1 release];
		return;
	};
	
	self.locGeom0 = nil;
	self.locGeom1 = nil;
	[self computeMinDistancePoints:pts0 andPoints:pts1];
	[self updateMinDistanceWithFlip:false];
	
	[lines0 release];
	[lines1 release];
	[pts0 release];
	[pts1 release];
}

- (void)computeMinDistanceLines:(NSArray *)lines0 andLines:(NSArray *)lines1 {
	for (int i = 0, ni = [lines0 count]; i < ni; ++i) {
		OTSLineString *line0 = [lines0 objectAtIndex:i];
		for (int j=0, nj = [lines1 count]; j < nj; ++j) {
			OTSLineString *line1 = [lines1 objectAtIndex:j];
			[self computeMinDistanceLine:line0 andLine:line1];
			if (minDistance <= terminateDistance) return;
		}
	}
}

- (void)computeMinDistancePoints:(NSArray *)points0 andPoints:(NSArray *)points1 {
	for (int i = 0, ni = [points0 count]; i < ni; ++i) {
		OTSPoint *pt0 = [points0 objectAtIndex:i];
		for (int j = 0, nj = [points1 count]; j < nj; ++j) {
			OTSPoint *pt1 = [points1 objectAtIndex:j];
			double dist = [[pt0 getCoordinate] distance:[pt1 getCoordinate]];			
			if (dist < minDistance) {
				minDistance = dist;
				// this is wrong - need to determine closest points on both segments!!!
				self.locGeom0 = [[[OTSGeometryLocation alloc] initWithGeometry:pt0 segIndex:0 pt:[pt0 getCoordinate]] autorelease];
				self.locGeom1 = [[[OTSGeometryLocation alloc] initWithGeometry:pt1 segIndex:0 pt:[pt1 getCoordinate]] autorelease];
			}			
			if (minDistance <= terminateDistance) return;
		}
	}	
}

- (void)computeMinDistanceLines:(NSArray *)lines andPoints:(NSArray *)points {
	for (OTSLineString *line in lines) {
		for (OTSPoint *point in points) {
			[self computeMinDistanceLine:line andPoint:point];
			if (minDistance <= terminateDistance) return;
		}
	}
}

- (void)computeMinDistanceLine:(OTSLineString * const)line0 andLine:(OTSLineString * const)line1 {
	
	OTSEnvelope *env0 = [line0 getEnvelopeInternal];
	OTSEnvelope *env1 = [line1 getEnvelopeInternal];
	if ([env0 distanceTo:env1] > minDistance) {
		return;
	}
	
	OTSCoordinateSequence *coord0 = [line0 getCoordinatesRO];
	OTSCoordinateSequence *coord1 = [line1 getCoordinatesRO];
	int npts0 = [coord0 size];
	int npts1 = [coord1 size];
	
	// brute force approach!
	for(int i = 0; i < npts0 - 1; ++i) {
		for(int j = 0; j < npts1 - 1; ++j) {
			double dist = [OTSCGAlgorithms distanceLineLine:[coord0 getAt:i] B:[coord0 getAt:i + 1] 
														  C:[coord1 getAt:j] D:[coord1 getAt:j + 1]];
			if (dist < minDistance) {
				minDistance = dist;
				OTSLineSegment *seg0 = [[OTSLineSegment alloc] initWithCoordinate:[coord0 getAt:i] toCoordinate:[coord0 getAt:i + 1]];
				OTSLineSegment *seg1 = [[OTSLineSegment alloc] initWithCoordinate:[coord1 getAt:j] toCoordinate:[coord1 getAt:j + 1]];
				OTSCoordinateSequence *closestPt = [seg0 closestPoints:seg1];
				[seg0 release];
				[seg1 release];
				self.locGeom0 = [[[OTSGeometryLocation alloc] initWithGeometry:line0 segIndex:i pt:[closestPt getAt:0]] autorelease];
				self.locGeom1 = [[[OTSGeometryLocation alloc] initWithGeometry:line1 segIndex:j pt:[closestPt getAt:1]] autorelease];				
			}
			if (minDistance <= terminateDistance) return;
		}
	}
	
}

- (void)computeMinDistanceLine:(OTSLineString * const)line andPoint:(OTSPoint * const)pt {

	OTSEnvelope *env0 = [line getEnvelopeInternal];
	OTSEnvelope *env1 = [pt getEnvelopeInternal];
	if ([env0 distanceTo:env1] > minDistance) {
		return;
	}
	OTSCoordinateSequence *coord0 = [line getCoordinatesRO];
	OTSCoordinate *coord = [OTSCoordinate coordinateWithCoordinate:[pt getCoordinate]];
	
	// brute force approach!
	int npts0 = [coord0 size];
	for(int i = 0; i < npts0 - 1; ++i) {
		double dist = [OTSCGAlgorithms distancePointLine:coord A:[coord0 getAt:i] B:[coord0 getAt:i + 1]];
		if (dist < minDistance) {
			minDistance = dist;
			OTSLineSegment *seg = [[OTSLineSegment alloc] initWithCoordinate:[coord0 getAt:i] toCoordinate:[coord0 getAt:i + 1]];
			OTSCoordinate *segClosestPoint = [seg closestPoint:coord];
			self.locGeom0 = [[[OTSGeometryLocation alloc] initWithGeometry:line segIndex:i pt:segClosestPoint] autorelease];
			self.locGeom1 = [[[OTSGeometryLocation alloc] initWithGeometry:pt segIndex:0 pt:coord] autorelease];			
			[seg release];
		}
		if (minDistance <= terminateDistance) return;
	}
}

@end
 

