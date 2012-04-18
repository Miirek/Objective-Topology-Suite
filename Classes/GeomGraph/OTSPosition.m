//
//  OTSPosition.m
//

#import "OTSPosition.h"


@implementation OTSPosition

+ (OTSPositionValue)opposite:(OTSPositionValue)position {
	if (position == kOTSPositionLeft) return kOTSPositionRight;
	if (position == kOTSPositionRight) return kOTSPositionLeft;
	return position;
}

@end
