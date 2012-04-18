//
//  OTSEdgeIntersection.m
//

#import "OTSEdgeIntersection.h"
#import "OTSCoordinate.h"

@implementation OTSEdgeIntersection

@synthesize coordinate;
@synthesize segmentIndex;	
@synthesize distance;

- (id)initWithCoordinate:(OTSCoordinate *)newCoord segmentIndex:(int)newSegmentIndex distance:(double)newDist {
	if (self = [super init]) {
		self.coordinate = newCoord;
		segmentIndex = newSegmentIndex;
		distance = newDist;
	}
	return self;
}

- (void)dealloc {
	[coordinate release];
	[super dealloc];
}

- (int)compare:(int)newSegmentIndex distance:(double)newDist {
	if (segmentIndex < newSegmentIndex) return -1;
	if (segmentIndex > newSegmentIndex) return 1;
	if (distance < newDist) return -1;
	if (distance > newDist) return 1;
	return 0;
}

- (BOOL)isEndPoint:(int)maxSegmentIndex {
	if (segmentIndex == 0 && distance == 0.0) return YES;
	if (segmentIndex == maxSegmentIndex) return YES;
	return NO;	
}

- (int)compareTo:(OTSEdgeIntersection *)other {
	return [self compare:other.segmentIndex distance:other.distance];
}

+ (BOOL)edgeIntersection:(OTSEdgeIntersection *)ei1 lessThan:(OTSEdgeIntersection *)ei2 {
	if ( ei1.segmentIndex < ei2.segmentIndex ||
		( ei1.segmentIndex == ei2.segmentIndex &&
		 ei1.distance < ei2.distance )) return YES;
	return NO;
}

- (BOOL)equalsTo:(OTSEdgeIntersection *)other {
	return 
		[coordinate isEqual2D:other.coordinate] && 
		segmentIndex == other.segmentIndex && 
		distance == other.distance;
}

@end
