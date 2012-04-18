//
//  OTSRayCrossingCounter.m
//

#import "OTSRayCrossingCounter.h"
#import "OTSRobustDeterminant.h"
#import "OTSGeometry.h"
#import "OTSLocation.h"
#import "OTSCoordinate.h"
#import "OTSCoordinateSequence.h"

@implementation OTSRayCrossingCounter

@synthesize point;
@synthesize crossingCount;
@synthesize pointOnSegment;

- (id)initWithPoint:(OTSCoordinate *)_point {
	if (self = [super init]) {
		self.point = _point;
		crossingCount = 0;
		pointOnSegment = NO;
	}
	return self;
}

- (void)dealloc {
	[point release];
	[super dealloc];
}

+ (int)locatePoint:(OTSCoordinate *)p inRing:(OTSCoordinateSequence*)ring {
	OTSRayCrossingCounter *rcc = [[OTSRayCrossingCounter alloc] initWithPoint:p];
	
	for (int i = 1, ni = [ring size]; i < ni; i++) 
	{
		OTSCoordinate *p1 = [ring getAt:i];
		OTSCoordinate *p2 = [ring getAt:i-1];
		
		[rcc countSegment:p1 p2:p2];
		
    if ([rcc pointOnSegment]) {
      int ret = [rcc getLocation];
      [rcc release];
      return ret;
    }
	}
  
  int ret = [rcc getLocation];
	[rcc release];
  return ret;
}

+ (int)locatePoint:(OTSCoordinate *)p inArrayRing:(NSArray *)ring {
	OTSRayCrossingCounter *rcc = [[OTSRayCrossingCounter alloc] initWithPoint:p];
	
	for (int i = 1, ni = [ring count]; i < ni; i++) 
	{
		OTSCoordinate *p1 = [ring objectAtIndex:i];
		OTSCoordinate *p2 = [ring objectAtIndex:i-1];
		
		[rcc countSegment:p1 p2:p2];
		
		if ([rcc pointOnSegment]) {
			int ret = [rcc getLocation];
      [rcc release];
      return ret;
    }
	}
  
  int ret = [rcc getLocation];
	[rcc release];
  return ret;
}

- (void)countSegment:(OTSCoordinate *)p1 p2:(OTSCoordinate *)p2 {
	// For each segment, check if it crosses 
	// a horizontal ray running from the test point in
	// the positive x direction.
	
	// check if the segment is strictly to the left of the test point
	if (p1.x < point.x && p2.x < point.x)
		return;
	
	// check if the point is equal to the current ring vertex
	if (point.x == p2.x && point.y == p2.y) 
	{
		pointOnSegment = YES;
		return;
	}
	
	// For horizontal segments, check if the point is on the segment.
	// Otherwise, horizontal segments are not counted.
	if (p1.y == point.y && p2.y == point.y) 
	{
		double minx = p1.x;
		double maxx = p2.x;
		
		if (minx > maxx) 
		{
			minx = p2.x;
			maxx = p1.x;
		}
		
		if (point.x >= minx && point.x <= maxx) 
			pointOnSegment = YES;
		
		return;
	}
	
	// Evaluate all non-horizontal segments which cross a horizontal ray
	// to the right of the test pt.
	// To avoid double-counting shared vertices, we use the convention that
	// - an upward edge includes its starting endpoint, and excludes its
	//   final endpoint
	// - a downward edge excludes its starting endpoint, and includes its
	//   final endpoint
	if (((p1.y > point.y) && (p2.y <= point.y)) ||
		((p2.y > point.y) && (p1.y <= point.y)) ) 
	{
		// translate the segment so that the test point lies
		// on the origin
		double x1 = p1.x - point.x;
		double y1 = p1.y - point.y;
		double x2 = p2.x - point.x;
		double y2 = p2.y - point.y;
		
		// The translated segment straddles the x-axis.
		// Compute the sign of the ordinate of intersection
		// with the x-axis. (y2 != y1, so denominator
		// will never be 0.0)
		// MD - faster & more robust computation?
		double xIntSign = [OTSRobustDeterminant signOfDet2x2WithX1:x1 y1:y1 x2:x2 y2:y2];
		if (xIntSign == 0.0) 
		{
			pointOnSegment = YES;
			return;
		}
		
		if (y2 < y1)
			xIntSign = -xIntSign;
		
		// The segment crosses the ray if the sign is strictly positive.
		if (xIntSign > 0.0) 
			crossingCount++;
	}	
}

- (int)getLocation {
	if (pointOnSegment)
		return kOTSLocationBoundary;
	
	// The point is in the interior of the ring if the number
	// of X-crossings is odd.
	if ((crossingCount % 2) == 1)
		return kOTSLocationInterior;
	
	return kOTSLocationExterior;	
}

- (BOOL)isPointInPolygon {
	return [self getLocation] != kOTSLocationExterior;
}

@end
