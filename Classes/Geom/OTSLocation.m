//
//  OTSLocation.m
//

#import "OTSLocation.h"


@implementation OTSLocation

+ (char)toLocationSymbol:(OTSLocationValue)locationValue {
	switch (locationValue) {
		case kOTSLocationExterior:
			return 'e';
		case kOTSLocationBoundary:
			return 'b';
		case kOTSLocationInterior:
			return 'i';
		case kOTSLocationUndefined: //NULL
			return '-';
		default:
			@throw [NSException exceptionWithName:@"IllegalArgumentException" 
										   reason:@"Unknown location value"
										 userInfo:nil];
	}
}

@end
