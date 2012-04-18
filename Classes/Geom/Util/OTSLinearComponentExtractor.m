//
//  OTSLinearComponentExtractor.m
//

#import "OTSLinearComponentExtractor.h"
#import "OTSGeometry.h"
#import "OTSLineString.h"

@implementation OTSLinearComponentExtractor

@synthesize comps;

+ (void)getLinesFromGeometry:(OTSGeometry *)geom into:(NSMutableArray *)ret {
	OTSLinearComponentExtractor *lce = [[OTSLinearComponentExtractor alloc] initWithArray:ret];
	[geom apply_roGeometryComponentFilter:lce];
	[lce release];
}

- (id)initWithArray:(NSMutableArray *)newComps {
	if (self = [super init]) {
		self.comps = newComps;
	}
	return self;
}

- (void)dealloc {
	[comps release];
	[super dealloc];
}

- (void)filter_rw:(OTSGeometry *)geom {
	if ([geom isKindOfClass:[OTSLineString class]])
		[comps addObject:geom];
}

- (void)filter_ro:(OTSGeometry *)geom {
	if ([geom isKindOfClass:[OTSLineString class]])
		[comps addObject:geom];
}

@end
