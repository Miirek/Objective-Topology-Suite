//
//  OTSLineIntersector.m
//

#import "OTSLineIntersector.h"
#import "OTSCGAlgorithms.h"
#import "OTSHCoordinate.h"
#import "OTSNotRepresentableException.h"
#import "OTSCentralEndpointIntersector.h"
#import "OTSCoordinate.h"
#import "OTSPrecisionModel.h"
#import "OTSEnvelope.h"

@implementation OTSLineIntersector

@synthesize precisionModel;
@synthesize result;
@synthesize properVar;

- (id)initWithPrecisionModel:(OTSPrecisionModel *)_precisionModel {
	if (self = [super init]) {
		self.precisionModel = _precisionModel;
		result = 0;		
	}
	return self;
}

- (void)dealloc {
	
	[intPt[0] release];
	[intPt[1] release];
	
	[inputLines[0][0] release];
	[inputLines[0][1] release];
	[inputLines[1][0] release];
	[inputLines[1][1] release];
	
	[super dealloc];
}

- (BOOL)hasIntersection {
	return result != kOTSLineNoIntersection;
}

- (int)getIntersectionNum { 
	return result; 
}

- (OTSCoordinate *)getIntersection:(int)intIndex {
	return intPt[intIndex];
}

- (BOOL)isProper {
	return [self hasIntersection]&&properVar;
}

- (BOOL)isCollinear {
	return result == kOTSLineCollinearIntersection; 
}

- (BOOL)isEndPoint {
	return [self hasIntersection]&&!properVar;
}

+ (double)interpolateZAtPoint:(OTSCoordinate *)p from:(OTSCoordinate *)p1 to:(OTSCoordinate *)p2 {
	if ( isnan(p1.z) ) {
		return p2.z; // might be DoubleNotANumber again
	}
	
	if ( isnan(p2.z) ) {
		return p1.z; // might be DoubleNotANumber again
	}
	
	if ([p isEqual2D:p1]) {
		return p1.z;
	}
	if ([p isEqual2D:p2]) {
		return p2.z;
	}
	
	//double zgap = fabs(p2.z - p1.z);
	double zgap = p2.z - p1.z;
	if ( ! zgap ) {
		return p2.z;
	}
	double xoff = (p2.x-p1.x);
	double yoff = (p2.y-p1.y);
	double seglen = (xoff*xoff+yoff*yoff);
	xoff = (p.x-p1.x);
	yoff = (p.y-p1.y);
	double pdist = (xoff*xoff+yoff*yoff);
	double fract = sqrt(pdist/seglen);
	double zoff = zgap*fract;
	//double interpolated = p1.z < p2.z ? p1.z+zoff : p1.z-zoff;
	double interpolated = p1.z+zoff;
	return interpolated;	
}

+ (double)computeEdgeDistanceOfPoint:(OTSCoordinate *)p along:(OTSCoordinate *)p0 to:(OTSCoordinate *)p1 {
	double dx = fabs(p1.x-p0.x);
	double dy = fabs(p1.y-p0.y);
	double dist = -1.0;	// sentinel value
	if ([p isEqual2D:p0]) {
		dist = 0.0;
	} else if ([p isEqual2D:p1]) {
		if (dx > dy)
			dist = dx;
		else
			dist = dy;
	} else {
		double pdx = fabs(p.x - p0.x);
		double pdy = fabs(p.y - p0.y);
		if (dx > dy)
			dist = pdx;
		else
			dist = pdy;
		// <FIX>
		// hack to ensure that non-endpoints always have a non-zero distance
		if (dist == 0.0 && !([p isEqual2D:p0])) {
			dist = MAX(pdx,pdy);
		}
	}
	NSAssert(!(dist == 0.0 && !([p isEqual2D:p0])), @"Bad distance calculation"); // Bad distance calculation
	return dist;	
}

/*
+ (double)nonRobustComputeEdgeDistanceOfPoint:(OTSCoordinate *)p along:(OTSCoordinate *)p1 to:(OTSCoordinate *)p2 {
}
*/

- (BOOL)isInteriorIntersection {
	if ([self isInteriorIntersectionForInputLine:0]) return YES;
	if ([self isInteriorIntersectionForInputLine:1]) return YES;
	return NO;
}

- (BOOL)isInteriorIntersectionForInputLine:(int)inputLineIndex {
	for (int i = 0; i < result; i++) {
		if (!([intPt[i] isEqual2D:inputLines[inputLineIndex][0]]
			  || [intPt[i] isEqual2D:inputLines[inputLineIndex][1]]))
		{
			return YES;
		}
	}
	return NO;
}

- (void)computeIntersectionOfPoint:(OTSCoordinate *)p along:(OTSCoordinate *)p1 to:(OTSCoordinate *)p2 {
	
	properVar = NO;
	
	// do between check first, since it is faster than the orientation test
	if ([OTSEnvelope isFirstCoordinate:p1 secondCoordinate:p2 intersects:p]) {
		if ([OTSCGAlgorithms orientationIndex:p1 p2:p2 q:p] == 0 &&
			[OTSCGAlgorithms orientationIndex:p2 p2:p1 q:p] == 0) {
			properVar = YES;
			if ([p isEqual2D:p1]||[p isEqual2D:p2]) { // 2d only test
				properVar = NO;
			}
//#if COMPUTE_Z
//			if (intPt[0] != nil)
//				[intPt[0] release];
//			intPt[0] = [p retain];
//			double z = [OTSLineIntersector interpolateZAtPoint:p from:p1 to:p2];
//			if (!isnan(z)) {
//				if (isnan(intPt[0].z))
//					intPt[0].z = z;
//				else
//					intPt[0].z = (intPt[0].z + z)/2;
//			}
//#endif // COMPUTE_Z
			result = kOTSLinePointIntersection;
			return;
		}
	}
	result = kOTSLineNoIntersection;
	
}

+ (BOOL)hasIntersectionOfPoint:(OTSCoordinate *)p along:(OTSCoordinate *)p1 to:(OTSCoordinate *)p2 {
	if ([OTSEnvelope isFirstCoordinate:p1 secondCoordinate:p2 intersects:p]) {
		if ([OTSCGAlgorithms orientationIndex:p1 p2:p2 q:p] == 0 &&
			[OTSCGAlgorithms orientationIndex:p2 p2:p1 q:p] == 0) {
			return YES;
		}
	}
	return NO;	
}

- (void)computeIntersectionOfLineOfPoint:(OTSCoordinate *)p1 to:(OTSCoordinate *)p2 andLineOfPoint:(OTSCoordinate *)p3 to:(OTSCoordinate *)p4 {
	if (inputLines[0][0] != nil) [inputLines[0][0] release];
	inputLines[0][0] = [p1 retain];
	if (inputLines[0][1] != nil) [inputLines[0][1] release];
	inputLines[0][1] = [p2 retain];
	if (inputLines[1][0] != nil) [inputLines[1][0] release];
	inputLines[1][0] = [p3 retain];
	if (inputLines[1][1] != nil) [inputLines[1][1] release];
	inputLines[1][1] = [p4 retain];
	result = [self computeIntersect:p1 p2:p2 q1:p3 q2:p4];	
}

+ (BOOL)isSameSignAndNonZero:(double)a and:(double)b {
	if (a==0 || b==0) {
		return NO;
	}
	return (a<0 && b<0) || (a>0 && b>0);
}

- (BOOL)isIntersection:(OTSCoordinate *)pt {
	for (int i = 0; i < result; i++) {
		if ([intPt[i] isEqual2D:pt]) {
			return YES;
		}
	}
	return NO;	
}

- (OTSCoordinate *)getIntersectionAlongSegment:(int)segmentIndex intersectionIndex:(int)intIndex {
	// lazily compute int line array
	[self computeIntLineIndex];
	return intPt[intLineIndex[segmentIndex][intIndex]];
}

- (int)getIndexAlongSegment:(int)segmentIndex intersectionIndex:(int)intIndex {
	[self computeIntLineIndex];
	return intLineIndex[segmentIndex][intIndex];
}

- (double)getEdgeDistance:(int)geomIndex intersectionIndex:(int)intIndex {
	double dist = [OTSLineIntersector computeEdgeDistanceOfPoint:intPt[intIndex] 
															  along:inputLines[geomIndex][0] 
																 to:inputLines[geomIndex][1]];
	return dist;	
}

- (void)intersectionWithNormalization:(OTSCoordinate *)p1 
								   p2:(OTSCoordinate *)p2 
								   q1:(OTSCoordinate *)q1 
								   q2:(OTSCoordinate *)q2 
								intPt:(OTSCoordinate *)pintPt {
	OTSCoordinate *n1 = p1;
	OTSCoordinate *n2 = p2;
	OTSCoordinate *n3 = q1;
	OTSCoordinate *n4 = q2;
	OTSCoordinate *normPt = [[OTSCoordinate alloc] init];
	[self normalizeToEnvCentre:n1 n01:n2 n10:n3 n11:n4 normPt:normPt];
	[self safeHCoordinateIntersection:n1 p2:n2 q1:n3 q2:n4 intPt:pintPt];
	
	pintPt.x += normPt.x;
	pintPt.y += normPt.y;	
	
	[normPt release];
}

- (int)computeIntersect:(OTSCoordinate *)p1 
					 p2:(OTSCoordinate *)p2 
					 q1:(OTSCoordinate *)q1 
					 q2:(OTSCoordinate *)q2 {
	
	properVar=false;
	
	// first try a fast test to see if the envelopes of the lines intersect
	if (![OTSEnvelope isFirstCoordinate:p1 secondCoordinate:p2 intersectsFirstCoordinate:q1 andSecondCoordinate:q2]) {
		return kOTSLineNoIntersection;
	}
	
	// for each endpoint, compute which side of the other segment it lies
	// if both endpoints lie on the same side of the other segment,
	// the segments do not intersect
	int Pq1 = [OTSCGAlgorithms orientationIndex:p1 p2:p2 q:q1];
	int Pq2 = [OTSCGAlgorithms orientationIndex:p1 p2:p2 q:q2];
	
	if ((Pq1 > 0 && Pq2 > 0) || (Pq1 < 0 && Pq2 < 0)) {
		return kOTSLineNoIntersection;
	}
	
	int Qp1 = [OTSCGAlgorithms orientationIndex:q1 p2:q2 q:p1];
	int Qp2 = [OTSCGAlgorithms orientationIndex:q1 p2:q2 q:p2];
	
	if ((Qp1 > 0 && Qp2 > 0)||(Qp1 < 0 && Qp2 < 0)) {
		return kOTSLineNoIntersection;
	}
	
	BOOL collinear = Pq1 == 0 && Pq2 == 0 && Qp1 == 0 && Qp2 == 0;
	if (collinear) {
		return [self computeCollinearIntersection:p1 p2:p2 q1:q1 q2:q2];
	}
	
	/**
	 * At this point we know that there is a single intersection point
	 * (since the lines are not collinear).
	 */
	
	/*
	 * Check if the intersection is an endpoint.
	 * If it is, copy the endpoint as
	 * the intersection point. Copying the point rather than
	 * computing it ensures the point has the exact value,
	 * which is important for robustness. It is sufficient to
	 * simply check for an endpoint which is on the other line,
	 * since at this point we know that the inputLines must
	 *  intersect.
	 */
	if (Pq1 == 0 || Pq2 == 0 || Qp1 == 0 || Qp2 == 0) {
//#if COMPUTE_Z
//		int hits = 0;
//		double z = 0.0;
//#endif
		properVar = false;
		
		/* Check for two equal endpoints.
		 * This is done explicitly rather than by the orientation tests
		 * below in order to improve robustness.
		 * 
		 * (A example where the orientation tests fail
		 *  to be consistent is:
		 * 
		 * LINESTRING ( 19.850257749638203 46.29709338043669,
		 * 			20.31970698357233 46.76654261437082 )
		 * and
		 * LINESTRING ( -48.51001596420236 -22.063180333403878,
		 * 			19.850257749638203 46.29709338043669 )
		 * 
		 * which used to produce the result:
		 * (20.31970698357233, 46.76654261437082, NaN)
		 */
		
		if ([p1 isEqual2D:q1] || [p1 isEqual2D:q2]) {
			if (intPt[0] == nil) [intPt[0] release];
			intPt[0] = [p1 retain];
//#if COMPUTE_Z
//			if (!isnan(p1.z)) {
//				z += p1.z;
//				hits++;
//			}
//#endif
		} else if ([p2 isEqual2D:q1] || [p2 isEqual2D:q2]) {
			if (intPt[0] == nil) [intPt[0] release];
			intPt[0] = [p2 retain];
//#if COMPUTE_Z
//			if (!isnan(p2.z)) {
//				z += p2.z;
//				hits++;
//			}
//#endif
		}
		
		/**
		 * Now check to see if any endpoint lies on the interior of the other segment.
		 */
		else if (Pq1 == 0) {
			if (intPt[0] == nil) [intPt[0] release];
			intPt[0] = [q1 retain];
//#if COMPUTE_Z
//			if (!isnan(q1.z)) {
//				z += q1.z;
//				hits++;
//			}
//#endif
		}
		else if (Pq2 == 0) {
			if (intPt[0] == nil) [intPt[0] release];
			intPt[0] = [q2 retain];
//#if COMPUTE_Z
//			if (!isnan(q2.z)) {
//				z += q2.z;
//				hits++;
//			}
//#endif
		}
		else if (Qp1 == 0) {
			if (intPt[0] == nil) [intPt[0] release];
			intPt[0] = [p1 retain];
//#if COMPUTE_Z
//			if (!isnan(p1.z)) {
//				z += p1.z;
//				hits++;
//			}
//#endif
		}
		else if (Qp2 == 0) {
			if (intPt[0] == nil) [intPt[0] release];
			intPt[0] = [p2 retain];
//#if COMPUTE_Z
//			if (!isnan(p2.z)) {
//				z += p2.z;
//				hits++;
//			}
//#endif
		}
//#if COMPUTE_Z
//		if (hits) intPt[0].z = z/hits;
//#endif // COMPUTE_Z
	} else {
		properVar = true;		
		OTSCoordinate *tmp = [[[OTSCoordinate alloc] init] autorelease];
		[self intersection:p1 p2:p2 q1:q1 q2:q2 intPt:tmp];
		if (intPt[0] == nil) [intPt[0] release];
		intPt[0] = tmp;
		[intPt[0] retain];
	}
	return kOTSLinePointIntersection;
}

- (void)computeIntLineIndex {
	[self computeIntLineIndex:0];
	[self computeIntLineIndex:1];
}

- (void)computeIntLineIndex:(int)segmentIndex {
	double dist0 = [self getEdgeDistance:segmentIndex intersectionIndex:0];
	double dist1 = [self getEdgeDistance:segmentIndex intersectionIndex:1];
	if (dist0 > dist1) {
		intLineIndex[segmentIndex][0] = 0;
		intLineIndex[segmentIndex][1] = 1;
	} else {
		intLineIndex[segmentIndex][0] = 1;
		intLineIndex[segmentIndex][1] = 0;
	}
}

- (int)computeCollinearIntersection:(OTSCoordinate *)p1 
								 p2:(OTSCoordinate *)p2 
								 q1:(OTSCoordinate *)q1 
								 q2:(OTSCoordinate *)q2 {
//#if COMPUTE_Z
//	double ztot;
//	int hits;
//	double p2z;
//	double p1z;
//	double q1z;
//	double q2z;
//#endif // COMPUTE_Z
	
	bool p1q1p2 = [OTSEnvelope isFirstCoordinate:p1 secondCoordinate:p2 intersects:q1];
	bool p1q2p2 = [OTSEnvelope isFirstCoordinate:p1 secondCoordinate:p2 intersects:q2];
	bool q1p1q2 = [OTSEnvelope isFirstCoordinate:q1 secondCoordinate:q2 intersects:p1];
	bool q1p2q2 = [OTSEnvelope isFirstCoordinate:q1 secondCoordinate:q2 intersects:p2];
	
	if (p1q1p2 && p1q2p2) {
		if (intPt[0] == nil) [intPt[0] release];
		intPt[0] = [q1 retain];
//#if COMPUTE_Z
//		ztot = 0;
//		hits = 0;
//		q1z = [OTSLineIntersector interpolateZAtPoint:q1 from:p1 to:p2];
//		if (!isnan(q1z)) { ztot+=q1z; hits++; }
//		if (!isnan(q1.z)) { ztot+=q1.z; hits++; }
//		if (hits) intPt[0].z = ztot/hits;
//#endif
		if (intPt[1] == nil) [intPt[1] release];
		intPt[1] = [q2 retain];
//#if COMPUTE_Z
//		ztot = 0;
//		hits = 0;
//		q2z = [OTSLineIntersector interpolateZAtPoint:q2 from:p1 to:p2];
//		if (!isnan(q2z)) { ztot+=q2z; hits++; }
//		if (!isnan(q2.z)) { ztot+=q2.z; hits++; }
//		if (hits) intPt[1].z = ztot/hits;
//#endif
		return kOTSLineCollinearIntersection;
	}
	if (q1p1q2 && q1p2q2) {
		if (intPt[0] == nil) [intPt[0] release];
		intPt[0] = [p1 retain];
//#if COMPUTE_Z
//		ztot = 0;
//		hits = 0;
//		p1z = [OTSLineIntersector interpolateZAtPoint:p1 from:q1 to:q2];
//		if (!isnan(p1z)) { ztot+=p1z; hits++; }
//		if (!isnan(p1.z)) { ztot+=p1.z; hits++; }
//		if (hits) intPt[0].z = ztot/hits;
//#endif
		if (intPt[1] == nil) [intPt[1] release];
		intPt[1] = [p2 retain];
//#if COMPUTE_Z
//		ztot = 0;
//		hits = 0;
//		p2z = [OTSLineIntersector interpolateZAtPoint:p2 from:q1 to:q2];
//		if (!isnan(p2z)) { ztot+=p2z; hits++; }
//		if (!isnan(p2.z)) { ztot+=p2.z; hits++; }
//		if (hits) intPt[1].z = ztot/hits;
//#endif
		return kOTSLineCollinearIntersection;
	}
	if (p1q1p2 && q1p1q2) {
		if (intPt[0] == nil) [intPt[0] release];
		intPt[0] = [q1 retain];
//#if COMPUTE_Z
//		ztot = 0;
//		hits = 0;
//		q1z = [OTSLineIntersector interpolateZAtPoint:q1 from:p1 to:p2];
//		if (!isnan(q1z)) { ztot+=q1z; hits++; }
//		if (!isnan(q1.z)) { ztot+=q1.z; hits++; }
//		if (hits) intPt[0].z = ztot/hits;
//#endif
		if (intPt[1] == nil) [intPt[1] release];
		intPt[1] = [p1 retain];
//#if COMPUTE_Z
//		ztot = 0;
//		hits = 0;
//		p1z = [OTSLineIntersector interpolateZAtPoint:p1 from:q1 to:q2];
//		if (!isnan(p1z)) { ztot+=p1z; hits++; }
//		if (!isnan(p1.z)) { ztot+=p1.z; hits++; }
//		if (hits) intPt[1].z = ztot/hits;
//#endif
		return (q1 == p1) && !p1q2p2 && !q1p2q2 ? kOTSLinePointIntersection : kOTSLineCollinearIntersection;
	}
	if (p1q1p2 && q1p2q2) {
		if (intPt[0] == nil) [intPt[0] release];
		intPt[0] = [q1 retain];
//#if COMPUTE_Z
//		ztot = 0;
//		hits = 0;
//		q1z = [OTSLineIntersector interpolateZAtPoint:q1 from:p1 to:p2];
//		if (!isnan(q1z)) { ztot+=q1z; hits++; }
//		if (!isnan(q1.z)) { ztot+=q1.z; hits++; }
//		if (hits) intPt[0].z = ztot/hits;
//#endif
		if (intPt[1] == nil) [intPt[1] release];
		intPt[1] = [p2 retain];
//#if COMPUTE_Z
//		ztot = 0;
//		hits = 0;
//		p2z = [OTSLineIntersector interpolateZAtPoint:p2 from:q1 to:q2];
//		if (!isnan(p2z)) { ztot+=p2z; hits++; }
//		if (!isnan(p2.z)) { ztot+=p2.z; hits++; }
//		if (hits) intPt[1].z = ztot/hits;
//#endif
		return (q1 == p2) && !p1q2p2 && !q1p1q2 ? kOTSLinePointIntersection : kOTSLineCollinearIntersection;
	}
	if (p1q2p2 && q1p1q2) {
		if (intPt[0] == nil) [intPt[0] release];
		intPt[0] = [q2 retain];
//#if COMPUTE_Z
//		ztot = 0;
//		hits = 0;
//		q2z = [OTSLineIntersector interpolateZAtPoint:q2 from:p1 to:p2];
//		if (!isnan(q2z)) { ztot+=q2z; hits++; }
//		if (!isnan(q2.z)) { ztot+=q2.z; hits++; }
//		if (hits) intPt[0].z = ztot/hits;
//#endif
		if (intPt[1] == nil) [intPt[1] release];
		intPt[1] = [p1 retain];
//#if COMPUTE_Z
//		ztot = 0;
//		hits = 0;
//		p1z = [OTSLineIntersector interpolateZAtPoint:p1 from:q1 to:q2];
//		if (!isnan(p1z)) { ztot+=p1z; hits++; }
//		if (!isnan(p1.z)) { ztot+=p1.z; hits++; }
//		if (hits) intPt[1].z = ztot/hits;
//#endif
		return (q2 == p1) && !p1q1p2 && !q1p2q2 ? kOTSLinePointIntersection : kOTSLineCollinearIntersection;
	}
	if (p1q2p2 && q1p2q2) {
		if (intPt[0] == nil) [intPt[0] release];
		intPt[0] = [q2 retain];
//#if COMPUTE_Z
//		ztot = 0;
//		hits = 0;
//		q2z = [OTSLineIntersector interpolateZAtPoint:q2 from:p1 to:p2];
//		if (!isnan(q2z)) { ztot+=q2z; hits++; }
//		if (!isnan(q2.z)) { ztot+=q2.z; hits++; }
//		if (hits) intPt[0].z = ztot/hits;
//#endif
		if (intPt[1] == nil) [intPt[1] release];
		intPt[1] = [p2 retain];
//#if COMPUTE_Z
//		ztot = 0;
//		hits = 0;
//		p2z = [OTSLineIntersector interpolateZAtPoint:p2 from:q1 to:q2];
//		if (!isnan(p2z)) { ztot+=p2z; hits++; }
//		if (!isnan(p2.z)) { ztot+=p2.z; hits++; }
//		if (hits) intPt[1].z = ztot/hits;
//#endif
		return (q2 == p2) && !p1q1p2 && !q1p1q2 ? kOTSLinePointIntersection : kOTSLineCollinearIntersection;
	}
	return kOTSLineNoIntersection;	
}

- (void)intersection:(OTSCoordinate *)p1 
				  p2:(OTSCoordinate *)p2 
				  q1:(OTSCoordinate *)q1 
				  q2:(OTSCoordinate *)q2 
			   intPt:(OTSCoordinate *)pintPt {
	
	[self intersectionWithNormalization:p1 p2:p2 q1:q1 q2:q2 intPt:pintPt];
	
	/*
	 * Due to rounding it can happen that the computed intersection is
	 * outside the envelopes of the input segments.  Clearly this
	 * is inconsistent.
	 * This code checks this condition and forces a more reasonable answer
	 *
	 * MD - May 4 2005 - This is still a problem.  Here is a failure case:
	 *
	 * LINESTRING (2089426.5233462777 1180182.3877339689,
	 *             2085646.6891757075 1195618.7333999649)
	 * LINESTRING (1889281.8148903656 1997547.0560044837,
	 *             2259977.3672235999 483675.17050843034)
	 * int point = (2097408.2633752143,1144595.8008114607)
	 */
	
	if (![self isInSegmentEnvelopes:pintPt]) {
		pintPt = [OTSCentralEndpointIntersector getIntersection:p1 p01:p2 p10:q1 p11:q2];
	}
	
	if (precisionModel!=NULL) {
		[precisionModel makePrecise:pintPt];
	}
	
//#if COMPUTE_Z
//	double ztot = 0;
//	double zvals = 0;
//	double zp = [OTSLineIntersector interpolateZAtPoint:pintPt from:p1 to:p2];
//	double zq = [OTSLineIntersector interpolateZAtPoint:pintPt from:q1 to:q2];
//	if (!isnan(zp)) { ztot += zp; zvals++; }
//	if (!isnan(zq)) { ztot += zq; zvals++; }
//	if (zvals) pintPt.z = ztot/zvals;
//#endif // COMPUTE_Z	
}

- (double)smallestInAbsValue:(double)x1 
						  x2:(double)x2 
						  x3:(double)x3 
						  x4:(double)x4 {
	double x = x1;
	double xabs = fabs(x);
	if (fabs(x2) < xabs) {
		x = x2;
		xabs = fabs(x2);
	}
	if (fabs(x3) < xabs) {
		x = x3;
		xabs = fabs(x3);
	}
	if (fabs(x4) < xabs) {
		x = x4;
	}
	return x;	
}

- (BOOL)isInSegmentEnvelopes:(OTSCoordinate *)pintPt {
	OTSEnvelope *env0 = [[[OTSEnvelope alloc] initWithFirstCoordinate:inputLines[0][0] secondCoordinate:inputLines[0][1]] autorelease];
	OTSEnvelope *env1 = [[[OTSEnvelope alloc] initWithFirstCoordinate:inputLines[1][0] secondCoordinate:inputLines[1][1]] autorelease];
	return [env0 containsCoordinate:pintPt] && [env1 containsCoordinate:pintPt];
}

- (void)normalizeToEnvCentre:(OTSCoordinate *)n00 
						 n01:(OTSCoordinate *)n01 
						 n10:(OTSCoordinate *)n10 
						 n11:(OTSCoordinate *)n11 
					  normPt:(OTSCoordinate *)normPt {
	 
	double minX0 = n00.x < n01.x ? n00.x : n01.x;
	double minY0 = n00.y < n01.y ? n00.y : n01.y;
	double maxX0 = n00.x > n01.x ? n00.x : n01.x;
	double maxY0 = n00.y > n01.y ? n00.y : n01.y;
	
	double minX1 = n10.x < n11.x ? n10.x : n11.x;
	double minY1 = n10.y < n11.y ? n10.y : n11.y;
	double maxX1 = n10.x > n11.x ? n10.x : n11.x;
	double maxY1 = n10.y > n11.y ? n10.y : n11.y;
	
	double intMinX = minX0 > minX1 ? minX0 : minX1;
	double intMaxX = maxX0 < maxX1 ? maxX0 : maxX1;
	double intMinY = minY0 > minY1 ? minY0 : minY1;
	double intMaxY = maxY0 < maxY1 ? maxY0 : maxY1;
	
	double intMidX = (intMinX + intMaxX) / 2.0;
	double intMidY = (intMinY + intMaxY) / 2.0;
	
	normPt.x = intMidX;
	normPt.y = intMidY;
	
	n00.x -= normPt.x;    n00.y -= normPt.y;
	n01.x -= normPt.x;    n01.y -= normPt.y;
	n10.x -= normPt.x;    n10.y -= normPt.y;
	n11.x -= normPt.x;    n11.y -= normPt.y;
	
//#if COMPUTE_Z
//	double minZ0 = n00.z < n01.z ? n00.z : n01.z;
//	double minZ1 = n10.z < n11.z ? n10.z : n11.z;
//	double maxZ0 = n00.z > n01.z ? n00.z : n01.z;
//	double maxZ1 = n10.z > n11.z ? n10.z : n11.z;
//	double intMinZ = minZ0 > minZ1 ? minZ0 : minZ1;
//	double intMaxZ = maxZ0 < maxZ1 ? maxZ0 : maxZ1;
//	double intMidZ = (intMinZ + intMaxZ) / 2.0;
//	normPt.z = intMidZ;
//	n00.z -= normPt.z;
//	n01.z -= normPt.z;
//	n10.z -= normPt.z;
//	n11.z -= normPt.z;
//#endif	
}

- (void)safeHCoordinateIntersection:(OTSCoordinate *)p1 
								 p2:(OTSCoordinate *)p2 
								 q1:(OTSCoordinate *)q1 
								 q2:(OTSCoordinate *)q2 
							  intPt:(OTSCoordinate *)pintPt {
	@try {
		pintPt = [OTSHCoordinate intersectionOfP1:p1 p2:p2 q1:q1 q2:q2];
	}
	@catch (OTSNotRepresentableException *e) {
		pintPt = [OTSCentralEndpointIntersector getIntersection:p1 p01:p2 p10:q1 p11:q2];
	}
}

@end
