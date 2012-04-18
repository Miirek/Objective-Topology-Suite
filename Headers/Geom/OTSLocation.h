//
//  OTSLocation.h
//

#import <Foundation/Foundation.h>

typedef enum {
	kOTSLocationUndefined = -1,
	kOTSLocationInterior  = 0,
	kOTSLocationBoundary  = 1,
	kOTSLocationExterior  = 2
} OTSLocationValue;

@interface OTSLocation : NSObject {
}

+ (char)toLocationSymbol:(OTSLocationValue)locationValue;

@end
