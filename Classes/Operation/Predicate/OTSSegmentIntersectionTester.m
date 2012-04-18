//
//  OTSSegmentIntersectionTester.m
//

#import "OTSSegmentIntersectionTester.h"
#import "OTSLineString.h"
#import "OTSCoordinateSequence.h"
#import "OTSLineIntersector.h"

@implementation OTSSegmentIntersectionTester

@synthesize li;
@synthesize hasIntersection;

- (id)init {
	if (self = [super init]) {
		li = [[OTSLineIntersector alloc] init];
		hasIntersection = NO;
	}
	return self;
}

- (void)dealloc {
	[li release];
	[super dealloc];
}

- (BOOL)coordinateSequence:(OTSCoordinateSequence *)seq hasIntersectionWithLineStrings:(NSArray *)lines {
	for (int i = 0, n = [lines count]; i < n; ++i) {
		OTSLineString *line = [lines objectAtIndex:i];
		[self coordinateSequence:seq hasIntersectionCoordinateSequence:[line getCoordinatesRO]];
		if (hasIntersection) break;
	}
	return hasIntersection;
}

- (BOOL)coordinateSequence:(OTSCoordinateSequence *)seq0 hasIntersectionCoordinateSequence:(OTSCoordinateSequence *)seq1 {
	for (int i = 1, ni = [seq0 size]; i < ni; ++i) {
		
		OTSCoordinate *pt00 = [seq0 getAt:i - 1];
		OTSCoordinate *pt01 = [seq0 getAt:i];
		
        for (int j = 1, nj = [seq1 size]; j < nj; ++j) {
			OTSCoordinate *pt10 = [seq1 getAt:j-1];
			OTSCoordinate *pt11 = [seq1 getAt:j]; 
			
			[li computeIntersectionOfLineOfPoint:pt00 to:pt01 andLineOfPoint:pt10 to:pt11];
			if ([li hasIntersection]) {
				hasIntersection = YES;
				return hasIntersection;
			}
		}
	}
	return hasIntersection;
}

@end
