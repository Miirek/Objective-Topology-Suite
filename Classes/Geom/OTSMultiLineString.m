//
//  OTSMultiLineString.m
//

#import "OTSCGAlgorithms.h"
#import "OTSGeometryGraph.h"
#import "OTSMultiLineString.h"
#import "OTSLineString.h"
#import "OTSGeometryFactory.h"
#import "OTSDimension.h"

@implementation OTSMultiLineString

- (id)initWithMultiLineString:(OTSMultiLineString *)mls {
	if (self = [super initWithGeometryCollection:mls]) {
	}
	return self;
}

- (id)initWithArray:(NSArray *)_geometries factory:(OTSGeometryFactory *)newFactory {
	if (self = [super initWithArray:_geometries factory:newFactory]) {
	}
	return self;
}

- (OTSGeometryTypeId)getGeometryTypeId {
	return kOTSGeometryMultiLineString;
}

- (OTSDimensionType)getDimension {
	return kOTSDimensionL;
}

- (int)getBoundaryDimension {
	if ([self isClosed]) {
		return kOTSDimensionFalse;
	}
	return 0;
}

- (BOOL)isClosed {
	if ([self isEmpty]) {
		return NO;
	}
	for (OTSLineString *ls in geometries) {
		if (![ls isClosed]) {
			return NO;
		}
	}
	return YES;
}

@end
