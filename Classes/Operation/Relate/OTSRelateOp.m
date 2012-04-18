//
//  OTSRelateOp.m
//

#import "OTSRelateComputer.h"
#import "OTSRelateOp.h"

@class OTSIntersectionMatrix;
@class OTSGeometry;

@implementation OTSRelateOp

@synthesize relateComp;

+ (OTSIntersectionMatrix *)relateGeometry:(OTSGeometry *)a andGeometry:(OTSGeometry *)b {
	OTSRelateOp *relOp = [[OTSRelateOp alloc] initWithGeometry:a andGeometry:b];
	OTSIntersectionMatrix *ret = [relOp getIntersectionMatrix];
	[relOp release];
	return ret;
}

+ (OTSIntersectionMatrix *)relateGeometry:(OTSGeometry *)a 
								 andGeometry:(OTSGeometry *)b 
										with:(OTSBoundaryNodeRule *)boundaryNodeRule {
	OTSRelateOp *relOp = [[OTSRelateOp alloc] initWithGeometry:a andGeometry:b with:boundaryNodeRule];
	OTSIntersectionMatrix *ret = [relOp getIntersectionMatrix];
	[relOp release];
	return ret;
}

- (id)initWithGeometry:(OTSGeometry *)g0 andGeometry:(OTSGeometry *)g1 {
	if (self = [super initWithFirstGeometry:g0 andSecondGeometry:g1]) {
		relateComp = [[OTSRelateComputer alloc] initWithGeometryGraphArray:arg];
	}
	return self;
}

- (id)initWithGeometry:(OTSGeometry *)g0 
		   andGeometry:(OTSGeometry *)g1 
				  with:(OTSBoundaryNodeRule *)boundaryNodeRule {
	if (self = [super initWithFirstGeometry:g0 andSecondGeometry:g1 with:boundaryNodeRule]) {
		relateComp = [[OTSRelateComputer alloc] initWithGeometryGraphArray:arg];
	}
	return self;
}

- (void)dealloc {
	[relateComp release];
	[super dealloc];
}

- (OTSIntersectionMatrix *)getIntersectionMatrix {
	OTSIntersectionMatrix *ret = [relateComp computeIM];
	// need to retain result matrix, becuase relateComp creates and release the matrix
	return [[ret retain] autorelease];
}

@end
