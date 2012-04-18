//
//  OTSElevationMatrixCell.h
//

#import <Foundation/Foundation.h>

@class OTSCoordinate;

@interface OTSElevationMatrixCell : NSObject {
	NSMutableSet *zvals;
	double ztot;
}

@property (nonatomic, retain) NSMutableSet *zvals;
@property (nonatomic, assign) double ztot;

- (void)add:(OTSCoordinate *)c;
- (void)addDouble:(double)z;
- (double)getAvg;
- (double)getTotal;

@end
