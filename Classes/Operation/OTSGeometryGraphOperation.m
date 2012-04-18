//
//  OTSGeometryGraphOperation.m
//

#import "OTSBoundaryNodeRule.h"
#import "OTSPrecisionModel.h"
#import "OTSCoordinate.h"
#import "OTSLineIntersector.h"
#import "OTSGeometry.h"
#import "OTSPlanarGraph.h"
#import "OTSGeometryGraph.h"
#import "OTSGeometryGraphOperation.h"


@implementation OTSGeometryGraphOperation

@synthesize resultPrecisionModel, li;

- (id)initWithFirstGeometry:(OTSGeometry *)g0 
		  andSecondGeometry:(OTSGeometry *)g1 {
	if (self = [super init]) {
		OTSPrecisionModel *pm0 = [g0 precisionModel];
		NSAssert(pm0 != nil, @"Precision model for first geometry is nil");
		
		OTSPrecisionModel *pm1 = [g1 precisionModel];
		NSAssert(pm1 != nil, @"Precision model for second geometry is nil");
		
		// use the most precise model for the result
		if ([pm0 compareTo:pm1] >= 0)
			[self setComputationPrecision:pm0];
		else
			[self setComputationPrecision:pm1];
		
		li = [[OTSLineIntersector alloc] initWithPrecisionModel:resultPrecisionModel];

		OTSGeometryGraph *argAt0 = [[OTSGeometryGraph alloc] initWithArgIndex:0 parentGeom:g0 boundaryNodeRule:[OTSBoundaryNodeRule OGC_SFS_BOUNDARY_RULE]];
		OTSGeometryGraph *argAt1 = [[OTSGeometryGraph alloc] initWithArgIndex:1 parentGeom:g1 boundaryNodeRule:[OTSBoundaryNodeRule OGC_SFS_BOUNDARY_RULE]];
		arg = [[NSArray alloc] initWithObjects:argAt0, argAt1, nil];
		[argAt0 release];
		[argAt1 release];
	}
	return self;	
}

- (id)initWithFirstGeometry:(OTSGeometry *)g0 
		  andSecondGeometry:(OTSGeometry *)g1 
					   with:(OTSBoundaryNodeRule *)boundaryNodeRule {
	if (self = [super init]) {
		OTSPrecisionModel *pm0 = [g0 precisionModel];
		NSAssert(pm0 != nil, @"Precision model for first geometry is nil");
		
		OTSPrecisionModel *pm1 = [g1 precisionModel];
		NSAssert(pm1 != nil, @"Precision model for second geometry is nil");
		
		// use the most precise model for the result
		if ([pm0 compareTo:pm1] >= 0)
			[self setComputationPrecision:pm0];
		else
			[self setComputationPrecision:pm1];
		
		li = [[OTSLineIntersector alloc] initWithPrecisionModel:resultPrecisionModel];
		
		OTSGeometryGraph *argAt0 = [[OTSGeometryGraph alloc] initWithArgIndex:0 parentGeom:g0 boundaryNodeRule:boundaryNodeRule];
		OTSGeometryGraph *argAt1 = [[OTSGeometryGraph alloc] initWithArgIndex:1 parentGeom:g1 boundaryNodeRule:boundaryNodeRule];
		arg = [[NSArray alloc] initWithObjects:argAt0, argAt1, nil];
		[argAt0 release];
		[argAt1 release];
	}
	return self;		
}

- (void)dealloc {
	[li release];
	[resultPrecisionModel release];
	[arg release];
	[super dealloc];
}

- (void)setComputationPrecision:(OTSPrecisionModel *)pm {
	NSAssert(pm != nil, @"Cannot set nil computation precision");
	self.resultPrecisionModel = pm;
	li.precisionModel = pm;
}

- (OTSGeometry *)getArgGeometry:(int)i {
	OTSGeometryGraph *argAtIdx = [arg objectAtIndex:i];
	return [argAtIdx getGeometry];
}

@end
