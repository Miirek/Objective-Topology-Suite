//
//  OTSQuadrant.m
//

#import "OTSCoordinate.h"
#import "OTSQuadrant.h"


@implementation OTSQuadrant

+ (int)quadrant:(double)dx dy:(double)dy {
	if (dx == 0.0 && dy == 0.0) {
		NSException *e = [NSException exceptionWithName:@"IllegalArgumentException" 
												 reason:[NSString stringWithFormat:@"Cannot compute the quadrant for point (%.6f,%.6f)", dx, dy] 
											   userInfo:nil];
		@throw e;
	}
	if (dx >= 0) {
		if (dy >= 0)
			return kOTSQuadrantNE;
		else
			return kOTSQuadrantSE;
	} else {
		if (dy >= 0)
			return kOTSQuadrantNW;
		else
			return kOTSQuadrantSW;
	}	
}

+ (int)quadrant:(OTSCoordinate *)p0 p1:(OTSCoordinate *)p1 {
	if (p1.x == p0.x && p1.y == p0.y) {
		NSException *e = [NSException exceptionWithName:@"IllegalArgumentException" 
												 reason:@"Cannot compute the quadrant for two identical points" 
											   userInfo:nil];
		@throw e;
	}
	
	if (p1.x >= p0.x) {
		if (p1.y >= p0.y)
			return kOTSQuadrantNE;
		else
			return kOTSQuadrantSE;
	}
	else {
		if (p1.y >= p0.y)
			return kOTSQuadrantNW;
		else
			return kOTSQuadrantSW;
	}	
}

+ (BOOL)isOpposite:(int)quad1 quad2:(int)quad2 {
	if (quad1==quad2) return NO;
	int diff=(quad1-quad2+4)%4;
	// if quadrants are not adjacent, they are opposite
	if (diff==2) return YES;
	return NO;
	
}

+ (int)commonHalfPlane:(int)quad1 quad2:(int)quad2 {
	// if quadrants are the same they do not determine a unique
	// common halfplane.
	// Simply return one of the two possibilities
	if (quad1 == quad2) return quad1;
	int diff = (quad1-quad2+4)%4;
	// if quadrants are not adjacent, they do not share a common halfplane
	if (diff==2) return -1;
	//
	int min=(quad1<quad2)? quad1:quad2;
	int max=(quad1>quad2)? quad1:quad2;
	// for this one case, the righthand plane is NOT the minimum index;
	if (min==0 && max==3) return 3;
	// in general, the halfplane index is the minimum of the two
	// adjacent quadrants
	return min;
	
}

+ (BOOL)isInHalfPlane:(int)quad halfPlane:(int)halfPlane {
	if (halfPlane==kOTSQuadrantSE) {
		return quad==kOTSQuadrantSE || quad==kOTSQuadrantSW;
	}
	return quad==halfPlane || quad==halfPlane+1;	
}

+ (BOOL)isNorthern:(int)quad {
	return quad==kOTSQuadrantNE || quad==kOTSQuadrantNW;
}

@end
