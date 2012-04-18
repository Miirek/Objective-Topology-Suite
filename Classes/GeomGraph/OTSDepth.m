//
//  OTSDepth.m
//

#import "OTSDepth.h"
#import "OTSLabel.h"
#import "OTSPosition.h"
#import "OTSLocation.h"

@implementation OTSDepth

- (id) init {
	if (self = [super init]) {
		for (int i=0; i<2; i++) {
			for (int j=0; j<3;j++) {
				depth[i][j] = kOTSDepthNullValue;
			}
		}		
	}
	return self;
}

+ (int)depthAtLocation:(int)location {
	if (location == kOTSLocationExterior) return 0;
	if (location == kOTSLocationInterior) return 1;
	return kOTSDepthNullValue;
}

- (int)depthAt:(int)geomIndex posIndex:(int)posIndex {
	return depth[geomIndex][posIndex];
}

- (void)setDepth:(int)depthValue at:(int)geomIndex posIndex:(int)posIndex {
	depth[geomIndex][posIndex] = depthValue;
}

- (int)locationAt:(int)geomIndex posIndex:(int)posIndex {
	if (depth[geomIndex][posIndex] <= 0) return kOTSLocationExterior;
	return kOTSLocationInterior;
}

- (void)addLocation:(int)location at:(int)geomIndex posIndex:(int)posIndex {
	if (location == kOTSLocationInterior)
		depth[geomIndex][posIndex]++;
}

- (BOOL)isNull {
	for (int i=0; i<2; i++) {
		for (int j=0; j<3; j++) {
			if (depth[i][j] != kOTSDepthNullValue)
				return NO;
		}
	}
	return YES;
}

- (BOOL)isNullAt:(int)geomIndex {
	return depth[geomIndex][1] == kOTSDepthNullValue;
}

- (BOOL)isNullAt:(int)geomIndex posIndex:(int)posIndex {
	return depth[geomIndex][posIndex] == kOTSDepthNullValue;
}

- (int)deltaAt:(int)geomIndex {
	return depth[geomIndex][kOTSPositionRight]-depth[geomIndex][kOTSPositionLeft];
}

- (void)normalize {
	for (int i = 0; i < 2; i++) {
		if (![self isNullAt:i]) {
			int minDepth = depth[i][1];
			if (depth[i][2] < minDepth)
				minDepth = depth[i][2];
			if (minDepth < 0) minDepth = 0;
			for (int j = 1; j < 3; j++) {
				int newValue = 0;
				if (depth[i][j] > minDepth)
					newValue = 1;
				depth[i][j] = newValue;
			}
		}
	}	
}

- (void)addLabel:(OTSLabel *)lbl {
	for (int i=0; i<2; i++) {
		for (int j=1; j<3; j++) {
			int loc = [lbl locationAtGeometryIndex:i atPosIndex:j];
			if (loc == kOTSLocationExterior || loc == kOTSLocationInterior) {
				// initialize depth if it is null, otherwise
				// add this location value
				if ([self isNullAt:i posIndex:j]) {
					depth[i][j] = [OTSDepth depthAtLocation:loc];
				} else
					depth[i][j] += [OTSDepth depthAtLocation:loc];
			}
		}
	}	
}

@end
