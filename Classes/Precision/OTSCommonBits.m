//
//  OTSCommonBits.m
//

#import "OTSCommonBits.h"


@implementation OTSCommonBits

@synthesize first;
@synthesize commonMantissaBitsCount;
@synthesize commonBits;
@synthesize commonSignExp;	

- (id)init {
	if (self = [super init]) {
		first = YES;
		commonMantissaBitsCount = 53;
		commonBits = 0;
	}
	return self;
}

+ (int64_t)signExpBits:(int64_t)num {
	return num >> 52;
}

+ (int)numCommonMostSigMantissaBits:(int64_t)num1 num2:(int64_t)num2 {
	int count = 0;
	for (int i = 52; i >= 0; i--){
		if ([OTSCommonBits getBit:num1 i:i] != [OTSCommonBits getBit:num2 i:i])
			return count;
		count++;
	}
	return 52;	
}

+ (int64_t)zeroLowerBits:(int64_t)bits nBits:(int)nBits {
	int64_t invMask = (1<< nBits)-1;
	int64_t mask = ~ invMask;
	int64_t zeroed = bits & mask;
	return zeroed;
}

+ (int)getBit:(int64_t)bits i:(int)i {
	int64_t mask = (1 << i);
	return (bits & mask) != 0 ? 1 : 0;
}

- (void)add:(double)num {
	int64_t numBits = (int64_t)num;
	if (first) {
		commonBits = numBits;
		commonSignExp = [OTSCommonBits signExpBits:commonBits];
		first = false;
		return;
	}
	int64_t numSignExp = [OTSCommonBits signExpBits:numBits];
	if (numSignExp != commonSignExp) {
		commonBits = 0;
		return;
	}
	commonMantissaBitsCount = [OTSCommonBits numCommonMostSigMantissaBits:commonBits num2:numBits];
	commonBits = [OTSCommonBits zeroLowerBits:commonBits nBits:64 - (12 + commonMantissaBitsCount)];
}

- (double)getCommon {
	return (double)commonBits;
}

@end
