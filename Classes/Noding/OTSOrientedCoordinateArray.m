//
//  OTSOrientedCoordinateArray.m
//

#import "OTSOrientedCoordinateArray.h"
#import "OTSCoordinateSequence.h"


@implementation OTSOrientedCoordinateArray

@synthesize pts;
@synthesize orientation;

- (id)initWithCoordinateSequence:(OTSCoordinateSequence *)_pts {
	if (self = [super init]) {
		self.pts = _pts;
		orientation = [OTSOrientedCoordinateArray orientation:_pts];
	}
	return self;
}

- (int)compareTo:(OTSOrientedCoordinateArray *)oca {
	return [OTSOrientedCoordinateArray compareOrientedPts1:pts orientation1:orientation pts2:oca.pts orientation2:oca.orientation];
}

- (BOOL)isEqual:(id)anObject {
	if ([anObject isKindOfClass:[OTSOrientedCoordinateArray class]]) {
		OTSOrientedCoordinateArray *other = (OTSOrientedCoordinateArray *)anObject;
		return [self compareTo:other] == 0;
	}
	return NO;
}

+ (int)compareOrientedPts1:(OTSCoordinateSequence *)pts1 
			  orientation1:(BOOL)orientation1 
					  pts2:(OTSCoordinateSequence *)pts2 
			  orientation2:(BOOL)orientation2 {
	int dir1 = orientation1 ? 1 : -1;
    int dir2 = orientation2 ? 1 : -1;
    int limit1 = orientation1 ? [pts1 size] : -1;
    int limit2 = orientation2 ? [pts2 size] : -1;
	
    int i1 = orientation1 ? 0 : [pts1 size] - 1;
    int i2 = orientation2 ? 0 : [pts2 size] - 1;
    //int comp = 0; // unused, but is in JTS ...
    while (YES) {
		int compPt = [[pts1 getAt:i1] compareTo:[pts2 getAt:i2]];
		if (compPt != 0)
			return compPt;
		i1 += dir1;
		i2 += dir2;
		BOOL done1 = i1 == limit1;
		BOOL done2 = i2 == limit2;
		if (done1 && !done2) return -1;
		if (!done1 && done2) return 1;
		if (done1 && done2) return 0;
    }
}

+ (BOOL)orientation:(OTSCoordinateSequence *)_pts {
	return ([OTSCoordinateSequence increasingDirection:_pts] == 1);
}

- (id)copyWithZone:(NSZone *)zone {
	OTSOrientedCoordinateArray *copy = [[[self class] allocWithZone:zone] initWithCoordinateSequence:[self pts]];
    return copy;
}

@end
