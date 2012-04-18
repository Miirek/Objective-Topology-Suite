//
//  OTSHCoordinate.m
//

#import "OTSHCoordinate.h"
#import "OTSNotRepresentableException.h"
#import "OTSCoordinate.h"

@implementation OTSHCoordinate

@synthesize x, y, w;

+ (OTSCoordinate *)intersectionOfP1:(OTSCoordinate *)p1 p2:(OTSCoordinate *)p2 q1:(OTSCoordinate *)q1 q2:(OTSCoordinate *)q2 {
	
	OTSHCoordinate *hc1p1 = [[OTSHCoordinate alloc] initWithCoordinate:p1];
	OTSHCoordinate *hc1p2 = [[OTSHCoordinate alloc] initWithCoordinate:p2];
	OTSHCoordinate *l1 = [[OTSHCoordinate alloc] initWithHCoordinateP1:hc1p1 p2:hc1p2];
	
	OTSHCoordinate *hc2q1 = [[OTSHCoordinate alloc] initWithCoordinate:q1];
	OTSHCoordinate *hc2q2 = [[OTSHCoordinate alloc] initWithCoordinate:q2];
	OTSHCoordinate *l2 = [[OTSHCoordinate alloc] initWithHCoordinateP1:hc2q1 p2:hc2q2];
	
	OTSHCoordinate *intHCoord = [[OTSHCoordinate alloc] initWithHCoordinateP1:l1 p2:l2];
	OTSCoordinate *ret = [intHCoord getCoordinate];
	
	[hc1p1 release];
	[hc1p2 release];
	[l1 release];
	
	[hc2q1 release];
	[hc2q2 release];
	[l2 release];
	
	[intHCoord release];
	
	return ret;
}

- (id)init {
	if (self = [super init]) {
		x = 0.0;
		y = 0.0;
		w = 1.0;
	}
	return self;
}

- (id)initWithX:(long double)_x y:(long double)_y w:(long double)_w {
	if (self = [super init]) {
		self.x = _x;
		self.y = _y;
		self.w = _w;
	}
	return self;
}

- (id)initWithCoordinate:(OTSCoordinate *)p {
	if (self = [super init]) {
		self.x = p.x;
		self.y = p.y;
		self.w = 1.0;
	}
	return self;
}

- (id)initWithCoordinateP1:(OTSCoordinate *)p1 p2:(OTSCoordinate *)p2 {
	if (self = [super init]) {
		// optimization when it is known that w = 1
		self.x = p1.y - p2.y;
		self.y = p2.x - p1.x;
		self.w = p1.x * p2.y - p2.x * p1.y;
		
	}
	return self;
}

- (id)initWithCoordinateP1:(OTSCoordinate *)p1 p2:(OTSCoordinate *)p2 q1:(OTSCoordinate *)q1 q2:(OTSCoordinate *)q2 {
	if (self = [super init]) {
		// unrolled computation
		double px = p1.y - p2.y;
		double py = p2.x - p1.x;
		double pw = p1.x * p2.y - p2.x * p1.y;
		
		double qx = q1.y - q2.y;
		double qy = q2.x - q1.x;
		double qw = q1.x * q2.y - q2.x * q1.y;
		
		self.x = py * qw - qy * pw;
		self.y = qx * pw - px * qw;
		self.w = px * qy - qx * py;		
	}
	return self;
}

- (id)initWithHCoordinateP1:(OTSHCoordinate *)p1 p2:(OTSHCoordinate *)p2 {
	if (self = [super init]) {
		self.x = p1.y*p2.w - p2.y*p1.w;
		self.y = p2.x*p1.w - p1.x*p2.w;
		self.w = p1.x*p2.y - p2.x*p1.y;
	}
	return self;
}

- (long double)getComputedX {
	long double a = x/w;
	
	if (!isfinite(a)) {
		NSException *e = [OTSNotRepresentableException exceptionWithName:@"OTSNotRepresentableException" reason:nil userInfo:nil];
		@throw e;
	}
	return a;	
}

- (long double)getComputedY {
	long double a = y/w;
	
	if (!isfinite(a)) {
		NSException *e = [OTSNotRepresentableException exceptionWithName:@"OTSNotRepresentableException" reason:nil userInfo:nil];
		@throw e;
	}
	return a;
	
}

- (OTSCoordinate *)getCoordinate {
	return [[[OTSCoordinate alloc] initWithX:[self getComputedX] Y:[self getComputedY]] autorelease];
}

@end
