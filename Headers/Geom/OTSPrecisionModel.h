//
//  OTSPrecisionModel.h
//

#import <Foundation/Foundation.h>

@class OTSCoordinate;

typedef enum {
	kOTSPrecisionFixed,
	kOTSPrecisionFloating,
	kOTSPrecisionFloatingSingle
} OTSPrecisionModelType;

@interface OTSPrecisionModel : NSObject {
	OTSPrecisionModelType modelType;
	double scale;
}

@property (nonatomic, assign) OTSPrecisionModelType modelType;
@property (nonatomic, assign) double scale;

- (int)maximumSignificantDigits;
- (int)compareTo:(OTSPrecisionModel *)other;
- (double)makePreciseDouble:(double)val;
- (void)makePrecise:(OTSCoordinate *)coord;

@end
