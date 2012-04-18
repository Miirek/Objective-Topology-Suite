//
//  OTSEdgeIntersection.h
//

#import <Foundation/Foundation.h>

#import "OTSCoordinate.h" // for CoordinateLessThen

@interface OTSEdgeIntersection : NSObject {
	// the point of intersection
	OTSCoordinate *coordinate;
	// the index of the containing line segment in the parent edge
	int segmentIndex;	
	// the edge distance of this point along the containing line segment
	double distance;
}

@property (nonatomic, retain) OTSCoordinate *coordinate;
@property (nonatomic, assign) int segmentIndex;	
@property (nonatomic, assign) double distance;

- (id)initWithCoordinate:(OTSCoordinate *)newCoord segmentIndex:(int)newSegmentIndex distance:(double)newDist;
- (int)compare:(int)newSegmentIndex distance:(double)newDist;
- (BOOL)isEndPoint:(int)maxSegmentIndex;
- (int)compareTo:(OTSEdgeIntersection *)other;
+ (BOOL)edgeIntersection:(OTSEdgeIntersection *)ei1 lessThan:(OTSEdgeIntersection *)ei2;
- (BOOL)equalsTo:(OTSEdgeIntersection *)other;

@end
