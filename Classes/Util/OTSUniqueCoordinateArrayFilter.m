//
//  OTSUniqueCoordinateArrayFilter.m
//

#import "OTSUniqueCoordinateArrayFilter.h"
#import "OTSCoordinateSequence.h"
#import "OTSCoordinate.h"

@implementation OTSUniqueCoordinateArrayFilter

@synthesize pts;
@synthesize uniqPts;

- (id)initWithArray:(NSMutableArray *)target {
	if (self = [super init]) {
		self.pts = target;
		self.uniqPts = [NSMutableSet set];
	}
	return self;
}

- (void)dealloc {
	[pts release];
	[uniqPts release];
	[super dealloc];
}

- (void)filter_ro:(OTSCoordinate *)coord {
	if ([uniqPts member:coord] == nil) {
		[uniqPts addObject:coord];
		[pts addObject:coord];
	}
}

@end
