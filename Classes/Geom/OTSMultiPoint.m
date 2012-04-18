//
//  OTSMultiPoint.m
//

#import "OTSMultiPoint.h"
#import "OTSGeometryFactory.h"

@implementation OTSMultiPoint

- (id)initWithMultiPoint:(OTSMultiPoint *)mp {
	if (self = [super initWithGeometryCollection:mp]) {
	}
	return self;
}

- (id)initWithArray:(NSArray *)_geometries factory:(OTSGeometryFactory *)newFactory {
	if (self = [super initWithArray:_geometries factory:newFactory]) {
	}
	return self;
}

- (OTSGeometryTypeId)getGeometryTypeId {
	return kOTSGeometryMultiPoint;
}

- (OTSDimensionType)getDimension {
	return kOTSDimensionP;
}

- (int)getBoundaryDimension {
	return kOTSDimensionFalse;
}

@end
