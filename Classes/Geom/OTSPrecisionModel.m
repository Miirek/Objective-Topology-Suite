//
//  OTSPrecisionModel.m
//

#import "OTSPrecisionModel.h"
#import "OTSCoordinate.h"

@implementation OTSPrecisionModel

@synthesize modelType, scale;

- (id)init {
	if (self = [super init]) {
		modelType = kOTSPrecisionFloating;
	}
	return self;	
}

- (int)maximumSignificantDigits {
	int maxSigDigits = 16;
	if (modelType == kOTSPrecisionFloating) {
		maxSigDigits = 16;
	} else if (modelType == kOTSPrecisionFloatingSingle) {
		maxSigDigits = 6;
	} else if (modelType == kOTSPrecisionFixed) {
		maxSigDigits = 1 + (int)ceil((double)log(scale)/(double)log(10.0));
	}
	return maxSigDigits;	
}

- (int)compareTo:(OTSPrecisionModel *)other {
	int sigDigits = [self maximumSignificantDigits];
	int otherSigDigits = [other maximumSignificantDigits];
	return sigDigits < otherSigDigits ? -1 : (sigDigits == otherSigDigits ? 0 : 1);	
}

- (double)makePreciseDouble:(double)val {
	
	if (modelType == kOTSPrecisionFloatingSingle) {
		float floatSingleVal = (float) val;
		return (double)floatSingleVal;
	} if (modelType == kOTSPrecisionFixed) {
		// Use whatever happens to be the default rounding method
		double ret = round(val*scale)/scale;
		return ret;
	}
	// modelType == FLOATING - no rounding necessary
	return val;
}

- (void)makePrecise:(OTSCoordinate *)coord {
	// optimization for full precision 
	if (modelType == kOTSPrecisionFloating) return;	
	coord.x = [self makePreciseDouble:coord.x];
	coord.y = [self makePreciseDouble:coord.y];
}


@end
