//
//  OTSPosition.h
//

#import <Foundation/Foundation.h>

typedef enum {
	kOTSPositionOn = 0,
	kOTSPositionLeft,
	kOTSPositionRight
} OTSPositionValue;

@interface OTSPosition : NSObject {
}

+ (OTSPositionValue)opposite:(OTSPositionValue)position;

@end
