//
//  OTSCommonBits.h
//

#import <Foundation/Foundation.h>


@interface OTSCommonBits : NSObject {
	BOOL first;
	int commonMantissaBitsCount;
	int64_t commonBits;
	int64_t commonSignExp;	
}

@property (nonatomic, assign) BOOL first;
@property (nonatomic, assign) int commonMantissaBitsCount;
@property (nonatomic, assign) int64_t commonBits;
@property (nonatomic, assign) int64_t commonSignExp;	

+ (int64_t)signExpBits:(int64_t)num;
+ (int)numCommonMostSigMantissaBits:(int64_t)num1 num2:(int64_t)num2;
+ (int64_t)zeroLowerBits:(int64_t)bits nBits:(int)nBits;
+ (int)getBit:(int64_t)bits i:(int)i;

- (void)add:(double)num;
- (double)getCommon;

@end
