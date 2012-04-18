//
//  OTSLineIntersector.h
//

#import <Foundation/Foundation.h>

#import "OTSCoordinate.h"

@class OTSPrecisionModel;

enum {
	/// Indicates that line segments do not intersect
	kOTSLineNoIntersection=0,
	
	/// Indicates that line segments intersect in a single point
	kOTSLinePointIntersection=1,
	
	/// Indicates that line segments intersect in a line segment
	kOTSLineCollinearIntersection=2
};

@interface OTSLineIntersector : NSObject {
	OTSPrecisionModel *precisionModel;
	int result;
	OTSCoordinate *inputLines[2][2];
	OTSCoordinate *intPt[2];
	int intLineIndex[2][2];
	BOOL properVar;
}

@property (nonatomic, retain) OTSPrecisionModel *precisionModel;
@property (nonatomic, assign) int result;
@property (nonatomic, assign) BOOL properVar;

- (id)initWithPrecisionModel:(OTSPrecisionModel *)_precisionModel;

+ (double)interpolateZAtPoint:(OTSCoordinate *)p from:(OTSCoordinate *)p1 to:(OTSCoordinate *)p2;
+ (double)computeEdgeDistanceOfPoint:(OTSCoordinate *)p along:(OTSCoordinate *)p0 to:(OTSCoordinate *)p1;
//+ (double)nonRobustComputeEdgeDistanceOfPoint:(OTSCoordinate *)p along:(OTSCoordinate *)p1 to:(OTSCoordinate *)p2;

- (BOOL)isInteriorIntersection;
- (BOOL)isInteriorIntersectionForInputLine:(int)inputLineIndex;
- (void)computeIntersectionOfPoint:(OTSCoordinate *)p along:(OTSCoordinate *)p1 to:(OTSCoordinate *)p2;
+ (BOOL)hasIntersectionOfPoint:(OTSCoordinate *)p along:(OTSCoordinate *)p1 to:(OTSCoordinate *)p2;

- (void)computeIntersectionOfLineOfPoint:(OTSCoordinate *)p1 to:(OTSCoordinate *)p2 andLineOfPoint:(OTSCoordinate *)p3 to:(OTSCoordinate *)p4;
- (BOOL)hasIntersection;
- (int)getIntersectionNum;
- (OTSCoordinate *)getIntersection:(int)intIndex;
+ (BOOL)isSameSignAndNonZero:(double) a and:(double)b;
- (BOOL)isIntersection:(OTSCoordinate *)pt;
- (BOOL)isProper;
- (OTSCoordinate *)getIntersectionAlongSegment:(int)segmentIndex intersectionIndex:(int)intIndex;
- (int)getIndexAlongSegment:(int)segmentIndex intersectionIndex:(int)intIndex;
- (double)getEdgeDistance:(int)geomIndex intersectionIndex:(int)intIndex;
- (void)intersectionWithNormalization:(OTSCoordinate *)p1 
								   p2:(OTSCoordinate *)p2 
								   q1:(OTSCoordinate *)q1 
								   q2:(OTSCoordinate *)q2 
								intPt:(OTSCoordinate *)pintPt;
- (BOOL)isCollinear;
- (int)computeIntersect:(OTSCoordinate *)p1 
					 p2:(OTSCoordinate *)p2 
					 q1:(OTSCoordinate *)q1 
					 q2:(OTSCoordinate *)q2;
- (BOOL)isEndPoint;
- (void)computeIntLineIndex;
- (void)computeIntLineIndex:(int)segmentIndex;
- (int)computeCollinearIntersection:(OTSCoordinate *)p1 
								 p2:(OTSCoordinate *)p2 
								 q1:(OTSCoordinate *)q1 
								 q2:(OTSCoordinate *)q2;

- (void)intersection:(OTSCoordinate *)p1 
				  p2:(OTSCoordinate *)p2 
				  q1:(OTSCoordinate *)q1 
				  q2:(OTSCoordinate *)q2 
			   intPt:(OTSCoordinate *)pintPt;
- (double)smallestInAbsValue:(double)x1 
						  x2:(double)x2 
						  x3:(double)x3 
						  x4:(double)x4;

- (BOOL)isInSegmentEnvelopes:(OTSCoordinate *)pintPt;
- (void)normalizeToEnvCentre:(OTSCoordinate *)n00 
						 n01:(OTSCoordinate *)n01 
						 n10:(OTSCoordinate *)n10 
						 n11:(OTSCoordinate *)n11 
					  normPt:(OTSCoordinate *)normPt;

- (void)safeHCoordinateIntersection:(OTSCoordinate *)p1 
								 p2:(OTSCoordinate *)p2 
								 q1:(OTSCoordinate *)q1 
								 q2:(OTSCoordinate *)q2 
							  intPt:(OTSCoordinate *)pintPt;

@end
