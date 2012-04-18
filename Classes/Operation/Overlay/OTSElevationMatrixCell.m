//
//  OTSElevationMatrixCell.m
//

#import "OTSElevationMatrixCell.h"
#import "OTSCoordinate.h"

@implementation OTSElevationMatrixCell

@synthesize zvals;
@synthesize ztot;

- (id)init {
	if (self = [super init]) {
		zvals = [NSMutableSet set];
	}
	return self;
}

- (void)dealloc {
	[zvals release];
	[super dealloc];
}

- (void)add:(OTSCoordinate *)c {
	if (!isnan(c.z)) {
		NSNumber *m = [NSNumber numberWithDouble:c.z];
		if ([zvals member:m] == nil) {
			[zvals addObject:m];
			ztot += c.z;
		}
	}
}

- (void)addDouble:(double)z {
	if (!isnan(z)) {
		NSNumber *m = [NSNumber numberWithDouble:z];
		if ([zvals member:m] == nil) {
			[zvals addObject:m];
			ztot += z;
		}
	}	
}
					   
- (double)getAvg {
	if ( [zvals count] == 0) return NAN;
	return (ztot/[zvals count]);
}

- (double)getTotal {
	return ztot;
}

@end
