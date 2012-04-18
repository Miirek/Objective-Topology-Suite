//
//  OTSUniqueCoordinateArrayFilter.h
//

#import <Foundation/Foundation.h>

#import "OTSCoordinateFilter.h"

@class OTSCoordinate;
@class OTSCoordinateSequence;

@interface OTSUniqueCoordinateArrayFilter : OTSCoordinateFilter {
	NSMutableArray *pts;	// target set reference
	NSMutableSet *uniqPts; 	// unique points set
}

@property (nonatomic, retain) NSMutableArray *pts;
@property (nonatomic, retain) NSMutableSet *uniqPts;

- (id)initWithArray:(NSMutableArray *)target;

@end
