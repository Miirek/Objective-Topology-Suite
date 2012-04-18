//
//  OTSCommonBitsRemover.h
//

#import <Foundation/Foundation.h>

#import "OTSCoordinate.h" // for composition

@class OTSGeometry;
@class OTSCommonBitsRemover;
@class OTSCommonCoordinateFilter;

@interface OTSCommonBitsRemover : NSObject {
	OTSCoordinate *commonCoord;	
	OTSCommonCoordinateFilter *ccFilter;
}

@property (nonatomic, retain) OTSCoordinate *commonCoord;	
@property (nonatomic, retain) OTSCommonCoordinateFilter *ccFilter;

- (void)add:(OTSGeometry *)geom;
- (OTSCoordinate *)getCommonCoordinate;
- (OTSGeometry *)removeCommonBits:(OTSGeometry *)geom;
- (OTSGeometry *)addCommonBits:(OTSGeometry *)geom;

@end
