//
//  OTSSnapIfNeededOverlayOp.m
//

#import "OTSSnapIfNeededOverlayOp.h"
#import "OTSSnapOverlayOp.h"
#import "OTSOverlayOp.h"
#import "OTSGeometry.h" // for use in auto_ptr

@implementation OTSSnapIfNeededOverlayOp

@synthesize geom0, geom1;

- (id)initWithFirstGeometry:(OTSGeometry *)g0 
		  andSecondGeometry:(OTSGeometry *)g1 {
	if (self = [super init]) {
		self.geom0 = g0;
		self.geom1 = g1;
	}
	return self;	
}

- (void)dealloc {
	[geom0 release];
	[geom1 release];
	[super dealloc];
}

- (OTSGeometry *)resultGeometryWithOp:(OTSOverlayOpCode)opCode {
	
	BOOL isSuccess = NO;
	OTSGeometry *result = nil;
	
	@try {
		result = [OTSOverlayOp overlayOpFirstGeometry:geom0 andSecondGeometry:geom1 withOp:opCode];
		isSuccess = YES;
	}
	@catch (NSException * e) {
		isSuccess = NO;
	}
	
	if (! isSuccess) {
		result = [OTSSnapOverlayOp overlayOpOfGeometry1:geom0 geometry2:geom1 opCode:opCode];
	}
	
	return result;
}

+ (OTSGeometry *)overlayOpFirstGeometry:(OTSGeometry *)g0 
						 andSecondGeometry:(OTSGeometry *)g1 
									withOp:(OTSOverlayOpCode)opCode {
	OTSSnapIfNeededOverlayOp *op = [[OTSSnapIfNeededOverlayOp alloc] initWithFirstGeometry:g0 andSecondGeometry:g1];
	OTSGeometry *ret = [op resultGeometryWithOp:opCode];
	[op release];
	return ret;
}

@end
