//
//  OTSGeometryGraphOperation.h
//

#import <Foundation/Foundation.h>

#import "OTSLineIntersector.h" // for composition

@class OTSBoundaryNodeRule;
@class OTSGeometry;
@class OTSPrecisionModel;
@class OTSGeometryGraph;

@interface OTSGeometryGraphOperation : NSObject {
	NSArray *arg;
	OTSPrecisionModel *resultPrecisionModel;
	OTSLineIntersector *li;
}

@property (nonatomic, retain) OTSPrecisionModel *resultPrecisionModel;
@property (nonatomic, retain) OTSLineIntersector *li;

- (id)initWithFirstGeometry:(OTSGeometry *)g0 
		  andSecondGeometry:(OTSGeometry *)g1;
- (id)initWithFirstGeometry:(OTSGeometry *)g0 
		  andSecondGeometry:(OTSGeometry *)g1 
					   with:(OTSBoundaryNodeRule *)boundaryNodeRule;
- (void)setComputationPrecision:(OTSPrecisionModel *)pm;
- (OTSGeometry *)getArgGeometry:(int)i;

@end
