//
//  OTSCoordinateFilter.h
//

#import <Foundation/Foundation.h>

@class OTSCoordinate;

@interface OTSCoordinateFilter : NSObject {	
}

- (void)filter_rw:(OTSCoordinate *)coord;
- (void)filter_ro:(OTSCoordinate *)coord;

@end
