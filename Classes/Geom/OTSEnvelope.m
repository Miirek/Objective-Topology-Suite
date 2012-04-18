//
//  OTSEnvelope.m
//

#import "OTSCoordinate.h"
#import "OTSEnvelope.h"


@implementation OTSEnvelope

@synthesize minx, maxx, miny, maxy;

- (id)init {
	if (self = [super init]) {
		[self setToNull];
	}
	return self;	
}

- (id)initWithFirstX:(double)x1 secondX:(double)x2 firstY:(double)y1 secondY:(double)y2 {
	if (self = [self init]) {
		[self setWithFirstX:x1 secondX:x2 firstY:y1 secondY:y2];		
	}
	return self;
}

- (void)setWithFirstX:(double)x1 secondX:(double)x2 firstY:(double)y1 secondY:(double)y2 {
	if (x1 < x2) {
		minx = x1;
		maxx = x2;
	} else {
		minx = x2;
		maxx = x1;
	}
	if (y1 < y2) {
		miny = y1;
		maxy = y2;
	} else {
		miny = y2;
		maxy = y1;
	}
}

- (id)initWithFirstCoordinate:(OTSCoordinate *)p1 secondCoordinate:(OTSCoordinate *)p2 {
	return [self initWithFirstX:p1.x secondX:p2.x firstY:p1.y secondY:p2.y];
}

- (void)setWithFirstCoordinate:(OTSCoordinate *)p1 secondCoordinate:(OTSCoordinate *)p2 {
	[self setWithFirstX:p1.x secondX:p2.x firstY:p1.y secondY:p2.y];
}

- (id)initWithCoordinate:(OTSCoordinate *)p {
	return [self initWithFirstX:p.x secondX:p.x firstY:p.y secondY:p.y];
}

- (id)initWithEnvelope:(OTSEnvelope *)env {
	return [self initWithFirstX:env.minx secondX:env.maxx firstY:env.miny secondY:env.maxy];	
}

+ (id)envelopeWithFirstX:(double)x1 secondX:(double)x2 firstY:(double)y1 secondY:(double)y2 {
	return [[[OTSEnvelope alloc] initWithFirstX:x1 secondX:x2 firstY:y1 secondY:y2] autorelease];
}

+ (BOOL)isFirstCoordinate:(OTSCoordinate *)p1 
		 secondCoordinate:(OTSCoordinate *)p2 
			   intersects:(OTSCoordinate *)q {
	if (((q.x >= (p1.x < p2.x ? p1.x : p2.x)) && (q.x <= (p1.x > p2.x ? p1.x : p2.x))) &&
        ((q.y >= (p1.y < p2.y ? p1.y : p2.y)) && (q.y <= (p1.y > p2.y ? p1.y : p2.y)))) {
		return YES;
	}
	return NO;
	
}

+ (BOOL)isFirstCoordinate:(OTSCoordinate *)p1 
		 secondCoordinate:(OTSCoordinate *)p2 
intersectsFirstCoordinate:(OTSCoordinate *)q1 
	  andSecondCoordinate:(OTSCoordinate *)q2 {
	double minq = MIN(q1.x,q2.x);
	double maxq = MAX(q1.x,q2.x);
	double minp = MIN(p1.x,p2.x);
	double maxp = MAX(p1.x,p2.x);
	if(minp > maxq)
		return NO;
	if(maxp < minq)
		return NO;
	minq = MIN(q1.y,q2.y);
	maxq = MAX(q1.y,q2.y);
	minp = MIN(p1.y,p2.y);
	maxp = MAX(p1.y,p2.y);
	if(minp > maxq)
		return NO;
	if(maxp < minq)
		return NO;
	return YES;	
}

- (void)setToNull {
	minx = 0;
	maxx = -1;
	miny = 0;
	maxy = -1;	
}

- (BOOL)isNull {
	return maxx < minx;
}

- (double)width {
	if ([self isNull]) {
		return 0;
	}
	return maxx - minx;	
}

- (double)height {
	if ([self isNull]) {
		return 0;
	}
	return maxy - miny;	
}

- (double)area {
	return [self width] * [self height];
}

- (OTSCoordinate *)centre {
	if ([self isNull]) return nil;
	OTSCoordinate *centre = [[OTSCoordinate alloc] init];
	centre.x=(minx + maxx) / 2.0;
	centre.y=(miny + maxy) / 2.0;
	return [centre autorelease];
}

- (OTSEnvelope *)intersection:(OTSEnvelope *)env {
	if ([self isNull] || [env isNull] || ! [self intersects:env]) return nil;
	double intMinX = minx > env.minx ? minx : env.minx;
	double intMinY = miny > env.miny ? miny : env.miny;
	double intMaxX = maxx < env.maxx ? maxx : env.maxx;
	double intMaxY = maxy < env.maxy ? maxy : env.maxy;
	OTSEnvelope *result = [[OTSEnvelope alloc] initWithFirstX:intMinX secondX:intMaxX firstY:intMinY secondY:intMaxY];
	return [result autorelease];	
}

- (void)translateWithX:(double)transX andY:(double)transY {
	if ([self isNull]) return;
	minx = minx + transX;
	maxx = maxx + transX;
	miny = miny + transY;
	maxy = maxy + transY;
}

- (void)expandByDeltaX:(double)deltaX deltaY:(double)deltaY {
	if ([self isNull]) return;
	
	minx -= deltaX;
	maxx += deltaX;
	miny -= deltaY;
	maxy += deltaY;
	
	// check for envelope disappearing
	if (minx > maxx || miny > maxy)
		[self setToNull];
}

- (void)expandByDistance:(double)distance {
	[self expandByDeltaX:distance deltaY:distance];
}

- (void)expandToIncludeCoordinate:(OTSCoordinate *)p {
	[self expandToIncludeX:p.x andY:p.y];
}

- (void)expandToIncludeX:(double)x andY:(double)y {
	if ([self isNull]) {
		minx = x;
		maxx = x;
		miny = y;
		maxy = y;
	} else {
		if (x < minx) {
			minx = x;
		}
		if (x > maxx) {
			maxx = x;
		}
		if (y < miny) {
			miny = y;
		}
		if (y > maxy) {
			maxy = y;
		}
	}
}

- (void)expandToInclude:(OTSEnvelope *)other {
	if ([other isNull]) {
		return;
	}
	if ([self isNull]) {
		minx = other.minx;
		maxx = other.maxx;
		miny = other.miny;
		maxy = other.maxy;
	} else {
		if (other.minx < minx) {
			minx = other.minx;
		}
		if (other.maxx > maxx) {
			maxx = other.maxx;
		}
		if (other.miny < miny) {
			miny = other.miny;
		}
		if (other.maxy > maxy) {
			maxy = other.maxy;
		}
	}	
}

- (BOOL)contains:(OTSEnvelope *)other {
	return [self covers:other];
}

- (BOOL)containsCoordinate:(OTSCoordinate *)p {
	return [self coversCoordinate:p];
}

- (BOOL)containsX:(double)x andY:(double)y {
	return [self containsX:x andY:y];
}

- (BOOL)intersectsCoordinate:(OTSCoordinate *)p {
	return (p.x <= maxx && p.x >= minx &&
			p.y <= maxy && p.y >= miny);
}

- (BOOL)intersectsX:(double)x andY:(double)y {
	return (x <= maxx && x >= minx && y <= maxy && y >= miny);
}

- (BOOL)intersects:(OTSEnvelope *)other {
	if ( [self isNull] || [other isNull] ) return NO;
	return !(other.minx > maxx ||
			 other.maxx < minx ||
			 other.miny > maxy ||
			 other.maxy < miny);
	
}

- (BOOL)coversCoordinate:(OTSCoordinate *)p {
	return [self coversX:p.x andY:p.y];
}

- (BOOL)coversX:(double)x andY:(double)y {
	if ([self isNull]) return NO;
	return x >= minx &&
		x <= maxx &&
		y >= miny &&
		y <= maxy;	
}

- (BOOL)covers:(OTSEnvelope *)other {
	if ([self isNull] || [other isNull]) return NO;
	
	return 
		other.minx >= minx &&
		other.maxx <= maxx &&
		other.miny >= miny &&
		other.maxy <= maxy;
	
}

- (BOOL)equals:(OTSEnvelope *)other {
	if ([self isNull] || [other isNull]) { return NO; }
	return 
		other.minx == minx &&
		other.maxx == maxx &&
		other.miny == miny &&
		other.maxy == maxy;	
}

- (double)distanceToFirstX:(double)x0 firstY:(double)y0 secondX:(double)x1 secondY:(double)y1 {
	double dx=x1-x0;
	double dy=y1-y0;
	return sqrt(dx*dx+dy*dy);	
}

- (double)distanceTo:(OTSEnvelope *)env {
	if ([self intersects:env]) return 0;
	double dx = 0.0;
	if(maxx < env.minx) dx = env.minx - maxx;
	if(minx > env.maxx) dx = minx - env.maxx;
	double dy = 0.0;
	if(maxy < env.miny) dy = env.miny - maxy;
	if(miny > env.maxy) dy = miny - env.maxy;
	// if either is zero, the envelopes overlap either vertically or horizontally
	if (dx == 0.0) return dy;
	if (dy == 0.0) return dx;
	return sqrt(dx*dx + dy*dy);	
}

@end
