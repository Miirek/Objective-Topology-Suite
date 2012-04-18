//
//  OTSCGAlgorithms.m
//

#import "OTSCGAlgorithms.h"
#import "OTSRobustDeterminant.h"
#import "OTSLineIntersector.h"
#import "OTSRayCrossingCounter.h"
#import "OTSCoordinateSequence.h"
#import "OTSCoordinate.h"
#import "OTSLocation.h"

@implementation OTSCGAlgorithms

+ (BOOL)isPoint:(OTSCoordinate *)p inRing:(OTSCoordinateSequence*)ring {
	return [self locatePoint:p inRing:ring] != kOTSLocationExterior;
}

+ (BOOL)isPoint:(OTSCoordinate *)p inArrayRing:(NSArray *)ring {
	return [self locatePoint:p inArrayRing:ring] != kOTSLocationExterior;
}

+ (int)locatePoint:(OTSCoordinate *)p inRing:(OTSCoordinateSequence*)ring {
	return [OTSRayCrossingCounter locatePoint:p inRing:ring];
}

+ (int)locatePoint:(OTSCoordinate *)p inArrayRing:(NSArray *)ring {
	return [OTSRayCrossingCounter locatePoint:p inArrayRing:ring];
}

+ (BOOL)isPoint:(OTSCoordinate *)p onLine:(OTSCoordinateSequence*) pt {
	int ptsize = [pt size];
	if (ptsize == 0) return NO;
	
	OTSCoordinate *pp = [pt getAt:0];
	for(int i=1; i < ptsize; ++i)
	{
		OTSCoordinate *p1 = [pt getAt:i];
		if ([OTSLineIntersector hasIntersectionOfPoint:p along:pp to:p1])
			return YES;
		pp = p1;
	}
	return NO;
}

+ (BOOL)isCCW:(OTSCoordinateSequence*)ring {
	
	// # of points without closing endpoint
	int nPts = [ring size] - 1;
	
	// sanity check
	if (nPts < 3) {
		NSException *ex = [NSException exceptionWithName:@"IllegalArgumentException" 
												  reason:@"Ring has fewer than 3 points, so orientation cannot be determined" 
												userInfo:nil];
		@throw ex;
	}
	
	// find highest point
	OTSCoordinate *hiPt = [ring getAt:0];
	int hiIndex=0;
	for (int i=1; i <= nPts; ++i)
	{
		OTSCoordinate *p = [ring getAt:i];
		if (p.y > hiPt.y) {
			hiPt = p;
			hiIndex = i;
		}
	}
	
	// find distinct point before highest point
	int iPrev = hiIndex;
	do {
		iPrev = iPrev - 1;
		if (iPrev < 0)
            iPrev = nPts;
	} while ([[ring getAt:iPrev] isEqual2D:hiPt] && iPrev != hiIndex);
	
	// find distinct point after highest point
	int iNext = hiIndex;
	do {
		iNext = (iNext + 1) % nPts;
	} while ([[ring getAt:iNext] isEqual2D:hiPt] && iNext != hiIndex);
	
	OTSCoordinate *prev = [ring getAt:iPrev];
	OTSCoordinate *next = [ring getAt:iNext];
	
	/*
	 * This check catches cases where the ring contains an A-B-A
	 * configuration of points.
	 * This can happen if the ring does not contain 3 distinct points
	 * (including the case where the input array has fewer than 4 elements),
	 * or it contains coincident line segments.
	 */
	if ([prev isEqual2D:hiPt] || [next isEqual2D:hiPt] ||
		[prev isEqual2D:next])
	{
		return NO;
		// MD - don't bother throwing exception,
		// since this isn't a complete check for ring validity
		//throw  IllegalArgumentException("degenerate ring (does not contain 3 distinct points)");
	}
	
	int disc = [self computeOrientation:prev p2:hiPt q:next];
	
	/**
	 *  If disc is exactly 0, lines are collinear. 
	 * There are two possible cases:
	 *  (1) the lines lie along the x axis in opposite directions
	 *  (2) the lines lie on top of one another
	 *
	 *  (1) is handled by checking if next is left of prev ==> CCW
	 *  (2) should never happen, so we're going to ignore it!
	 *  (Might want to assert this)
	 */
	bool isCCW=false;
	
	if (disc == 0) {
		// poly is CCW if prev x is right of next x
		isCCW = (prev.x > next.x);
	} else {
		// if area is positive, points are ordered CCW
		isCCW = (disc > 0);
	}
	
	return isCCW;	
}

+ (int)computeOrientation:(OTSCoordinate *)p1 p2:(OTSCoordinate *)p2 q:(OTSCoordinate *)q {
	return [self orientationIndex:p1 p2:p2 q:q];
}

+ (double)distancePointLine:(OTSCoordinate *)p A:(OTSCoordinate *) A B:(OTSCoordinate *)B {
	//if start==end, then use pt distance
	if ([A isEqual2D:B]) return [p distance:A];
	
	double r=((p.x-A.x)*(B.x-A.x)+(p.y-A.y)*(B.y-A.y))/
	((B.x-A.x)*(B.x-A.x)+(B.y-A.y)*(B.y-A.y));
	if (r<=0.0) return [p distance:A];
	if (r>=1.0) return [p distance:B];
	double s=((A.y-p.y)*(B.x-A.x)-(A.x-p.x)*(B.y-A.y))/
	((B.x-A.x)*(B.x-A.x)+(B.y-A.y)*(B.y-A.y));
	return fabs(s)*sqrt(((B.x-A.x)*(B.x-A.x)+(B.y-A.y)*(B.y-A.y)));	
}

+ (double)distancePointLinePerpendicular:(OTSCoordinate *)p A:(OTSCoordinate *) A B:(OTSCoordinate *)B {
	double s = ((A.y - p.y) *(B.x - A.x) - (A.x - p.x)*(B.y - A.y) )
	/
	((B.x - A.x) * (B.x - A.x) + (B.y - A.y) * (B.y - A.y) );
    return fabs(s)*sqrt(((B.x - A.x) * (B.x - A.x) + (B.y - A.y) * (B.y - A.y)));	
}
	
+ (double)distanceLineLine:(OTSCoordinate *) A B:(OTSCoordinate *)B C:(OTSCoordinate *)C D:(OTSCoordinate *)D {
	// check for zero-length segments
	if ([A isEqual2D:B]) return [self distancePointLine:A A:C B:D];
	if ([C isEqual2D:D]) return [self distancePointLine:D A:A B:B];
	
	double r_top=(A.y-C.y)*(D.x-C.x)-(A.x-C.x)*(D.y-C.y);
	double r_bot=(B.x-A.x)*(D.y-C.y)-(B.y-A.y)*(D.x-C.x);
	double s_top=(A.y-C.y)*(B.x-A.x)-(A.x-C.x)*(B.y-A.y);
	double s_bot=(B.x-A.x)*(D.y-C.y)-(B.y-A.y)*(D.x-C.x);
	if ((r_bot==0)||(s_bot==0)) {
		return MIN([self distancePointLine:A A:C B:D],
						MIN([self distancePointLine:B A:C B:D],
								 MIN([self distancePointLine:C A:A B:B], [self distancePointLine:D A:A B:B])));
	}
	double s=s_top/s_bot;
	double r=r_top/r_bot;
	if ((r<0)||( r>1)||(s<0)||(s>1)) {
		//no intersection
		return MIN([self distancePointLine:A A:C B:D],
				   MIN([self distancePointLine:B A:C B:D],
					   MIN([self distancePointLine:C A:A B:B], [self distancePointLine:D A:A B:B])));
	}
	return 0.0; //intersection exists	
}

+ (double)signedArea:(OTSCoordinateSequence *)ring {
	int npts = [ring size];
	
	if (npts < 3) return 0.0;
	
	double sum=0.0;
	for (int i=0; i < npts-1; ++i)
	{
		double bx = [ring getAt:i].x;
		double by = [ring getAt:i].y;
		double cx = [ring getAt:i+1].x;
		double cy = [ring getAt:i+1].y;
		sum += (bx+cx)*(cy-by);
	}
	return -sum/2.0;	
}

+ (double)length:(OTSCoordinateSequence *)pts {
	// optimized for processing CoordinateSequences
	
	int npts = [pts size];
	if (npts <= 1) return 0.0;
	
	double len = 0.0;
	
	OTSCoordinate *p = [pts getAt:0];
	double x0 = p.x;
	double y0 = p.y;
	
	for(int i = 1; i < npts; ++i)
	{
		OTSCoordinate *p = [pts getAt:i];
		double x1 = p.x;
		double y1 = p.y;
		double dx = x1 - x0;
		double dy = y1 - y0;
		
		len += sqrt(dx * dx + dy * dy);
		
		x0 = x1;
		y0 = y1;
	}
	
	return len;
}

+ (int)orientationIndex:(OTSCoordinate *)p1 p2:(OTSCoordinate *)p2 q:(OTSCoordinate *)q {
	// travelling along p1->p2, turn counter clockwise to get to q return 1,
	// travelling along p1->p2, turn clockwise to get to q return -1,
	// p1, p2 and q are colinear return 0.
	double dx1=p2.x-p1.x;
	double dy1=p2.y-p1.y;
	double dx2=q.x-p2.x;
	double dy2=q.y-p2.y;
	return [OTSRobustDeterminant signOfDet2x2WithX1:dx1 y1:dy1 x2:dx2 y2:dy2];
}

@end
