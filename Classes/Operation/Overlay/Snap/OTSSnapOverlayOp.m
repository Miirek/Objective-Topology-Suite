//
//  OTSSnapOverlayOp.m
//

#import "OTSSnapOverlayOp.h"
#import "OTSGeometrySnapper.h"
#import "OTSCommonBitsRemover.h"
#import "OTSGeometry.h"

@implementation OTSSnapOverlayOp

@synthesize geom0;
@synthesize geom1;
@synthesize snapTolerance;	
@synthesize cbr;

- (id)initWithGeometry1:(OTSGeometry *)g0 
			  geometry2:(OTSGeometry *)g1 {
	if (self = [super init]) {
		self.geom0 = g0;
		self.geom1 = g1;
		[self computeSnapTolerance];		
	}
	return self;
}

- (void)dealloc {
	[geom0 release];
	[geom1 release];
	[cbr release];
	[super dealloc];
}

+ (OTSGeometry *)overlayOpOfGeometry1:(OTSGeometry *)g0 
							   geometry2:(OTSGeometry *)g1 
								  opCode:(OTSOverlayOpCode)opCode {
	OTSSnapOverlayOp *op = [[OTSSnapOverlayOp alloc] initWithGeometry1:g0 geometry2:g1];
	OTSGeometry *result = [op getResultGeometry:opCode];
	[op release];
	return result;
}

+ (OTSGeometry *)intersectionOfGeometry1:(OTSGeometry *)g0 
								  geometry2:(OTSGeometry *)g1 {
	return [OTSSnapOverlayOp overlayOpOfGeometry1:g0 geometry2:g1 opCode:kOTSOverlayIntersection];
}

+ (OTSGeometry *)unionOfGeometry1:(OTSGeometry *)g0 
						   geometry2:(OTSGeometry *)g1 {
	return [OTSSnapOverlayOp overlayOpOfGeometry1:g0 geometry2:g1 opCode:kOTSOverlayUnion];
}

+ (OTSGeometry *)differenceOfGeometry1:(OTSGeometry *)g0 
								geometry2:(OTSGeometry *)g1 {
	return [OTSSnapOverlayOp overlayOpOfGeometry1:g0 geometry2:g1 opCode:kOTSOverlayDifference];
}

+ (OTSGeometry *)symDifferenceOfGeometry1:(OTSGeometry *)g0 
								   geometry2:(OTSGeometry *)g1 {
	return [OTSSnapOverlayOp overlayOpOfGeometry1:g0 geometry2:g1 opCode:kOTSOverlaySymDifference];
}

- (void)computeSnapTolerance {
	snapTolerance = [OTSGeometrySnapper computeOverlaySnapToleranceOfGeometry1:geom0 geometry2:geom1];
}

- (OTSGeometry *)getResultGeometry:(OTSOverlayOpCode)opCode {
	OTSGeometry *ret0 = nil;
	OTSGeometry *ret1 = nil;	
	[self snapGeometry1:&ret0 geometry2:&ret1];
	OTSGeometry *result = [OTSOverlayOp overlayOpFirstGeometry:ret0 andSecondGeometry:ret1 withOp:opCode];
	[self prepareResult:result];
	return result;
}

- (void)snapGeometry1:(OTSGeometry **)ret0
            geometry2:(OTSGeometry **)ret1 {
	OTSGeometry *remGeom0 = nil;
	OTSGeometry *remGeom1 = nil;
	[self removeCommonBitsOfGeometry1:geom0 geometry2:geom1 result1:&remGeom0 result2:&remGeom1];
	[OTSGeometrySnapper snapGeometry1:remGeom0 geometry2:remGeom1 snapTolerance:snapTolerance result1:ret0 result2:ret1];
}

- (void)removeCommonBitsOfGeometry1:(OTSGeometry *)g0
                          geometry2:(OTSGeometry *)g1
                            result1:(OTSGeometry **)ret0
                            result2:(OTSGeometry **)ret1 {
	
	if (cbr != nil) [cbr release];
	cbr = [[OTSCommonBitsRemover alloc] init];
	[cbr add:geom0];
	[cbr add:geom1];
	
	*ret0 = [cbr removeCommonBits:[geom0 clone]];
	*ret1 = [cbr removeCommonBits:[geom1 clone]];
}
	
- (void)prepareResult:(OTSGeometry *)geom {
	[cbr addCommonBits:geom];
}

@end
