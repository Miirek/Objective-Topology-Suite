//
//  OTSGeometryList.m
//

#import "OTSGeometryList.h"


@implementation OTSGeometryList

@synthesize geoms;

- (id)init {
	if (self = [super init]) {
		self.geoms = [NSMutableArray array];
	}
	return self;
}

- (void)dealloc {
	[geoms release];
	[super dealloc];
}

+ (OTSGeometryList *)create {
	return [[[OTSGeometryList alloc] init] autorelease];
}

- (void)add:(OTSGeometry *)geom {
	[geoms addObject:geom];
}

- (int)size {
	return [geoms count];
}

- (OTSGeometry *)getAt:(int)i {
	return [geoms objectAtIndex:i];
}

@end
