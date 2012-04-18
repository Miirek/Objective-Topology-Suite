//
//  OTSMultiPolygon.m
//

#import "OTSMultiPolygon.h"
#import "OTSGeometryFactory.h"

@implementation OTSMultiPolygon

- (id)initWithMultiPolygon:(OTSMultiPolygon *)mp {
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
	return kOTSGeometryMultiPolygon;
}

- (OTSDimensionType)getDimension {
	return kOTSDimensionA;
}

- (int)getBoundaryDimension {
	return 1;
}

@end
