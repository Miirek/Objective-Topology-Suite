//
//  OTSElevationMatrix.h
//

#import <Foundation/Foundation.h>

#import "OTSCoordinateFilter.h" // for inheritance 
#import "OTSEnvelope.h" // for composition
#import "OTSElevationMatrixCell.h" // for composition

@class OTSCoordinate;
@class OTSCoordinateSequence;
@class OTSGeometry;
@class OTSElevationMatrixFilter;
@class OTSElevationMatrix;

@interface OTSElevationMatrixFilter : OTSCoordinateFilter {
	OTSElevationMatrix *em;
	double avgElevation;
}

@property (nonatomic, retain) OTSElevationMatrix *em;
@property (nonatomic, assign) double avgElevation;

@end

@interface OTSElevationMatrix : NSObject {
	OTSElevationMatrixFilter *filter;
	OTSEnvelope *env;
	int cols;
	int rows;
	double cellwidth;
	double cellheight;
	BOOL avgElevationComputed;
	double avgElevation;
	NSMutableArray *cells;
}

@property (nonatomic, retain) OTSElevationMatrixFilter *filter;
@property (nonatomic, retain) OTSEnvelope *env;
@property (nonatomic, assign) int cols;
@property (nonatomic, assign) int rows;
@property (nonatomic, assign) double cellwidth;
@property (nonatomic, assign) double cellheight;
@property (nonatomic, assign) BOOL avgElevationComputed;
@property (nonatomic, assign) double avgElevation;
@property (nonatomic, retain) NSMutableArray *cells;

- (id)initWithEnvelope:(OTSEnvelope *)extent rows:(int)_rows cols:(int)_cols;
- (void)add:(OTSGeometry *)geom;
- (void)elevate:(OTSGeometry *)geom;
- (double)getAvgElevation;
- (OTSElevationMatrixCell *)getCell:(OTSCoordinate *)c;
- (void)addCoordinateSequence:(OTSCoordinateSequence *)cs;
- (void)addCoordinate:(OTSCoordinate *)c;

@end
