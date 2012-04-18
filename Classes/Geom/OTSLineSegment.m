//
//  OTSLineSegment.m
//

#import "OTSLineSegment.h"
#import "OTSLineString.h" // for toGeometry
#import "OTSCoordinate.h"
#import "OTSCoordinateSequence.h"
#import "OTSGeometryFactory.h"
#import "OTSCGAlgorithms.h"
#import "OTSLineIntersector.h"
#import "OTSHCoordinate.h"
#import "OTSNotRepresentableException.h"


@implementation OTSLineSegment

@synthesize p0;
@synthesize p1;

- (id)initWithCoordinate:(OTSCoordinate *)_p0 toCoordinate:(OTSCoordinate *)_p1 {
	if (self = [super init]) {
		self.p0 = _p0;
		self.p1 = _p1;
	}
	return self;
}

- (void)dealloc {
	[p0 release];
	[p1 release];
	[super dealloc];
}

- (double)distance:(OTSCoordinate *)p {
	return [OTSCGAlgorithms distancePointLine:p A:p0 B:p1];
}

- (double)projectionFactor:(OTSCoordinate *)p {
	if ([p isEqual2D:p0]) return 0.0;
	if ([p isEqual2D:p1]) return 1.0;
    // Otherwise, use comp.graphics.algorithms Frequently Asked Questions method
    /*(1)     	      AC dot AB
	 r = ---------
	 ||AB||^2
	 r has the following meaning:
	 r=0 P = A
	 r=1 P = B
	 r<0 P is on the backward extension of AB
	 r>1 P is on the forward extension of AB
	 0<r<1 P is interior to AB
	 */
	double dx = p1.x - p0.x;
	double dy = p1.y - p0.y;
	double len2 = dx*dx + dy*dy;
	double r = ((p.x - p0.x)*dx + (p.y - p0.y)*dy) / len2;
	return r;
}

- (OTSCoordinate *)project:(OTSCoordinate *)p {
	if ([p isEqual2D:p0] || [p isEqual2D:p1]) 
		return [OTSCoordinate coordinateWithCoordinate:p];
	double r = [self projectionFactor:p];
	return [OTSCoordinate coordinateWithX:p0.x+r*(p1.x-p0.x) Y:p0.y+r*(p1.y-p0.y)];
}

- (OTSCoordinate *)closestPoint:(OTSCoordinate *)p {
	double factor = [self projectionFactor:p];
	if (factor > 0 && factor < 1) {
		return [self project:p];
	}
	double dist0 = [p0 distance:p];
	double dist1 = [p1 distance:p];
	if (dist0 < dist1) {
		return p0;
	}
	return p1;
}

- (OTSCoordinateSequence *)closestPoints:(OTSLineSegment *)line {
	// test for intersection
	OTSCoordinate *intPt = [self intersection:line];
	if (intPt != nil) {
		OTSCoordinateSequence *cl = [[OTSCoordinateSequence alloc] initWithArray:[NSArray arrayWithObjects:intPt, intPt, nil]];
		return [cl autorelease];
	}
	
	/*
	 * if no intersection closest pair contains at least one endpoint.
	 * Test each endpoint in turn.
	 */
	//OTSCoordinateSequence *closestPt = [[OTSCoordinateSequence alloc] initWithCapacity:2];
	OTSCoordinate *_closestPt[2];
	
	double minDistance = DBL_MAX;
	double dist;
	
	OTSCoordinate *close00 = [self closestPoint:line.p0];
	minDistance = [close00 distance:line.p0];
	
	//[closestPt set:close00 at:0];
	//[closestPt set:line.p0 at:1];
	_closestPt[0] = close00;
	_closestPt[1] = line.p0;
	
	OTSCoordinate *close01 = [self closestPoint:line.p1];
	dist = [close01 distance:line.p1];
	if (dist < minDistance) {
		minDistance = dist;		
		//[closestPt set:close01 at:0];
		//[closestPt set:line.p1 at:1];
		_closestPt[0] = close01;
		_closestPt[1] = line.p1;
	}
	
	OTSCoordinate *close10 = [line closestPoint:p0];
	dist = [close10 distance:p0];
	if (dist < minDistance) {
		minDistance = dist;
		//[closestPt set:p0 at:0];
		//[closestPt set:close10 at:1];
		_closestPt[0] = p0;
		_closestPt[1] = close10;
	}
	
	OTSCoordinate *close11 = [line closestPoint:p1];
	dist = [close11 distance:p1];
	if (dist < minDistance) {
		minDistance = dist;
		//[closestPt set:p1 at:0];
		//[closestPt set:close11 at:1];
		_closestPt[0] = p1;
		_closestPt[1] = close11;
	}
	
	OTSCoordinateSequence *closestPt = [[OTSCoordinateSequence alloc] init];
	[closestPt add:_closestPt[0]];
	[closestPt add:_closestPt[1]];
	return [closestPt autorelease];
}

- (OTSCoordinate *)intersection:(OTSLineSegment *)line {
	OTSLineIntersector *li = [[OTSLineIntersector alloc] init];
	[li computeIntersectionOfLineOfPoint:p0 to:p1 andLineOfPoint:line.p0 to:line.p1];
	OTSCoordinate *ret = nil;
	if ([li hasIntersection]) {
		ret = [li getIntersection:0];
	}
	[li release];
	return ret;
}

@end
