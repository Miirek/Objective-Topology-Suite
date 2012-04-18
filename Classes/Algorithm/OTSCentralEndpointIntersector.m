//
//  OTSCentralEndpointIntersector.m
//

#import "OTSCoordinate.h"
#import "OTSCentralEndpointIntersector.h"


@implementation OTSCentralEndpointIntersector

@synthesize pts;
@synthesize intPt;

+ (OTSCoordinate *)getIntersection:(OTSCoordinate *)p00 
								  p01:(OTSCoordinate *)p01 
								  p10:(OTSCoordinate *)p10 
								  p11:(OTSCoordinate *)p11 {
	OTSCentralEndpointIntersector *intor = [[OTSCentralEndpointIntersector alloc] initWithP00:p00 p01:p01 p10:p10 p11:p11];
	OTSCoordinate *ret = [intor getIntersection];
	[intor release];
	return ret;
	
}

+ (OTSCoordinate *)average:(NSArray *)ppts {
	OTSCoordinate *avg = [[OTSCoordinate alloc] initWithX:0 Y:0];
	int n = [ppts count];
	if (!n) return [avg autorelease];
	for (int i=0; i < n; ++i) {
		avg.x += ((OTSCoordinate *)[ppts objectAtIndex:i]).x;
		avg.y += ((OTSCoordinate *)[ppts objectAtIndex:i]).y;
	}
	avg.x /= n;
	avg.y /= n;
	return [avg autorelease];	
}

- (id)initWithP00:(OTSCoordinate *)p00 
			  p01:(OTSCoordinate *)p01 
			  p10:(OTSCoordinate *)p10 
			  p11:(OTSCoordinate *)p11 {
	if (self = [super init]) {
		self.pts = [NSArray arrayWithObjects:p00, p01, p10, p11, nil];
		[self compute];		
	}
	return self;
}

- (void)dealloc {
	[pts release];
	[intPt release];
	[super dealloc];
}

- (OTSCoordinate *)getIntersection {
	return intPt;
}

- (void)compute {
	OTSCoordinate *centroid = [[OTSCentralEndpointIntersector average:pts] retain];
	self.intPt = [self findNearestPoint:centroid pts:pts];
	[centroid release];
}

- (OTSCoordinate *)findNearestPoint:(OTSCoordinate *)p pts:(NSArray *)ppts {
	double minDist = DBL_MAX;
	OTSCoordinate *result = [OTSCoordinate nullCoordinate];
	for (int i = 0, n = [ppts count]; i < n; ++i) {
		double dist = [p distance:[ppts objectAtIndex:i]];
		if (dist < minDist) {
			minDist = dist;
			result = [ppts objectAtIndex:i];
		}
	}
	return result;	
}

@end
